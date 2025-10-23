#!/usr/bin/env bash
# Print OFBiz admin credentials and default URLs.
cat <<'EOT'
OFBiz Admin Credentials
-----------------------
Username: admin
Password: ofbiz

URLs (after port-forward):
- OFBiz:    https://localhost:8443/partymgr
- NiFi:     http://localhost:8080/nifi
- Superset: http://localhost:8088
EOT
