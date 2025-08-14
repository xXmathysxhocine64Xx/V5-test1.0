# 🚀 GetYourSite - Installation Ubuntu 24.04

## 📦 Scripts d'Installation Modernes et Corrigés

Ce répertoire contient les **scripts d'installation corrigés et optimisés** pour Ubuntu Server 24.04 LTS.

### ⚠️ Important
Tous les **anciens scripts problématiques ont été supprimés**. Utilisez uniquement les scripts ci-dessous.

---

## 🎯 Scripts Disponibles

### 🚀 Installation Principale
```bash
sudo ./setup-getyoursite.sh
```
**Script d'installation complet et automatique** - Installe et configure tous les services

### 🧪 Test de Compatibilité (Recommandé)
```bash
sudo ./test-installation.sh
```
**Vérification préalable** - Teste la compatibilité de votre système avant installation

### 🔍 Diagnostic de Problèmes
```bash
sudo ./diagnostic-getyoursite.sh
```
**Diagnostic post-installation** - Identifie et aide à résoudre les problèmes

### ✅ Vérification des Scripts
```bash
./verify-scripts.sh
```
**Test de syntaxe** - Vérifie que tous les scripts sont syntaxiquement corrects

---

## 📚 Documentation

### 📖 Guides d'Installation
- **`README_INSTALLATION.md`** - Guide complet avec toutes les options
- **`QUICK_START.md`** - Démarrage ultra-rapide (5 minutes)
- **`SCRIPT_INSTALLATION_FINAL.md`** - Résumé des améliorations

---

## 🚀 Installation Rapide

### Option 1: Installation directe
```bash
sudo ./setup-getyoursite.sh
```

### Option 2: Avec test préalable (Recommandée)
```bash
# 1. Test de compatibilité
sudo ./test-installation.sh

# 2. Si test OK, installation
sudo ./setup-getyoursite.sh
```

### Option 3: En cas de problème
```bash
# Diagnostic pour identifier les problèmes
sudo ./diagnostic-getyoursite.sh
```

---

## ✅ Ce que fait l'installation

### 🔧 Services Installés
- **Node.js 18 LTS** + Yarn + PM2
- **Nginx** (reverse proxy configuré)
- **GetYourSite** (application complète)

### 🛡️ Sécurité Intégrée
- **UFW Firewall** configuré
- **Fail2ban** protection anti-attaque
- **Headers de sécurité** Nginx

### ⚡ Optimisations
- **Compression Gzip** activée
- **Logs centralisés**
- **Sauvegardes automatiques**
- **Monitoring PM2**

---

## 🎯 Après Installation

Votre site sera accessible sur :
- **http://votre-ip-serveur** (site principal)
- **http://votre-ip-serveur/api/contact** (test API)

### 🔧 Commandes de gestion
```bash
pm2 status              # Statut de l'application
pm2 logs getyoursite    # Voir les logs
pm2 restart getyoursite # Redémarrer
```

---

## 🆘 Support

1. **Logs** : `pm2 logs getyoursite`
2. **Diagnostic** : `sudo ./diagnostic-getyoursite.sh`
3. **Documentation** : Consultez les guides dans ce répertoire

---

## 📋 Fichiers du Projet

```
📁 GetYourSite Installation
├── 🚀 setup-getyoursite.sh          # Installation principale
├── 🧪 test-installation.sh          # Test compatibilité
├── 🔍 diagnostic-getyoursite.sh     # Diagnostic problèmes
├── ✅ verify-scripts.sh             # Vérification syntaxe
├── 📖 README.md                     # Ce fichier
├── 📚 README_INSTALLATION.md        # Guide complet
├── 🎯 QUICK_START.md                # Démarrage rapide
└── 📋 SCRIPT_INSTALLATION_FINAL.md  # Résumé améliorations
```

---

**🚀 Installation en moins de 10 minutes sur Ubuntu Server 24.04 !**

*Scripts testés et optimisés - Janvier 2025*