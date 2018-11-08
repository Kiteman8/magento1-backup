#!/bin/bash

#@author		Kliggs based on idea from MagePsycho
#@website		https://www.kliggs.de
#@version		0.1.0
#@magento		1.x

#features
# Backup with timestamp of magento root and database
#usage
# 1. login first magento and disable all cache at yourhost.com/index.php/admin/cache/
# 2. deactivate merging of CSS and JS yourhost.com/index.php/admin/system_config/edit/section/dev/
# 3. sites with traffic put store on maintainance mode
# 4. Logout and terminat session
# 5. Edit following vars to your needs
# 6. run script from shell by sh ./_backup.sh

#/************************ EDIT VARIABLES ************************/
nameBackup="magento-1.9"
sourceDir=/home/www/magento
backupDir=/home/www/_backups
#/************************ //EDIT VARIABLES **********************/

RED='\033[0;31m'
NC='\033[0m' # No Color
# printf "I tput setab [1-7]${RED}love${NC} Stack Overflow\n"

fileName=$nameBackup-$(date +"%Y-%m-%d-%s")
echo "name of backup will be $fileName"

if [ ! -d $backupDir ]
then
echo "make directory to $backupDir"
mkdir -m 0764 $backupDir
fi

if [ ! -d $sourceDir ]
then
exit "directory not found - check for magento root"
else
cd $sourceDir
fi


dbXmlPath="$sourceDir/app/etc/local.xml"
{
	# the given XML is in file.xml
	host="$(echo "cat /config/global/resources/default_setup/connection/host/text()" | xmllint --nocdata --shell $dbXmlPath | sed '1d;$d')"
	username="$(echo "cat /config/global/resources/default_setup/connection/username/text()" | xmllint --nocdata --shell $dbXmlPath | sed '1d;$d')"
	password="$(echo "cat /config/global/resources/default_setup/connection/password/text()" | xmllint --nocdata --shell $dbXmlPath | sed '1d;$d')"
	dbName="$(echo "cat /config/global/resources/default_setup/connection/dbname/text()" | xmllint --nocdata --shell $dbXmlPath | sed '1d;$d')"
}


###### magento compiler off

	echo "----------------------------------------------------"
	echo "disable Magento compiler and clear..."
	php -f ${sourceDir}/shell/compiler.php -- disable
	php -f ${sourceDir}/shell/compiler.php -- clear

###### dump database
	echo "----------------------------------------------------"
	echo "Dumping MySQL $dbName to $backupDir"
	mysqldump -h $host -u $username -p$password $dbName | gzip > $backupDir/$fileName.sql.gz
	

	 # --ignore-table=$dbName.log_url_info \
	 # --ignore-table=$dbName.log_url \
	 # --ignore-table=$dbName.log_visitor \
	 # --ignore-table=$dbName.log_visitor_event
	 
	echo "Done with backup path $backupDir/$fileName.sql.gz"

	echo "----------------------------------------------------"
	echo "Make tar archive of directory $sourceDir"
	
	# --exclude=./directory excludes als directories relative to path with the name of directory. Trailing slash no effect (Darwin/FreeBSD)
	# --exclude=directory excludes all directories with the name
	# --exclude=/nicht absolute path dont work
	
	# cd for tar on top defined
	tar -zcf $backupDir/$fileName.tar.gz \
	--exclude=var/session/sess* \
	--exclude=var/cache/* \
	--exclude=var/backups/* \
	--exclude=var/tmp/* \
	--exclude=includes \
	*
	
	echo "Done with backup path $backupDir/$fileName.tar.gz"
	echo "----------------------------------------------------"
	echo "List latest on to with MB block size"
	ls -AltH --block-size=M $backupDir
	
