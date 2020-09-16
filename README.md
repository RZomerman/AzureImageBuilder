# AzureImageBuilder
See https://blog.azureinfra.com/2020/09/16/windows-virtual-desktop-builing-your-image-automated-ii/

Download and run each of the installers separately, or download and run the BuildCustomImage.ps1 to run all the installers specified in the indexfile.txt

for the indexfile.txt icw BuildCustomImage.ps1
Indexfile.txt
;https://mydomain.com/CustomRegistry.ps1
This will download the CustomRegistry.ps1 file and run the ps1 file

Indexfile.txt
https://mydomain.com/installer.exe
This will download the installer.exe file and do nothing further - handy if you need to download a background file or company files for example

Indexfile.txt
https://mydomain.com/installer.exe;https://mydomain.com/installerscript.ps1
This will download the installer.exe as well as the installerscript.pss1 file and run the ps1 file
