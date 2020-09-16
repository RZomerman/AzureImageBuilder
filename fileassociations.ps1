#Import fileassociations.xml if exist
$workfolder="c:\deployment"
$fileassociations="extensionassociation.xml"
$uri1='https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/extensionassociation.xml'


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

$logFile = $workfolder+'\fileassociations_'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]"  -logfile $logfile

Writelog -Message "Downloading files" -logfile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $fileassociations) -retries 3 -LogFile $logfile


If (Test-Path ($workfolder + "\" + $fileassociations)) {
    $fileassociationsLocation=($workfolder + "\" + $fileassociations)
    writelog -Message "Importig Custom App Associations" -Logfile $logFile
    &"dism" /online /Import-DefaultAppAssociations:$fileassociationsLocation
    writelog -Message "Complete" -Logfile $logFile
}
