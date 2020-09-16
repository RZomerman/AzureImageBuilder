#OneDrive.ps1
$workfolder="c:\deployment"

#Office.ps1
$workfolder="c:\deployment"
$uri1='https://azureinfra.blob.core.windows.net/artifacts/OneDriveSetup.exe'
$FileName="OneDriveSetup.exe"


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
$logFile = $workfolder+'\OneDrive'+$date+'.log'
WriteLog "Steps will be tracked on the log file : [ $logFile ]"

Writelog "Downloading files"
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $FileName) -retries 3


    $File=($workfolder + "\" + $FileName)
    #$Command=("$File /VERYSILENT /MERGETASKS=!runcode")
    #&"$File"

    Start-Process -FilePath $File -Argument "/SILENT /Allusers" -Wait




