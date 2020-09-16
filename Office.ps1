#Office.ps1
$workfolder="c:\deployment"
$XMLFile=($workfolder + "\WVDOffice.xml")
$uri1='https://azureinfra.blob.core.windows.net/artifacts/officedeploymenttool_12827-20268.exe'
$uri2='https://azureinfra.blob.core.windows.net/artifacts/WVDOffice.xml'

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
WriteLog "Steps will be tracked on the log file : [ $logFile ]"

Writelog "Downloading files"
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\officedeploymenttool_12827-20268.exe") -retries 3
DownloadWithRetry -url $URI2 -downloadLocation ($workfolder + "\WVDOffice.xml") -retries 3

If (!(Test-path ($workfolder + "\Office"))) {
    $OfficeInstallFolder=new-item -Path $workfolder -Name Office -ItemType Directory
}
$OfficeInstallPath=($workfolder + "\Office")
#Extracting the Office Deployment Tool (extracting in C:\Deployment)
$File=Get-ChildItem -Path $workfolder -Filter officedeploymenttool_*.exe -Recurse -File -Name 
    $File=($workfolder + "\" + $File)
    #$Command=("$File /VERYSILENT /MERGETASKS=!runcode")
    #&"$File"

    writelog "Starting Tools installation"
    Start-Process -FilePath $File -Argument "/quiet /extract:$OfficeInstallPath" -Wait
    writelog "finished Tools installation"
    

#After Extracting, we can check for an OfficeXML file and download the configuration
$OfficeSetup=($OfficeInstallPath + "\setup.exe")
copy $XMLFile ($OfficeInstallPath + "\office.xml")

$Command={& "$OfficeSetup" /download Office.xml}
RunLog-Command -Description "Starting Office download" -Command $Command


$Command={& "$OfficeSetup" /Configure Office.xml}
RunLog-Command -Description "Starting installation / configuration" -Command $Command

writelog -description "Installation Complete"
