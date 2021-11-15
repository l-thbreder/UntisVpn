Param
  (
    [parameter(Mandatory=$false)]
    [String] $ConnectionName = "BKU",
	
	[parameter(Mandatory=$false)]
    [String] $VpnServerName = "vpn.intern.bkukr.de",

	[parameter(Mandatory=$false)]
    [String] $TunnelType = "SSTP",
	
	[parameter(Mandatory=$false)]
    [String] $DnsSuffix = "intern.bkukr.de",
	
	[parameter(Mandatory=$false)]
	$DnsServer = ("10.0.0.51", "10.32.0.51"),

    [parameter(Mandatory=$false)]
	[String]$DBServer = "MySQL" # or "SQL Server"
  )

$DBConnection = @("Server=services1.intern.bkukr.de", "Trusted_Connection=No", "Uid=DBUser", "Pwd=DBUserPassword", "Database=DBName")

# L�schen der VPN-Verbindung wenn sie vorhanden ist.
Get-VpnConnection -Name $ConnectionName | Remove-VpnConnection -Force -PassThru

# VPN-Verbindung mit den notwendigen Parametern neu anlegen.
Add-VpnConnection -Name $ConnectionName -ServerAddress $VpnServerName -TunnelType $TunnelType -DnsSuffix $DnsSuffix -EncryptionLevel "Required" -AuthenticationMethod MSChapv2 -RememberCredential -SplitTunneling -IdleDisconnectSeconds 300 -Force -PassThru

# Netzwerke, in denen keine VPN-Verbindung aufgebaut werden braucht. 
Add-VpnConnectionTriggerTrustedNetwork -ConnectionName $ConnectionName -DnsSuffix $DnsSuffix -Force -PassThru
Add-VpnConnectionTriggerDnsConfiguration -ConnectionName $ConnectionName -DnsSuffix $DnsSuffix -DnsIPAddress $DnsServer -Force -PassThru

# Alle Untis-Installationen als TriggerApplication der VPN-Verbiundung zuf�gen.
$UntisPaths = Resolve-Path -Path "C:\Program Files*\Untis\*\untis.exe"
Add-VpnConnectionTriggerApplication -ConnectionName $ConnectionName -ApplicationID $UntisPaths -Force -PassThru

<#
if (test-path -path "C:\Program Files (x86)\Untis\*\untis.exe") {
    $UntisPlatform = "32-bit"
} elseif (test-path -path "C:\Program Files\Untis\*\untis.exe") {
    $UntisPlatform = "64-bit"
}

$OdbcDriver = Get-OdbcDriver -Name ($DBServer +"*") -Platform $UntisPlatform
if ($OdbcDriver.Name -like "MySQL*") {
    Add-OdbcDsn -Name "Untis" -DriverName $OdbcDriver.Name -DsnType "User" -Platform $OdbcDriver.Platform -SetPropertyValue $DBConnection
}
#>