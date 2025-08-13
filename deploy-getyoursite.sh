#!/bin/bash

# 🚀 SCRIPT DE DÉPLOIEMENT AUTOMATIQUE GETYOURSITE
# Script tout-en-un pour Ubuntu Server 24.04
# Évite complètement les erreurs EOF et 404

set -e  # Arrêt en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Fonctions d'affichage
print_header() {
    echo -e "\n${PURPLE}===============================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}===============================================${NC}\n"
}

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

# Vérification des privilèges root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Ce script doit être exécuté en tant que root"
        echo "Utilisez: sudo ./deploy-getyoursite.sh"
        exit 1
    fi
}

# Demander les informations Gmail
get_gmail_info() {
    print_header "CONFIGURATION GMAIL (OPTIONNELLE)"
    echo "Pour que le formulaire de contact fonctionne, vous pouvez configurer Gmail :"
    echo "Ou appuyez sur Entrée pour ignorer (vous pourrez le faire plus tard)"
    echo ""
    
    read -p "Votre email Gmail (optionnel): " GMAIL_USER
    
    if [ ! -z "$GMAIL_USER" ]; then
        echo ""
        echo "Pour obtenir le mot de passe d'application :"
        echo "1. Allez sur myaccount.google.com"
        echo "2. Sécurité > Vérification en 2 étapes (activez-la)"
        echo "3. Mots de passe des applications > Générer"
        echo ""
        read -p "Mot de passe d'application Gmail (16 caractères): " GMAIL_APP_PASSWORD
        read -p "Email de réception (par défaut même que l'expéditeur): " GMAIL_RECIPIENT
        
        if [ -z "$GMAIL_RECIPIENT" ]; then
            GMAIL_RECIPIENT="$GMAIL_USER"
        fi
    else
        GMAIL_USER="votre-email@gmail.com"
        GMAIL_APP_PASSWORD="votre-mot-de-passe-app-16-caracteres"
        GMAIL_RECIPIENT="votre-email@gmail.com"
        print_warning "Configuration Gmail ignorée. Vous pourrez la faire plus tard."
    fi
}

# Installation système
install_system() {
    print_header "INSTALLATION SYSTÈME"
    
    print_step "Mise à jour du système..."
    apt update && apt upgrade -y
    
    print_step "Installation de Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs nginx git curl
    
    print_step "Installation de PM2..."
    npm install -g pm2
    
    # Vérification des versions
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_success "Node.js $NODE_VERSION installé"
    print_success "NPM $NPM_VERSION installé"
    print_success "PM2 installé"
}

# Création de la structure du projet
create_project_structure() {
    print_header "CRÉATION DE LA STRUCTURE DU PROJET"
    
    print_step "Création du répertoire principal..."
    rm -rf /var/www/getyoursite 2>/dev/null || true
    mkdir -p /var/www/getyoursite
    cd /var/www/getyoursite
    
    print_step "Création de la structure des dossiers..."
    mkdir -p app/api/contact
    mkdir -p components/ui
    mkdir -p lib
    
    print_success "Structure créée dans /var/www/getyoursite"
}

# Création des fichiers de configuration
create_config_files() {
    print_header "CRÉATION DES FICHIERS DE CONFIGURATION"
    
    print_step "Création de package.json..."
    cat > package.json << 'PACKAGE_JSON_END'
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
PACKAGE_JSON_END

    print_step "Création de next.config.js..."
    cat > next.config.js << 'NEXTCONFIG_END'
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
NEXTCONFIG_END

    print_step "Création de tailwind.config.js..."
    cat > tailwind.config.js << 'TAILWIND_END'
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
        secondary: {
          DEFAULT: "hsl(210 40% 96%)",
          foreground: "hsl(222.2 84% 4.9%)",
        },
        muted: {
          DEFAULT: "hsl(210 40% 96%)",
          foreground: "hsl(215.4 16.3% 46.9%)",
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
TAILWIND_END

    print_step "Création de postcss.config.js..."
    cat > postcss.config.js << 'POSTCSS_END'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSS_END

    print_step "Création du fichier .env.local..."
    cat > .env.local << ENV_END
GMAIL_USER=$GMAIL_USER
GMAIL_APP_PASSWORD=$GMAIL_APP_PASSWORD
GMAIL_RECIPIENT=$GMAIL_RECIPIENT
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
ENV_END

    print_success "Fichiers de configuration créés"
}

# Création des fichiers utilitaires
create_utils() {
    print_header "CRÉATION DES FICHIERS UTILITAIRES"
    
    print_step "Création de lib/utils.js..."
    cat > lib/utils.js << 'UTILS_END'
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs) {
  return twMerge(clsx(inputs))
}
UTILS_END

    print_step "Création de app/globals.css..."
    cat > app/globals.css << 'CSS_END'
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
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
  }
  
  body {
    background-color: hsl(var(--background));
    color: hsl(var(--foreground));
  }
}
CSS_END

    print_success "Fichiers utilitaires créés"
}

