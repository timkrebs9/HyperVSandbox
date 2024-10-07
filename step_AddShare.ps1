# =====================================================================================================
# Purpose : Define and Add a Shared Folder for Data and File Exchange Between Hyper-V VM and Host
#
# =====================================================================================================

# Variables
$VMName = "YourVMName"                    # TODO: Name of your Hyper-V VM
$HostSharePath = Read-Host "Enter the host's shared folder path (e.g., \\vmshare):"  # User input for the share path
$VMShareMountPoint = "Z:"                 # TODO: Drive letter for mounting the shared folder in the VM
$VMUsername = "YourVMUsername"            # TODO: Username for the VM (use for network share access)
$VMPassword = "YourVMPassword"            # TODO: Password for the VM user (use for network share access)

# Function to check if the share path is accessible
function Test-HostShare {
    Write-Output "Testing if the share path is accessible from the host..."
    if (Test-Connection -ComputerName $HostSharePath.Split('\\')[2] -Count 1 -Quiet) {
        Write-Output "The share path is accessible."
    } else {
        Write-Output "Error: Unable to reach the specified share path. Please ensure it's available and try again."
        exit
    }
}

# Function to set up the shared folder on the VM
function Setup-VMShare {
    Write-Output "Configuring shared folder on the Hyper-V VM..."

    # Ensure the VM is running
    $vm = Get-VM -Name $VMName
    if ($vm.State -ne 'Running') {
        Write-Output "Starting VM '$VMName'..."
        Start-VM -Name $VMName
        Start-Sleep -Seconds 30  # Wait for VM to start
    }

    # Map the network drive inside the VM
    Invoke-Command -VMName $VMName -ScriptBlock {
        param ($HostShare, $MountPoint, $VMUsername, $VMPassword)

        # Check if the mount point (drive) is already in use
        if (Test-Path $MountPoint) {
            Write-Output "The mount point $MountPoint already exists. Skipping the mapping."
        } else {
            Write-Output "Mapping the shared folder $HostShare to drive $MountPoint on the VM."
            
            # Create credential object
            $securePassword = ConvertTo-SecureString $VMPassword -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ($VMUsername, $securePassword)

            # Map the network drive
            New-PSDrive -Name $MountPoint -PSProvider FileSystem -Root $HostShare -Credential $credential -Persist

            if (Test-Path $MountPoint) {
                Write-Output "Successfully mapped $HostShare to $MountPoint."
            } else {
                Write-Output "Failed to map the shared folder."
            }
        }
    } -ArgumentList $HostSharePath, $VMShareMountPoint, $VMUsername, $VMPassword

    Write-Output "Shared folder setup completed."
}

# Start Script Execution
Write-Output "=================== Starting VM Share Setup Process ==================="

# Check if the share path is accessible
Test-HostShare

# Set up the shared folder in the VM
Setup-VMShare

Write-Output "=================== VM Share Setup Process Completed ==================="
