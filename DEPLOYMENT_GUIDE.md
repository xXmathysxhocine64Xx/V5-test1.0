# 🚀 Guide d'installation GetYourSite - Ubuntu Server 24.04

Guide ultra-simple pour déployer votre site vitrine GetYourSite en 3 étapes !

## 📋 Prérequis
- Ubuntu Server 24.04 LTS
- Accès root ou sudo
- Connexion Internet
- Nom de domaine (optionnel)

## ⚡ Installation Rapide (3 étapes)

### Étape 1 : Préparation du système
```bash
# Mise à jour et installation Node.js 18+
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs nginx git

# Vérification
node --version  # Doit afficher v18.x.x ou plus
npm --version
```

### Étape 2 : Installation de GetYourSite
```bash
# Création du répertoire et clonage du projet
sudo mkdir -p /var/www/getyoursite
cd /var/www/getyoursite

# Si vous avez un repo GitHub, sinon on créera les fichiers manuellement
# git clone https://github.com/votre-compte/getyoursite.git .

# Création manuelle des fichiers du projet
sudo tee package.json > /dev/null << 'EOF'
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
        "@radix-ui/react-collapsible": "^1.1.11",
        "@radix-ui/react-context-menu": "^2.2.15",
        "@radix-ui/react-dialog": "^1.1.14",
        "@radix-ui/react-dropdown-menu": "^2.1.15",
        "@radix-ui/react-hover-card": "^1.1.14",
        "@radix-ui/react-label": "^2.1.7",
        "@radix-ui/react-menubar": "^1.1.15",
        "@radix-ui/react-navigation-menu": "^1.2.13",
        "@radix-ui/react-popover": "^1.1.14",
        "@radix-ui/react-progress": "^1.1.7",
        "@radix-ui/react-radio-group": "^1.3.7",
        "@radix-ui/react-scroll-area": "^1.2.9",
        "@radix-ui/react-select": "^2.2.5",
        "@radix-ui/react-separator": "^1.1.7",
        "@radix-ui/react-slider": "^1.3.5",
        "@radix-ui/react-slot": "^1.2.3",
        "@radix-ui/react-switch": "^1.2.5",
        "@radix-ui/react-tabs": "^1.1.12",
        "@radix-ui/react-toast": "^1.2.14",
        "@radix-ui/react-toggle": "^1.1.9",
        "@radix-ui/react-toggle-group": "^1.1.10",
        "@radix-ui/react-tooltip": "^1.2.7",
        "@tanstack/react-table": "^8.21.3",
        "axios": "^1.10.0",
        "class-variance-authority": "^0.7.1",
        "clsx": "^2.1.1",
        "cmdk": "^1.1.1",
        "date-fns": "^4.1.0",
        "embla-carousel-react": "^8.6.0",
        "input-otp": "^1.4.2",
        "lucide-react": "^0.516.0",
        "next": "14.2.3",
        "next-themes": "^0.4.6",
        "react": "^18",
        "react-day-picker": "^9.7.0",
        "react-dom": "^18",
        "react-hook-form": "^7.58.1",
        "react-resizable-panels": "^3.0.3",
        "recharts": "^2.15.3",
        "sonner": "^2.0.5",
        "tailwind-merge": "^3.3.1",
        "tailwindcss-animate": "^1.0.7",
        "uuid": "^9.0.1",
        "vaul": "^1.1.2",
        "zod": "^3.25.67"
    },
    "devDependencies": {
        "autoprefixer": "^10.4.19",
        "globals": "^16.2.0",
        "postcss": "^8",
        "tailwindcss": "^3.4.1"
    }
}
EOF

# Configuration des variables d'environnement
sudo tee .env.local > /dev/null << 'EOF'
# Configuration Gmail pour le formulaire de contact
GMAIL_USER=votre-email@gmail.com
GMAIL_APP_PASSWORD=votre-mot-de-passe-app
GMAIL_RECIPIENT=votre-email@gmail.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
EOF

# Création de la structure des répertoires
sudo mkdir -p app/api/contact
sudo mkdir -p components/ui
sudo mkdir -p lib/utils

# Configuration Tailwind
sudo tee tailwind.config.js > /dev/null << 'EOF'
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
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
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
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
EOF

# Configuration PostCSS
sudo tee postcss.config.js > /dev/null << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Configuration Next.js
sudo tee next.config.js > /dev/null << 'EOF'
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
EOF

# Création des styles globaux
sudo mkdir -p app
sudo tee app/globals.css > /dev/null << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 217.2 91.2% 59.8%;
    --primary-foreground: 222.2 84% 4.9%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 224.3 76.3% 94.1%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF

# Changement des permissions
sudo chown -R $USER:$USER /var/www/getyoursite

# Installation des dépendances
npm install

# Build de production  
npm run build
```

