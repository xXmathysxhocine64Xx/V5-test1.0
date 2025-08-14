#!/bin/bash

# ===============================================
# 🔧 Fix PM2 GetYourSite - Diagnostic et Réparation
# ===============================================

set -euo pipefail

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

PROJECT_NAME="getyoursite"
PROJECT_DIR="/var/www/${PROJECT_NAME}"

print_step() {
    echo -e "${BLUE}[ÉTAPE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ SUCCÈS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠ ATTENTION]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗ ERREUR]${NC} $1"
}

print_step "Diagnostic et réparation PM2 pour GetYourSite"

# Vérification des privilèges root
if [[ $EUID -ne 0 ]]; then
    print_error "Ce script doit être exécuté avec des privilèges root"
    echo "Utilisez: sudo $0"
    exit 1
fi

# 1. Vérifier si PM2 est installé
print_step "Vérification de PM2..."
if ! command -v pm2 &> /dev/null; then
    print_warning "PM2 non trouvé - installation en cours..."
    npm install -g pm2
    if command -v pm2 &> /dev/null; then
        print_success "PM2 installé avec succès: $(pm2 --version)"
    else
        print_error "Échec de l'installation de PM2"
        exit 1
    fi
else
    print_success "PM2 trouvé: $(pm2 --version)"
fi

# 2. Vérifier le répertoire du projet
print_step "Vérification du projet..."
if [[ ! -d "$PROJECT_DIR" ]]; then
    print_error "Répertoire projet non trouvé: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

if [[ ! -f "package.json" ]]; then
    print_error "package.json non trouvé dans $PROJECT_DIR"
    exit 1
fi

print_success "Projet trouvé dans $PROJECT_DIR"

# 3. Vérifier le build Next.js
print_step "Vérification du build Next.js..."
if [[ ! -d ".next" ]]; then
    print_warning "Build Next.js manquant - reconstruction..."
    yarn build
    if [[ -d ".next" ]]; then
        print_success "Build Next.js terminé"
    else
        print_error "Échec du build Next.js"
        exit 1
    fi
else
    print_success "Build Next.js trouvé"
    # Vérifier si le build est récent (moins de 24h)
    if [[ $(find .next -name "BUILD_ID" -mtime +1) ]]; then
        print_warning "Build Next.js ancien - reconstruction recommandée..."
        yarn build
        print_success "Build Next.js mis à jour"
    fi
fi

# 3.1 Vérifier que yarn start fonctionne
print_step "Test de démarrage Next.js..."
timeout 10s yarn start > /tmp/nextjs-test.log 2>&1 &
NEXTJS_PID=$!
sleep 5

if curl -s http://localhost:3000 > /dev/null 2>&1; then
    print_success "Next.js démarre correctement"
    kill $NEXTJS_PID 2>/dev/null || true
else
    print_error "Next.js ne démarre pas - vérifiez les logs:"
    cat /tmp/nextjs-test.log
    kill $NEXTJS_PID 2>/dev/null || true
    exit 1
fi

# 4. Arrêter et nettoyer PM2
print_step "Nettoyage PM2..."
pm2 delete "$PROJECT_NAME" 2>/dev/null || true
pm2 kill 2>/dev/null || true
sleep 2

# 5. Recréer la configuration PM2
print_step "Création de la configuration PM2..."
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: '${PROJECT_NAME}',
    script: 'yarn',
    args: 'start',
    cwd: '${PROJECT_DIR}',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      HOSTNAME: '0.0.0.0'
    },
    error_file: '/var/log/pm2/${PROJECT_NAME}-error.log',
    out_file: '/var/log/pm2/${PROJECT_NAME}-out.log',
    log_file: '/var/log/pm2/${PROJECT_NAME}.log',
    time: true,
    kill_timeout: 5000,
    wait_ready: true,
    listen_timeout: 10000
  }]
}
EOF

# 6. Créer les répertoires de logs
mkdir -p /var/log/pm2
chown -R www-data:www-data /var/log/pm2

# 7. Démarrer PM2
print_step "Démarrage de l'application..."
pm2 start ecosystem.config.js
sleep 5

# 8. Configuration du démarrage automatique
print_step "Configuration du démarrage automatique..."
pm2 startup systemd -u root --hp /root >/dev/null 2>&1 || true
pm2 save

# 9. Tests
print_step "Tests de fonctionnement..."
sleep 3

if pm2 list | grep -q "$PROJECT_NAME.*online"; then
    print_success "PM2: Application en ligne"
else
    print_error "PM2: Application non démarrée"
    pm2 logs "$PROJECT_NAME" --lines 10
    exit 1
fi

# Test de l'API
if curl -s http://localhost:3000/api/contact | grep -q "API GetYourSite active"; then
    print_success "API: Fonctionnelle"
else
    print_warning "API: Problème détecté"
fi

# Test du site principal
if curl -s http://localhost:3000 | grep -q "GetYourSite"; then
    print_success "Site: Accessible"
else
    print_warning "Site: Problème d'accès"
fi

print_success "🎉 Réparation terminée !"
echo
echo -e "${BLUE}COMMANDES UTILES :${NC}"
echo "• Statut : pm2 status"
echo "• Logs : pm2 logs $PROJECT_NAME"
echo "• Redémarrer : pm2 restart $PROJECT_NAME"
echo "• Monitoring : pm2 monit"
echo
print_success "Votre site devrait maintenant fonctionner correctement !"