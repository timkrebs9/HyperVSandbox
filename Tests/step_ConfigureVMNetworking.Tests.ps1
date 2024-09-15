# File: Tests\step_ConfigureVMNetworking.Tests.ps1

Import-Module Pester

Describe "step_ConfigureVMNetworking.ps1" {

    It "Should install the certificate" {
        # Assuming the certificate is installed, check if it exists
        $cert = Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object { $_.Subject -eq "CN=YourCertName" }
        $cert | Should -Not -BeNullOrEmpty
    }

    It "Should configure proxy settings in the registry" {
        $registryPath = "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"
        $proxyEnable = Get-ItemProperty -Path $registryPath -Name "ProxyEnable" -ErrorAction SilentlyContinue
        $proxyEnable.ProxyEnable | Should -Be 1
    }
}
