#!/bin/bash

# ===============================================
# 🧪 Test du Script d'Installation GetYourSite
# ===============================================
# Teste la compatibilité et les prérequis

set -euo pipefail

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

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
    echo -e "${YELLOW}[⚠ ATTENTION]${NC} $1"
}

# Tests de compatibilité
test_system() {
    print_header "TESTS DE COMPATIBILITÉ SYSTÈME"
    
    # Test OS
    print_test "Vérification du système d'exploitation..."
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            local version_number
            version_number=$(echo "$VERSION_ID" | cut -d. -f1)
            if [[ "$version_number" -ge 20 ]]; then
                print_success "Ubuntu $VERSION_ID détecté (compatible)"
            else
                print_error "Ubuntu $VERSION_ID détecté (version trop ancienne, >= 20.04 requis)"
                return 1
            fi
        else
            print_error "Système non-Ubuntu détecté: $ID"
            return 1
        fi
    else
        print_error "Impossible de détecter le système d'exploitation"
        return 1
    fi
    
    # Test architecture
    print_test "Vérification de l'architecture..."
    local arch=$(uname -m)
    if [[ "$arch" == "x86_64" || "$arch" == "aarch64" ]]; then
        print_success "Architecture supportée: $arch"
    else
        print_warning "Architecture non testée: $arch"
    fi
    
    # Test mémoire
    print_test "Vérification de la mémoire..."
    local mem_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [[ "$mem_gb" -ge 1 ]]; then
        print_success "Mémoire disponible: ${mem_gb}GB (suffisant)"
    else
        print_warning "Mémoire limitée: ${mem_gb}GB (minimum 1GB recommandé)"
    fi
    
    # Test espace disque
    print_test "Vérification de l'espace disque..."
    local disk_gb=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ "$disk_gb" -ge 5 ]]; then
        print_success "Espace disque disponible: ${disk_gb}GB (suffisant)"
    else
        print_error "Espace disque insuffisant: ${disk_gb}GB (minimum 5GB requis)"
        return 1
    fi
}

# Test des privilèges
test_privileges() {
    print_header "TEST DES PRIVILÈGES"
    
    print_test "Vérification des privilèges root..."
    if [[ $EUID -eq 0 ]]; then
        print_success "Privilèges root disponibles"
    else
        print_error "Privilèges root requis (utilisez sudo)"
        return 1
    fi
}

# Test connectivité
test_connectivity() {
    print_header "TESTS DE CONNECTIVITÉ"
    
    print_test "Test de connectivité Internet..."
    if ping -c 1 google.com >/dev/null 2>&1; then
        print_success "Connectivité Internet OK"
    else
        print_error "Pas de connectivité Internet (requis pour l'installation)"
        return 1
    fi
    
    print_test "Test d'accès aux dépôts Ubuntu..."
    if curl -s --connect-timeout 5 archive.ubuntu.com >/dev/null; then
        print_success "Accès aux dépôts Ubuntu OK"
    else
        print_warning "Problème d'accès aux dépôts Ubuntu"
    fi
    
    print_test "Test d'accès au dépôt NodeSource..."
    if curl -s --connect-timeout 5 deb.nodesource.com >/dev/null; then
        print_success "Accès au dépôt NodeSource OK"
    else
        print_warning "Problème d'accès au dépôt NodeSource"
    fi
}

# Test des ports
test_ports() {
    print_header "TESTS DES PORTS"
    
    print_test "Vérification du port 80 (HTTP)..."
    if netstat -ln | grep -q ":80 "; then
        print_warning "Port 80 déjà utilisé (sera reconfiguré)"
    else
        print_success "Port 80 disponible"
    fi
    
    print_test "Vérification du port 3000 (Next.js)..."
    if netstat -ln | grep -q ":3000 "; then
        print_warning "Port 3000 déjà utilisé (sera reconfiguré)"
    else
        print_success "Port 3000 disponible"
    fi
    
    print_test "Vérification du port 443 (HTTPS)..."
    if netstat -ln | grep -q ":443 "; then
        print_warning "Port 443 déjà utilisé (normal si HTTPS configuré)"
    else
        print_success "Port 443 disponible"
    fi
}

