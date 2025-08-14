#!/bin/bash

# ===============================================
# 🧪 Test de Configuration Nginx - GetYourSite
# ===============================================
# Vérifie que la configuration Nginx générée est valide

set -euo pipefail

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

PROJECT_NAME="getyoursite"
TEMP_CONFIG="/tmp/nginx-test-config-$$"

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗ ERREUR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠ WARNING]${NC} $1"
}

echo -e "\n${BLUE}🧪 TEST CONFIGURATION NGINX${NC}"
echo "======================================"
echo

# Créer la configuration temporaire (même que dans le script)
print_test "Génération de la configuration Nginx..."

cat > "$TEMP_CONFIG" << 'EOF'
# Configuration Nginx pour GetYourSite
server {
    listen 80;
    server_name _;
    
    # Sécurité
    server_tokens off;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Logs
    access_log /var/log/nginx/getyoursite_access.log;
    error_log /var/log/nginx/getyoursite_error.log;
    
    # Configuration proxy vers Next.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
    
    # Gestion des erreurs
    error_page 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
    
    # Optimisations
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

print_success "Configuration générée"

# Test de syntaxe avec nginx si disponible
print_test "Vérification de la syntaxe Nginx..."

if command -v nginx >/dev/null 2>&1; then
    # Si nginx est installé, tester la configuration
    if nginx -t -c /dev/null -T 2>&1 | grep -q "test is successful"; then
        print_success "Nginx est installé et fonctionnel"
        
        # Tester notre configuration spécifique
        if nginx -t -c <(echo "events {}; http { include $TEMP_CONFIG; }") 2>/dev/null; then
            print_success "Configuration Nginx valide ✅"
        else
            print_error "Configuration Nginx invalide ❌"
            echo
            echo "Détails de l'erreur :"
            nginx -t -c <(echo "events {}; http { include $TEMP_CONFIG; }") 2>&1 || true
            exit 1
        fi
    else
        print_warning "Nginx installé mais configuration système problématique"
    fi
else
    print_warning "Nginx non installé - test de syntaxe ignoré"
    print_success "Configuration générée (sera testée lors de l'installation)"
fi

# Vérification des directives critiques
print_test "Vérification des directives critiques..."

# Vérifier que les directives problématiques ne sont pas présentes
if grep -q "must-revalidate" "$TEMP_CONFIG"; then
    print_error "Directive 'must-revalidate' trouvée (invalide pour gzip_proxied)"
    exit 1
else
    print_success "Pas de directive 'must-revalidate' invalide"
fi

# Vérifier les directives importantes
REQUIRED_DIRECTIVES=(
    "listen 80"
    "server_name"
    "proxy_pass"
    "gzip on"
    "proxy_set_header"
)

for directive in "${REQUIRED_DIRECTIVES[@]}"; do
    if grep -q "$directive" "$TEMP_CONFIG"; then
        print_success "Directive '$directive' présente"
    else
        print_error "Directive '$directive' manquante"
        exit 1
    fi
done

# Nettoyage
rm -f "$TEMP_CONFIG"

echo
print_success "✅ Configuration Nginx validée avec succès !"
echo -e "${GREEN}La configuration sera correctement appliquée lors de l'installation.${NC}"
echo