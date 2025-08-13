# 🚀 GetYourSite - Installation SIMPLIFIÉE (SANS ERREUR EOF)

## ⚠️ SOLUTION POUR ÉVITER LES ERREURS 404 ET EOF

Cette méthode évite complètement les erreurs de copier-coller avec EOF.

---

## 📥 MÉTHODE 1 : Téléchargement des scripts

Sur votre serveur Ubuntu, exécutez :

```bash
# Téléchargement des scripts (à adapter selon votre méthode de transfert)
curl -O https://votre-serveur.com/install-getyoursite.sh
curl -O https://votre-serveur.com/create-app-files.sh
curl -O https://votre-serveur.com/app-page.txt
curl -O https://votre-serveur.com/api-route.txt

# Ou utilisez scp/sftp pour transférer les fichiers
```

---

## 📥 MÉTHODE 2 : Installation manuelle (RECOMMANDÉE)

### Étape 1 : Préparation système
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs nginx git
sudo npm install -g pm2
```

### Étape 2 : Création du projet
```bash
sudo mkdir -p /var/www/getyoursite
cd /var/www/getyoursite
sudo chown -R $USER:$USER /var/www/getyoursite
```

### Étape 3 : Fichiers de base (COPIE SIMPLE)

**A) Créer package.json :**
```bash
nano package.json
```
Copiez-collez ce contenu :
```json
{
    "name": "getyoursite",
    "version": "1.0.0",
    "private": true,
    "scripts": {
        "dev": "next dev",
        "build": "next build",
        "start": "next start"
    },
    "dependencies": {
        "@radix-ui/react-slot": "^1.2.3",
        "class-variance-authority": "^0.7.1",
        "clsx": "^2.1.1",
        "lucide-react": "^0.516.0",
        "next": "14.2.3",
        "nodemailer": "^6.9.8",
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
```

**B) Créer next.config.js :**
```bash
nano next.config.js
```
```javascript
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
```

**C) Créer tailwind.config.js :**
```bash
nano tailwind.config.js
```
```javascript
module.exports = {
  darkMode: ["class"],
  content: [
    './app/**/*.{js,jsx}',
    './components/**/*.{js,jsx}',
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(214.3 31.8% 91.4%)",
        background: "hsl(0 0% 100%)",
        foreground: "hsl(222.2 84% 4.9%)",
        primary: {
          DEFAULT: "hsl(221.2 83.2% 53.3%)",
          foreground: "hsl(210 40% 98%)",
        },
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
```

**D) Créer postcss.config.js :**
```bash
nano postcss.config.js
```
```javascript
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

**E) Variables d'environnement :**
```bash
nano .env.local
```
```env
GMAIL_USER=votre-email@gmail.com
GMAIL_APP_PASSWORD=votre-mot-de-passe-app-16-caracteres
GMAIL_RECIPIENT=votre-email@gmail.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
```

### Étape 4 : Structure des dossiers
```bash
mkdir -p app/api/contact
mkdir -p components/ui
mkdir -p lib
```

### Étape 5 : Fichiers CSS et Utils

**app/globals.css :**
```bash
nano app/globals.css
```
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
  }
  body {
    background-color: hsl(var(--background));
    color: hsl(var(--foreground));
  }
}
```

**lib/utils.js :**
```bash
nano lib/utils.js
```
```javascript
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs) {
  return twMerge(clsx(inputs))
}
```

### Étape 6 : Composants UI simplifiés

**components/ui/button.jsx :**
```bash
nano components/ui/button.jsx
```
```jsx
import React from "react"
import { cn } from "@/lib/utils"

export const Button = React.forwardRef(({ className, variant = "default", size = "default", ...props }, ref) => {
  const variants = {
    default: "bg-blue-600 text-white hover:bg-blue-700",
    outline: "border border-gray-300 bg-white hover:bg-gray-50",
    ghost: "hover:bg-gray-100"
  }
  
  const sizes = {
    default: "h-10 px-4 py-2",
    sm: "h-8 px-3 text-sm",
    lg: "h-12 px-8 text-lg"
  }
  
  return (
    <button
      className={cn("inline-flex items-center justify-center rounded-md font-medium transition-colors", variants[variant], sizes[size], className)}
      ref={ref}
      {...props}
    />
  )
})
```

**components/ui/card.jsx :**
```bash
nano components/ui/card.jsx
```
```jsx
import React from "react"
import { cn } from "@/lib/utils"