# Création des composants UI
create_ui_components() {
    print_header "CRÉATION DES COMPOSANTS UI"
    
    print_step "Création de components/ui/button.jsx..."
    cat > components/ui/button.jsx << 'BUTTON_END'
import React from "react"
import { cn } from "@/lib/utils"

export const Button = React.forwardRef(({ className, variant = "default", size = "default", ...props }, ref) => {
  const variants = {
    default: "bg-blue-600 text-white hover:bg-blue-700",
    outline: "border border-gray-300 bg-white hover:bg-gray-50 text-gray-700",
    ghost: "hover:bg-gray-100 text-gray-700"
  }
  
  const sizes = {
    default: "h-10 px-4 py-2",
    sm: "h-8 px-3 text-sm",
    lg: "h-12 px-8 text-lg"
  }
  
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none",
        variants[variant],
        sizes[size],
        className
      )}
      ref={ref}
      {...props}
    />
  )
})

Button.displayName = "Button"
BUTTON_END

    print_step "Création des autres composants UI..."
    
    # Card components
    cat > components/ui/card.jsx << 'CARD_END'
import React from "react"
import { cn } from "@/lib/utils"

export const Card = React.forwardRef(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("rounded-lg border bg-white shadow-sm", className)} {...props} />
))

export const CardHeader = React.forwardRef(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />
))

export const CardTitle = React.forwardRef(({ className, ...props }, ref) => (
  <h3 ref={ref} className={cn("text-lg font-semibold leading-none tracking-tight", className)} {...props} />
))

export const CardDescription = React.forwardRef(({ className, ...props }, ref) => (
  <p ref={ref} className={cn("text-sm text-gray-600", className)} {...props} />
))

export const CardContent = React.forwardRef(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
))

Card.displayName = "Card"
CardHeader.displayName = "CardHeader"
CardTitle.displayName = "CardTitle"
CardDescription.displayName = "CardDescription"
CardContent.displayName = "CardContent"
CARD_END

    # Input component
    cat > components/ui/input.jsx << 'INPUT_END'
import React from "react"
import { cn } from "@/lib/utils"

export const Input = React.forwardRef(({ className, type, ...props }, ref) => {
  return (
    <input
      type={type}
      className={cn(
        "flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50",
        className
      )}
      ref={ref}
      {...props}
    />
  )
})

Input.displayName = "Input"
INPUT_END

    # Textarea component
    cat > components/ui/textarea.jsx << 'TEXTAREA_END'
import React from "react"
import { cn } from "@/lib/utils"

export const Textarea = React.forwardRef(({ className, ...props }, ref) => {
  return (
    <textarea
      className={cn(
        "flex min-h-[80px] w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50",
        className
      )}
      ref={ref}
      {...props}
    />
  )
})

Textarea.displayName = "Textarea"
TEXTAREA_END

    # Badge component
    cat > components/ui/badge.jsx << 'BADGE_END'
import React from "react"
import { cn } from "@/lib/utils"

export const Badge = React.forwardRef(({ className, variant = "default", ...props }, ref) => {
  const variants = {
    default: "bg-blue-600 text-white hover:bg-blue-700",
    secondary: "bg-gray-100 text-gray-900 hover:bg-gray-200",
    outline: "text-gray-700 border border-gray-300"
  }
  
  return (
    <div
      ref={ref}
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold transition-colors",
        variants[variant],
        className
      )}
      {...props}
    />
  )
})

