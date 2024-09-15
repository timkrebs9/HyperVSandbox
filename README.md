# Automated Hyper-V VM Setup with NAT and Proxy Configuration

This repository contains a set of PowerShell scripts and configuration files designed to automate the creation and configuration of a Hyper-V virtual machine (VM) environment. The scripts set up a Windows 11 VM connected to an internal virtual switch with NAT configured on the host for internet access. Additionally, it includes post-installation scripts for configuring networking within the VM, including installing certificates and setting proxy settings.

---

## Table of Contents

- [Automated Hyper-V VM Setup with NAT and Proxy Configuration](#automated-hyper-v-vm-setup-with-nat-and-proxy-configuration)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Overview](#overview)
  - [Script and Configuration Files](#script-and-configuration-files)
    - [1\_VMs.psd1](#1_vmspsd1)
    - [2\_UnattendSettings.psd1](#2_unattendsettingspsd1)
    - [3\_PostInstallScripts.psd1](#3_postinstallscriptspsd1)
    - [4\_HostNetworkSettings.psd1](#4_hostnetworksettingspsd1)
    - [Configure-HostNetwork.ps1](#configure-hostnetworkps1)
    - [step\_DoWindowsUpdates.ps1](#step_dowindowsupdatesps1)
    - [step\_ConfigureVMNetworking.ps1](#step_configurevmnetworkingps1)
  - [Usage Instructions](#usage-instructions)
    - [1. Set Up Host Network Settings](#1-set-up-host-network-settings)
    - [2. Configure VM Settings](#2-configure-vm-settings)
    - [3. Configure Unattended Installation Settings](#3-configure-unattended-installation-settings)
    - [4. Define Post-Installation Scripts](#4-define-post-installation-scripts)
    - [5. Execute VM Creation and Configuration](#5-execute-vm-creation-and-configuration)
  - [Purpose of Each Script](#purpose-of-each-script)
    - [Configure-HostNetwork.ps1](#configure-hostnetworkps1-1)
    - [1\_VMs.psd1](#1_vmspsd1-1)
    - [2\_UnattendSettings.psd1](#2_unattendsettingspsd1-1)
    - [3\_PostInstallScripts.psd1](#3_postinstallscriptspsd1-1)
    - [4\_HostNetworkSettings.psd1](#4_hostnetworksettingspsd1-1)
    - [step\_DoWindowsUpdates.ps1](#step_dowindowsupdatesps1-1)
    - [step\_ConfigureVMNetworking.ps1](#step_configurevmnetworkingps1-1)
  - [Notes and Troubleshooting](#notes-and-troubleshooting)
  - [License](#license)

---

## Prerequisites

- **Operating System:** Windows 10 or Windows Server with Hyper-V installed and enabled.
- **Permissions:** Administrative privileges to execute PowerShell scripts and modify system settings.
- **PowerShell Execution Policy:** Set to allow script execution. You can set it using:

  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- **Golden Image VHDX:** A Windows 11 VHDX file located at `C:\temp\HyperVSandbox\VHDX\Win11_23H2.vhdx` or modify the path in `1_VMs.psd1`.

- **Certificate File:** A certificate file to be installed on the VM, placed at `C:\CertStore\<CERT-NAME>.cer`.

- **Proxy Server Details:** Proxy server address and port to be configured in the VM.

---

## Overview

The automation process involves:

1. **Configuring the Host Network:**
   - Creating an internal virtual switch named `Internal`.
   - Assigning an IP address to the host's virtual network adapter.
   - Configuring NAT on the host to allow VMs on the internal network to access the internet.

2. **Creating and Configuring the VM:**
   - Defining VM settings in `1_VMs.psd1`.
   - Setting up unattended installation settings in `2_UnattendSettings.psd1`.
   - Executing post-installation scripts defined in `3_PostInstallScripts.psd1`.

3. **Running Post-Installation Scripts on the VM:**
   - Updating Windows.
   - Installing certificates.
   - Configuring proxy settings.

---

## Script and Configuration Files

### 1_VMs.psd1

Defines the VM configuration, including:

- VM name and path.
- Memory and processor count.
- Network adapters connected to the internal switch.

### 2_UnattendSettings.psd1

Contains unattended installation settings for the VM, such as:

- Computer name.
- Localization settings.
- Static IP configuration.

### 3_PostInstallScripts.psd1

Lists the post-installation scripts to be executed on the VM in order.

### 4_HostNetworkSettings.psd1

Stores host network configuration settings, including:

- Virtual switch name.
- Interface alias.
- IP addressing for the host's virtual adapter.
- NAT configuration.

### Configure-HostNetwork.ps1

A PowerShell script that:

- Creates the internal virtual switch.
- Assigns IP addresses to the host's virtual adapter.
- Configures NAT for internet access.

### step_DoWindowsUpdates.ps1

A script executed on the VM to:

- Search for and install Windows updates.
- Log the update process.

### step_ConfigureVMNetworking.ps1

A script executed on the VM to:

- Install a certificate.
- Configure proxy settings for all users.
- Log the configuration process.

---

## Usage Instructions

### 1. Set Up Host Network Settings

Run the `Configure-HostNetwork.ps1` script to set up the host's network configuration.

```powershell
# Open PowerShell as Administrator
.\Configure-HostNetwork.ps1
```

This script will:

- Create the internal virtual switch if it doesn't exist.
- Assign the specified IP address to the host's virtual network adapter.
- Configure NAT to allow internet access from the internal network.

### 2. Configure VM Settings

Edit the `1_VMs.psd1` file to define your VM settings.

```powershell
@{
    'VM0' = @{
        vmName                = "Sandbox"
        vmPath                = ""
        GoldenImagePath       = "C:\temp\HyperVSandbox\VHDX\Win11_23H2.vhdx"
        vmMemory              = 4GB
        vmGeneration          = 2
        vmProcCount           = 2
        vmAutomaticStopAction = "ShutDown"
        vmNics                = @{
            "aMGMT" = @{"Switch" = "Internal"; "VLANID" = "" }
        }
        vmDataDisks           = @()
    }
}
```

Ensure that:

- The `GoldenImagePath` points to your Windows 11 VHDX file.
- The network adapter is connected only to the internal switch.

### 3. Configure Unattended Installation Settings

Edit the `2_UnattendSettings.psd1` file to set up unattended installation parameters.

```powershell
@{
    VM0 = @{
        ComputerName  = 'Sandbox'
        Organization  = 'myavd'
        Owner         = 'myavd'
        Timezone      = 'W. Europe Standard Time'
        InputLocale   = 'de-DE'
        SystemLocale  = 'en-US'
        UserLocale    = 'en-US'
        IPAddress     = "192.168.0.10"
        IPMask        = "24"
        IPGateway     = "192.168.0.1"
        DNSIP         = "8.8.8.8"
    }
}
```

Make sure:

- The `IPAddress` does not conflict with the host's IP.
- The `IPGateway` is set to the host's virtual adapter IP (`192.168.0.1`).
- DNS servers are reachable.

### 4. Define Post-Installation Scripts

Edit `3_PostInstallScripts.psd1` to specify scripts to run after the VM is set up.

```powershell
@{
    VM0 = @{
        vmPostInstallSteps = @(
            @{
                stepHeadline    = 'Step0 - TimeStamp'
                scriptFilePath  = 'step_AddDateTimeToLog.ps1'
                requiresRestart = $false
            }
            @{
                stepHeadline    = 'Step1 - WindowsUpdate'
                scriptFilePath  = 'step_DoWindowsUpdates.ps1'
                requiresRestart = $true
            }
            @{
                stepHeadline    = 'Step2 - ConfigureVMNetworking'
                scriptFilePath  = 'step_ConfigureVMNetworking.ps1'
                requiresRestart = $true
            }
        )
    }
}
```

### 5. Execute VM Creation and Configuration

Run your VM deployment script or process that uses the above configuration files to create and configure the VM. Ensure that the scripts `step_DoWindowsUpdates.ps1` and `step_ConfigureVMNetworking.ps1` are accessible to the VM during post-installation.

---

## Purpose of Each Script

### Configure-HostNetwork.ps1

Automates the creation of the internal virtual switch and configures NAT on the host to provide internet access to VMs connected to the internal network.

### 1_VMs.psd1

Defines the VM's hardware settings and network configuration for creation in Hyper-V.

### 2_UnattendSettings.psd1

Provides settings for an unattended Windows installation, automating the setup of the operating system within the VM.

### 3_PostInstallScripts.psd1

Lists the scripts to be executed inside the VM after the OS installation, specifying the order and whether a restart is required.

### 4_HostNetworkSettings.psd1

Contains configuration data for the host network settings used by `Configure-HostNetwork.ps1`.

### step_DoWindowsUpdates.ps1

Executed within the VM to search for, download, and install all available Windows updates, logging the process.

### step_ConfigureVMNetworking.ps1

Executed within the VM to:

- Install a specified certificate into the local machine's root certificate store.
- Configure system-wide proxy settings for all users.
- Log the actions taken.

---

## Notes and Troubleshooting

- **Administrative Privileges:** Ensure all scripts are run with administrative privileges to allow for system configuration changes.

- **Execution Policy:** If you encounter issues running scripts due to execution policies, adjust the policy using:

  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- **Certificate Installation:**
  - Place your certificate file at `C:\CertStore\<CERT-NAME>.cer`.
  - Replace `<CERT-NAME>` in `step_ConfigureVMNetworking.ps1` with your actual certificate file name.

- **Proxy Configuration:**
  - Update the `$proxyServer` variable in `step_ConfigureVMNetworking.ps1` with your actual proxy server details.
  - Ensure the proxy settings are compatible with your network environment.

- **VM Network Connectivity:**
  - If the VM cannot access the internet, verify that:
    - The NAT configuration on the host is correct.
    - The VM's network settings are properly configured.
    - Firewall settings are not blocking traffic.

- **Logging:**
  - Logs for post-installation scripts are stored in `C:\temp` within the VM.
  - Review these logs to troubleshoot any issues with script execution.

- **Order of Execution:**
  - Steps in `3_PostInstallScripts.psd1` are executed based on the `stepHeadline` in alphabetical order.
  - Adjust numbering (`Step0`, `Step1`, `Step2`, etc.) to control execution order.

- **Testing:**
  - Before deploying to production environments, test the entire setup in a controlled environment to ensure all scripts perform as expected.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Disclaimer:** Use these scripts at your own risk. Always ensure you have backups and have tested the scripts in a non-production environment before deploying.