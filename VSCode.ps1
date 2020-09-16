#VSCodeInstall.ps1
$workfolder="c:\deployment"
$uri1='https://go.microsoft.com/fwlink/?Linkid=852157'
$FileName="VSCodeSetup.exe"


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
$logFile = $workfolder+'\VSCode'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]" -Logfile $logfile

Writelog -Message "Downloading files" -Logfile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $FileName) -retries 3 -LogFile $logfile
WriteLog -Message "Download complete" -Logfile $logfile


$VSCode=Get-ChildItem -Path $workfolder -Filter VSCodeSetup*.exe -Recurse -File -Name 
    $File=($workfolder + "\" + $VSCode)
    WriteLog -Message "Staring install of $VSCode" -Logfile $logfile
    Start-Process -FilePath $File -Argument "/VERYSILENT /MERGETASKS=!runcode" -Wait
    WriteLog -Message "Finished install" -Logfile $logfile
