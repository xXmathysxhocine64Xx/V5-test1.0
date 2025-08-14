#!/bin/bash

# ===============================================
# 🔍 Diagnostic GetYourSite - Détection de Problèmes
# ===============================================
# Script de diagnostic pour identifier les problèmes après installation

set -euo pipefail

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

PROJECT_NAME="getyoursite"
PROJECT_DIR="/var/www/${PROJECT_NAME}"

print_header() {
    echo -e "\n${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
}

print_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
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

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Vérification de l'installation
check_installation() {
    print_header "VÉRIFICATION DE L'INSTALLATION"
    
    print_check "Répertoire du projet..."
    if [[ -d "$PROJECT_DIR" ]]; then
        print_success "Répertoire trouvé: $PROJECT_DIR"
    else
        print_error "Répertoire manquant: $PROJECT_DIR"
        return 1
    fi
    
    print_check "Fichiers essentiels..."
    local files=("package.json" "app/page.js" "app/layout.js" ".env.local")
    for file in "${files[@]}"; do
        if [[ -f "$PROJECT_DIR/$file" ]]; then
            print_success "Fichier trouvé: $file"
        else
            print_error "Fichier manquant: $file"
        fi
    done
    
    print_check "Node modules..."
    if [[ -d "$PROJECT_DIR/node_modules" ]]; then
        print_success "Dependencies installées"
    else
        print_error "Node modules manquants (yarn install requis)"
    fi
    
    print_check "Build Next.js..."
    if [[ -d "$PROJECT_DIR/.next" ]]; then
        print_success "Application buildée"
    else
        print_error "Build manquant (yarn build requis)"
    fi
}

# Vérification des services
check_services() {
    print_header "VÉRIFICATION DES SERVICES"
    
    print_check "Node.js..."
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        print_success "Node.js installé: $node_version"
    else
        print_error "Node.js non installé"
    fi
    
    print_check "Yarn..."
    if command -v yarn >/dev/null 2>&1; then
        local yarn_version=$(yarn --version)
        print_success "Yarn installé: $yarn_version"
    else
        print_error "Yarn non installé"
    fi
    
    print_check "PM2..."
    if command -v pm2 >/dev/null 2>&1; then
        local pm2_version=$(pm2 --version)
        print_success "PM2 installé: $pm2_version"
        
        print_check "Application PM2..."
        if pm2 list | grep -q "$PROJECT_NAME"; then
            local status=$(pm2 list | grep "$PROJECT_NAME" | awk '{print $10}')
            if [[ "$status" == "online" ]]; then
                print_success "Application PM2 en ligne"
            else
                print_error "Application PM2 hors ligne (status: $status)"
            fi
        else
            print_error "Application PM2 non trouvée"
        fi
    else
        print_error "PM2 non installé"
    fi
    
    print_check "Nginx..."
    if systemctl is-active --quiet nginx; then
        print_success "Nginx actif"
    else
        print_error "Nginx inactif"
    fi
    
    print_check "Configuration Nginx..."
    if [[ -f "/etc/nginx/sites-available/$PROJECT_NAME" ]]; then
        print_success "Configuration Nginx trouvée"
        if nginx -t 2>/dev/null; then
            print_success "Configuration Nginx valide"
        else
            print_error "Configuration Nginx invalide"
        fi
    else
        print_error "Configuration Nginx manquante"
    fi
}

# Vérification des ports
check_ports() {
    print_header "VÉRIFICATION DES PORTS"
    
    print_check "Port 3000 (Next.js)..."
    if netstat -ln 2>/dev/null | grep -q ":3000 "; then
        print_success "Port 3000 en écoute"
    else
        print_error "Port 3000 non en écoute"
    fi
    
    print_check "Port 80 (HTTP)..."
    if netstat -ln 2>/dev/null | grep -q ":80 "; then
        print_success "Port 80 en écoute"
    else
        print_error "Port 80 non en écoute"
    fi
    
    print_check "Port 443 (HTTPS)..."
    if netstat -ln 2>/dev/null | grep -q ":443 "; then
        print_success "Port 443 en écoute (SSL configuré)"
    else
        print_warning "Port 443 non en écoute (SSL non configuré)"
    fi
}

