function parse ([string]$Inputs) {
    $Param = if ($Inputs) { try { $Inputs | ConvertFrom-Json } catch { throw $_ }} else { [PSCustomObject]@{} }
    switch ($Param) {
        { !$_.File } { throw "Missing required parameter 'File'." }
        { !$_.Hash } { throw "Missing required parameter 'Hash'." }
    }
    $Param
}
$Param = parse $args[0]
$Text1 = "ファイルが悪性と判定されたため隔離しました。`r`nこのファイルが業務で利用する正規のファイルである場合は、以下の情報を情報システム部に連絡をしてください。`r`n`r`n"
$Text2 = "＜ファイル名＞`r`n"
$Text3 = "`r`n`r`n＜ハッシュ値＞`r`n"
$Message = @($Text1, $Text2, $Param.File, $Text3, $Param.Hash)
$Def = @"
using System;
using System.Runtime.InteropServices;
public class WTSMessage {
[DllImport("wtsapi32.dll", SetLastError = true)]
public static extern bool WTSSendMessage(
IntPtr hServer,
[MarshalAs(UnmanagedType.I4)] int SessionId,
String pTitle,
[MarshalAs(UnmanagedType.U4)] int TitleLength,
String pMessage,
[MarshalAs(UnmanagedType.U4)] int MessageLength,
[MarshalAs(UnmanagedType.U4)] int Style,
[MarshalAs(UnmanagedType.U4)] int Timeout,
[MarshalAs(UnmanagedType.U4)] out int pResponse,
bool bWait
);
static int response = 0;
public static int SendMessage(int SessionID, String Title, String Message, int Timeout, int MessageBoxType) {
WTSSendMessage(IntPtr.Zero, SessionID, Title, Title.Length, Message, Message.Length, MessageBoxType, Timeout, out response, true);
return response;
}
}
"@
if (!([System.Management.Automation.PSTypeName]'WTSMessage').Type) { Add-Type -TypeDefinition $Def }
$Out = ps -IncludeUserName | ? { $_.SessionId -ne 0 } | select SessionId, UserName | sort -Unique | % {
    $Result = if ($_.SessionId) {
        [WTSMessage]::SendMessage($_.SessionId,'CrowdStrike Falcon',$Message,0,0x00000040L)
    } else {
        "no_active_session"
    }
    [PSCustomObject] @{ Username = $_.UserName; Message  = if ($Result -eq 1) { $Param.Message } else { $Result }}
}
output $Out $Param "send_message.ps1"