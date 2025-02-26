
<# USER CONFIG ###############################################################################>
$AuditMessage = 'Sensor-Tag Replace Real-Time Response script'
$Hostname = "https://api.crowdstrike.com"
$Id = ''
$Secret = ''
<############################################################################### USER CONFIG #>

# Parse Input Tags
function parse ([string]$Inputs) {
$Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
switch ($Param) {
    { !$_.Tags } { throw "Missing required parameter 'Tags'." }
}
$Param
}

# API Access
function Invoke-Falcon ($Uri, $Method, $Headers, $Body) {
    $Request = [System.Net.WebRequest]::Create($Uri)
    $Request.Method = $Method
    switch ($Headers.GetEnumerator()) {
        { $_.Key -eq 'accept' } {
            $Request.Accept = $_.Value
        }
        { $_.Key -eq 'content-type' } {
            $Request.ContentType = $_.Value
        }
        default {
            $Request.Headers.Add($_.Key, $_.Value)
        }
    }
    $RequestStream = $Request.GetRequestStream()
    $StreamWriter = [System.IO.StreamWriter]($RequestStream)
    $StreamWriter.Write($Body)
    $StreamWriter.Flush()
    $StreamWriter.Close()
    $Invoke = try {
        $Response = $Request.GetResponse()
        $ResponseStream = $Response.GetResponseStream()
        $StreamReader = [System.IO.StreamReader]($ResponseStream)
        ConvertFrom-Json ($StreamReader.ReadToEnd())
    } catch {
        $_
    }
    return $Invoke
}
Add-Type -AssemblyName System.Net.Http

# HostId value from registry
$HostId = ([System.BitConverter]::ToString(((Get-ItemProperty ("HKLM:\SYSTEM\CrowdStrike\" +
"{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\{16e0423f-7058-48c9-a204-725362b67639}" +
"\Default") -Name AG).AG)).ToLower() -replace '-','')

if ((-not $Id) -or (-not $Secret)) {
    throw "API credentials not configured in script"
}
if (-not $HostId) {
    throw "Unable to retrieve host identifier"
}
$Param = @{
    Uri = "$($Hostname)/oauth2/token"
    Method = 'post'
    Headers = @{
        accept = 'application/json'
        'content-type' = 'application/x-www-form-urlencoded'
    }
    Body = "client_id=$Id&client_secret=$Secret"
}
$Token = Invoke-Falcon @Param

if (-not $Token.access_token) {
    throw "Unable to request token"
}
$Param = @{
    Uri = "$($Hostname)/policy/combined/reveal-uninstall-token/v1"
    Method = 'post'
    Headers = @{
        accept = 'application/json'
        'content-type' = 'application/json'
        authorization = "$($Token.token_type) $($Token.access_token)"
    }
    Body = @{
        audit_message = $AuditMessage
        device_id = $HostId
    } | ConvertTo-Json
}
$Request = Invoke-Falcon @Param

if (-not $Request.resources) {
    throw "Unable to retrieve uninstall token"
}
$Uninstall = $($Request.resources.uninstall_token)
$Param = parse $args[0]
$Tags = $Param.Tags

echo $Uninstall | & "C:\Program Files\CrowdStrike\CsSensorSettings.exe" set --grouping-tags $Tags