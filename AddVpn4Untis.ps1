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
	$ConnectionIdleTimer = 60
  )

# Setzen der Ausführungsrichtline für den angemeldeten Benutzer
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force

# Löschen der VPN-Verbindung wenn sie vorhanden ist.
if (Get-VpnConnection -Name $ConnectionName) {
    Remove-VpnConnection -Name $ConnectionName -Force -PassThru
}

# VPN-Verbindung mit den notwendigen Parametern neu anlegen.
Add-VpnConnection -Name $ConnectionName -ServerAddress $VpnServerName -TunnelType $TunnelType -DnsSuffix $DnsSuffix -EncryptionLevel "Required" -AuthenticationMethod MSChapv2 -RememberCredential -SplitTunneling -IdleDisconnectSeconds $ConnectionIdleTimer -Force -PassThru

# Netzwerke, in denen keine VPN-Verbindung aufgebaut werden braucht. 
Add-VpnConnectionTriggerTrustedNetwork -ConnectionName $ConnectionName -DnsSuffix $DnsSuffix -Force -PassThru
Add-VpnConnectionTriggerDnsConfiguration -ConnectionName $ConnectionName -DnsSuffix $DnsSuffix -DnsIPAddress $DnsServer -Force -PassThru

# Alle Untis-Installationen als TriggerApplication der VPN-Verbiundung zufügen.
$UntisPaths = Resolve-Path -Path "C:\Program Files*\Untis\*\untis.exe"
Add-VpnConnectionTriggerApplication -ConnectionName $ConnectionName -ApplicationID $UntisPaths -Force -PassThru
