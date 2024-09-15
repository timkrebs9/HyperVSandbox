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


@{
    VM0 = @{
        vmPostInstallSteps = @(
            @{
                stepHeadline    = 'Step0 - TimeStamp'           # Headline of the step - ! steps will be performed in alphabetical order !
                scriptFilePath  = 'step_AddDateTimeToLog.ps1'   # Path to the script to be executed
                requiresRestart = $false                        # Does the step require a restart of the VM?
            }
            #@{
            #    stepHeadline    = 'Step1 - WindowsUpdate'       # Headline of the step - ! steps will be performed in alphabetical order !
            #    scriptFilePath  = 'step_DoWindowsUpdates.ps1'   # Path to the script to be executed
            #    requiresRestart = $false                        # Does the step require a restart of the VM?
            #}
            @{
                stepHeadline    = 'Step1 - ConfigureVMNetworking'    # New step
                scriptFilePath  = 'step_ConfigureVMNetworking.ps1'
                requiresRestart = $true                             # Set to $true if a restart is required
            }
        )
    }
}