### Étape 3 : Démarrage et configuration
```bash
# Installation de PM2 pour la gestion des processus
sudo npm install -g pm2

# Configuration PM2
sudo tee ecosystem.config.js > /dev/null << 'EOF'
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
EOF

# Démarrage avec PM2
pm2 start ecosystem.config.js
pm2 startup
pm2 save

# Configuration Nginx
sudo tee /etc/nginx/sites-available/getyoursite > /dev/null << 'EOF'
server {
    listen 80;
    server_name getyoursite.com www.getyoursite.com;  # Remplacez par votre domaine
    
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
EOF

# Activation du site
sudo ln -s /etc/nginx/sites-available/getyoursite /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx
```

## 🎉 C'est terminé !

Votre site GetYourSite est accessible sur :
- **Local** : http://localhost:3000
- **Domaine** : http://votre-domaine.com

## 📧 Configuration Email (Important)

Pour que le formulaire de contact fonctionne, éditez le fichier `.env.local` :

```bash
sudo nano /var/www/getyoursite/.env.local
```

Remplacez par vos vraies informations Gmail :
```env
GMAIL_USER=votre-email@gmail.com
GMAIL_APP_PASSWORD=votre-mot-de-passe-application-16-caracteres
GMAIL_RECIPIENT=votre-email@gmail.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
```

**Comment obtenir le mot de passe d'application Gmail :**
1. Allez dans votre compte Google → Sécurité
2. Activez la vérification en 2 étapes si ce n'est pas fait
3. Allez dans "Mots de passe des applications"
4. Sélectionnez "Courrier" et donnez un nom (ex: "Site GetYourSite")
5. Google génèrera un mot de passe de 16 caractères

Puis redémarrez :
```bash
pm2 restart getyoursite
```

## 🔧 Commandes de gestion

### Gestion PM2
```bash
# Voir le statut
pm2 status

# Redémarrer
pm2 restart getyoursite

# Voir les logs
pm2 logs getyoursite

# Arrêter
pm2 stop getyoursite

# Supprimer de PM2
pm2 delete getyoursite
```

### Mise à jour du site
```bash
cd /var/www/getyoursite
git pull  # Si vous utilisez Git
npm install
npm run build
pm2 restart getyoursite
```

## 🛡️ Sécurité (Recommandé)

### SSL avec Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com
```

### Firewall
```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw --force enable
```

### Sauvegardes automatiques
```bash
# Créer un script de sauvegarde
sudo tee /usr/local/bin/backup-getyoursite.sh > /dev/null << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/getyoursite"
mkdir -p $BACKUP_DIR

# Sauvegarde des fichiers
tar -czf $BACKUP_DIR/getyoursite_$DATE.tar.gz -C /var/www getyoursite

# Garder seulement les 7 dernières sauvegardes
find $BACKUP_DIR -name "getyoursite_*.tar.gz" -mtime +7 -delete
EOF

sudo chmod +x /usr/local/bin/backup-getyoursite.sh

