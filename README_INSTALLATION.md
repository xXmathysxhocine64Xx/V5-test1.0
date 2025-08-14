# 🚀 GetYourSite - Guide d'Installation Ubuntu 24.04

## Installation Ultra-Simple en Une Commande

### Option 1: Installation Automatique (Recommandée)

```bash
# Télécharger et exécuter le script d'installation
curl -fsSL https://raw.githubusercontent.com/votre-repo/getyoursite/main/setup-getyoursite.sh | sudo bash
```

### Option 2: Installation Manuelle

```bash
# 1. Télécharger le script
wget https://raw.githubusercontent.com/votre-repo/getyoursite/main/setup-getyoursite.sh

# 2. Rendre le script exécutable
chmod +x setup-getyoursite.sh

# 3. Exécuter l'installation
sudo ./setup-getyoursite.sh
```

### Option 3: Depuis les Sources Locales

Si vous avez le projet GetYourSite localement :

```bash
# Naviguer vers le répertoire du projet
cd /path/to/getyoursite

# Exécuter le script d'installation
sudo ./setup-getyoursite.sh
```

## 🔧 Ce que fait le script automatiquement

### ✅ Configuration Système
- Vérification Ubuntu 24.04 LTS
- Mise à jour complète du système
- Installation des outils de base

### ✅ Installation des Technologies
- **Node.js 18** (dernière version LTS)
- **Yarn** (gestionnaire de paquets)
- **PM2** (gestionnaire de processus)
- **Nginx** (serveur web)

### ✅ Sécurité Intégrée
- **UFW Firewall** configuré
- **Fail2ban** installé
- **Headers de sécurité** Nginx
- **Permissions** optimisées

### ✅ Configuration Avancée
- **Sauvegardes automatiques** quotidiennes
- **Logs centralisés** PM2 et Nginx
- **Monitoring** intégré
- **Redémarrage automatique** des services

### ✅ Optimisations Performance
- **Compression Gzip** activée
- **Mise en cache** configurée
- **Build de production** optimisé

## 📧 Configuration Gmail (Optionnelle)

Le script vous demandera si vous voulez configurer le formulaire de contact :

### Étapes pour obtenir un mot de passe d'application Gmail :

1. **Aller sur** → [myaccount.google.com](https://myaccount.google.com)
2. **Sécurité** → Vérification en 2 étapes *(l'activer si nécessaire)*
3. **Sécurité** → Mots de passe des applications
4. **Sélectionner** "Courrier" et donner un nom (ex: "Site GetYourSite")
5. **Copier** le mot de passe généré (16 caractères)

Vous pouvez aussi configurer Gmail plus tard en modifiant :
```bash
sudo nano /var/www/getyoursite/.env.local
```

## 🎯 Après l'Installation

### Votre site sera accessible sur :
- **Local** : http://localhost
- **Public** : http://votre-ip-serveur
- **API Test** : http://votre-ip-serveur/api/contact

### Commandes de gestion :
```bash
# Voir le statut
pm2 status

# Redémarrer le site
pm2 restart getyoursite

# Voir les logs
pm2 logs getyoursite

# Monitoring en temps réel
pm2 monit
```

## 🛡️ Certificat SSL (HTTPS)

Pour activer HTTPS avec un certificat gratuit :

```bash
# Installer Certbot
sudo apt install certbot python3-certbot-nginx

# Obtenir le certificat (remplacer par votre domaine)
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com
```

## 🔄 Mise à Jour du Site

Pour mettre à jour votre site GetYourSite :

```bash
cd /var/www/getyoursite

# Si vous utilisez Git
git pull

# Ou copier vos nouveaux fichiers manuellement

# Puis rebuilder et redémarrer
yarn install
yarn build
pm2 restart getyoursite
```

## 🆘 Dépannage

### Site ne démarre pas :
```bash
# Vérifier les logs
pm2 logs getyoursite

# Redémarrer complètement
pm2 delete getyoursite
cd /var/www/getyoursite
pm2 start ecosystem.config.js
```

### Erreur 502 Bad Gateway :
```bash
# Vérifier que Next.js fonctionne
pm2 status

# Vérifier Nginx
sudo nginx -t
sudo systemctl restart nginx
```

### Problème de permissions :
```bash
sudo chown -R www-data:www-data /var/www/getyoursite
sudo chmod -R 755 /var/www/getyoursite
```

## 📊 Fonctionnalités Incluses

✅ **Site vitrine professionnel**  
✅ **Formulaire de contact Gmail**  
✅ **Design responsive moderne**  
✅ **Optimisé SEO et performances**  
✅ **Portfolio des réalisations**  
✅ **Section services complète**  
✅ **Navigation fluide avec ancres**  
✅ **Animations et effets visuels**  
✅ **Mode sombre/clair** *(si configuré)*  
✅ **Optimisations de sécurité**

## 📞 Support

En cas de problème :

1. **Vérifier les logs** : `pm2 logs getyoursite`
2. **Status des services** : `pm2 status` et `sudo systemctl status nginx`
3. **Test de configuration** : `sudo nginx -t`
4. **Vérifier les ports** : `sudo netstat -tulpn | grep :3000`

---

**🚀 Votre site GetYourSite sera opérationnel en moins de 10 minutes !**

*Script d'installation testé et optimisé pour Ubuntu Server 24.04 LTS*