
#Custom background download
$uri1='https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/customback.jpg'
$backgroundfile="customback.jpg"
$workfolder="c:\deployment"

If(!(test-path $workfolder)){
  new-item -Path c:\ -Name Deployment -ItemType Directory
}

If (!(test-path C:\deployment\BuildCustomImage.psm1)){
  Invoke-webrequest -uri https://raw.githubusercontent.com/RZomerman/AzureImageBuilder/master/BuildCustomImage.psm1 -OutFile C:\deployment\BuildCustomImage.psm1 -UseBasicParsing
}
If (!(Get-Module -Name BuildCustomImage )){
  Import-Module C:\deployment\BuildCustomImage.psm1
}

##Setting Global Parameters##
$ErrorActionPreference = "Stop"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = "C:\Deployment"
$logFile = $workfolder+'\Registry'+$date+'.log'
WriteLog -Message "Steps will be tracked on the log file : [ $logFile ]"  -logfile $logfile

Writelog -Message "Downloading files" -logfile $logfile
If ($URI) {
  DownloadWithRetry -url $URI1 -downloadLocation ($workfolder + "\customback.jpg") -retries 3 -LogFile $logfile
}

#This part of the script add's registry items for HKEY_LOCAL_MACHINE
#Add your standard registry stuff in here.
Writelog -Message "Setting HKLM settings" -logfile $logfile 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f


#LOAD THE NTUSER.DAT under HKLM\DEFAULT -
# this is to set the default user behavior through the registry
Writelog -Message "Loading NTUSER.dat" -logfile $logfile
& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT

#Add registry edits here ; but change the hive to HKLM\DEFAULT
Writelog -Message "HKLM\DEFAULT" -logfile $logfile
  #background image
  If (test-path ($workfolder + "\customback.jpg")) {
    If (!(Test-Path ($workfolder + "\background"))) {
      new-item -Path c:\ -Name background -ItemType Directory
      }
    copy ($workfolder + "\" + $backgroundfile) ("c:\background\customback.jpg")
    reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /t REG_SZ /d c:\background\customback.jpg /f
  }


  #disable storage pool
  reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f

  #Enable File Extension viewing
  If (!(Test-path HKLM:\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\)) {
      New-Item -Path HKLM:\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\
  }
  New-ItemProperty -Path 'HKLM:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' -Name HideFileExt -Value 0 -PropertyType DWORD

  #Enable go to Computer
  New-ItemProperty -Path 'HKLM:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' -Name LaunchTo -Value 1 -PropertyType DWORD

  #Disable People on Taskbar
  If (!(Test-path HKLM:\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People)) {
      New-Item -Path HKLM:\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People
  }
  New-ItemProperty -Path 'HKLM:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' -Name PeopleBand -Value 0 -PropertyType DWORD


  Writelog -Message "Unloading HIVE" -logfile $logfile
#This part unloads the NTUSER default hive and make the registry clean again
$unloaded = $false
$attempts = 0
while (!$unloaded -and ($attempts -le 5)) {
    [gc]::Collect() # necessary call to be able to unload registry hive
    & REG UNLOAD HKLM\DEFAULT
    $unloaded = $?
    $attempts += 1
  }
  if (!$unloaded) {
    new-item -Path C:\ -Name HIVENOTUNLOADED_WARNING.TXT
    Writelog -Message "WARNING HIVE NOT UNLOADED" -logfile $logfile
  }
  Writelog -Message "Done" -logfile $logfile