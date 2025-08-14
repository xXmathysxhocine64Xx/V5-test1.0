#!/bin/bash

# ===============================================
# 🚀 GetYourSite - Installation Ubuntu 24.04 LTS
# ===============================================
# Script d'installation moderne et sécurisé
# Version: 2.0
# Compatible: Ubuntu Server 24.04 LTS

set -euo pipefail  # Mode strict bash

# ===============================================
# CONFIGURATION ET VARIABLES
# ===============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="getyoursite"
PROJECT_DIR="/var/www/${PROJECT_NAME}"
NODE_VERSION="18"

# Couleurs pour l'affichage
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# ===============================================
# FONCTIONS UTILITAIRES
# ===============================================

print_header() {
    echo -e "\n${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
}

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

print_info() {
    echo -e "${CYAN}[ℹ INFO]${NC} $1"
}

# Fonction de nettoyage en cas d'erreur
cleanup_on_error() {
    print_error "Une erreur est survenue à la ligne $1"
    print_info "Nettoyage en cours..."
    
    # Arrêter les services si nécessaire
    systemctl stop nginx 2>/dev/null || true
    pm2 delete "$PROJECT_NAME" 2>/dev/null || true
    
    print_error "Installation interrompue. Consultez les logs ci-dessus."
    exit 1
}

# Piège pour capturer les erreurs
trap 'cleanup_on_error $LINENO' ERR

# Vérification des privilèges root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Ce script doit être exécuté avec des privilèges root"
        echo "Utilisez: sudo $0"
        exit 1
    fi
}

# Vérification de la version Ubuntu
check_ubuntu_version() {
    print_step "Vérification de la version du système..."
    
    if [[ ! -f /etc/os-release ]]; then
        print_error "Impossible de détecter la version du système"
        exit 1
    fi
    
    source /etc/os-release
    
    if [[ "$ID" != "ubuntu" ]]; then
        print_error "Ce script est conçu pour Ubuntu uniquement"
        print_info "Système détecté: $ID"
        exit 1
    fi
    
    local version_number
    version_number=$(echo "$VERSION_ID" | cut -d. -f1)
    
    if [[ "$version_number" -lt 20 ]]; then
        print_error "Ubuntu 20.04 LTS ou plus récent requis"
        print_info "Version détectée: $VERSION_ID"
        exit 1
    fi
    
    print_success "Système compatible détecté: Ubuntu $VERSION_ID"
}

# Mise à jour du système
update_system() {
    print_step "Mise à jour du système..."
    
    export DEBIAN_FRONTEND=noninteractive
    
    apt-get update -y
    apt-get upgrade -y
    
    # Installation des outils de base
    apt-get install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        ufw \
        fail2ban
    
    print_success "Système mis à jour avec succès"
}

# Installation de Node.js
install_nodejs() {
    print_step "Installation de Node.js ${NODE_VERSION}..."
    
    # Nettoyage des installations Node.js existantes
    apt-get remove -y nodejs npm 2>/dev/null || true
    
    # Installation via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt-get install -y nodejs
    
    # Vérification de l'installation
    local node_version
    local npm_version
    node_version=$(node --version)
    npm_version=$(npm --version)
    
    print_success "Node.js installé: $node_version"
    print_success "npm installé: $npm_version"
    
    # Installation de Yarn et PM2
    npm install -g yarn pm2
    
    # Vérification des installations
    local yarn_version
    local pm2_version
    
    if ! command -v yarn &> /dev/null; then
        print_error "Yarn n'a pas pu être installé"
        exit 1
    fi
    
    if ! command -v pm2 &> /dev/null; then
        print_error "PM2 n'a pas pu être installé"
        exit 1
    fi
    
    yarn_version=$(yarn --version)
    pm2_version=$(pm2 --version)
    
    print_success "Yarn installé: $yarn_version"
    print_success "PM2 installé: $pm2_version"
}

