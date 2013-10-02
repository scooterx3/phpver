#!/bin/bash

### wanna basically run this remotely, add an argument and check to see if there isn't an argument
### check whilst I'm at it I can have each case modify the .htaccess for me

url="env.scooterx3.net/php/"
ini52="php.ini_52"
ini52fcgi="php.ini_52fcgi"
ini53="php.ini_53"
ini54="php.ini_54"
ini54fcgi="php.ini_54fcgi"

handler52="AddHandler application/x-httpd-php5 .php"
handler52f="AddHandler fcgid-script .php"
handler53="AddHandler application/x-httpd-php53 .php"
handler54="AddHandler application/x-httpd-php54 .php"
handler54f="AddHandler fcgid54-script .php" 

replacestring="AddHandler.*.php"

backupext=".bak___phpver___"

function ckfiles () {

# if no .htaccess.backup, check for .htaccess. If no .htaccess, create one and don't try backup. Otherwise try backup.. 
if [[ ! -f .htaccess$backupext ]]; then
	
	# if no .htaccess then make a blank one
	if [[ ! -f .htaccess ]]; then
		echo "No .htaccess, attempting to create one."
		echo "" >> .htaccess
		echo "New blank .htaccess in place."
	else
		cat .htaccess > .htaccess$backupext
		echo No .htaccess backup present, attempting to back up now
	fi

fi


# Check .htaccess for an AddHandler line. If there isn't one the rest of the script won't work. Add one. 
if [[ ! -n `grep AddHandler.*.php .htaccess` ]]; then
	echo "No AddHandler for php in .htaccess, adding now..."
	cat .htaccess > .htaccess.tmp && echo "$handler52" > .htaccess && cat .htaccess.tmp >> .htaccess && rm -f .htaccess.tmp	
fi

#If the backup of the original php.ini isn't present, make one. 
if [[ ! -f php.ini$backupext ]]; then
	if [[ ! -f php.ini ]]; then
		echo "No php.ini, not attempting backup"
	else
		echo "No php.ini backup present, attempting to back up now"
		cat php.ini > php.ini$backupext
	fi
fi

}

phpver () {
case "$1" in
2) ckfiles
    echo "Switching to php 5.2..."
    curl -Ss $url$ini52 > php.ini
    sed -i "s|$replacestring|$handler52|" .htaccess 	
    echo "Done."
    ;;

2f) ckfiles
     echo "Switching to php 5.2 (fcgi)..."
     curl -Ss $url$ini52fcgi > php.ini
     sed -i "s|$replacestring|$handler52f|" .htaccess
     echo "Done."
     ;;

3) ckfiles
    echo "Switching to php 5.3..."
    curl -Ss $url$ini53 > php.ini
    sed -i "s|$replacestring|$handler53|" .htaccess
    echo "Done."
    ;;

4) ckfiles
    echo "Switching to php 5.4..."
    curl -Ss $url$ini54 > php.ini
    sed -i "s|$replacestring|$handler54|" .htaccess
    echo "Done."
    ;;

4f) ckfiles
     echo "Switching to php 5.4 (fcgi)..."
     curl -Ss $url$ini54fcgi > php.ini
     sed -i "s|$replacestring|$handler54f|" .htaccess
     echo "Done."
     ;;

--restore) echo "restoring"
	rm .htaccess php.ini
	mv .htaccess$backupext .htaccess
	mv php.ini$backupext php.ini
	echo "restore complete"
	;;


*) clear && echo "
This script does the following:
-Check for backups of original .htaccess and php.ini. If none, creates them as {}$backupext
-If {}$backupext already exists it won't attempt to overwrite.
-Check for presence of .htaccess. If none, creates it. 
-Check for AddHandler.*.php in .htaccess. if none, adds default 5.2
-Replaces AddHandler.*.php in .htaccess with appropriate version, AND provides new php.ini appropriate for that version. 

**EVEN THOUGH THIS ATTEMPTS BACKUPS**
**MAKE A BACKUP YOURSELF. YOU'VE BEEN WARNED**

Valid arguments:
2  - php 5.2
2f - php 5.2 fcgi
3  - php 5.3
4  - php 5.4
4f - php 5.4 fcgi
--restore - deletes the current .htaccess, php.ini and moves the $backupext ones into place


example: 
. <(curl -Ss env.scooterx3.net/php/phpversion.sh) 54
^^ changes the current directory to php 5.4

"
;;
esac
}

echo "
phpver injected into shell. For information and examples, run 'phpver' 
"

