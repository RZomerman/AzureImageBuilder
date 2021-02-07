#Teams.ps1
$workfolder="c:\deployment"


$workfolder="c:\deployment"
$uri1='https://go.microsoft.com/fwlink/p/?LinkID=869426&clcid=0x409&culture=en-us&country=US&lm=deeplink&lmsrc=groupChatMarketingPageWeb&cmpid=directDownloadWin64'
$uri2='https://aka.ms/vs/16/release/vc_redist.x64.exe'
$uri3='https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt'

$FileName="Teams_windows_x64.msi"
$VCRedist="VC_redist.x64.exe"
$MsRdcWebRTCSvc="MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi"



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
$logFile = $workfolder+'\Teams'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]" -Logfile $logFile

Writelog -Message "Downloading files" -Logfile $logFile
DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\" + $FileName) -retries 3 -LogFile $logfile
DownloadWithRetry -url $URI2 -downloadLocation ($workfolder + "\" + $VCRedist) -retries 3 -LogFile $logfile
DownloadWithRetry -url $URI3 -downloadLocation ($workfolder + "\" + $MsRdcWebRTCSvc ) -retries 3 -LogFile $logfile
    
$File=$FileName
    $File=($workfolder + "\" + $File)

$logfile=($workfolder + "\TeamsInstall.log")

#Set Registry Keys:
Writelog -Message "Setting registry settings" -Logfile $logFile
New-Item -Path HKLM:\SOFTWARE\Microsoft\Teams\
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Teams\' -Name IsWVDEnvironment -Value 1 -PropertyType DWORD

    $MSIArguments = @(
    "/i"
    ('"{0}"' -f $File)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
    "ALLUSERS=1"
    "ALLUSER=1"
)
Writelog -Message "Installing Teams" -Logfile $logFile
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 

#End of teams install, now need to install VCRedist
Writelog -Message "Installing VCRedistribute" -Logfile $logFile
$File=($workfolder + "\" + $VCRedist)
$logfile=($workfolder + "\VC_redist_x64.log")
Start-Process -FilePath $File -Argument "/Install /quiet /norestart /log $logfile" -Wait


#WebRTCPackage
$MSIFile=($workfolder + "\" + $MsRdcWebRTCSvc)
$MSIArguments = @(
"/i"
('"{0}"' -f $MSIFile)
"/qn"
"/norestart"
"/L*v"
$logFile
)
Writelog -Message "Installing MS RTCWEB" -Logfile $logFile
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 