Badge.displayName = "Badge"
BADGE_END

    print_success "Composants UI créés"
}

# Création du layout et de l'API
create_app_files() {
    print_header "CRÉATION DES FICHIERS PRINCIPAUX"
    
    print_step "Création de app/layout.js..."
    cat > app/layout.js << 'LAYOUT_END'
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
LAYOUT_END

    print_step "Création de l'API de contact..."
    cat > app/api/contact/route.js << 'API_END'
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

    if (!process.env.GMAIL_USER || process.env.GMAIL_USER === 'votre-email@gmail.com') {
      console.log('Contact form submission (Gmail not configured):', {
        name, email, subject, message, timestamp: new Date().toISOString()
      });
      
      return NextResponse.json({
        success: true,
        message: 'Message reçu ! Nous vous recontacterons bientôt.',
        note: 'Configuration Gmail requise pour l\'envoi automatique'
      });
    }

    try {
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
      
    } catch (emailError) {
      console.error('Email sending error:', emailError);
      return NextResponse.json(
        { error: 'Erreur lors de l\'envoi de l\'email' },
        { status: 500 }
      );
    }

  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Erreur serveur' },
      { status: 500 }
    );
  }
}
API_END

    print_success "Fichiers principaux créés"
}

# Téléchargement du fichier page.js principal (trop volumineux pour le script)
download_page_file() {
    print_header "CRÉATION DE LA PAGE PRINCIPALE"
    
    print_step "Création de app/page.js..."
    
    # Créer une version simplifiée pour test
    cat > app/page.js << 'PAGE_END'
'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Code2, Rocket, RefreshCw, Mail, Phone, MapPin, Star, Users, Globe, Zap, Menu, X } from 'lucide-react'

export default function HomePage() {
  const [contactForm, setContactForm] = useState({ name: '', email: '', subject: '', message: '' })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [submitStatus, setSubmitStatus] = useState(null)

  const handleContactSubmit = async (e) => {
    e.preventDefault()
    
    if (!contactForm.name || !contactForm.email || !contactForm.message) {
      setSubmitStatus({ type: 'error', message: 'Veuillez remplir tous les champs requis' })
      return
    }

    setIsSubmitting(true)
    setSubmitStatus(null)

    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(contactForm)
      })

      const data = await response.json()

      if (response.ok) {
        setContactForm({ name: '', email: '', subject: '', message: '' })
        setSubmitStatus({ type: 'success', message: 'Votre message a été envoyé avec succès!' })
      } else {
        setSubmitStatus({ type: 'error', message: data.error || 'Erreur lors de l\'envoi' })
      }
    } catch (error) {
      setSubmitStatus({ type: 'error', message: 'Une erreur est survenue' })
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleInputChange = (e) => {
    setContactForm({ ...contactForm, [e.target.name]: e.target.value })
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-slate-200 sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <div className="text-2xl font-bold text-slate-800">
              Get<span className="text-blue-600">Your</span>Site
            </div>
            <div className="flex space-x-8">
              <a href="#accueil" className="text-slate-600 hover:text-blue-600">Accueil</a>
              <a href="#services" className="text-slate-600 hover:text-blue-600">Services</a>
              <a href="#contact" className="text-slate-600 hover:text-blue-600">Contact</a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section id="accueil" className="py-20 px-4">
        <div className="container mx-auto text-center max-w-4xl">
          <h1 className="text-4xl md:text-6xl font-bold text-slate-800 mb-6">
            Créez votre <span className="text-blue-600">présence en ligne</span>
          </h1>
          <p className="text-xl text-slate-600 mb-8">
            Expert en conception, déploiement et refonte de sites web pour particuliers et professionnels.
          </p>
          <Button size="lg" className="bg-blue-600 hover:bg-blue-700">
            Découvrir nos services
          </Button>
        </div>
      </section>

      {/* Services */}
      <section id="services" className="py-20 px-4 bg-white">
        <div className="container mx-auto max-w-6xl">
          <h2 className="text-3xl font-bold text-center mb-12">Nos Services</h2>
          <div className="grid md:grid-cols-3 gap-8">
            <Card>
              <CardHeader className="text-center">
                <Code2 className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                <CardTitle>Conception Web</CardTitle>
                <CardDescription>Sites web modernes et performants</CardDescription>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="text-center">
                <Rocket className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                <CardTitle>Déploiement</CardTitle>
                <CardDescription>Mise en ligne professionnelle</CardDescription>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="text-center">
                <RefreshCw className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                <CardTitle>Refonte</CardTitle>
                <CardDescription>Modernisation de sites existants</CardDescription>
              </CardHeader>
            </Card>
          </div>
        </div>
      </section>

      {/* Contact */}
      <section id="contact" className="py-20 px-4">
        <div className="container mx-auto max-w-4xl">
          <h2 className="text-3xl font-bold text-center mb-12">Contactez-nous</h2>
          <div className="grid md:grid-cols-2 gap-8">
            <div className="space-y-4">
              <div className="flex items-center space-x-4">
                <Mail className="w-6 h-6 text-blue-600" />
                <span>contact@getyoursite.com</span>
              </div>
              <div className="flex items-center space-x-4">
                <Phone className="w-6 h-6 text-blue-600" />
                <span>+33 (0)1 23 45 67 89</span>
              </div>
            </div>
            
            <Card>
              <CardHeader>
                <CardTitle>Envoyez-nous un message</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleContactSubmit} className="space-y-4">
                  <Input name="name" value={contactForm.name} onChange={handleInputChange} placeholder="Votre nom" required />
                  <Input name="email" type="email" value={contactForm.email} onChange={handleInputChange} placeholder="votre@email.com" required />
                  <Input name="subject" value={contactForm.subject} onChange={handleInputChange} placeholder="Sujet" />
                  <Textarea name="message" value={contactForm.message} onChange={handleInputChange} placeholder="Votre message..." rows={4} required />
                  
                  {submitStatus && (
                    <div className={`p-3 rounded text-sm ${submitStatus.type === 'success' ? 'bg-green-50 text-green-800' : 'bg-red-50 text-red-800'}`}>
                      {submitStatus.message}
                    </div>
                  )}
                  
                  <Button type="submit" className="w-full" disabled={isSubmitting}>
                    {isSubmitting ? 'Envoi...' : 'Envoyer'}
                  </Button>
                </form>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-white py-12 px-4">
        <div className="container mx-auto max-w-6xl text-center">
          <div className="text-2xl font-bold mb-4">
            Get<span className="text-blue-400">Your</span>Site
          </div>
          <p className="text-slate-300">© 2024 GetYourSite. Tous droits réservés.</p>
        </div>
      </footer>
    </div>
  )
}
PAGE_END

    print_success "Page principale créée (version simplifiée)"
    print_warning "Vous pouvez remplacer app/page.js par la version complète plus tard"
}

