# Block Notification with FileName

# Parse Input Filepath
function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.File } { throw "Missing required parameter 'File'." }
    }
    $Param
}

# Toast Function
Function New-ToastNotification {
    Param($MsgSender, $Message, $Detail)
 
    # Required parameters
    $AudioSource = "ms-winsoundevent:Notification.Default"
    $HeaderFormat = "ImageAndTitle" # Choose from "TitleOnly", "ImageOnly" or "ImageAndTitle"
    $Base64Image = "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"
 
    # Create an image file from base64 string and save to user temp location
    If ($Base64Image) {
        $ImageFile = "$env:Temp\ToastLogo.png"
        [byte[]]$Bytes = [convert]::FromBase64String($Base64Image)
        [System.IO.File]::WriteAllBytes($ImageFile, $Bytes)
    }
 
    # Load namespaces
    $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
 
    # Register the AppID in the registry for use with the Action Center, if required
    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    $AppID = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe"
    $RegPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'
 
    if (!(Test-Path –Path "$RegPath\$AppId")) {
        $null = New-Item –Path "$RegPath\$AppId" –Force
        $null = New-ItemProperty –Path "$RegPath\$AppId" –Name 'ShowInActionCenter' –Value 1 –PropertyType 'DWORD'
    }
 
    # XML format
    [xml]$ToastTemplate = @"
<toast duration="long">
<visual>
<binding template="ToastGeneric">
<text>$MsgSender</text>
<image placement="appLogoOverride" hint-crop="Default" src="$ImageFile"/>
<text>$Message</text>
<text>$Detail</text>
</binding>
</visual>
<audio src="$AudioSource"/>
</toast>
"@
     
 
    # Load the notification
    $ToastXml = New-Object –TypeName Windows.Data.Xml.Dom.XmlDocument
    $ToastXml.LoadXml($ToastTemplate.OuterXml)
 
    # Display
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($ToastXml)
}

# Define Toast Messages

$MsgSender = "CrowdStrike Falcon Sensor"
$Message = "ファイルが隔離されました"
$Param = parse $args[0]
$Detail = $Param.File
Invoke-Command –ScriptBlock ${function:New-ToastNotification} –ArgumentList $MsgSender, $Message, $Detail