#ChromeInstall.ps1
$workfolder="c:\deployment"
$ChromeZipFile=Get-ChildItem -Path $workfolder -Filter GoogleChrome*.zip -Recurse -File -Name  | ForEach-Object {
    $ZIPFolderName=[System.IO.Path]::GetFileNameWithoutExtension($_)
    Expand-Archive ($workfolder + "\" + $_) -DestinationPath ($workfolder + "\" + $ZIPFolderName) -Force}

    $InstallFolder=($workfolder + "\" + $ZIPFolderName + "\Installers\")
    $Installer=Get-ChildItem -Path $InstallFolder -Filter GoogleChrome*.msi -Recurse -File -Name
    $MSIFile=($InstallFolder + $Installer)

    $MSIArguments = @(
    "/i"
    ('"{0}"' -f $MSIFile)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
