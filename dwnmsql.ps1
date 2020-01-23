Set-ExecutionPolicy Unrestricted -Force
$client = new-object System.Net.WebClient
$client.DownloadFile(“https://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-web-community-8.0.19.0.msi”,“C:\mysql.msi”)
msiexec /i C:\mysql.msi /passive
