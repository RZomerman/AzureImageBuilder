<#
 #<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 #This part was added to allow local copy from an IIS server
 # with an invalid certificate. remove for production use!
 #<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 Add-Type @"
 using System;
 using System.Net;
 using System.Net.Security;
 using System.Security.Cryptography.X509Certificates;
 public class ServerCertificateValidationCallback
 {
     public static void Ignore()
     {
         ServicePointManager.ServerCertificateValidationCallback += 
             delegate
             (
                 Object obj, 
                 X509Certificate certificate, 
                 X509Chain chain, 
                 SslPolicyErrors errors
             )
             {
                 return true;
             };
     }
 }
"@
[ServerCertificateValidationCallback]::Ignore();
#<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>



new-item -Path c:\ -Name Deployment -ItemType Directory
$StartMenu = "customStartMenu.xml"
$fileassociations="extensionassociation.xml"

Invoke-webrequest -uri https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/BuildCustomImage.psm1 -OutFile C:\deployment\BuildCustomImage.psm1 -UseBasicParsing

Import-Module C:\deployment\BuildCustomImage.psm1

##Setting Global Paramaters##
$ErrorActionPreference = "Stop"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
#$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$workfolder = "C:\Deployment"
$logFile = $workfolder+'\Deployment'+$date+'.log'
WriteLog "Steps will be tracked on the log file : [ $logFile ]" 


$AllInstallers = New-Object System.Collections.ArrayList
#Download Indexfile
DownloadWithRetry -url 'https://azureinfra.blob.core.windows.net/artifacts/indexfile.txt' -downloadLocation ($workfolder + "\indexfile.txt") -retries 3


#This part opens the index file (if exists) and then download all the URL's in the index file. If a line starts with #, this is seen as a comment and no download will occur.
If (Test-path ($workfolder + "\indexfile.txt")) {
    [array]$DownloadIndex=Get-Content -Path ($workfolder + "\indexfile.txt")
    ForEach ($URI in $DownloadIndex) {
        If ($URI.startswith("#")) {
            WriteLog -Description $URI -Color "Yellow"
        }else{
            If ($URI.Contains(";")){
                $URL=$URI.split(";")
                $Installer=($URL[1].split("/")[-1])
                $TargetURL=$URL[1]
                DownloadWithRetry -url $TargetURL -downloadLocation ($workfolder + "\" + $Installer) -retries 3
                $void=$AllInstallers.add($Installer)
                

                If (!($URL[0].split("/")[-1] -eq "")) {
                $FileName=($URL[0].split("/")[-1])
                $TargetURL=$URL[0]
                
                DownloadWithRetry -url $TargetURL -downloadLocation ($workfolder + "\" + $FileName) -retries 3
                }

            }else{
                $FileName=($URI.split("/")[-1])
                DownloadWithRetry -url $URI -downloadLocation ($workfolder + "\" + $FileName) -retries 3
            }
        }
    }
}

#Run all installers in the $AllInstallers array
ForEach ($Installer in $AllInstallers){
    writelog "starting installation of $Installer"
    $Command=($workfolder + "\" + $Installer)
    writelog $Command
    &"$Command"
}

#Execute StartMenu import if exist
If (Test-Path ($workfolder + "\" + $StartMenu)) {
        new-item -Path c:\ -Name StartMenu -ItemType Directory
        copy ($workfolder + "\" + $StartMenu) ("c:\startMenu\Startmenu.xml")
        $systemdrive=($env:SystemDrive + "\")
        Import-StartLayout -LayoutPath 'c:\startMenu\Startmenu.xml' -MountPath $systemdrive
    }

#Import fileassociations.xml if exist
If (Test-Path ($workfolder + "\" + $fileassociations)) {
    $fileassociationsLocation=($workfolder + "\" + $fileassociations)
    $Command="dism /online /Import-DefaultAppAssociations:$fileassociationsLocation"
    &"$Command"
}