export const Card = React.forwardRef(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("rounded-lg border bg-white shadow-sm", className)} {...props} />
))

export const CardHeader = React.forwardRef(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />
))

export const CardTitle = React.forwardRef(({ className, ...props }, ref) => (
  <h3 ref={ref} className={cn("text-lg font-semibold", className)} {...props} />
))

export const CardDescription = React.forwardRef(({ className, ...props }, ref) => (
  <p ref={ref} className={cn("text-sm text-gray-600", className)} {...props} />
))

export const CardContent = React.forwardRef(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
))
```

**components/ui/input.jsx :**
```bash
nano components/ui/input.jsx
```
```jsx
import React from "react"
import { cn } from "@/lib/utils"

export const Input = React.forwardRef(({ className, type, ...props }, ref) => {
  return (
    <input
      type={type}
      className={cn("flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none", className)}
      ref={ref}
      {...props}
    />
  )
})
```

**components/ui/textarea.jsx :**
```bash
nano components/ui/textarea.jsx
```
```jsx
import React from "react"
import { cn } from "@/lib/utils"

export const Textarea = React.forwardRef(({ className, ...props }, ref) => {
  return (
    <textarea
      className={cn("flex min-h-[80px] w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none", className)}
      ref={ref}
      {...props}
    />
  )
})
```

**components/ui/badge.jsx :**
```bash
nano components/ui/badge.jsx
```
```jsx
import React from "react"
import { cn } from "@/lib/utils"

export const Badge = React.forwardRef(({ className, variant = "default", ...props }, ref) => {
  const variants = {
    default: "bg-blue-600 text-white",
    secondary: "bg-gray-100 text-gray-900",
  }
  
  return (
    <div ref={ref} className={cn("inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold", variants[variant], className)} {...props} />
  )
})
```

### Étape 7 : Fichiers principaux

**app/layout.js :**
```bash
nano app/layout.js
```
```jsx
import './globals.css'

export const metadata = {
  title: 'GetYourSite - Création de Sites Web',
  description: 'Expert en création de sites web professionels',
}

export default function RootLayout({ children }) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  )
}
```

**app/page.js :** 
```bash
nano app/page.js
```
Puis copiez tout le contenu du fichier `app-page.txt` que j'ai créé

**app/api/contact/route.js :**
```bash
mkdir -p app/api/contact
nano app/api/contact/route.js
```
Puis copiez tout le contenu du fichier `api-route.txt` que j'ai créé

### Étape 8 : Installation et build
```bash
npm install
npm run build
```

### Étape 9 : Configuration PM2
```bash
nano ecosystem.config.js
```
```javascript
module.exports = {
  apps: [{
    name: 'getyoursite',
    script: 'npm',
    args: 'start',
    instances: 1,
    autorestart: true,
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
```

### Étape 10 : Configuration Nginx
```bash
sudo nano /etc/nginx/sites-available/getyoursite
```
```nginx
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Étape 11 : Activation
```bash
sudo ln -s /etc/nginx/sites-available/getyoursite /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

pm2 start ecosystem.config.js
pm2 startup
pm2 save
```

---

## 🎯 Vérifications finales

1. **Test du build :** `npm run build` doit réussir
2. **Test PM2 :** `pm2 status` doit montrer "online"  
3. **Test Nginx :** `sudo nginx -t` doit être OK
4. **Test site :** `curl http://localhost:3000` doit répondre

## 🔧 Dépannage erreur 404

Si vous avez une erreur 404 :

```bash
# Vérifier que Next.js démarre
pm2 logs getyoursite

# Vérifier les fichiers requis
ls -la /var/www/getyoursite/app/
ls -la /var/www/getyoursite/app/page.js

# Reconstruire si nécessaire
cd /var/www/getyoursite
npm run build
pm2 restart getyoursite
```

## 📧 Configuration Gmail

N'oubliez pas de modifier `.env.local` avec vos vraies informations :

1. Activez la vérification en 2 étapes sur Google
2. Générez un mot de passe d'application 
3. Modifiez le fichier :
```bash
nano .env.local
```

4. Redémarrez :
```bash
pm2 restart getyoursite
```

---

**Cette méthode évite complètement les erreurs EOF et garantit un déploiement réussi !** 🚀