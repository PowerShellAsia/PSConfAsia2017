
<#

Author: I.C.A. Strachan
Version:
Version History:

Purpose: Pester script to validate Group Polcies status and Link on Domain,Sites and OUs

#>

[CmdletBinding()]
Param()

#Import saved snapshot of GPOsSOM

$lookupGPOInReport = Import-Clixml "$PSScriptRoot\GPOcSOM-20092016.xml" | Group-Object -AsHashTable -Property 'DisplayName'  


Describe 'Group Policies Scope of Management validation' {
   BeforeAll {
      #region Get GPOs Producution Validation set

      $gpoValidationSet = @'
DisplayName,DistinguishedName,GPOStatus,BlockInheritance,LinkEnabled,Enforced,LinkOrderNr
Default Domain Policy,"DC=pshirwin,DC=local",AllSettingsEnabled,FALSE,TRUE,FALSE,1
Default Domain Controllers Policy,"OU=Domain Controllers,DC=pshirwin,DC=local",AllSettingsEnabled,FALSE,TRUE,FALSE,1
WinRM Listeners,"OU=Servers,DC=pshirwin,DC=local",AllSettingsEnabled,FALSE,TRUE,FALSE,1
RemoteDesktop,"OU=Servers,DC=pshirwin,DC=local",AllSettingsEnabled,FALSE,TRUE,FALSE,2
Firewall,"OU=Servers,DC=pshirwin,DC=local",UserSettingsDisabled,FALSE,TRUE,TRUE,3
'@ | ConvertFrom-Csv -Delimiter ','

      #endregion
   }

   It 'GPOs Scope of Managment retrieved' {
        $lookupGPOInReport | should not BeNullOrEmpty
   }

   It 'GPO validation set retrieved' {
      $gpoValidationSet | Should not BeNullOrEmpty
   }
}


   foreach($set in $gpoValidationSet){
      Describe "GPO $($set.DisplayName)" {
         it "GPO $($set.DisplayName) exists" {
            $lookupGPOInReport.$($set.DisplayName) | Should Not BeNullOrEmpty
         }
      
         it "GPO is linked to $($set.DistinguishedName)"{
            $lookupGPOInReport.$($set.DisplayName).DistinguishedName | Should be $set.DistinguishedName
         }
      
         it "BlockInheritance: $($set.BlockInheritance)" {
            $lookupGPOInReport.$($set.DisplayName).BlockInheritance | Should be $set.BlockInheritance
         }

         it "LinkEnabled: $($set.LinkEnabled)" {
            $lookupGPOInReport.$($set.DisplayName).LinkEnabled | Should be $set.LinkEnabled
         }

         it "Group policy Enforced: $($set.Enforced)" {
            $lookupGPOInReport.$($set.DisplayName).Enforced | Should be $set.Enforced
         }

         it "Group policy LinkOrder nr: $($set.LinkOrderNr)" {
            $lookupGPOInReport.$($set.DisplayName).LinkOrderNr | Should be $set.LinkOrderNr
         }

         it "Group policy status: $($set.GPOStatus)" {
            $lookupGPOInReport.$($set.DisplayName).GPOStatus.Value | Should be $set.GPOStatus
         }
      }
}