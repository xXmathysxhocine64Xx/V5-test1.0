# 🚀 DÉPLOIEMENT AUTOMATIQUE GETYOURSITE

## Installation en UNE SEULE COMMANDE

### Étape 1 : Télécharger le script
```bash
# Sur votre serveur Ubuntu 24.04, exécutez :
wget https://raw.githubusercontent.com/votre-compte/getyoursite/main/deploy-getyoursite.sh
# OU copiez le fichier deploy-getyoursite.sh sur votre serveur
```

### Étape 2 : Exécuter l'installation
```bash
# Rendre le script exécutable
chmod +x deploy-getyoursite.sh

# Lancer l'installation automatique
sudo ./deploy-getyoursite.sh
```

## ✨ CE QUE LE SCRIPT FAIT AUTOMATIQUEMENT

✅ **Installation système complète**
- Node.js 18+ 
- Nginx
- PM2
- Toutes les dépendances

✅ **Création du projet GetYourSite**
- Structure de fichiers complète
- Configuration Next.js + Tailwind
- Composants UI (Button, Card, Input, etc.)
- API de contact avec nodemailer
- Page d'accueil fonctionnelle

✅ **Configuration serveur**
- PM2 avec démarrage automatique
- Nginx avec proxy vers Next.js
- Firewall UFW
- Permissions correctes

✅ **Tests automatiques**
- Vérification de l'API
- Test du site web
- Affichage des logs

## 🎯 RÉSULTAT FINAL

Après exécution, vous aurez :
- ✅ Site GetYourSite en ligne sur http://votre-ip
- ✅ Formulaire de contact fonctionnel
- ✅ Design moderne et responsive
- ✅ Services configurés (PM2, Nginx)
- ✅ Prêt pour la production

## 📧 CONFIGURATION GMAIL (OPTIONNELLE)

Le script vous demande :
1. **Votre email Gmail** (ou appuyez sur Entrée pour ignorer)
2. **Mot de passe d'application** (16 caractères)
3. **Email de réception**

Si ignoré, vous pouvez le faire plus tard :
```bash
nano /var/www/getyoursite/.env.local
# Modifiez les valeurs GMAIL_*
pm2 restart getyoursite
```

## 🛠️ COMMANDES POST-INSTALLATION

```bash
# Voir le statut
pm2 status

# Voir les logs
pm2 logs getyoursite

# Redémarrer
pm2 restart getyoursite

# Arrêter
pm2 stop getyoursite

# Reconstruire après modification
cd /var/www/getyoursite
npm run build
pm2 restart getyoursite
```

## 🔧 PERSONNALISATION

### Modifier le contenu
```bash
# Éditer la page principale
nano /var/www/getyoursite/app/page.js

# Éditer les styles
nano /var/www/getyoursite/app/globals.css

# Reconstruire
cd /var/www/getyoursite
npm run build
pm2 restart getyoursite
```

### Ajouter un domaine
```bash
# Modifier la config Nginx
sudo nano /etc/nginx/sites-available/getyoursite
# Remplacer "server_name _;" par "server_name votredomaine.com;"

# Redémarrer Nginx
sudo systemctl restart nginx

# SSL avec Let's Encrypt (optionnel)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d votredomaine.com
```

## 🚨 DÉPANNAGE

### Site inaccessible (erreur 502)
```bash
# Vérifier PM2
pm2 status
pm2 restart getyoursite

# Vérifier Nginx
sudo nginx -t
sudo systemctl restart nginx
```

### Erreur de build
```bash
cd /var/www/getyoursite
rm -rf .next node_modules
npm install
npm run build
pm2 restart getyoursite
```

### Logs d'erreur
```bash
# Logs PM2
pm2 logs getyoursite --lines 50

# Logs Nginx
sudo tail -f /var/log/nginx/error.log
```

## 📊 MONITORING

### Surveillance des ressources
```bash
# Monitoring PM2 en temps réel
pm2 monit

# Statut système
htop
df -h
free -h
```

### Sauvegardes
```bash
# Sauvegarde du projet
tar -czf getyoursite-backup-$(date +%Y%m%d).tar.gz -C /var/www getyoursite

# Restauration
tar -xzf getyoursite-backup-YYYYMMDD.tar.gz -C /var/www
pm2 restart getyoursite
```

## 🎉 AVANTAGES DE CE SCRIPT

- **🚀 Ultra rapide** : Installation complète en 5 minutes
- **🔒 Zéro erreur** : Évite tous les problèmes EOF et 404
- **🛡️ Sécurisé** : Firewall, permissions, configuration optimale
- **📱 Responsive** : Site moderne qui fonctionne partout
- **✉️ Email ready** : Formulaire de contact intégré
- **🔧 Maintenable** : Structure claire, logs détaillés

---

## ⚠️ PRÉREQUIS

- Ubuntu Server 24.04 LTS
- Accès root (sudo)
- Connexion Internet
- 1GB RAM minimum
- 5GB espace disque

---

**Votre site GetYourSite sera en ligne en moins de 10 minutes !** 🚀

---

*Pour toute question : vérifiez d'abord `pm2 logs getyoursite`*