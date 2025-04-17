#Requires -RunAsAdministrator

[CmdletBinding()]
param(
)

$RootPath = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"
# Ciphers listed in https://ciphersuite.info/cs/?security=insecure that are enabled on IIS by default (Windows Server 2016)
$BadCiphers = @("DES 56/56", "RC2 40/128", "RC4 56/128", "RC4 128/128", "Triple DES 168")
$BadCertCiphers = @("TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA","TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA","TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256","TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA","TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384","TLS_RSA_WITH_AES_128_CBC_SHA","TLS_RSA_WITH_AES_128_CBC_SHA256","TLS_RSA_WITH_AES_128_GCM_SHA256","TLS_RSA_WITH_AES_256_CBC_SHA","TLS_RSA_WITH_AES_256_CBC_SHA256","TLS_RSA_WITH_AES_256_GCM_SHA384")
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

foreach($cc in $BadCertCiphers) {
    Disable-TlsCipherSuite -Name $cc
    Write-Host "Disabled Cert Cipher: $cc"
}