# Test de connectivité
check_connectivity() {
    print_header "TESTS DE CONNECTIVITÉ"
    
    print_check "Application locale (port 3000)..."
    if curl -s --connect-timeout 5 http://localhost:3000 >/dev/null; then
        print_success "Application accessible sur port 3000"
    else
        print_error "Application inaccessible sur port 3000"
    fi
    
    print_check "Site via Nginx (port 80)..."
    if curl -s --connect-timeout 5 http://localhost >/dev/null; then
        print_success "Site accessible via Nginx"
    else
        print_error "Site inaccessible via Nginx"
    fi
    
    print_check "API GetYourSite..."
    local api_response=$(curl -s --connect-timeout 5 http://localhost/api/contact 2>/dev/null || echo "")
    if echo "$api_response" | grep -q "API GetYourSite active"; then
        print_success "API fonctionnelle"
    else
        print_error "API non fonctionnelle"
    fi
}

# Vérification de la configuration
check_configuration() {
    print_header "VÉRIFICATION DE LA CONFIGURATION"
    
    print_check "Fichier .env.local..."
    if [[ -f "$PROJECT_DIR/.env.local" ]]; then
        print_success "Fichier .env.local trouvé"
        
        # Vérifier les variables Gmail
        if grep -q "GMAIL_USER=votre-email@gmail.com" "$PROJECT_DIR/.env.local"; then
            print_warning "Configuration Gmail par défaut (à configurer)"
        else
            print_success "Configuration Gmail personnalisée"
        fi
    else
        print_error "Fichier .env.local manquant"
    fi
    
    print_check "Configuration PM2..."
    if [[ -f "$PROJECT_DIR/ecosystem.config.js" ]]; then
        print_success "Configuration PM2 trouvée"
    else
        print_error "Configuration PM2 manquante"
    fi
    
    print_check "Permissions..."
    local dir_owner=$(stat -c %U "$PROJECT_DIR" 2>/dev/null || echo "unknown")
    if [[ "$dir_owner" == "www-data" ]]; then
        print_success "Permissions correctes (www-data)"
    else
        print_warning "Permissions à vérifier (propriétaire: $dir_owner)"
    fi
}

# Vérification des logs
check_logs() {
    print_header "VÉRIFICATION DES LOGS"
    
    print_check "Logs PM2..."
    if [[ -f "/var/log/pm2/$PROJECT_NAME.log" ]]; then
        print_success "Logs PM2 trouvés"
        
        # Vérifier les erreurs récentes
        local error_count=$(tail -n 50 "/var/log/pm2/$PROJECT_NAME.log" 2>/dev/null | grep -i error | wc -l)
        if [[ "$error_count" -gt 0 ]]; then
            print_warning "Erreurs récentes détectées ($error_count)"
        else
            print_success "Pas d'erreurs récentes"
        fi
    else
        print_warning "Logs PM2 non trouvés"
    fi
    
    print_check "Logs Nginx..."
    if [[ -f "/var/log/nginx/${PROJECT_NAME}_error.log" ]]; then
        print_success "Logs Nginx trouvés"
        
        # Vérifier les erreurs récentes
        local nginx_errors=$(tail -n 50 "/var/log/nginx/${PROJECT_NAME}_error.log" 2>/dev/null | wc -l)
        if [[ "$nginx_errors" -gt 0 ]]; then
            print_warning "Erreurs Nginx détectées ($nginx_errors)"
        else
            print_success "Pas d'erreurs Nginx récentes"
        fi
    else
        print_warning "Logs Nginx non trouvés"
    fi
}

# Vérification du firewall
check_firewall() {
    print_header "VÉRIFICATION DU FIREWALL"
    
    print_check "Status UFW..."
    if command -v ufw >/dev/null 2>&1; then
        local ufw_status=$(ufw status | head -n 1)
        if echo "$ufw_status" | grep -q "active"; then
            print_success "UFW actif"
            
            # Vérifier les règles importantes
            if ufw status | grep -q "80"; then
                print_success "Port 80 autorisé"
            else
                print_warning "Port 80 non autorisé"
            fi
            
            if ufw status | grep -q "443"; then
                print_success "Port 443 autorisé"
            else
                print_warning "Port 443 non autorisé"
            fi
        else
            print_warning "UFW inactif"
        fi
    else
        print_warning "UFW non installé"
    fi
}

# Diagnostic des ressources système
check_resources() {
    print_header "VÉRIFICATION DES RESSOURCES SYSTÈME"
    
    print_check "Utilisation mémoire..."
    local mem_usage=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}')
    if (( $(echo "$mem_usage > 90" | bc -l) )); then
        print_error "Mémoire critique: ${mem_usage}%"
    elif (( $(echo "$mem_usage > 75" | bc -l) )); then
        print_warning "Mémoire élevée: ${mem_usage}%"
    else
        print_success "Mémoire OK: ${mem_usage}%"
    fi
    
    print_check "Espace disque..."
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ "$disk_usage" -gt 90 ]]; then
        print_error "Disque critique: ${disk_usage}%"
    elif [[ "$disk_usage" -gt 75 ]]; then
        print_warning "Disque élevé: ${disk_usage}%"
    else
        print_success "Disque OK: ${disk_usage}%"
    fi
    
    print_check "Charge système..."
    local load_avg=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    print_info "Charge moyenne: $load_avg"
}