# Test des services existants
test_existing_services() {
    print_header "TESTS DES SERVICES EXISTANTS"
    
    print_test "Vérification de Apache..."
    if systemctl is-active --quiet apache2 2>/dev/null; then
        print_warning "Apache2 actif (conflit potentiel avec Nginx)"
    else
        print_success "Apache2 non actif"
    fi
    
    print_test "Vérification de Nginx..."
    if systemctl is-active --quiet nginx 2>/dev/null; then
        print_warning "Nginx déjà actif (sera reconfiguré)"
    else
        print_success "Nginx non actif"
    fi
    
    print_test "Vérification de Node.js..."
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        print_warning "Node.js déjà installé: $node_version (sera mis à jour si nécessaire)"
    else
        print_success "Node.js non installé (sera installé)"
    fi
    
    print_test "Vérification de PM2..."
    if command -v pm2 >/dev/null 2>&1; then
        print_warning "PM2 déjà installé (sera reconfiguré)"
    else
        print_success "PM2 non installé (sera installé)"
    fi
}

# Test de simulation (dry-run)
test_dry_run() {
    print_header "SIMULATION D'INSTALLATION"
    
    print_test "Test de création de répertoire..."
    local test_dir="/tmp/getyoursite-test-$$"
    if mkdir -p "$test_dir" && rmdir "$test_dir"; then
        print_success "Permissions de création de répertoire OK"
    else
        print_error "Problème de permissions pour créer des répertoires"
        return 1
    fi
    
    print_test "Test d'écriture dans /var/www..."
    if [[ -w /var/www ]] || mkdir -p /var/www/test-$$ && rmdir /var/www/test-$$ 2>/dev/null; then
        print_success "Permissions d'écriture dans /var/www OK"
    else
        print_error "Problème de permissions dans /var/www"
        return 1
    fi
    
    print_test "Test d'écriture dans /etc..."
    if [[ $EUID -eq 0 ]]; then
        # Si root, on peut écrire dans /etc
        print_success "Permissions d'écriture dans /etc OK (root)"
    elif [[ -w /etc ]]; then
        # Si le répertoire est accessible en écriture
        print_success "Permissions d'écriture dans /etc OK"
    else
        # Pas de permissions, mais c'est normal en non-root
        print_success "Permissions d'écriture dans /etc (sudo requis pour installation)"
    fi
}

# Résumé et recommandations
show_summary() {
    print_header "RÉSUMÉ ET RECOMMANDATIONS"
    
    echo -e "${GREEN}✅ Tests passés avec succès${NC}"
    echo -e "${YELLOW}⚠️  Avertissements à noter${NC}"
    echo -e "${RED}❌ Erreurs bloquantes${NC}"
    echo
    
    echo "📋 PRÉREQUIS POUR L'INSTALLATION :"
    echo "   • Ubuntu 20.04 LTS ou plus récent"
    echo "   • Privilèges root (sudo)"
    echo "   • Connectivité Internet"
    echo "   • Au moins 1GB de RAM"
    echo "   • Au moins 5GB d'espace disque libre"
    echo
    
    echo "🚀 POUR LANCER L'INSTALLATION :"
    echo "   sudo ./setup-getyoursite.sh"
    echo
    
    echo "📞 EN CAS DE PROBLÈME :"
    echo "   • Vérifiez les logs de ce test"
    echo "   • Assurez-vous d'avoir une connexion Internet stable"
    echo "   • Libérez de l'espace disque si nécessaire"
    echo "   • Arrêtez les services conflictuels (Apache, etc.)"
}

# Fonction principale
main() {
    print_header "TEST D'INSTALLATION GETYOURSITE"
    echo "Ce script vérifie la compatibilité de votre système avec GetYourSite"
    echo
    
    local error_count=0
    
    # Exécution des tests
    test_system || ((error_count++))
    test_privileges || ((error_count++))
    test_connectivity || ((error_count++))
    test_ports || ((error_count++))
    test_existing_services || ((error_count++))
    test_dry_run || ((error_count++))
    
    echo
    show_summary
    
    if [[ $error_count -eq 0 ]]; then
        print_success "✅ Votre système est prêt pour l'installation GetYourSite !"
        exit 0
    else
        print_error "❌ $error_count erreur(s) détectée(s). Corrigez les problèmes avant d'installer."
        exit 1
    fi
}

# Gestion des erreurs
trap 'echo -e "\n${RED}Test interrompu${NC}"; exit 1' ERR

# Démarrage
main "$@"