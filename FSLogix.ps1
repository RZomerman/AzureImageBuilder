#ChromeInstall.ps1
$workfolder="c:\deployment"

$uri1='https://aka.ms/fslogix_download'
$FileName="FSLogix_Apps_2.9.7349.30108.zip"



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
$logFile = $workfolder+'\FSLogix'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]" -Logfile $logfile

Writelog -Message "Downloading files" -Logfile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $FileName) -retries 3

$File=Get-ChildItem -Path $workfolder -Filter FSLogi*.zip -Recurse -File -Name  | ForEach-Object {
    $ZIPFolderName=[System.IO.Path]::GetFileNameWithoutExtension($_)
    Expand-Archive ($workfolder + "\" + $_) -DestinationPath ($workfolder + "\" + $ZIPFolderName) -Force}

    $InstallFolder=($workfolder + "\" + $ZIPFolderName + "\x64\Release")


$File=($InstallFolder + "\FSLogixAppsSetup.exe")
$logfile=($workfolder + "\FSLogixAppsSetup.log")
Writelog -Message "Running installer for FSLogix" -Logfile $logFile
Start-Process -FilePath $File -Argument "/Install /quiet /norestart /log $logfile" -Wait