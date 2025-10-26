#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# CapsuleBay Infra Bootstrap
# - Vault, Registry, UI, htpasswd
# ==========================================

# Defaults
BASE_DIR="${BASE_DIR:-/opt/infra"
LAN_IP="${LAN_IP:-$(hostname -I | awk '{print $1}')}"
REGISTRY_TITLE="${REGISTRY_TITLE:-Local Registry}"
JENKINS_USER="${JENKINS_USER:-jenkins}"
JENKINS_PASS="${JENKINS_PASS:-$(openssl rand -hex 16)}"
VAULT_PORT=8200
REGISTRY_PORT=5000
REGISTRY_UI_PORT=5001

# Helper
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1"; exit 1; }; }

echo "== Homelab Infra Bootstrap =="
echo "Detected LAN IP: $LAN_IP"
echo

# Check dependencies
need docker
need curl
need openssl

# Setup folders
mkdir -p "$BASE_DIR"/{data/vault,data/registry,data/auth}
cd "$BASE_DIR"

# Vault config
cat > vault.hcl <<EOF
storage "file" {
  path = "/vault/file"
}
listener "tcp" {
  address     = "0.0.0.0:${VAULT_PORT}"
  tls_disable = "true"
}
ui = true
disable_mlock = true
EOF

# Compose env snapshot
cat > .env <<EOF
LAN_IP=${LAN_IP}
REGISTRY_TITLE=${REGISTRY_TITLE}
JENKINS_USER=${JENKINS_USER}
JENKINS_PASS=${JENKINS_PASS}
EOF

# Save credentials securely
cat > "$BASE_DIR/.secrets" <<EOF
# Generated $(date)
JENKINS_USER=${JENKINS_USER}
JENKINS_PASS=${JENKINS_PASS}
EOF
chmod 600 "$BASE_DIR/.secrets"

# Docker Compose definition
cat > compose.yaml <<'COMPOSE'
version: "3.9"
name: infra

services:
  vault:
    image: hashicorp/vault:1.15.4
    container_name: vault
    ports:
      - "8200:8200"
      - "8201:8201"
    cap_add:
      - IPC_LOCK
    environment:
      - LAN_IP=${LAN_IP}
    volumes:
      - ./data/vault:/vault/file
      - ./vault.hcl:/vault/config/vault.hcl:ro
    command: ["vault", "server", "-config=/vault/config/vault.hcl"]
    restart: unless-stopped
    networks: [infra]

  htpasswd:
    image: httpd:alpine
    container_name: htpasswd-generator
    entrypoint: >
      sh -c "mkdir -p /auth && \
             htpasswd -Bbn ${JENKINS_USER} ${JENKINS_PASS} > /auth/htpasswd"
    volumes:
      - ./data/auth:/auth
    restart: "no"
    networks: [infra]

  registry:
    image: registry:2.8.3
    depends_on:
      htpasswd:
        condition: service_completed_successfully
    container_name: docker-registry
    ports:
      - "${LAN_IP}:5000:5000"
    environment:
      REGISTRY_HTTP_ADDR: :5000
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    volumes:
      - ./data/registry:/var/lib/registry
      - ./data/auth:/auth:ro
      - ./data/registry/config.yml:/etc/docker/registry/config.yml:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/v2/"]
      interval: 15s
      timeout: 5s
      retries: 10
    restart: unless-stopped
    networks: [infra]

  registry-ui:
    image: joxit/docker-registry-ui:2.5.0
    container_name: docker-registry-ui
    ports:
      - "${LAN_IP}:5001:80"
    environment:
      - REGISTRY_TITLE=${REGISTRY_TITLE}
      - REGISTRY_URL=http://${LAN_IP}:5000
      - DELETE_IMAGES=true
    depends_on:
      - registry
    restart: unless-stopped
    networks: [infra]

networks:
  infra:
    driver: bridge
COMPOSE

# Bring it up
echo "Bringing up stack..."
docker compose up -d

# Wait for registry health
echo "Waiting for registry..."
for i in {1..20}; do
  if curl -fs "http://${LAN_IP}:${REGISTRY_PORT}/v2/" >/dev/null 2>&1; then
    echo "Registry OK."
    break
  fi
  sleep 3
done

# Output summary
echo
echo "===================================="
echo "Infra Ready"
echo "Vault UI:       http://${LAN_IP}:${VAULT_PORT}  (uninitialized)"
echo "Note: Vault starts sealed. Initialize with:"
echo "  docker exec -it vault vault operator init"
echo
echo "Registry:       http://${LAN_IP}:${REGISTRY_PORT}"
echo "Registry UI:    http://${LAN_IP}:${REGISTRY_UI_PORT}"
echo "Registry Auth:  ${JENKINS_USER}:${JENKINS_PASS}"
echo "Base Dir:       ${BASE_DIR}"
echo
echo "Credentials saved at: $BASE_DIR/.secrets"
echo "===================================="
echo
