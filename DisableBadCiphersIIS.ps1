#Requires -RunAsAdministrator

[CmdletBinding()]
param(
)

$RootPath = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"
$BadCiphers = @("DES 56/56", "RC2 40/128", "RC4 56/128")

function CreateAndSetReg {
    param(
        [string]$Cipher
    )
    if([string]::IsNullOrEmpty($Cipher)) {
        return
    }
    (Get-Item HKLM:).OpenSubKey($RootPath,$true).CreateSubKey($Cipher) | Out-Null
    New-ItemProperty -Path "HKLM:\$RootPath\$Cipher" -Name 'Enabled' -Value 0 -Type 'DWORD' | Out-Null
}
    
foreach($c in $BadCiphers) {
    CreateAndSetReg $c
    Write-Host "Disabled Cipher: $c"
}