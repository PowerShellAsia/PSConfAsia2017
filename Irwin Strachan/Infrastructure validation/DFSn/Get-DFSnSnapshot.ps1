
<#

Author: I. Strachan
Version:
Version History:

Purpose: Get DFSn Configuration for current Domain
    
#>
[cmdletbinding()]
Param()

Import-Module DFSN -Verbose:$false

#HashTable to save ADReport
$DFSnSnapshot = @{}

#region Function toGet ServerName from RootTarget path
Function Get-DFSnRootTargetServerName{
    param($TargetPath)

    $colNamespaceServers =  @{}

    Foreach($path in $TargetPath){
        $ServerName = $($path.split('\\')[2])
        if(!($colNamespaceServers.ContainsKey($ServerName))){
            $colNamespaceServers.Add($ServerName,$null )
            [PSCustomObject]@{
                ComputerName = $ServerName
            }
        }
    }
}
#endregion

#region Main
$DFSnSnapshot.Roots = $(Get-DFSnRoot)
$DFSnSnapshot.RootTargets = $(Get-DfsnRoot | ForEach-Object {Get-DfsnRootTarget -Path $_.Path})
$DFSnSnapshot.Folders = $(Get-DfsnRoot | ForEach-Object {Get-DfsnFolder -Path "$($_.Path)\*"})
$DFSnSnapshot.FolderTargets = $(Get-DfsnRoot | ForEach-Object {Get-DfsnFolder -Path "$($_.Path)\*"} | Get-DfsnFolderTarget)
$DFSnSnapshot.ServerConfiguration = Get-DFSnRootTargetServerName -TargetPath $DFSnSnapshot.RootTarget.TargetPath |
Foreach-Object{
    Get-DfsnServerConfiguration -ComputerName $_.ComputerName
}
#endregion

#region Export to XML
$exportDate = Get-Date -Format ddMMyyyy
$DFSnSnapshot | Export-Clixml $PSScriptRoot\DFSnSnapshot-$($exportDate).xml -Encoding UTF8
#endregion