# Installation des dépendances et build
install_and_build() {
    print_header "INSTALLATION ET BUILD"
    
    print_step "Installation des dépendances npm..."
    npm install || {
        print_error "Échec de l'installation npm"
        exit 1
    }
    
    print_step "Build de production..."
    npm run build || {
        print_error "Échec du build"
        print_warning "Vérifiez les erreurs ci-dessus"
        exit 1
    }
    
    print_success "Build réalisé avec succès"
}

# Configuration PM2
setup_pm2() {
    print_header "CONFIGURATION PM2"
    
    print_step "Création de la configuration PM2..."
    cat > ecosystem.config.js << 'PM2_END'
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
PM2_END

    print_step "Arrêt des processus PM2 existants..."
    pm2 delete getyoursite 2>/dev/null || true
    
    print_step "Démarrage de l'application..."
    pm2 start ecosystem.config.js
    
    print_step "Configuration du démarrage automatique..."
    pm2 startup systemd --uid root --gid root -hp /root >/dev/null 2>&1 || true
    pm2 save
    
    print_success "PM2 configuré et démarré"
}

# Configuration Nginx
setup_nginx() {
    print_header "CONFIGURATION NGINX"
    
    print_step "Arrêt de Nginx..."
    systemctl stop nginx 2>/dev/null || true
    
    print_step "Création de la configuration Nginx..."
    cat > /etc/nginx/sites-available/getyoursite << 'NGINX_END'
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
        
        # Headers CORS (optionnel)
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
    }
    
    # Gestion des erreurs
    error_page 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