# Installation et configuration de Nginx
install_nginx() {
    print_step "Installation et configuration de Nginx..."
    
    apt-get install -y nginx
    
    # Démarrage et activation de Nginx
    systemctl start nginx
    systemctl enable nginx
    
    print_success "Nginx installé et configuré"
}

# Configuration des informations Gmail
configure_gmail() {
    print_header "CONFIGURATION DU FORMULAIRE DE CONTACT"
    
    echo -e "${CYAN}Le formulaire de contact peut envoyer des emails via Gmail.${NC}"
    echo -e "${CYAN}Cette étape est optionnelle - vous pouvez la configurer plus tard.${NC}\n"
    
    read -p "Voulez-vous configurer Gmail maintenant ? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
        echo -e "${YELLOW}Pour obtenir un mot de passe d'application Gmail:${NC}"
        echo "1. Allez sur myaccount.google.com"
        echo "2. Sécurité → Vérification en 2 étapes (activez-la si nécessaire)"
        echo "3. Sécurité → Mots de passe des applications"
        echo "4. Générez un mot de passe pour 'Courrier'"
        echo
        
        read -p "Votre adresse Gmail: " GMAIL_USER
        echo
        read -p "Mot de passe d'application (16 caractères): " GMAIL_APP_PASSWORD
        echo
        read -p "Email de réception [${GMAIL_USER}]: " GMAIL_RECIPIENT
        
        # Valeurs par défaut
        GMAIL_RECIPIENT=${GMAIL_RECIPIENT:-$GMAIL_USER}
        
        print_success "Configuration Gmail enregistrée"
    else
        print_info "Configuration Gmail ignorée - vous pourrez la faire plus tard"
        GMAIL_USER="votre-email@gmail.com"
        GMAIL_APP_PASSWORD="votre-mot-de-passe-app-16-caracteres"
        GMAIL_RECIPIENT="votre-email@gmail.com"
    fi
}

# Création de la structure du projet
create_project_structure() {
    print_step "Création de la structure du projet..."
    
    # Nettoyage et création du répertoire
    rm -rf "$PROJECT_DIR" 2>/dev/null || true
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # Création des sous-répertoires
    mkdir -p app/api/contact
    mkdir -p components/ui
    mkdir -p lib
    mkdir -p hooks
    
    print_success "Structure du projet créée dans $PROJECT_DIR"
}

# Création des fichiers de configuration
create_config_files() {
    print_step "Création des fichiers de configuration..."
    
    # package.json
    cat > package.json << 'EOF'
{
    "name": "getyoursite",
    "version": "1.0.0",
    "private": true,
    "scripts": {
        "dev": "next dev --hostname 0.0.0.0 --port 3000",
        "build": "next build",
        "start": "next start --hostname 0.0.0.0 --port 3000",
        "lint": "next lint"
    },
    "dependencies": {
        "@hookform/resolvers": "^5.1.1",
        "@radix-ui/react-accordion": "^1.2.11",
        "@radix-ui/react-alert-dialog": "^1.1.14",
        "@radix-ui/react-aspect-ratio": "^1.1.7",
        "@radix-ui/react-avatar": "^1.1.10",
        "@radix-ui/react-checkbox": "^1.3.2",
        "@radix-ui/react-dialog": "^1.1.14",
        "@radix-ui/react-dropdown-menu": "^2.1.15",
        "@radix-ui/react-label": "^2.1.7",
        "@radix-ui/react-popover": "^1.1.14",
        "@radix-ui/react-select": "^2.2.5",
        "@radix-ui/react-separator": "^1.1.7",
        "@radix-ui/react-slot": "^1.2.3",
        "@radix-ui/react-tabs": "^1.1.12",
        "@radix-ui/react-toast": "^1.2.14",
        "@radix-ui/react-tooltip": "^1.2.7",
        "class-variance-authority": "^0.7.1",
        "clsx": "^2.1.1",
        "lucide-react": "^0.516.0",
        "next": "14.2.3",
        "nodemailer": "^6.9.8",
        "react": "^18",
        "react-dom": "^18",
        "react-hook-form": "^7.58.1",
        "tailwind-merge": "^3.3.1",
        "tailwindcss-animate": "^1.0.7",
        "zod": "^3.25.67"
    },
    "devDependencies": {
        "autoprefixer": "^10.4.19",
        "postcss": "^8",
        "tailwindcss": "^3.4.1"
    }
}
EOF

    # next.config.js
    cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
        port: '',
        pathname: '/**',
      },
    ],
  },
  // Configuration pour production
  output: 'standalone',
  poweredByHeader: false,
  compress: true,
}

