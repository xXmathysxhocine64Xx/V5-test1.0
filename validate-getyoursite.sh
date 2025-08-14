#!/bin/bash

# ===============================================
# 🔍 Validation GetYourSite - Vérification Post-Déploiement
# ===============================================

set -euo pipefail

# Couleurs
readonly RED='33[0;31m'
readonly GREEN='33[0;32m'
readonly YELLOW='33[1;33m'
readonly BLUE='33[0;34m'
readonly NC='33[0m'

PROJECT_NAME="getyoursite"
PROJECT_DIR="/var/www/${PROJECT_NAME}"

print_step() {
    echo -e "${BLUE}[VALIDATION]${NC} $1"
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

# Validation PM2
validate_pm2() {
    print_step "Validation PM2..."
    
    if ! command -v pm2 >/dev/null 2>&1; then
        print_error "PM2 non installé"
        return 1
    fi
    
    if pm2 list | grep -q "$PROJECT_NAME.*online"; then
        print_success "Application PM2 en ligne"
    else
        print_error "Application PM2 hors ligne"
        echo "Status PM2:"
        pm2 list
        return 1
    fi
}

# Validation Next.js
validate_nextjs() {
    print_step "Validation Next.js..."
    
    # Test de l'application
    if curl -s --connect-timeout 10 http://localhost:3000 >/dev/null; then
        print_success "Application accessible sur port 3000"
    else
        print_error "Application inaccessible sur port 3000"
        return 1
    fi
    
    # Test de l'API
    local api_response=$(curl -s --connect-timeout 10 http://localhost:3000/api/contact 2>/dev/null || echo "")
    if echo "$api_response" | grep -q "API GetYourSite active"; then
        print_success "API fonctionnelle"
    else
        print_error "API non fonctionnelle"
        echo "Réponse API: $api_response"
        return 1
    fi
}

# Validation Nginx
validate_nginx() {
    print_step "Validation Nginx..."
    
    if ! systemctl is-active --quiet nginx; then
        print_error "Nginx inactif"
        return 1
    fi
    
    # Test via Nginx (port 80)
    if curl -s --connect-timeout 10 http://localhost >/dev/null; then
        print_success "Site accessible via Nginx"
    else
        print_warning "Site inaccessible via Nginx (port 80)"
    fi
}

# Validation des logs
validate_logs() {
    print_step "Validation des logs..."
    
    # Vérifier les logs PM2
    if [[ -f "/var/log/pm2/$PROJECT_NAME.log" ]]; then
        local error_count=$(tail -n 20 "/var/log/pm2/$PROJECT_NAME.log" 2>/dev/null | grep -i error | wc -l)
        if [[ "$error_count" -eq 0 ]]; then
            print_success "Pas d'erreurs récentes dans les logs PM2"
        else
            print_warning "$error_count erreur(s) récente(s) dans les logs PM2"
        fi
    else
        print_warning "Logs PM2 non trouvés"
    fi
}

# Validation complète
main() {
    echo -e "${BLUE}🔍 VALIDATION GETYOURSITE${NC}"
    echo "Vérification post-déploiement de l'application"
    echo
    
    local validation_errors=0
    
    validate_pm2 || ((validation_errors++))
    validate_nextjs || ((validation_errors++))
    validate_nginx || ((validation_errors++))
    validate_logs || ((validation_errors++))
    
    echo
    if [[ $validation_errors -eq 0 ]]; then
        print_success "✅ Validation réussie - Application fonctionnelle"
        echo
        echo -e "${GREEN}🎉 Votre site GetYourSite est opérationnel !${NC}"
        echo "• Application Next.js: ✓ Fonctionnelle"
        echo "• API de contact: ✓ Fonctionnelle" 
        echo "• PM2: ✓ En ligne"
        echo "• Nginx: ✓ Actif"
    else
        print_error "❌ Validation échouée - $validation_errors problème(s) détecté(s)"
        echo
        echo -e "${YELLOW}🔧 Actions recommandées:${NC}"
        echo "• Vérifiez les logs: pm2 logs $PROJECT_NAME"
        echo "• Redémarrez l'application: pm2 restart $PROJECT_NAME"
        echo "• Consultez les logs Nginx: tail -f /var/log/nginx/*error.log"
        return 1
    fi
}

# Gestion des erreurs
trap 'echo -e "\n${RED}Validation interrompue${NC}"; exit 1' ERR

# Démarrage de la validation
main "$@"