NGINX_END

    print_step "Activation du site..."
    ln -sf /etc/nginx/sites-available/getyoursite /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    print_step "Test de la configuration..."
    nginx -t || {
        print_error "Erreur dans la configuration Nginx"
        exit 1
    }
    
    print_step "Démarrage de Nginx..."
    systemctl start nginx
    systemctl enable nginx
    
    print_success "Nginx configuré et démarré"
}

# Configuration du firewall
setup_firewall() {
    print_header "CONFIGURATION FIREWALL"
    
    print_step "Configuration UFW..."
    ufw --force enable
    ufw allow ssh
    ufw allow 'Nginx Full'
    ufw allow 80
    ufw allow 443
    
    print_success "Firewall configuré"
}

# Ajustement des permissions
fix_permissions() {
    print_header "AJUSTEMENT DES PERMISSIONS"
    
    print_step "Configuration des permissions..."
    chown -R www-data:www-data /var/www/getyoursite
    chmod -R 755 /var/www/getyoursite
    
    print_success "Permissions ajustées"
}

# Tests finaux
run_tests() {
    print_header "TESTS FINAUX"
    
    print_step "Test du statut PM2..."
    pm2 status
    
    print_step "Test de l'API..."
    sleep 3
    if curl -s http://localhost:3000/api/contact | grep -q "active"; then
        print_success "API fonctionnelle"
    else
        print_warning "L'API pourrait avoir des problèmes"
    fi
    
    print_step "Test du site principal..."
    if curl -s http://localhost:3000 | grep -q "GetYourSite"; then
        print_success "Site principal fonctionnel"
    else
        print_warning "Le site principal pourrait avoir des problèmes"
    fi
    
    print_step "Vérification des logs..."
    echo "Derniers logs PM2:"
    pm2 logs getyoursite --lines 5
}

# Affichage des informations finales
show_final_info() {
    print_header "INSTALLATION TERMINÉE"
    
    echo -e "${GREEN}🎉 GetYourSite est maintenant déployé !${NC}\n"
    
    echo "📋 INFORMATIONS D'ACCÈS :"
    echo "   • Site web : http://$(curl -s ifconfig.me 2>/dev/null || echo "VOTRE-IP-SERVEUR")"
    echo "   • Site local : http://localhost"
    echo "   • API test : http://localhost/api/contact"
    echo ""
    
    echo "🔧 COMMANDES UTILES :"
    echo "   • Statut PM2 : pm2 status"
    echo "   • Logs PM2 : pm2 logs getyoursite"
    echo "   • Redémarrer : pm2 restart getyoursite"
    echo "   • Statut Nginx : systemctl status nginx"
    echo ""
    
    if [ "$GMAIL_USER" != "votre-email@gmail.com" ]; then
        echo -e "${GREEN}✅ Gmail configuré pour : $GMAIL_USER${NC}"
    else
        echo -e "${YELLOW}⚠️  Configuration Gmail requise pour le formulaire de contact${NC}"
        echo "   Modifiez le fichier : /var/www/getyoursite/.env.local"
        echo "   Puis redémarrez : pm2 restart getyoursite"
    fi
    
    echo ""
    echo "📁 FICHIERS DU PROJET : /var/www/getyoursite"
    echo ""
    
    print_success "Déploiement terminé avec succès !"
}

# FONCTION PRINCIPALE
main() {
    print_header "DÉPLOIEMENT AUTOMATIQUE GETYOURSITE"
    echo "Ce script va installer automatiquement GetYourSite sur Ubuntu Server 24.04"
    echo ""
    
    read -p "Continuer l'installation ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation annulée."
        exit 0
    fi
    
    # Exécution de toutes les étapes
    check_root
    get_gmail_info
    install_system
    create_project_structure
    create_config_files
    create_utils
    create_ui_components
    create_app_files
    download_page_file
    install_and_build
    setup_pm2
    setup_nginx
    setup_firewall
    fix_permissions
    run_tests
    show_final_info
}

# Gestion des erreurs
trap 'print_error "Une erreur est survenue à la ligne $LINENO"; exit 1' ERR

# Lancement du script
main "$@"