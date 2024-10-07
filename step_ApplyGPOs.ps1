# =====================================================================================================
# Purpose : Export GPOs from Host Machine and Import into Hyper-V VM
#
# =====================================================================================================

# Variables
$BackupDirectory = "C:\Users\timkrebs\OneDrive - Microsoft\Dokumente\06_DSE_EDE\004_BA\0002_HyperVSandbox\HyperVSandbox\GPOs"   # TODO: Local backup directory for GPOs
$VMName = "YourVMName"                                                                                                          # TODO: Name of your Hyper-V VM
$VMGpoBackupDirectory = "C:\VM_GPO_Backups"                                                                                     # TODO: Destination directory inside the VM for GPOs

# Function to export GPOs
function Export-GPOs {
    Write-Output "Checking if GPOs have been backed up already..."
    if (Test-Path -Path "$BackupDirectory") {
        Write-Output "GPO backup folder exists. Checking contents..."
        $existingGPOs = Get-ChildItem -Path $BackupDirectory
        if ($existingGPOs.Count -gt 0) {
            Write-Output "GPOs already exist in $BackupDirectory, skipping export."
        } else {
            Write-Output "No GPOs found in backup folder, exporting GPOs now."
            Get-GPO -All | ForEach-Object {
                Backup-GPO -Name $_.DisplayName -Path $BackupDirectory
            }
        }
    } else {
        Write-Output "GPO backup folder does not exist. Creating folder and exporting GPOs..."
        New-Item -ItemType Directory -Path $BackupDirectory -Force
        Get-GPO -All | ForEach-Object {
            Backup-GPO -Name $_.DisplayName -Path $BackupDirectory
        }
    }
}

# Function to copy GPOs to VM
function Copy-GPOsToVM {
    Write-Output "Transferring GPO backups to the Hyper-V VM..."
    Copy-VMFile -Name $VMName -SourcePath $BackupDirectory -DestinationPath $VMGpoBackupDirectory -CreateFullPath -FileSource Host
    Write-Output "GPOs transferred to VM successfully."
}

# Function to import GPOs on the VM
function Import-GPOsToVM {
    Write-Output "Connecting to the Hyper-V VM to import GPOs..."
    Invoke-Command -VMName $VMName -ScriptBlock {
        $BackupLocation = "C:\VM_GPO_Backups"
        Get-ChildItem -Path $BackupLocation | ForEach-Object {
            Import-GPO -BackupId $_.Name -Path $BackupLocation -TargetName $_.Name
        }
        Write-Output "GPOs imported successfully on the VM."
    }
}

# Start Script Execution
Write-Output "=================== Starting GPO Export/Import Process ==================="

# Export GPOs from the host machine
Export-GPOs

# Copy GPOs to Hyper-V VM
Copy-GPOsToVM

# Import GPOs on the Hyper-V VM
Import-GPOsToVM

Write-Output "=================== GPO Export/Import Process Completed ==================="