# Ajouter au cron (sauvegarde quotidienne à 2h du matin)
echo "0 2 * * * /usr/local/bin/backup-getyoursite.sh" | sudo crontab -
```

## 🚨 Dépannage

### Site ne démarre pas
```bash
# Vérifier les logs
pm2 logs getyoursite

# Vérifier les processus
pm2 status

# Redémarrer complètement
pm2 delete getyoursite
pm2 start ecosystem.config.js
```

### Erreur 502 Bad Gateway
```bash
# Vérifier que Next.js tourne
pm2 status

# Vérifier la configuration Nginx
sudo nginx -t
sudo systemctl restart nginx

# Vérifier les ports
sudo netstat -tulpn | grep :3000
```

### Problème de permissions
```bash
# Corriger les permissions
sudo chown -R $USER:$USER /var/www/getyoursite
sudo chmod -R 755 /var/www/getyoursite
```

### Erreur de mémoire
```bash
# Augmenter la limite mémoire de Node.js
# Modifier ecosystem.config.js
sudo nano /var/www/getyoursite/ecosystem.config.js

# Ajouter dans env:
NODE_OPTIONS: '--max-old-space-size=2048'

# Puis redémarrer
pm2 restart getyoursite
```

### Problème d'email
```bash
# Vérifier les variables d'environnement
cat /var/www/getyoursite/.env.local

# Tester l'envoi d'email
pm2 logs getyoursite --lines 50
```

## 📋 Checklist finale

- [ ] Node.js 18+ installé (`node --version`)
- [ ] Dépendances installées (`npm install` réussi)
- [ ] Site buildé avec succès (`npm run build`)
- [ ] PM2 démarre le site (`pm2 status` montre "online")
- [ ] Nginx configuré et redémarré (`sudo nginx -t`)
- [ ] Variables d'environnement email configurées
- [ ] Nom de domaine pointé vers le serveur IP
- [ ] SSL configuré (optionnel mais recommandé)
- [ ] Firewall activé et configuré
- [ ] Sauvegardes automatiques configurées

## 🎯 Fonctionnalités de GetYourSite

✅ **Site vitrine professionnel**  
✅ **Formulaire de contact avec envoi Gmail**  
✅ **Design responsive moderne**  
✅ **Optimisé SEO et performances**  
✅ **Portfolio des réalisations**  
✅ **Section services détaillée**  
✅ **Navigation fluide avec ancres**  
✅ **Animations et effets modernes**

## 📊 Monitoring et maintenance

### Surveillance avec PM2 Plus (optionnel)
```bash
# Installation de PM2 Plus pour monitoring avancé
pm2 install pm2-server-monit
```

### Logs et monitoring
```bash
# Voir les logs en temps réel
pm2 logs getyoursite --lines 100

# Monitoring des ressources
pm2 monit

# Statistiques
pm2 show getyoursite
```

## 🔄 Processus de mise à jour

1. **Sauvegarde** : `sudo /usr/local/bin/backup-getyoursite.sh`
2. **Arrêt** : `pm2 stop getyoursite`
3. **Mise à jour du code** : `git pull` ou copie manuelle
4. **Installation** : `npm install`
5. **Build** : `npm run build`
6. **Redémarrage** : `pm2 start getyoursite`
7. **Vérification** : `pm2 status`

---

**Votre site GetYourSite est maintenant en production ! 🚀**

*Pour toute question ou problème, vérifiez d'abord les logs avec `pm2 logs getyoursite`*

## 📞 Support

En cas de problème :
1. Vérifiez les logs PM2 : `pm2 logs getyoursite`
2. Vérifiez le statut des services : `pm2 status` et `sudo systemctl status nginx`
3. Testez la configuration Nginx : `sudo nginx -t`
4. Vérifiez les ports : `sudo netstat -tulpn | grep :3000`
5. Consultez cette documentation pour le dépannage

---

*Documentation créée pour GetYourSite - Agence de création de sites web*