<#
.DESCRIPTION
    Script is automatically configuring the Exchange Online tenant to receive mail from BullPhish.
.NOTES
    Created by: T13nn3s
    Date: 21-09-2020
    Version: 1.0
#>

# Parameters
$WhitelistIPs = @(
    "168.245.13.192",
    "3.17.161.215"
    "18.223.13.154",
    "3.18.16.105",
    "3.18.67.92",
    "3.17.244.221",
    "3.18.32.205"
)

$TransPortRuleNameBullphish = "BullPhish"

# Check if the ExchangeOnlineManagement Module is available
if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "ExchangeOnlineManagement module is not installed. Please install this module first."
    Write-Host "Module can be installed by running this command 'Install-Module -Name ExchangeOnlineManagement' elevated Windows PowerShell window" -ForegroundColor Yellow
    exit 1
}
Else {
    Write-Host "ExchangeOnlineManagement module is installed."
}

Try {
    Write-Host "[*] Try to import the ExchangeOnlineManagement Module..."
    Import-Module ExchangeOnlineManagement
    Write-Host "[*] Try to import the ExchangeOnlineManagement Module...Done"
}
Catch {
    $errormessage = $_.exception.Message
    Write-Host "[-] Try to import the ExchangeOnlineManagement Module...Failed Error: $errormessage" -ForegroundColor Red
    exit 1
}

Try {
    Write-Host "[*] Connect to Exchange Online..."
    Connect-ExchangeOnline -ShowBanner:$false
    sleep 5 # relax
    Write-Host "[*] Connect to Exchange Online...Done"
}
Catch {
    $errormessage = $_.exception.Message
    Write-Host "[-] Connect to Exchange Online...Failed Error: $errormessage" -ForegroundColor Red
    Exit 1
}

# Configuring the Connection Filter
try {
    Write-Host "[*] Configuring the Connection Filter..."
    Get-HostedConnectionFilterPolicy | Select-Object IPAllowList | ForEach-Object {
        foreach ($ip in $WhitelistIPs) {
            if ($_.ipallowlist -like $ip) {
                Write-Host "[+] $($ip) already on the whitelist" -ForegroundColor Green
            }
            Else {
                Write-Host "[*] $($ip) not on the allowlist, adding $($ip) now..."
                try {
                    Set-HostedConnectionFilterPolicy "Default" -IPAllowList @{Add = "$ip" }
                    Write-Host "[+] $($ip) not on the allowlist, adding $($ip) now...Done" -ForegroundColor Green
                }
                Catch {
                    $errormessage = $_.exception.Message
                    Write-Host "[+] $($ip) not on the allowlist, adding $($ip) now...Failed Error: $Errormessage" -ForegroundColor Red
                    exit 1
                }
            }
        }
    }
    Write-Host "[*] Configuring the Connection Filter...Done"
}
Catch {
    $errormessage = $_.exception.Message
    Write-Host "[-] Configuring the Connection Filter...Failed Error:$errormessage"
    exit 1
}

# Configuring the Mail Flow rules
$TransPortRule = Get-TransportRule $TransPortRuleNameBullphish
if ($TransPortRule) {
    Write-Host "[+] Rule already exists. No action needed." -ForegroundColor Green   
    Write-Host "[+] All Done!"
    exit 1
}
Else {

    # Creating and configuring the Transport rule
    Write-Host "[*] TransPortRule with name $($TransPortRuleNameBullphish) not present. Creating and configuring the rule..."
    Try {
        New-TransportRule -Name $TransPortRuleNameBullphish -SenderIpRanges $WhitelistIPs -SetHeaderName "X-Mailer-BullPhish" -SetHeaderValue "true" -SetSCL "-1" | Out-Null
        Write-Host "[+] TransPortRule with name $($TransPortRuleNameBullphish) created and configured." -ForegroundColor Green
    }
    Catch {
        $errormessage = $_.exception.Message
        Write-Host "[-] TransPortRule with name $($TransPortRuleNameBullphish) creation or configuration failed. Error: $errormessage"
        exit 1    
    }  
}
