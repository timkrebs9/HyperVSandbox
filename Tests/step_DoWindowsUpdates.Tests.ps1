# File: Tests\step_DoWindowsUpdates.Tests.ps1

Import-Module Pester

Describe "step_DoWindowsUpdates.ps1" {

    It "Should run without throwing any exceptions" {
        { . "$PSScriptRoot\..\step_DoWindowsUpdates.ps1" } | Should -Not -Throw
    }
}
