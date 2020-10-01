# BullPhish ID
Bullphish ID is a security awareness training and phishing resistance training will educate and empower your employees to avoid threats at work and at home.

## BullPhish Prepare ExchangeOnline Powershell Script
This Powershell Script is preparing your Exchange Online environment to bypass the antispam filters of Exchange Online.

## Quickstart
Just run the script. The script will ask you to authenticate agains your Microsoft 365 environment. The authentication method is supporting Multi-Factor Authentication.
```
PS C:\Users\T13nn3s\Scripts> .\BullPhishPrepareExchangeOnline.ps1
```

![Bullphish ID Powershell Prepare Exchange Online](https://i.imgur.com/G2QVz7n.png "Bullphish ID Powershell Prepare Exchange Online")


## IP Whitelist
These IP addresses are added to the whitelist of the Connection Filter:
  1) 168.245.13.192
  2) 3.17.161.215
  3) 18.223.13.154
  4) 3.18.16.105
  5) 3.18.67.92
  6) 3.17.244.221
  7) 3.18.32.205
  
## Transport rule
The script is adding and transport rule with the name 'Bullphish' with the following properties:

  1) E-mail messages coming from the IP addresses specified in the whitelist, the **email header X-Mailer-BullPhish** will be added with the value **true**.
  2) The spam score (SCL) is configured to *-1* (Bypass antispam filter).


