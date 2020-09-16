#Office.ps1
$workfolder="c:\deployment"
$XMLFile=($workfolder + "\WVDOffice.xml")
$uri1='https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_12827-20268.exe'
$uri2='https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/WVDOffice.xml'

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

If (!(Test-path ($workfolder + "\Office"))) {
    $OfficeInstallFolder=new-item -Path $workfolder -Name Office -ItemType Directory
}
$OfficeInstallPath=($workfolder + "\Office")
#Extracting the Office Deployment Tool (extracting in C:\Deployment)
$File=Get-ChildItem -Path $workfolder -Filter officedeploymenttool_*.exe -Recurse -File -Name 
    $File=($workfolder + "\" + $File)
    #$Command=("$File /VERYSILENT /MERGETASKS=!runcode")
    #&"$File"

    writelog  -Message  "Starting Tools installation"  -logfile $logfile
    Start-Process -FilePath $File -Argument "/quiet /extract:$OfficeInstallPath" -Wait
    writelog  -Message "finished Tools installation" -logfile $logfile
    

#After Extracting, we can check for an OfficeXML file and download the configuration
$OfficeSetup=($OfficeInstallPath + "\setup.exe")
copy $XMLFile ($OfficeInstallPath + "\office.xml")


writelog  -Message  "Starting Office Download" -logfile $logfile
&"$OfficeSetup" /download c:\deployment\office\Office.xml

writelog  -Message  "Starting Office Configuration" -logfile $logfile
&"$OfficeSetup" /Configure c:\deployment\office\Office.xml


writelog -Message "Installation Complete" -logfile $logfile