module.exports = nextConfig
EOF

    # tailwind.config.js
    cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './app/**/*.{js,jsx}',
    './components/**/*.{js,jsx}',
    './hooks/**/*.{js,jsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(214.3 31.8% 91.4%)",
        input: "hsl(214.3 31.8% 91.4%)",
        ring: "hsl(221.2 83.2% 53.3%)",
        background: "hsl(0 0% 100%)",
        foreground: "hsl(222.2 84% 4.9%)",
        primary: {
          DEFAULT: "hsl(221.2 83.2% 53.3%)",
          foreground: "hsl(210 40% 98%)",
        },
        secondary: {
          DEFAULT: "hsl(210 40% 96%)",
          foreground: "hsl(222.2 84% 4.9%)",
        },
        muted: {
          DEFAULT: "hsl(210 40% 96%)",
          foreground: "hsl(215.4 16.3% 46.9%)",
        },
        accent: {
          DEFAULT: "hsl(210 40% 96%)",
          foreground: "hsl(222.2 84% 4.9%)",
        },
        card: {
          DEFAULT: "hsl(0 0% 100%)",
          foreground: "hsl(222.2 84% 4.9%)",
        },
      },
      borderRadius: {
        lg: "0.5rem",
        md: "0.375rem",
        sm: "0.25rem",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
EOF

    # postcss.config.js
    cat > postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

    # Fichier d'environnement
    cat > .env << EOF
# Configuration Gmail pour le formulaire de contact
GMAIL_USER=${GMAIL_USER}
GMAIL_APP_PASSWORD=${GMAIL_APP_PASSWORD}
GMAIL_RECIPIENT=${GMAIL_RECIPIENT}
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587

# Configuration Next.js
NEXT_PUBLIC_SITE_NAME=GetYourSite
NEXT_PUBLIC_SITE_URL=http://localhost:3000
EOF

    # Vérification que le fichier .env a été créé
    if [[ -f .env ]]; then
        print_success "Fichier .env créé avec succès"
        if [[ "$GMAIL_USER" != "votre-email@gmail.com" ]]; then
            print_success "Configuration Gmail intégrée dans .env"
        fi
    else
        print_error "Erreur lors de la création du fichier .env"
        exit 1
    fi

    # Configuration jsconfig.json pour les imports absolus
    cat > jsconfig.json << 'EOF'
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  }
}
EOF

    print_success "Fichiers de configuration créés"
}

