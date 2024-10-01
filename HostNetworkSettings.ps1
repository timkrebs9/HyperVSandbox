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

param(
    [ValidateNotNullOrEmpty()]
    [string]$SwitchName = "Internal",

    [ValidateNotNullOrEmpty()]
    [string]$InterfaceAlias = "vEthernet (Internal)",

    [ValidatePattern('\b\d{1,3}(\.\d{1,3}){3}\b')]
    [string]$IPAddress = "192.168.0.1",

    [ValidateRange(1,32)]
    [int]$PrefixLength = 24,

    [ValidateNotNullOrEmpty()]
    [string]$NatName = "InternalNAT",

    [ValidatePattern('\b\d{1,3}(\.\d{1,3}){3}/\d{1,2}\b')]
    [string]$InternalIPPrefix = "192.168.0.0/24"
)

# Define variables
    #$SwitchName = "Internal"                                                    # TODO: Replace with your Internal Switch Name
    #$InterfaceAlias = "vEthernet ($SwitchName)"
    #$IPAddress = "192.168.0.1"                                                  # TODO: Replace with your IP Adress
    #$PrefixLength = 24
    #$NatName = "InternalNAT"
    #$InternalIPPrefix = "192.168.0.0/24"                                        # TODO: Replace with your IP prefix

# Step 1: Create Internal Virtual Switch if it doesn't exist
$InternalSwitch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue

if ($InternalSwitch -eq $null) {
    Write-Host "Creating Internal Virtual Switch named '$SwitchName'..."
    New-VMSwitch -Name $SwitchName -SwitchType Internal
} else {
    Write-Host "Internal Virtual Switch '$SwitchName' already exists."
}

# Wait for the virtual network adapter to be created
$WaitTime = 0
while ($WaitTime -lt 30 -and -not (Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 1
    $WaitTime++
}


# Step 2: Assign IP address to the host's virtual network adapter connected to the Internal switch
$HostAdapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue

# Retry if the adapter is not immediately available
$RetryCount = 0
While (($HostAdapter -eq $null) -and ($RetryCount -lt 5)) {
    Write-Host "Waiting for virtual network adapter '$InterfaceAlias' to be available..."
    Start-Sleep -Seconds 2
    $HostAdapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue
    $RetryCount++
}

if ($HostAdapter -ne $null) {
    # Check if the IP address is already assigned
    $ExistingIP = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -eq $IPAddress}

    if ($ExistingIP -eq $null) {
        Write-Host "Assigning IP address $IPAddress/$PrefixLength to interface '$InterfaceAlias'..."
        New-NetIPAddress -IPAddress $IPAddress -PrefixLength $PrefixLength -InterfaceAlias $InterfaceAlias
    } else {
        Write-Host "IP address $IPAddress/$PrefixLength is already assigned to interface '$InterfaceAlias'."
    }
} else {
    Write-Error "Virtual network adapter '$InterfaceAlias' not found. Please check the virtual switch creation."
    exit 1
}

# Step 3: Remove existing NAT configurations
$ExistingNat = Get-NetNat -Name $NatName -ErrorAction SilentlyContinue
if ($ExistingNat) {
    Write-Host "Removing existing NAT configuration '$NatName'..."
    Remove-NetNat -Name $NatName -Confirm:$false
} else {
    Write-Host "No existing NAT configuration named '$NatName' found."
}


# Step 4: Configure NAT for the internal network
Write-Host "Configuring NAT '$NatName' for internal network $InternalIPPrefix..."
New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix $InternalIPPrefix
