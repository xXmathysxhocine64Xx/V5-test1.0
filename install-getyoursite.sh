#!/bin/bash

# 🚀 Installation automatique GetYourSite - Script principal
# Évite les erreurs de copier-coller avec EOF

echo "🚀 Installation de GetYourSite - Ubuntu Server 24.04"
echo "=================================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_step() {
    echo -e "${BLUE}[ÉTAPE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

# Vérification des privilèges
if [[ $EUID -ne 0 ]]; then
   print_error "Ce script doit être exécuté en tant que root (sudo)"
   exit 1
fi

print_step "Mise à jour du système..."
apt update && apt upgrade -y

print_step "Installation de Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs nginx git

# Vérification de Node.js
NODE_VERSION=$(node --version)
print_success "Node.js installé: $NODE_VERSION"

print_step "Création du répertoire de projet..."
mkdir -p /var/www/getyoursite
cd /var/www/getyoursite

print_step "Création des fichiers de base..."

# Création du package.json SANS EOF
cat > package.json << 'PACKAGE_JSON'
{
    "name": "getyoursite",
    "version": "1.0.0",
    "private": true,
    "scripts": {
        "dev": "next dev",
        "build": "next build", 
        "start": "next start",
        "lint": "next lint"
    },
    "dependencies": {
        "@hookform/resolvers": "^5.1.1",
        "nodemailer": "^6.9.8",
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
        "react": "^18",
        "react-dom": "^18",
        "tailwind-merge": "^3.3.1",
        "tailwindcss-animate": "^1.0.7"
    },
    "devDependencies": {
        "autoprefixer": "^10.4.19",
        "postcss": "^8",
        "tailwindcss": "^3.4.1"
    }
}
PACKAGE_JSON

print_success "Package.json créé"

# Configuration Next.js
cat > next.config.js << 'NEXTCONFIG'
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
}

module.exports = nextConfig
NEXTCONFIG

# Configuration Tailwind
cat > tailwind.config.js << 'TAILWINDCONFIG'
/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{js,jsx}',
    './components/**/*.{js,jsx}',
    './app/**/*.{js,jsx}',
    './src/**/*.{js,jsx}',
  ],
  prefix: "",
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
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
TAILWINDCONFIG

# PostCSS
cat > postcss.config.js << 'POSTCSSCONFIG'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSSCONFIG

# Variables d'environnement
cat > .env.local << 'ENVFILE'
# Configuration Gmail pour le formulaire de contact
# REMPLACEZ CES VALEURS PAR VOS VRAIES INFORMATIONS
GMAIL_USER=votre-email@gmail.com
GMAIL_APP_PASSWORD=votre-mot-de-passe-application-16-caracteres
GMAIL_RECIPIENT=votre-email@gmail.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
ENVFILE

print_success "Fichiers de configuration créés"

# Création des dossiers
mkdir -p app/api/contact
mkdir -p components/ui
mkdir -p lib

print_step "Téléchargement des fichiers du site..."

# Au lieu d'utiliser EOF, on va créer les fichiers directement
# Ceci évite complètement les problèmes de copier-coller

print_warning "Les fichiers de l'application seront créés par le script create-app-files.sh"
print_warning "Vous devrez d'abord récupérer tous les fichiers source du projet"

print_step "Installation des dépendances..."
npm install

print_success "Dépendances installées"

print_step "Installation de PM2..."
npm install -g pm2

# Configuration PM2
cat > ecosystem.config.js << 'PM2CONFIG'
module.exports = {
  apps: [{
    name: 'getyoursite',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/getyoursite',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
PM2CONFIG

print_success "Configuration PM2 créée"

print_step "Configuration Nginx..."

# Configuration Nginx
cat > /etc/nginx/sites-available/getyoursite << 'NGINXCONFIG'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
NGINXCONFIG

# Activation du site Nginx
ln -sf /etc/nginx/sites-available/getyoursite /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test de la configuration Nginx
if nginx -t; then
    systemctl restart nginx
    print_success "Nginx configuré et redémarré"
else
    print_error "Erreur dans la configuration Nginx"
    exit 1
fi

# Permissions
chown -R www-data:www-data /var/www/getyoursite

print_success "Installation de base terminée!"
print_warning "ÉTAPES SUIVANTES IMPORTANTES:"
echo "1. Copiez les fichiers de votre application dans /var/www/getyoursite"
echo "2. Modifiez le fichier .env.local avec vos vraies informations Gmail"
echo "3. Lancez: npm run build"
echo "4. Lancez: pm2 start ecosystem.config.js"
echo "5. Lancez: pm2 startup && pm2 save"

print_step "Configuration du firewall (optionnel)..."
ufw allow 'Nginx Full'
ufw allow ssh
print_success "Firewall configuré"

echo ""
echo "=================================================="
print_success "Installation terminée!"
echo "Votre site sera accessible sur http://votre-ip"
echo "=================================================="