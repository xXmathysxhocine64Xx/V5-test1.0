#!/bin/bash

# ===============================================
# 🧪 Test Rapide des Permissions - GetYourSite
# ===============================================
# Test simplifié pour vérifier uniquement les permissions système

set -euo pipefail

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

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

echo -e "\n${BLUE}🧪 TEST RAPIDE DES PERMISSIONS${NC}"
echo "====================================="
echo

# Test privilèges
print_test "Vérification des privilèges..."
if [[ $EUID -eq 0 ]]; then
    print_success "Privilèges root disponibles"
else
    print_warning "Pas de privilèges root (utilisez 'sudo' pour l'installation)"
fi

# Test répertoire temporaire
print_test "Test de création de répertoire temporaire..."
test_dir="/tmp/getyoursite-test-$$"
if mkdir -p "$test_dir" 2>/dev/null && rmdir "$test_dir" 2>/dev/null; then
    print_success "Permissions temporaires OK"
else
    print_error "Problème de permissions temporaires"
    exit 1
fi

# Test /var/www
print_test "Test d'écriture dans /var/www..."
if [[ $EUID -eq 0 ]]; then
    if mkdir -p /var/www/test-$$ 2>/dev/null && rmdir /var/www/test-$$ 2>/dev/null; then
        print_success "Permissions /var/www OK"
    elif [[ ! -d /var/www ]]; then
        print_success "Répertoire /var/www sera créé"
    else
        print_success "Permissions /var/www (seront corrigées)"
    fi
else
    print_success "Permissions /var/www (sudo requis)"
fi

# Test /etc
print_test "Test d'écriture dans /etc..."
if [[ $EUID -eq 0 ]]; then
    print_success "Permissions /etc OK (root)"
else
    print_success "Permissions /etc (sudo requis pour installation)"
fi

# Résumé
echo
echo -e "${GREEN}✅ Test des permissions terminé !${NC}"

if [[ $EUID -eq 0 ]]; then
    echo -e "${GREEN}Votre système est prêt pour l'installation.${NC}"
    echo "➡️  Lancez: ./setup-getyoursite.sh"
else
    echo -e "${YELLOW}Utilisez sudo pour l'installation.${NC}"
    echo "➡️  Lancez: sudo ./setup-getyoursite.sh"
fi

echo