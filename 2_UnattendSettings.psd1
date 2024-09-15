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
        ComputerName  = 'Sandbox'                       # TODO: Replace with your VM name
        Organization  = 'myavd'                         # TODO: Replace with your organization name
        Owner         = 'myavd'                         # TODO: Replace with your name
        Timezone      = 'W. Europe Standard Time'
        InputLocale   = 'de-DE'
        SystemLocale  = 'en-US'
        UserLocale    = 'en-US'
        IPAddress     = "192.168.0.10"                  # TODO: Replace with your IP address
        IPMask        = "24"
        IPGateway     = "192.168.0.1"                   # TODO: Replace with your gateway
        DNSIP         = "8.8.8.8"                       # TODO: Replace with your DNS server
    }
}
