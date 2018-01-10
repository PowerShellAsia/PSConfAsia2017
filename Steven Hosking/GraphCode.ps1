#go to https://apps.dev.microsoft.com and create a new application to get the Client ID and Secrect with the required level of access.
$clientid = ""
$clientSecret = ""
$useremail = "User@mail.com"
$resource = "https://graph.microsoft.com"
$prompt = "login"

function get-GraphAPIToken
{
  param
  (
    [String]
    [Parameter(Mandatory)]
    $clientSecret,
    [String]
    [Parameter(Mandatory)]
    $clientid,
    [string]
    [Parameter(Mandatory)]
    $Redirecturi,
    [string]
    [Parameter(Mandatory)]
    $resource,
    [string]
    [Parameter(Mandatory)]
    $useremail,
    [string]
    [ValidateSet('admin_consent','login','consent')]
    $PromptType 
  )

  Add-Type -AssemblyName system.web
  #encoded Variables for the oauth string. 
  $clientIDEncoded = [Web.HttpUtility]::UrlEncode($clientid)
  $clientSecretEncoded = [Web.HttpUtility]::UrlEncode($clientSecret)
  $redirectUriEncoded =  [Web.HttpUtility]::UrlEncode($redirectUri)
  $resourceEncoded = [Web.HttpUtility]::UrlEncode($resource)

  # Get oauth2 Code
  $url = ('https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&redirect_uri={0}&client_id={1}&resource={2}&prompt={3}&login_hint={4}' -f $redirectUriEncoded, $clientIDEncoded, $resourceEncoded, $prompttype, $useremail)

  # Pops a window to Authenticate to Microsoft Online.
  $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=420;Height=600}
  $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=420;Height=600;Url=$url}
  $DocComp  = {$script:uri = $web.Url.AbsoluteUri; if ($script:uri -match "error=[^&]*|code=[^&]*") {$form.Close()}}
  $web.ScriptErrorsSuppressed = $true
  $web.Add_DocumentCompleted($DocComp)
  $form.Controls.Add($web)
  $form.Add_Shown({$form.Activate()})
  $null = $form.ShowDialog()
  $authCode = ([Web.HttpUtility]::ParseQueryString($web.Url.Query))["code"]

  # Convert the oAuth2 code into a Token.
  $body = ('grant_type=authorization_code&redirect_uri={0}&client_id={1}&client_secret={2}&code={3}&resource={4}' -f $redirectUri, $clientId, $clientSecretEncoded, $authCode, $resource)
  (Invoke-RestMethod -Uri https://login.microsoftonline.com/common/oauth2/token -Method Post -ContentType 'application/x-www-form-urlencoded' -Body $body -ErrorAction STOP).access_token
}
$token = get-GraphAPIToken -clientSecret $clientSecret -clientid $clientid -Redirecturi $redirectURI -resource $resource -useremail $useremail -prompttype $prompt

Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -uri "https://graph.microsoft.com/beta/me" -Method get