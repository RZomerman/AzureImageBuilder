#Execute StartMenu import if exist
$workfolder="c:\deployment"
$StartMenu = "customStartMenu.xml"
$uri1='https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/customstartmenu.xml'


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

$logFile = $workfolder+'\startmenu_'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]"  -logfile $logfile

Writelog -Message "Downloading files" -logfile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $StartMenu) -retries 3 -LogFile $logfile


If (!(Test-Path ($workfolder + "\StartMenu"))) {
    new-item -Path c:\ -Name StartMenu -ItemType Directory
}
copy ($workfolder + "\" + $StartMenu) ("c:\startMenu\Startmenu.xml")
$systemdrive=($env:SystemDrive + "\")
writelog -Message "Importig Custom Startmenu" -Logfile $logFile
Import-StartLayout -LayoutPath 'c:\startMenu\Startmenu.xml' -MountPath $systemdrive
writelog -Message "done" -Logfile $logFile
