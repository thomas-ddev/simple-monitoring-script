#!/bin/bash

# Paramètres pour l'envoi des mails
EMAIL=""
PASSWORD=""
MAILSERVER=""

# Récupérer les logs du jour uniquement, le cron doit donc être lancé le plus tard possible afin d'être précis (23h30)
DATESYS1="$(date +%b)"
DATESYS2="$(date +%d)"
DATEPHP="$(date +%d-%b-%Y)"
DATEMYSQL="$(date +%F)"
DATENGINX="$(date +%Y/%m/%d)"

# Vérifier s'il y a des erreurs OOM
echo "Vérification des erreurs OOM..."

if test $(grep -i -r "out of memory" /var/log/ | grep "$DATESYS1" | grep "$DATESYS2" | wc -c) -ne 0
     then
          swaks -t $EMAIL -s $MAILSERVER -tls -au $EMAIL --ap $PASSWORD -f $EMAIL --h-Subject "[ALERTE] [$HOSTNAME] Un processus a atteint la limite de mémoire disponible !" --body "Un des processus du serveur a subit un OOM (Out Of Memory) et a ainsi été tué. Cela peut signifier que le serveur nécesite soit une optimisation de la gestion de sa RAM, soit un upgrade. (grep -i -r 'out of memory' /var/log)"
     else
          echo "Aucune erreur OOM détectée."
fi

# Vérifier s'il y a des erreurs PHP
echo "Vérification de la présence d'erreurs PHP max_children..."

if test $(cat /var/log/php7.3-fpm.log | grep "max_children" | grep "$DATEPHP" | wc -c) -ne 0
     then
          swaks -t $EMAIL -s $MAILSERVER -tls -au $EMAIL --ap $PASSWORD -f $EMAIL --h-Subject "[ALERTE] [$HOSTNAME] Variable max_children atteinte !" --body "La variable max_children de la pool PHP a été atteinte. Si les ressources le permettent, il faut songer à l'augmenter. (cat /var/log/php7.3-fpm.log | grep 'max_children' && cat /var/log/php7.3-fpm.log.1 | grep 'max_children')"
     else
          echo "Aucune erreur PHP max_children détectée."
fi

# Vérifier s'il y a des erreurs SQL
if test $(cat /var/log/mysql/error.log | grep "error" | grep "$DATEMYSQL" | wc -c) -ne 0
     then
          swaks -t $EMAIL -s $MAILSERVER -tls -au $EMAIL --ap $PASSWORD -f $EMAIL --h-Subject "[ALERTE] [$HOSTNAME] Des erreurs MySQL sont présentes dans les logs !" --body "Une ou plusieurs erreurs ont étés détectées dans les logs MySQL. Cela peut signifier que le serveur nécessite une optimisation de sa configuration MySQL. (cat /var/log/mysql/error.log | grep 'error' && zcat /var/log/mysql/error.log.1.gz | grep 'error')"
     else
          echo "Aucune erreur SQL détectée."
fi

# Vérifier s'il y a des erreurs Nginx
if test $(cat /var/log/nginx/error.log | grep "crit" | grep "$DATENGINX" | wc -c) -ne 0
     then
          swaks -t $EMAIL -s $MAILSERVER -tls -au $EMAIL --ap $PASSWORD -f $EMAIL --h-Subject "[ALERTE] [$HOSTNAME] Des erreurs Nginx sont présentes dans les logs !" --body "Une ou plusieurs erreurs ont étés détectées dans les logs Nginx. Cela peut signifier que le serveur nécessite une optimisation de sa configuration Nginx. (cat /var/log/nginx/error.log | grep 'crit' && cat /var/log/nginx/error.log.1 | grep 'crit')"
     else
          echo "Aucune erreur Nginx détectée."
fi
