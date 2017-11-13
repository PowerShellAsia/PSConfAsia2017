function ConvertTo-HashTable{
   param(
      [PSObject]$PSObject
   )
   $splat = @{}

   $PSObject | 
   Get-Member -MemberType *Property |
   ForEach-Object{
         $splat.$($_.Name) = $PSObject.$($_.Name)
   }

   $splat
}

#region Get Parameters for New-ADUser
$paramsNewAzureRmAdUser = (Get-Command New-AzureRmADUser -ErrorAction Stop).ParameterSets.Parameters | 
Where-Object {$_.ValueFromPipelineByPropertyName -eq $true}|
Select-Object Name,Ismandatory

'Total parameters New-ADUser cmdlet: {0}' -f $paramsNewAzureRmAdUser.Count
$paramsNewAzureRmAdUser.Where{$_.IsMandatory -eq $true}
#endregion

#Import CSV file
$DemoUsers = Import-csv .\sources\csv\PSConfAsia.csv -Delimiter "`t" -Encoding UTF8 

#Get
$DemoUsers |
ForEach-Object{
    $splat = @{}
    $item = $_ 
    $item |
    Get-Member -MemberType *Property |
    ForEach-Object{
        $splat.$($_.Name) = $item.$($_.Name)
        if($_.Name -eq 'SamAccountName'){
            $splat.UserPrincipalName = $('{0}@irwinstrachangmail.onmicrosoft.com' -f $item.$($_.Name)).ToLower()
        }
    }
    [PSCustomObject]$splat
} |
Export-Csv .\export\dsa\PSConfAsia.csv -Encoding UTF8 -Delimiter "`t" -NoTypeInformation

$DemoUsers[0] | 
Select-Object UserPrincipalName,DisplayName,Password,
@{Name ='MailNickname'; Expression ={ $($_.UserPrincipalName)}} | 
New-AzureRmADUser 

