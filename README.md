# magento1-backup
Backup Script Magento 1. Backups Database and Magento Rootfolder

FEATURES

timestamp of backup
reads db params from local.xml of defined magento root
copies to backup directory _backups

USAGE

1. login first magento and disable all cache at yourhost.com/index.php/admin/cache/
2. deactivate merging of CSS and JS yourhost.com/index.php/admin/system_config/edit/section/dev/
3. sites with traffic put store on maintainance mode
4. Logout and terminat session
5. Edit following vars to your needs
6. run script from shell by sh ./_backup.sh
