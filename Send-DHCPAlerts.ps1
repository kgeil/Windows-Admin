<#
    .SYNOPSIS 
      Sends alerts based on certain DHCP events or configurations
    .Example
      DHCPEmail -DhcpServer MyDHCPServer -scope 10.50.0.0 -SMTPServer MySMTPServer -FromEmail monitoring@example.org -ToEmail admin1@example.org,admin2@example.org

#>
#TODO 1. Provide parameter for log file path
#TODO 2. Make email functionality optional
#TODO 3. Add send-to-syslog functionality, likely using Jason Fossen's script
Function DHCPEmail ($DhcpServer, $scope, $SMTPServer, $FromEmail, $ToEmail)
{
$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@
  $datetime= Get-Date #| Out-String
  $LeaseInfo = Get-DhcpServerv4Lease -scopeID $scope -ComputerName $DhcpServer | select -Property ClientID, Hostname, AddressState | where {$_.AddressState -eq "Active"}
  $Body = $LeaseInfo | ConvertTo-Html -Head $Header
  IF ($LeaseInfo) 
  {
      Send-MailMessage  -SmtpServer $SMTPServer -From $FromEmail -To $ToEmail -Subject "DHCP Lease without Reservation Detected" -BodyAsHtml "$Body"
          ForEach($_ in $leaseinfo)
              {"$datetime DHCP Lease without Reservation Detected $_" | Out-File -Append -FilePath .\dhcpscript.log}  
  }
    Else 
    {
    #$outstring = $datetime 
    "$datetime  No non-reserved dhcp leases detected for $dhcpserver for scope $scope" | Out-File -Append -FilePath .\dhcpscript.log  
    }
  #$LeaseInfo = $null
}


