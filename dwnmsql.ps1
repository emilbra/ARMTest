[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
Set-ExecutionPolicy Unrestricted -Force
$client = new-object System.Net.WebClient
$client.DownloadFile(https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.62-winx64.msi)
msiexec /i C:\mysql.msi /passive
