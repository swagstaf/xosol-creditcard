#!/usr/bin/env python3
# Requires: pip3 install beautifulsoup4 requests lxml
import re, sys, requests
from bs4 import BeautifulSoup

URLS = [
    "https://xosol.com/leadership/",
    "https://xosol.com/our-team-of-manufacturing-experts/",
]

EMAIL_DOMAIN = "xosol.com"

NAME_RE = re.compile(r"\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)+)\b")
PHONE_RE = re.compile(r"(\+?\d[\d\-\.\s\(\)]{7,}\d)")

def slugify_user(first: str, last: str) -> str:
    return f"{first}.{last}".lower()

def norm_phone(s: str) -> str:
    s = s.strip()
    m = re.sub(r"[^0-9+]", "", s)
    return m[:20]

def extract_people(url):
    html = requests.get(url, timeout=30).text
    soup = BeautifulSoup(html, "lxml")
    text = soup.get_text("\n", strip=True)

    emails = set(re.findall(rf"[A-Za-z0-9._%+-]+@{EMAIL_DOMAIN}", text))

    people = []
    for blk in soup.find_all(["section", "article", "div", "li"]):
        blk_text = blk.get_text(" ", strip=True)
        if not blk_text or len(blk_text) < 10:
            continue

        names = NAME_RE.findall(blk_text)
        if not names:
            continue

        phones = PHONE_RE.findall(blk_text)
        blk_emails = set(re.findall(rf"[A-Za-z0-9._%+-]+@{EMAIL_DOMAIN}", blk_text))

        for name in names:
            parts = name.split()
            if len(parts) < 2 or len(parts) > 3:
                continue
            first, last = parts[0], parts[-1]
            user = slugify_user(first, last)

            email_guess = f"{user}@{EMAIL_DOMAIN}"
            email = next((e for e in blk_emails if e.lower().startswith(first.lower() + ".")),
                         next((e for e in emails if e.lower().startswith(first.lower() + ".")),
                              email_guess))

            phone = norm_phone(phones[0]) if phones else ""

            people.append((first, last, email, phone))

    seen, out = set(), []
    for f,l,e,p in people:
        if e.lower() not in seen:
            seen.add(e.lower())
            out.append((f,l,e,p))
    return out

people = []
for u in URLS:
    try:
        people.extend(extract_people(u))
    except Exception as ex:
        print(f"# WARN: could not parse {u}: {ex}", file=sys.stderr)

print("""import org.apache.ofbiz.entity.DelegatorFactory
import org.apache.ofbiz.entity.util.EntityQuery
import org.apache.ofbiz.base.util.UtilDateTime

def now = UtilDateTime.nowTimestamp()
def adminUL = EntityQuery.use(delegator).from(\"UserLogin\").where(\"userLoginId\",\"admin\").queryOne()
String defaultPassword = System.getenv(\"XOSOL_DEFAULT_PASSWORD\") ?: \"password.1\"
String groupId = \"XOSOL_EMPLOYEE\"

// Ensure security group exists
def sg = EntityQuery.use(delegator).from(\"SecurityGroup\").where(\"groupId\", groupId).queryOne()
if (sg == null) {
    delegator.create(\"SecurityGroup\", [groupId: groupId, groupName: \"XOSOL Employee\'])
    logInfo(\"Created SecurityGroup \" + groupId)
}

def users = [""")
for first,last,email,phone in people:
    user = slugify_user(first, last)
    phone_js = '\"' + phone.replace('\"','') + '\"' if phone else '\"\"'
    print(f'  [first:\"{first}\", last:\"{last}\", email:\"{email}\", user:\"{user}\", phone:{phone_js}],')
print("""]
users.each { u ->
  try {
    // Create or update person + login
    def ctx = [userLogin: adminUL, firstName: u.first, lastName: u.last,
               userLoginId: u.user, currentPassword: defaultPassword,
               currentPasswordVerify: defaultPassword, emailAddress: u.email]
    dispatcher.runSync(\"createPersonAndUserLogin\", ctx)

    // Resolve partyId from created/updated login
    def ul = EntityQuery.use(delegator).from(\"UserLogin\").where(\"userLoginId\", u.user).queryOne()
    def partyId = ul?.partyId

    // Ensure group membership
    def existing = EntityQuery.use(delegator).from(\"UserLoginSecurityGroup\")
                    .where([userLoginId: u.user, groupId: groupId]).queryOne()
    if (existing == null) {
      delegator.create(\"UserLoginSecurityGroup\", [userLoginId: u.user, groupId: groupId, fromDate: now])
    }

    // Attach phone if present
    if (partyId && u.phone && u.phone.size() >= 7) {
      try {
        def pcm = dispatcher.runSync(\"createPartyContactMech\",
            [userLogin: adminUL, partyId: partyId, contactMechTypeId: \"TELECOM_NUMBER\",
             contactMechPurposeTypeId: \"PRIMARY_PHONE\", fromDate: now])
        def cmId = pcm.contactMechId
        if (cmId) {
          dispatcher.runSync(\"updateTelecomNumber\",
              [userLogin: adminUL, contactMechId: cmId, countryCode: \"1\", contactNumber: u.phone])
        }
      } catch (Exception pe) {
        logWarning(\"Phone add failed for ${u.user}: \" + pe.getMessage())
      }
    }

    logInfo(\"OK ${u.user} (${u.email})\")
  } catch (Exception e) {
    logError(\"FAIL ${u.user}: \" + e.getMessage())
  }
}
""")
