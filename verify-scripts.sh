#!/bin/bash
echo '🧪 Vérification de la syntaxe des scripts...'
echo

for script in setup-getyoursite.sh test-installation.sh diagnostic-getyoursite.sh; do
    echo -n "Vérification de $script... "
    if bash -n $script; then
        echo "✅ OK"
    else
        echo "❌ ERREUR"
        exit 1
    fi
done

echo
echo '✅ Tous les scripts ont une syntaxe correcte !'
echo '🚀 Ready pour installation sur Ubuntu 24.04'
