
#Add your standard registry stuff in here.. 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f



#LOAD THE NTUSER.DAT under HKLM\DEFAULT - this is to set the default user behavior through the registry
& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT

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
  }