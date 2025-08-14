# 🚀 GetYourSite - Démarrage Rapide Ubuntu 24.04

## Installation Ultra-Rapide (5 minutes)

### 📥 Étape 1: Télécharger les fichiers

Connectez-vous à votre serveur Ubuntu 24.04 et exécutez :

```bash
# Créer un répertoire temporaire
mkdir -p ~/getyoursite-install
cd ~/getyoursite-install

# Télécharger les scripts (remplacez l'URL par la vôtre)
wget https://votre-serveur.com/setup-getyoursite.sh
wget https://votre-serveur.com/test-installation.sh

# Ou si vous avez les fichiers localement, utilisez scp :
# scp setup-getyoursite.sh user@serveur:~/getyoursite-install/
# scp test-installation.sh user@serveur:~/getyoursite-install/
```

### 🧪 Étape 2: Tester la compatibilité (optionnel)

```bash
# Rendre le script de test exécutable
chmod +x test-installation.sh

# Lancer le test de compatibilité
sudo ./test-installation.sh
```

Si le test passe ✅, continuez à l'étape 3.  
Si le test échoue ❌, corrigez les problèmes signalés.

### 🚀 Étape 3: Installation automatique

```bash
# Rendre le script d'installation exécutable
chmod +x setup-getyoursite.sh

# Lancer l'installation
sudo ./setup-getyoursite.sh
```

**C'est tout ! 🎉**

---

## 🎯 Que fait l'installation automatiquement ?

### ✅ Installation et Configuration
- **Système mis à jour** (Ubuntu packages)
- **Node.js 18** + Yarn + PM2 installés
- **Nginx** configuré comme reverse proxy
- **GetYourSite** installé dans `/var/www/getyoursite`
- **Firewall UFW** configuré et activé
- **Sauvegardes automatiques** programmées

### ✅ Sécurité
- Headers de sécurité Nginx
- Fail2ban installé
- Permissions optimisées
- Firewall configuré (ports 22, 80, 443)

### ✅ Services Automatiques
- **PM2** : Redémarrage automatique de l'app
- **Systemd** : Démarrage automatique au boot
- **Nginx** : Serveur web optimisé
- **Cron** : Sauvegardes quotidiennes à 2h

---

## 📧 Configuration Email (Pendant l'installation)

Le script vous demandera si vous voulez configurer Gmail :

### Option A: Configurer maintenant
1. Répondez `y` quand demandé
2. Entrez votre email Gmail
3. Entrez votre mot de passe d'application (voir ci-dessous)

### Option B: Configurer plus tard
1. Répondez `n` 
2. Le formulaire fonctionnera mais loggera les messages
3. Configurez plus tard dans `/var/www/getyoursite/.env.local`

### 🔑 Obtenir un mot de passe d'application Gmail :

1. **Aller sur** → https://myaccount.google.com
2. **Sécurité** → Vérification en 2 étapes *(l'activer)*
3. **Sécurité** → Mots de passe des applications
4. **App** : Courrier, **Appareil** : Autre (Site web)
5. **Copier** le mot de passe de 16 caractères

---

## 🌐 Accès à votre site

Après l'installation, votre site sera accessible :

### 🔗 URLs d'accès
```
Site principal : http://VOTRE-IP-SERVEUR
Test API      : http://VOTRE-IP-SERVEUR/api/contact
Admin local   : http://localhost (sur le serveur)
```

### 📱 Test rapide
```bash
# Tester l'API
curl http://localhost/api/contact

# Voir les logs
pm2 logs getyoursite

# Statut des services
pm2 status
sudo systemctl status nginx
```

---

## 🔧 Commandes de gestion essentielles

### PM2 (Gestion de l'application)
```bash
pm2 status              # Voir le statut
pm2 restart getyoursite # Redémarrer
pm2 logs getyoursite    # Voir les logs
pm2 monit               # Interface de monitoring
```

### Nginx (Serveur web)
```bash
sudo systemctl status nginx    # Statut
sudo systemctl restart nginx   # Redémarrer
sudo nginx -t                  # Tester la config
```

### Logs importants
```bash
# Logs de l'application
tail -f /var/log/pm2/getyoursite.log

# Logs Nginx
tail -f /var/log/nginx/getyoursite_access.log
tail -f /var/log/nginx/getyoursite_error.log
```

---

## 🛡️ Sécuriser avec HTTPS (Recommandé)

Après l'installation, ajoutez un certificat SSL gratuit :

```bash
# Installer Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtenir le certificat SSL (remplacer votre-domaine.com)
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com

# Le certificat se renouvelle automatiquement
```

---

## 🔄 Mise à jour de GetYourSite

Pour mettre à jour votre site avec de nouveaux fichiers :

```bash
# Aller dans le répertoire
cd /var/www/getyoursite

# Sauvegarder (optionnel)
sudo /usr/local/bin/backup-getyoursite.sh

# Mettre à jour les fichiers (git ou copie manuelle)
# git pull  # Si vous utilisez Git
# ou copier vos nouveaux fichiers

# Rebuilder et redémarrer
yarn install
yarn build
pm2 restart getyoursite
```

---

## 🆘 Résolution de problèmes

### Site inaccessible (502 Bad Gateway)
```bash
# Vérifier que l'app fonctionne
pm2 status
pm2 restart getyoursite

# Vérifier Nginx
sudo nginx -t
sudo systemctl restart nginx
```

### Application ne démarre pas
```bash
# Voir les erreurs
pm2 logs getyoursite --lines 50

# Redémarrer complètement
pm2 delete getyoursite
cd /var/www/getyoursite
pm2 start ecosystem.config.js
```

### Problème de permissions
```bash
sudo chown -R www-data:www-data /var/www/getyoursite
sudo chmod -R 755 /var/www/getyoursite
```

### Email ne fonctionne pas
```bash
# Vérifier la configuration
cat /var/www/getyoursite/.env.local

# Modifier la configuration
sudo nano /var/www/getyoursite/.env.local

# Redémarrer après modification
pm2 restart getyoursite
```

---

## 📊 Monitoring et Maintenance

### Vérifications quotidiennes
```bash
# Statut général
pm2 status && sudo systemctl status nginx

# Espace disque
df -h

# Logs récents
pm2 logs getyoursite --lines 20
```

### Sauvegardes
- **Automatiques** : Chaque jour à 2h du matin
- **Manuelles** : `sudo /usr/local/bin/backup-getyoursite.sh`
- **Localisation** : `/var/backups/getyoursite/`

### Mise à jour système
```bash
# Mise à jour mensuelle recommandée
sudo apt update && sudo apt upgrade -y
sudo systemctl restart nginx
pm2 restart getyoursite
```

---

## 🎉 Félicitations !

Votre site **GetYourSite** est maintenant :
- ✅ **Installé** et fonctionnel
- 🛡️ **Sécurisé** avec firewall et headers
- 🚀 **Optimisé** pour les performances
- 🔄 **Sauvegardé** automatiquement
- 📊 **Monitoré** en temps réel

### 📞 Besoin d'aide ?

1. **Logs** : Consultez toujours les logs en premier
2. **Documentation** : Relisez ce guide
3. **Tests** : Utilisez `test-installation.sh` pour diagnostiquer
4. **Community** : Partagez vos questions sur les forums Ubuntu

---

*GetYourSite - Installation facile et rapide pour Ubuntu 24.04* 🚀