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


# Variables for logging
$tmppath = "C:\temp"
$logfile = "step_ConfigureVMNetworking.log"

# Create folder if it doesn't exist
if (!(Test-Path -Path $tmppath)) {
    New-Item -ItemType Directory -Path $tmppath -Force | Out-Null
}

# Start logging
Start-Transcript -Path "$tmppath\$logfile" -Append
Write-Output "(step_ConfigureVMNetworking.ps1) was run at $(Get-Date)"

# Install certificate
##############################################################
Write-Output "Installing certificate..."
$certFilePath = "C:\temp\HyperVSandbox\CertStore\test.cer"  # Replace <CERT-NAME> with your certificate name
$certStoreLocation = "Cert:\LocalMachine\Root"

if (Test-Path -Path $certFilePath) {
    try {
        Import-Certificate -FilePath $certFilePath -CertStoreLocation $certStoreLocation -Verbose
        Write-Output "Certificate imported successfully."
    } catch {
        Write-Error "Failed to import certificate: $_"
    }
} else {
    Write-Error "Certificate file not found at path: $certFilePath"
}

# Configure Proxy
####################################
Write-Output "Configuring proxy settings..."

$proxyServer = "proxy.sdst.sbaintern.de:8090"
$proxyOverride = "*.local;192.168.*"

$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

# Ensure the registry path exists
if (!(Test-Path -Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set proxy settings
try {
    New-ItemProperty -Path $registryPath -Name "ProxyEnable" -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "ProxyServer" -Value $proxyServer -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "ProxyOverride" -Value $proxyOverride -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "ProxySettingsPerUser" -Value 0 -PropertyType DWORD -Force | Out-Null
    Write-Output "Proxy settings configured successfully."
} catch {
    Write-Error "Failed to configure proxy settings: $_"
}

# End logging
Write-Output "Script execution completed at $(Get-Date)"
Stop-Transcript
