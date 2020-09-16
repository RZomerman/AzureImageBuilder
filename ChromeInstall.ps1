#ChromeInstall.ps1

$workfolder="c:\deployment"
$uri1='https://dl.google.com/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip'
$FileName="GoogleChromeEnterpriseBundle64.zip"



If(!(test-path $workfolder)){
    new-item -Path c:\ -Name Deployment -ItemType Directory
}

If (!(test-path C:\deployment\BuildCustomImage.psm1)){
    Invoke-webrequest -uri https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/BuildCustomImage.psm1 -OutFile C:\deployment\BuildCustomImage.psm1 -UseBasicParsing
}
If (!(Get-Module -Name BuildCustomImage )){
    Import-Module C:\deployment\BuildCustomImage.psm1
}



##Setting Global Paramaters##
$ErrorActionPreference = "Stop"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
#$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$workfolder = "C:\Deployment"
$logFile = $workfolder+'\GoogleChrome'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]" -LogFile $logfile

Writelog -Message "Downloading files" -LogFile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $FileName) -retries 3 -LogFile $logfile


$ChromeZipFile=Get-ChildItem -Path $workfolder -Filter GoogleChrome*.zip -Recurse -File -Name  | ForEach-Object {
    $ZIPFolderName=[System.IO.Path]::GetFileNameWithoutExtension($_)
   Writelog -Message "Expanding Archive" -LogFile $logfile
   Expand-Archive ($workfolder + "\" + $_) -DestinationPath ($workfolder + "\" + $ZIPFolderName) -Force}

    $InstallFolder=($workfolder + "\" + $ZIPFolderName + "\Installers\")
    $Installer=Get-ChildItem -Path $InstallFolder -Filter GoogleChrome*.msi -Recurse -File -Name
    $MSIFile=($InstallFolder + $Installer)

    $MSIArguments = @(
    "/i"
    ('"{0}"' -f $MSIFile)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Writelog -Message "Starting installation" -LogFile $logfile
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
Writelog -Message "Installation Completed" -LogFile $logfile
