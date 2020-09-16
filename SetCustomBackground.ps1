#SetCustomBackground.ps1
$workfolder="c:\deployment"
$uri1='https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/customback.jpg'


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
$logFile = $workfolder+'\Office_'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]"  -logfile $logfile

Writelog -Message "Downloading files" -logfile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\officedeploymenttool_12827-20268.exe") -retries 3 -LogFile $logfile
DownloadWithRetry -url $URI2 -downloadLocation ($workfolder + "\WVDOffice.xml") -retries 3 -LogFile $logfile
