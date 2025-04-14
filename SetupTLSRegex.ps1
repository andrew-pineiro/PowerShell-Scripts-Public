[CmdletBinding()]
param(
    [switch]$EnableTLS13
)
#Requires -RunAsAdministrator

$RootPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
$ValidProtocols = @("SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1", "TLS 1.2", "TLS 1.3")
$GoodProtocols = @("TLS 1.2", "TLS 1.3")
function CreateAndSetReg {
    param (
        [string]$Protocol
    )
    if([string]::IsNullOrEmpty($Protocol) -or $Protocol -notin $ValidProtocols) {
        Write-Host "Invalid Protocol Specified: $Protocol"
        return
    }
    $Enabled = 0
    if($Protocol -in $GoodProtocols) {
        $Enabled = 1
    }
    $DisabledByDefault = 1
    if($Protocol -in $GoodProtocols) {
        $DisabledByDefault = 0
    } 

    New-Item "$RootPath\$Protocol\Client" -Force | Out-Null
    New-Item "$RootPath\$Protocol\Server" -Force | Out-Null
    Set-ItemProperty -Path "$RootPath\$Protocol\Client" -Name 'Enabled' -Value $Enabled -Type 'DWORD' | Out-Null
    Set-ItemProperty -Path "$RootPath\$Protocol\Client" -Name 'DisabledByDefault' -value $DisabledByDefault -Type 'DWORD' | Out-Null
    Set-ItemProperty -Path "$RootPath\$Protocol\Server" -name 'Enabled' -value $Enabled -Type 'DWORD' | Out-Null
    Set-ItemProperty -Path "$RootPath\$Protocol\Server" -name 'DisabledByDefault' -value $DisabledByDefault -Type 'DWORD' | Out-Null
}

foreach($p in $ValidProtocols) {
    if(-not($EnableTLS13) -and $p -eq "TLS 1.3") {
        continue
    } 
    CreateAndSetReg $p
    Write-Host "Created Protocol Setup for $p"
}