# File: Tests\Configure-HostNetwork.Tests.ps1

Import-Module Pester

Describe "Configure-HostNetwork.ps1" {

    BeforeAll {
        # Import the script to test
        . "$PSScriptRoot\..\Configure-HostNetwork.ps1"
    }

    It "Should create an internal virtual switch named 'Internal'" {
        $switch = Get-VMSwitch -Name "Internal" -ErrorAction SilentlyContinue
        $switch | Should -Not -BeNullOrEmpty
        $switch.SwitchType | Should -Be 'Internal'
    }

    It "Should assign IP address 192.168.0.1 to the virtual network adapter" {
        $adapter = Get-NetAdapter -Name "vEthernet (Internal)" -ErrorAction SilentlyContinue
        $adapter | Should -Not -BeNullOrEmpty

        $ipAddress = Get-NetIPAddress -InterfaceAlias "vEthernet (Internal)" -ErrorAction SilentlyContinue
        $ipAddress.IPAddress | Should -Contain "192.168.0.1"
    }

    It "Should configure NAT named 'InternalNAT' for network 192.168.0.0/24" {
        $nat = Get-NetNat -Name "InternalNAT" -ErrorAction SilentlyContinue
        $nat | Should -Not -BeNullOrEmpty
        $nat.InternalIPInterfaceAddressPrefix | Should -Be "192.168.0.0/24"
    }
}
