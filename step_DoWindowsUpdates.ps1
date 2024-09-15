# =======================================================================================================================================================================
# Purpose : VM Configuration
#
# DISCLAIMER: The sample scripts provided here are not supported under any Microsoft standard support program or service. 
# All scripts are provided AS IS without warranty of any kind.
# Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. 
# In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever 
# (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) 
# arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages. 
# 
# ======================================================================================================================================================================


$tmppath = "c:\temp"
$logfile = "step_DoWindowsUpdates.log"
#create folder if it doesn't exist
if (!(Test-Path -Path $tmppath)){mkdir $tmppath}
Start-Transcript "$tmppath\$logfile" -Append
"(step_DoWindowsUpdates.ps1) was run at $(Get-Date)"

$updateSession = New-Object -ComObject "Microsoft.Update.Session"
$updateSession.ClientApplicationID = "PowerShell Sample Script"
$updateSearcher = $updateSession.CreateUpdateSearcher()

Write-Output "Searching for updates..."
Write-Output "============================================================"

#$searcherCriteriaString = "IsInstalled=0 and Type='Software' and IsHidden=0"
$searcherCriteriaString = "IsInstalled=0"

$searchResult = $updateSearcher.Search($searcherCriteriaString)

if ($searchResult.Updates.Count -eq 0) {
    Write-Output "There are no applicable updates."
}else {
    Write-Output "List of applicable items on the machine:"
    foreach ($update in $searchResult.Updates) {
        $update.Title
    }
}

Write-Output "Creating collection of updates to download:"
$updatesToDownload = New-Object -ComObject "Microsoft.Update.UpdateColl"

foreach ($update in $searchResult.Updates) {
    if ($update.InstallationBehavior.CanRequestUserInput -eq $true) {
        Write-Output "skipping: $($update.Title) because it requires user input"
        continue
    }elseif ($update.EulaAccepted -eq $false) {
        Write-Output "skipping: $($update.Title) as a license agreement  must be accepted:"
        Write-Output "$($update.EulaText)"
        continue
    }elseif ($update.EulaAccepted -eq $true) {
        "Adding Update {0} To Download" -f $($update.Title)
        $updatesToDownload.Add($update)
    }
}

If ($updatesToDownload.Count -eq 0) {
    Write-Output "All applicable updates were skipped."
    return 
}
Write-Output "========================End Search=========================="

Write-Output "Downloading updates...that might take a while pls be patient"
Write-Output "============================================================"

$downloader = $updateSession.CreateUpdateDownloader() 
$downloader.Updates = $updatesToDownload
$downloader.Download()
Write-Output "========================End Download========================"

Write-Output "Adding Updates To Install List"
Write-Output "============================================================"
$updatesToInstall = New-Object -ComObject "Microsoft.Update.UpdateColl"
foreach ($update in $($searchResult.Updates)) {
    if ($update.IsDownloaded -eq $true) {
        Write-Output "installing...$($update.Title)"
        $updatesToInstall.Add($update)
        If ($update.InstallationBehavior.RebootBehavior -gt 0) {
            $rebootMayBeRequired = $true
        }
    }
}
Write-Output "========================End================================="

Write-Output "Installing ...that might take a while pls be patient"
Write-Output "============================================================"
$installer = $updateSession.CreateUpdateInstaller()
$installer.Updates = $updatesToInstall
$installationResult = $installer.Install()
    
"Installation Result: {0} - Reboot Required: {1}" -f $($installationResult.ResultCode), $($installationResult.RebootRequired)
Write-Output "========================End================================="

Write-Output "============================================================"
"I finished at $(Get-Date)"
Write-Output "============================================================"

Stop-Transcript