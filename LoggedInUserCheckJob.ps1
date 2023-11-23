 
 
#variables below
 
#DEFINE 1ST ACCOUNT TO CHECK
$server1   = "redacted"
$username1 = "redacted"
 
#DEFINE 2ND ACCOUNT TO CHECK
$server2   = "redacted"
$username2 = "redacted"
 
#DEFINE 3RD ACCOUNT TO CHECK
$server3   = "redacted"
$username3 = "redacted"
 
#Get redacted's credentials since quser command on redacted is only responding if it's invoked by a server admin
$User2 = 'redacted'
$Pass2 = ConvertTo-SecureString -String 'redacted' -AsPlainText -Force
$RedactedAccount = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User2, $Pass2
 
#Get redacted's credentials since quser command on redacted is only responding if it's invoked by a server admin
$User3 = 'redacted'
$Pass3 = ConvertTo-SecureString -String 'redacted' -AsPlainText -Force
$RedactedAccount2 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User3, $Pass3
 
#how we will know if the run was a success or not
$HasError = $false
 
#email recipents
$SuccessRecipients = redacted@redacted.com
$ErrorRecipients = redacted@redacted.com
 
#Functions Below
 
#run quser command to see if user is logged in
function IsUserLoggedIn
{
    param (
    [string] $Server,
    [string] $Username
    )
 
    $output = Invoke-Expression "quser /SERVER:$Server"
 
    #check each line
    foreach ($line in $output)
    {
   #If line contains username, return true
        if ($line -match $Username)
        {
            return $true
        }
    }
    #if match is not found return false
    return $false
}
 
 
function IsUserLoggedInUsingCredentials
{
    param (
    [string] $Server,
    [string] $Username,
    [System.Management.Automation.PSCredential] $Credential
    )
 
    $ScriptBlock = { quser /SERVER:$Server }
 
    $output = Invoke-Command -ComputerName $Server -Credential $Credential -ScriptBlock $ScriptBlock
 
    foreach ($line in $output)
    {
    #If line contains username, return true
        if ($line -match $Username)
        {
            return $true
        }
    }
    #if match is not found return false
    return $false
 
 
}
 
#logging function
function Write-Log {
   
    param(
    [Parameter(Mandatory=$true)]
    [string] $Message,
 
    [Parameter(Mandatory=$false)]
    [ValidateSet("INFO","Warning","Error","DEBUG")]
    [string] $Level = "INFO"
    )
 
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 
    Out-File -FilePath $logfile -Append -InputObject "$timeStamp [$Level] $Message"
}
 
#main script below
 
#get the montth
$date = Get-Date -Format "yyyy-MM"
 
#only making a new log file once a month
$logfile = "C:\redacted\ServerLoggedInUserCheck\logs\$date.log"
 
$Check1Message =  ""
if (IsUserLoggedIn -Server $server1 -Username $username1)
{
 
    $Check1Message = (Get-Date).ToString() + " CHECK 1: (SUCCESS) $username1 is logged into $server1."
 
    Write-Log "CHECK 1: (SUCCESS) $username1 is logged into $server1."
 
}
else
{
    $HasError = $true
 
    $Check1Message = (Get-Date).ToString() + " CHECK 1: (FAILURE)  $username1 is not logged into $server1."
 
    Write-Log  -Level Error "CHECK 1: (FAILURE)  $username1 is not logged into $server1."
}
 
$Check2Message =  ""
if (IsUserLoggedInUsingCredentials -Server $server2 -Username $username2 -Credential $RedactedAccount)
{
    $Check2Message = (Get-Date).ToString() + " CHECK 2: (SUCCESS) $username2 is logged into $server2."
 
    Write-Log "CHECK 2: (SUCCESS) $username2 is logged into $server2."
 
}
else
{
    $HasError = $true
 
    $Check2Message = (Get-Date).ToString() + " CHECK 2: (FAILURE)  $username2 is not logged into $server2."
 
    Write-Log  -Level Error "CHECK 2: (FAILURE)  $username2 is not logged into $server2."
}
 
$Check3Message =  ""
if (IsUserLoggedInUsingCredentials -Server $server3 -Username $username3 -Credential $RedactedAccount2)
{
    $Check3Message = (Get-Date).ToString() + " CHECK 3: (SUCCESS) $username3 is logged into $server3."
 
    Write-Log "CHECK 3: (SUCCESS) $username3 is logged into $server3."
 
}
else
{
    $HasError = $true
 
    $Check3Message = (Get-Date).ToString() + " CHECK 3: (FAILURE)  $username3 is not logged into $server3."
 
    Write-Log  -Level Error "CHECK 3: (FAILURE)  $username3 is not logged into $server3."
}
 
#operations to get the subject for email
$Notif = ""
if ($HasError)
{
    $Notif = "(FAILURE)"
}
else
{
    $Notif = "(SUCCESS)"
}
 
$currTime = Get-Date
$subject =""
 
if ($currTime.Hour -eq 7)
{
    $subject = $Notif + " - ServerLoggedInUserCheck - Morning Report"
}
else
{
    $subject = $Notif + " - ServerLoggedInUserCheck - Afternoon Report"
}
 
#put check 1/2/3 on seperate lines in the email
$EmailBody = $Check1Message + "<br />" + $Check2Message + "<br />" + $Check3Message
 
#sending email to different groups depending on whether it has an error or not
if ($HasError)
{
    Send-MailMessage -From redacted@redacted.com -To $ErrorRecipients -Subject $subject -Body $EmailBody -BodyAsHtml -SmtpServer "redacted.redacted.com"
    
}
else
{
                #removing success email
     Send-MailMessage -From redacted@redacted.com -To $SuccessRecipients -Subject $subject -Body $EmailBody -BodyAsHtml -SmtpServer "redacted.redacted.com"
}
