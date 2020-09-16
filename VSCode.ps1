#VSCodeInstall.ps1
$workfolder="c:\deployment"
$VSCode=Get-ChildItem -Path $workfolder -Filter VSCodeSetup*.exe -Recurse -File -Name 
    $File=($workfolder + "\" + $VSCode)
    #$Command=("$File /VERYSILENT /MERGETASKS=!runcode")
    #&"$File"

    Start-Process -FilePath $File -Argument "/VERYSILENT /MERGETASKS=!runcode" -Wait




