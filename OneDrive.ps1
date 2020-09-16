#OneDrive.ps1
$workfolder="c:\deployment"

#Office.ps1
$workfolder="c:\deployment"
$uri1='https://go.microsoft.com/fwlink/?linkid=844652'
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
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]" -Logfile $logfile

Writelog -Message "Downloading files" -Logfile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $FileName) -retries 3 -LogFile $logfile


    $File=($workfolder + "\" + $FileName)
    #$Command=("$File /VERYSILENT /MERGETASKS=!runcode")
    #&"$File"

    Start-Process -FilePath $File -Argument "/SILENT /Allusers" -Wait