# Copie des fichiers source depuis le répertoire courant
copy_source_files() {
    print_step "Copie des fichiers source..."
    
    # Vérifier si nous sommes dans le bon répertoire
    if [[ -f "$SCRIPT_DIR/app/page.js" && -f "$SCRIPT_DIR/app/api/[[...path]]/route.js" ]]; then
        print_info "Copie depuis le répertoire source existant..."
        
        # Copier les fichiers de l'application
        cp -r "$SCRIPT_DIR/app"/* "$PROJECT_DIR/app/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/components"/* "$PROJECT_DIR/components/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/lib"/* "$PROJECT_DIR/lib/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/hooks"/* "$PROJECT_DIR/hooks/" 2>/dev/null || true
        
        print_success "Fichiers source copiés depuis le répertoire existant"
    else
        print_warning "Fichiers source non trouvés, création des fichiers de base..."
        create_basic_files
    fi
}

# Création des fichiers de base si les sources ne sont pas disponibles
create_basic_files() {
    print_step "Création des fichiers de base..."
    
    # lib/utils.js
    cat > lib/utils.js << 'EOF'
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs) {
  return twMerge(clsx(inputs))
}
EOF

    # app/globals.css
    cat > app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
  }
  
  body {
    background-color: hsl(var(--background));
    color: hsl(var(--foreground));
  }
}
EOF

    # app/layout.js
    cat > app/layout.js << 'EOF'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'GetYourSite - Création et Développement de Sites Web',
  description: 'Expert en conception, déploiement et refonte de sites web pour particuliers et professionnels. Transformez votre présence en ligne avec GetYourSite.',
  keywords: 'création site web, développement web, refonte site, conception web',
}

export default function RootLayout({ children }) {
  return (
    <html lang="fr">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
EOF

    # Créer un fichier app/page.js basique
    cat > app/page.js << 'EOF'
export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      <div className="container mx-auto px-4 py-20 text-center">
        <h1 className="text-4xl md:text-6xl font-bold text-slate-800 mb-6">
          Get<span className="text-blue-600">Your</span>Site
        </h1>
        <p className="text-xl text-slate-600 mb-8">
          Votre site vitrine professionnel est en cours de configuration...
        </p>
        <div className="bg-white rounded-lg shadow-lg p-8 max-w-2xl mx-auto">
          <h2 className="text-2xl font-bold mb-4">Installation réussie !</h2>
          <p className="text-gray-600">
            Votre site GetYourSite est maintenant installé et fonctionnel.
            Vous pouvez maintenant remplacer ce fichier par le contenu complet de votre site.
          </p>
        </div>
      </div>
    </div>
  )
}
EOF

    # API route basique
    mkdir -p app/api/contact
    cat > app/api/contact/route.js << 'EOF'
import { NextResponse } from 'next/server';
import nodemailer from 'nodemailer';

export async function GET(request) {
  return NextResponse.json({
    message: 'API GetYourSite active',
    timestamp: new Date().toISOString(),
    status: 'running'
  });
}

export async function POST(request) {
  try {
    const body = await request.json();
    const { name, email, message, subject = 'Nouveau message de GetYourSite' } = body;
    
    if (!name || !email || !message) {
      return NextResponse.json(
        { error: 'Le nom, l\'email et le message sont requis' },
        { status: 400 }
      );
    }

    // Vérifier la configuration Gmail
    if (!process.env.GMAIL_USER || process.env.GMAIL_USER === 'votre-email@gmail.com') {
      console.log('Contact form submission (Gmail not configured):', {
        name, email, subject, message, timestamp: new Date().toISOString()
      });
      
      return NextResponse.json({
        success: true,
        message: 'Message reçu ! Gmail n\'est pas encore configuré.',
        note: 'Le message a été enregistré dans les logs du serveur'
      });
    }

    // Configuration du transporteur email
    const transporter = nodemailer.createTransporter({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT),
      secure: false,
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_APP_PASSWORD,
      },
    });
    
    const mailOptions = {
      from: `"${name}" <${process.env.GMAIL_USER}>`,
      to: process.env.GMAIL_RECIPIENT || process.env.GMAIL_USER,
      replyTo: email,
      subject: subject,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #2563eb;">Nouveau message depuis GetYourSite</h2>
          <p><strong>Nom:</strong> ${name}</p>
          <p><strong>Email:</strong> ${email}</p>
          <p><strong>Message:</strong></p>
          <div style="background-color: #f8fafc; padding: 15px; border-radius: 5px; border-left: 4px solid #2563eb;">
            ${message.replace(/\n/g, '<br>')}
          </div>
        </div>
      `,
    };
    
    await transporter.sendMail(mailOptions);
    
    return NextResponse.json({ 
      success: true, 
      message: 'Votre message a été envoyé avec succès !'
    });
    
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Erreur lors du traitement de votre message' },
      { status: 500 }
    );
  }
}
EOF

    print_success "Fichiers de base créés"
}

# Installation des dépendances et build
install_and_build() {
    print_step "Installation des dépendances..."
    
    cd "$PROJECT_DIR"
    
    # Installation avec Yarn
    yarn install --frozen-lockfile
    
    print_success "Dépendances installées"
    
    print_step "Build de l'application..."
    
    # Build de production
    yarn build
    
    print_success "Application buildée avec succès"
}

# Configuration PM2
setup_pm2() {
    print_step "Configuration de PM2..."
    
    cd "$PROJECT_DIR"
    
    # Configuration PM2
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
      PORT: 3000
    },
    error_file: '/var/log/pm2/${PROJECT_NAME}-error.log',
    out_file: '/var/log/pm2/${PROJECT_NAME}-out.log',
    log_file: '/var/log/pm2/${PROJECT_NAME}.log',
    time: true
  }]
}
EOF

    # Créer le répertoire des logs PM2
    mkdir -p /var/log/pm2
    
    # Arrêter les processus existants
    pm2 delete "$PROJECT_NAME" 2>/dev/null || true
    
    # Démarrer l'application
    pm2 start ecosystem.config.js
    
    # Configuration du démarrage automatique
    pm2 startup systemd -u root --hp /root
    pm2 save
    
    print_success "PM2 configuré et démarré"
}

# Configuration Nginx
setup_nginx() {
    print_step "Configuration de Nginx..."
    
    # Configuration du site
    cat > /etc/nginx/sites-available/"$PROJECT_NAME" << EOF
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
    access_log /var/log/nginx/${PROJECT_NAME}_access.log;
    error_log /var/log/nginx/${PROJECT_NAME}_error.log;
    
    # Configuration proxy vers Next.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
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

    # Désactiver le site par défaut
    rm -f /etc/nginx/sites-enabled/default
    
    # Activer le nouveau site
    ln -sf /etc/nginx/sites-available/"$PROJECT_NAME" /etc/nginx/sites-enabled/
    
    # Test de la configuration
    nginx -t
    
    # Redémarrage de Nginx
    systemctl restart nginx
    
    print_success "Nginx configuré et redémarré"
}

# Configuration du firewall
setup_firewall() {
    print_step "Configuration du firewall UFW..."
    
    # Réinitialiser UFW
    ufw --force reset
    
    # Politique par défaut
    ufw default deny incoming
    ufw default allow outgoing
    
    # Autoriser SSH
    ufw allow ssh
    ufw allow 22/tcp
    
    # Autoriser HTTP et HTTPS
    ufw allow 'Nginx Full'
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Activer UFW
    ufw --force enable
    
    print_success "Firewall configuré"
}

# Configuration des permissions
fix_permissions() {
    print_step "Configuration des permissions..."
    
    # Permissions pour le projet
    chown -R www-data:www-data "$PROJECT_DIR"
    find "$PROJECT_DIR" -type d -exec chmod 755 {} \;
    find "$PROJECT_DIR" -type f -exec chmod 644 {} \;
    
    # Permissions spéciales pour les logs
    mkdir -p /var/log/nginx
    chown -R www-data:adm /var/log/nginx
    
    print_success "Permissions configurées"
}

# Tests de fonctionnement
run_tests() {
    print_step "Tests de fonctionnement..."
    
    # Attendre que les services soient prêts
    sleep 5
    
    # Test PM2
    if pm2 list | grep -q "$PROJECT_NAME.*online"; then
        print_success "PM2: Application en ligne"
    else
        print_warning "PM2: Problème détecté"
        pm2 logs "$PROJECT_NAME" --lines 10
    fi
    
    # Test Nginx
    if systemctl is-active --quiet nginx; then
        print_success "Nginx: Service actif"
    else
        print_error "Nginx: Service inactif"
    fi
    
    # Test de l'API
    sleep 3
    if curl -s http://localhost:3000/api/contact | grep -q "API GetYourSite active"; then
        print_success "API: Fonctionnelle"
    else
        print_warning "API: Problème détecté"
    fi
    
    # Test du site principal
    if curl -s http://localhost:3000 | grep -q "GetYourSite"; then
        print_success "Site: Accessible"
    else
        print_warning "Site: Problème détecté"
    fi
}



# Affichage des informations finales
show_final_info() {
    print_header "INSTALLATION TERMINÉE AVEC SUCCÈS"
    
    echo -e "${GREEN}🎉 GetYourSite est maintenant installé et fonctionnel !${NC}\n"
    
    # Obtenir l'IP publique
    local public_ip
    public_ip=$(curl -s ifconfig.me 2>/dev/null || echo "VOTRE-IP-SERVEUR")
    
    echo -e "${CYAN}📋 INFORMATIONS D'ACCÈS :${NC}"
    echo "   • Site web : http://${public_ip}"
    echo "   • Site local : http://localhost"
    echo "   • Test API : http://localhost/api/contact"
    echo
    
    echo -e "${CYAN}🔧 COMMANDES DE GESTION :${NC}"
    echo "   • Statut PM2 : pm2 status"
    echo "   • Logs PM2 : pm2 logs $PROJECT_NAME"
    echo "   • Redémarrer : pm2 restart $PROJECT_NAME"
    echo "   • Statut Nginx : systemctl status nginx"
    echo "   • Logs Nginx : tail -f /var/log/nginx/${PROJECT_NAME}_*.log"
    echo
    
    echo -e "${CYAN}📁 FICHIERS IMPORTANTS :${NC}"
    echo "   • Projet : $PROJECT_DIR"
    echo "   • Configuration : $PROJECT_DIR/.env"
    echo "   • Logs : /var/log/pm2/ et /var/log/nginx/"
    echo
    
    if [[ "$GMAIL_USER" != "votre-email@gmail.com" ]]; then
        echo -e "${GREEN}✅ Gmail configuré pour : $GMAIL_USER${NC}"
    else
        echo -e "${YELLOW}⚠️  Configuration Gmail requise pour le formulaire de contact${NC}"
        echo "   Modifiez le fichier : $PROJECT_DIR/.env"
        echo "   Puis redémarrez : pm2 restart $PROJECT_NAME"
    fi
    
    echo
    echo -e "${CYAN}🛡️  SÉCURITÉ :${NC}"
    echo "   • Firewall UFW : Activé"
    echo "   • Fail2ban : Installé"
    echo "   • Nginx headers : Configurés"
    echo
    
    echo -e "${CYAN}📊 MONITORING :${NC}"
    echo "   • pm2 monit : Interface de monitoring"
    echo "   • pm2 logs $PROJECT_NAME --lines 50 : Logs récents"
    echo
    
    print_success "Installation terminée ! Votre site est accessible."
    
    echo -e "\n${PURPLE}Pour obtenir un certificat SSL gratuit (HTTPS) :${NC}"
    echo "sudo apt install certbot python3-certbot-nginx"
    echo "sudo certbot --nginx -d votre-domaine.com"
}

# ===============================================
# FONCTION PRINCIPALE
# ===============================================

main() {
    print_header "INSTALLATION GETYOURSITE v2.0"
    echo -e "${WHITE}Installation automatique pour Ubuntu Server 24.04 LTS${NC}"
    echo -e "${WHITE}Ce script va installer et configurer complètement votre site GetYourSite${NC}\n"
    
    read -p "Continuer l'installation ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation annulée."
        exit 0
    fi
    
    print_info "Début de l'installation..."
    
    # Séquence d'installation
    check_root
    check_ubuntu_version
    configure_gmail
    update_system
    install_nodejs
    install_nginx
    create_project_structure
    create_config_files
    copy_source_files
    install_and_build
    setup_pm2
    setup_nginx
    setup_firewall
    fix_permissions
    run_tests
    show_final_info
    
    print_success "🚀 Installation terminée avec succès !"
}

# Démarrage du script
main "$@"