# Suggestions de résolution
suggest_fixes() {
    print_header "SUGGESTIONS DE RÉSOLUTION"
    
    echo -e "${CYAN}🔧 COMMANDES DE RÉPARATION COMMUNES :${NC}"
    echo
    echo "📌 Redémarrer l'application :"
    echo "   pm2 restart $PROJECT_NAME"
    echo
    echo "📌 Rebuilder l'application :"
    echo "   cd $PROJECT_DIR && yarn build && pm2 restart $PROJECT_NAME"
    echo
    echo "📌 Réinstaller les dépendances :"
    echo "   cd $PROJECT_DIR && rm -rf node_modules && yarn install && yarn build"
    echo
    echo "📌 Redémarrer Nginx :"
    echo "   sudo systemctl restart nginx"
    echo
    echo "📌 Vérifier la configuration Nginx :"
    echo "   sudo nginx -t"
    echo
    echo "📌 Corriger les permissions :"
    echo "   sudo chown -R www-data:www-data $PROJECT_DIR"
    echo
    echo "📌 Voir les logs en temps réel :"
    echo "   pm2 logs $PROJECT_NAME"
    echo
    echo "📌 Configuration Gmail :"
    echo "   sudo nano $PROJECT_DIR/.env.local"
    echo
    echo "📌 Test complet de réinstallation :"
    echo "   sudo ./setup-getyoursite.sh"
}

# Collecte des informations système
collect_system_info() {
    print_header "INFORMATIONS SYSTÈME"
    
    echo "🖥️  Système : $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Ubuntu Unknown')"
    echo "🏗️  Architecture : $(uname -m)"
    echo "💾 Mémoire totale : $(free -h | awk '/^Mem:/ {print $2}')"
    echo "💿 Espace disque : $(df -h / | awk 'NR==2 {print $4}') libre"
    echo "⚡ Charge système : $(uptime | awk '{print $(NF-2), $(NF-1), $(NF)}' | sed 's/,//g')"
    echo "🕐 Uptime : $(uptime -p 2>/dev/null || uptime | awk '{print $3, $4}' | sed 's/,//')"
    
    if command -v node >/dev/null 2>&1; then
        echo "🟢 Node.js : $(node --version)"
    fi
    
    if command -v pm2 >/dev/null 2>&1; then
        echo "📊 PM2 : $(pm2 --version)"
    fi
    
    if command -v nginx >/dev/null 2>&1; then
        echo "🌐 Nginx : $(nginx -v 2>&1 | cut -d' ' -f3)"
    fi
}

# Fonction principale
main() {
    print_header "DIAGNOSTIC GETYOURSITE"
    echo -e "${WHITE}Diagnostic complet de votre installation GetYourSite${NC}\n"
    
    collect_system_info
    
    # Tests de diagnostic
    local total_errors=0
    
    check_installation || ((total_errors++))
    check_services || ((total_errors++))
    check_ports || ((total_errors++))
    check_connectivity || ((total_errors++))
    check_configuration || ((total_errors++))
    check_logs || ((total_errors++))
    check_firewall || ((total_errors++))
    check_resources || ((total_errors++))
    
    suggest_fixes
    
    print_header "RÉSUMÉ DU DIAGNOSTIC"
    
    if [[ $total_errors -eq 0 ]]; then
        print_success "✅ Aucun problème majeur détecté !"
        echo -e "${GREEN}Votre installation GetYourSite semble fonctionnelle.${NC}"
    else
        print_warning "⚠️  $total_errors problème(s) détecté(s)"
        echo -e "${YELLOW}Consultez les suggestions ci-dessus pour résoudre les problèmes.${NC}"
    fi
    
    echo
    echo -e "${CYAN}📞 Pour plus d'aide :${NC}"
    echo "   • Consultez les logs : pm2 logs $PROJECT_NAME"
    echo "   • Relancez ce diagnostic après corrections"
    echo "   • Vérifiez la documentation d'installation"
}

# Gestion des erreurs
trap 'echo -e "\n${RED}Diagnostic interrompu${NC}"; exit 1' ERR

# Démarrage du diagnostic
main "$@"