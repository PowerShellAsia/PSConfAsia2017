<#

      Author: I.C.A. Strachan
      Version:
      Version History:

      Purpose: Pester script to validate Active Directory configuration.

#>
[CmdletBinding()]
Param(
    $xmlFile = 'DFSnSnapshot-20092016.xml'
)

$DFSnConfiguration = @{
   RootTargets = @(
      [PSCustomObject]@{
         Path       = '\\pshirwin.local\apps'
         TargetPath = '\\DC-DSC-01\apps'
      }
      [PSCustomObject]@{
         Path       = '\\pshirwin.local\GroupData'
         TargetPath = '\\DC-DSC-01\GroupData'
      }
      [PSCustomObject]@{
         Path       = '\\pshirwin.local\home'
         TargetPath = '\\DC-DSC-01\home'
      }
   )
   FolderTargets = Import-Csv "$PSScriptRoot\dfslinks.csv" -Delimiter "`t" -Encoding UTF8 
}

#Import saved AD snapshot
$SavedDFSnSnapshot= Import-Clixml $PSScriptRoot\$xmlfile

Describe 'DFSn configuration operational readiness' {
   
   Context 'Verifying DFSn Root Targets'{
      $lookupRootTargets = $DFSnConfiguration.RootTargets | Group-Object -AsHashTable -Property Path 
      $SavedDFSnSnapshot.RootTargets |
      ForEach-Object {
         It "Root Path $($_.Path) valid"{
            $_.Path | Should be $($lookupRootTargets.$($_.Path).Path)
         }
         It "Root TargetPath $($_.TargetPath) valid"{
            $_.TargetPath | Should be $($lookupRootTargets.$($_.Path).TargetPath)
         }
      }
   }

   #Verifying using DFSnConfiguration as reference
   Context 'Verifying DFSn Folder Targets DFSnConfiguration'{
      $lookupFolderTargets = $SavedDFSnSnapshot.FolderTargets | Group-Object -AsHashTable -Property Path
      $DFSnConfiguration.FolderTargets |
      ForEach-Object {
         It "Folder Path $($_.Path) valid"{
            $_.Path | Should be $($lookupFolderTargets.$($_.Path).Path)
         }
         It "Folder TargetPath $($_.TargetPath) valid"{
            $_.TargetPath | Should be $($lookupFolderTargets.$($_.Path).TargetPath)
         }
      }
   }
}