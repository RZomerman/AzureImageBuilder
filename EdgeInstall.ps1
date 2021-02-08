#EdgeInstall.ps1
$uri1='http://go.microsoft.com/fwlink/?LinkID=2093437'
$FileName="MicrosoftEdgeEnterpriseX64.msi"



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
$logFile = $workfolder+'\EdgeInstall'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]" -LogFile $logfile

Writelog -Message "Downloading files" -LogFile $logfile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $FileName) -retries 3 -LogFile $logfile

$MSIFile=($workfolder + "\" + $FileName)
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

Writelog -Message "Removing First Run Experience" -LogFile $logfile
If (!(Test-Path HKLM:\Software\Policies\Microsoft\Edge)) {
    New-Item HKLM:\Software\Policies\Microsoft\Edge
}
If (!(Test-Path HKLM:\Software\Policies\Microsoft\Edge\HideFirstRunExperience)) {
    New-Item HKLM:\Software\Policies\Microsoft\Edge -Name HideFirstRunExperience -ItemType DWORD -Value 1
}

Writelog -Message "Installation Completed" -LogFile $logfile


