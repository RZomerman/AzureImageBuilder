
Function RunLog-Command([string]$Description, [ScriptBlock]$Command, [string]$Color, [string]$LogFile){
    If (!($Color)) {$Color="Yellow"}
    Try{
        $Output = $Description+'  ... '
        Write-Host $Output -ForegroundColor $Color
        ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append -Force
        $Result = Invoke-Command -ScriptBlock $Command 
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $Output = 'Error '+$ErrorMessage
        ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append -Force
        $Result = ""
    }
    Finally {
        if ($ErrorMessage -eq $null) {
            $Output = "[Completed]  $Description  ... "} else {$Output = "[Failed]  $Description  ... "
        }
        ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append -Force
    }
    Return $Result
}


Function WriteLog([string]$Description, [string]$Color, [string]$LogFile){
    If (!($Color)) {$Color="Yellow"}
    $Output = $Description+'  ... '
    Write-Host $Output -ForegroundColor $Color
    ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append -Force   
}

function DownloadWithRetry
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $url,

        [Parameter(Mandatory=$false)]
        [string]
        $downloadLocation,
        
        [Parameter(Mandatory=$false)]
        [int]
        $retries,
        [Parameter(Mandatory=$false)]
        [string]
        $logfile
    )
    while($true)
    {
        try
        {
            write-host "downloading: " $url " to " $downloadLocation
            Invoke-WebRequest -uri $url -OutFile $downloadLocation -UseBasicParsing
            break
        }
        catch
        {
            $exceptionMessage = $_.Exception.Message
            WriteLog -Message "Error downloading '$url': $exceptionMessage" -Logfile $logfile
            if ($retries -gt 0) {
                $retries--
                WriteLog -Message ("Waiting 10 seconds before retrying. Retries left: " + $retries) -Logfile $logfile
                Start-Sleep -Seconds 10
 
            }else{
                $exception = $_.Exception
                WriteLog -Message "Failed to download '$url': $exceptionMessage" -Logfile $logfile
                break
            }
        }
    }
}
    