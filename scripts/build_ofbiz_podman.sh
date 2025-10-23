#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build && cd build
[ -d ofbiz-framework ] || git clone --depth 1 https://gitbox.apache.org/repos/asf/ofbiz-framework.git
cd ofbiz-framework
cat > Dockerfile.podman <<'EOF'
FROM eclipse-temurin:17-jammy
ENV JAVA_TOOL_OPTIONS="-Xmx2g -XX:MaxMetaspaceSize=512m"
ENV GRADLE_USER_HOME=/ofbiz/.gradle
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.jvmargs='-Xmx2g -XX:MaxMetaspaceSize=512m'"
RUN apt-get update && apt-get install -y unzip git && rm -rf /var/lib/apt/lists/*
WORKDIR /ofbiz
COPY . /ofbiz
RUN chmod +x gradlew
RUN ./gradlew --stacktrace --no-daemon --no-parallel --max-workers=1 clean assemble -x test
EXPOSE 8443
ENV OFBIZ_DATA_LOAD=demo
CMD ["bash","-lc","./gradlew --no-daemon --no-parallel --max-workers=1 -x test ofbiz"]
EOF
podman build --no-cache -t ofbiz-test:demo -f Dockerfile.podman .
echo "Built image: ofbiz-test:demo"
