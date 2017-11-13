<#

      Author: I.C.A. Strachan
      Version:
      Version History:

      Purpose: Infrastructure Dependencies script to create AzureADUser from CSV file

#>

[CmdletBinding(SupportsShouldProcess=$True)]

Param(
   [string]
   $xmlFileName = 'PSConfAsia.xml',

   [string]
   $xmlFilePath = 'C:\scripts\sources\xml'
)

#Get csv File
$xmlFile = $(Join-Path -Path $xmlFilePath -ChildPath $xmlFileName)

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

Function Test-CSVNewADUserParameters{
   param(
      $objActual,
      $objExpected
   )

   
   $allValid = $objActual |
   ForEach-Object{
      @{
         Actual   = $($_)
         Valid    = $($objExpected.Name -contains $_)
      }
   }

   $allValid.Valid -notcontains $False
}

Function Create-TestCasesUserProperties{
   param(
      $objActual,
      $objExpected,
      $Properties
   )

   $Properties |
   ForEach-Object{
      @{
         Actual   = $objActual.$_
         Expected = $objExpected.$_
         Property = $_
      }
   }
}

#region Arrange
#Define proper dependencies
#1) Verify xml file exist
#   a) Verify Mandatory Name parameter
#   b) Verify Valid parameters
#2) Can user read AzureAD properties.


$dependencies = @(
   @{
      Label  = 'AzureADPreview module is available '
      Test   = {(Get-module -ListAvailable).Name -contains 'AzureADPreview'}
      Action = {
         #Import ActiveDirectory
         Import-Module -Name AzureADPreview

         #Get New-ADUser Parameters available
         $script:parametersNewAzureADUser = (Get-Command New-AzureADUser -ErrorAction Stop).ParameterSets.Parameters | 
            Where-Object {$_.ValueFromPipelineByPropertyName -eq $true} |
            Select-Object Name,Ismandatory 
      }
   }

   @{
      Label  = "XML File at $($xmlFile) exists"
      Test   = {Test-Path -Path $xmlFile}
      Action = {
         $script:xmlPSConfAsia       = Import-Clixml -Path $xmlFile 
         $script:xmlPSConfAsiaColumns = ($xmlPSConfAsia| Get-Member -MemberType NoteProperty).Name
         #$script:UserProperties   = $csvPSConfAsiaColumns.Where{$_ -ne 'Path'}
      }
   }

   @{
      Label  = "XML contains Mandatory `'AccountEnabled`' parameter"
      Test   = {$script:xmlPSConfAsiaColumns -Contains 'AccountEnabled' }
      Action = {}
   }

   @{
      Label  = "XML contains Mandatory `'DisplayName`' parameter"
      Test   = {$script:xmlPSConfAsiaColumns -Contains 'DisplayName' }
      Action = {}
   }

   @{
      Label  = "XML contains Mandatory `'PasswordProfile`' parameter"
      Test   = {$script:xmlPSConfAsiaColumns -Contains 'PasswordProfile' }
      Action = {}
   }

   @{
      Label  = "XML contains Mandatory `'MailNickName`' parameter"
      Test   = {$script:xmlPSConfAsiaColumns -Contains 'MailNickName' }
      Action = {}
   }

   @{
      Label  = "XML contains valid parameters For cmdlet New-ADUser"
      Test   = {Test-CSVNewADUserParameters -objActual $script:xmlPSConfAsiaColumns -objExpected $parametersNewAzureADUser}
      Action = {}
   }

   @{
      Label  = "Current user can read AzureAD user object properties"
      Test   = {[bool](Get-AzureADUser -ObjectId 632401f7-dfc9-42f8-948f-e149caa069e4)}
      Action = {}
   }
)

foreach($dependency in $dependencies){
   if(!( & $dependency.Test)){
      throw "The check: $($dependency.Label) failed. Halting script"
   }
   else{
      Write-Verbose $($dependency.Label) 
      $dependency.Action.Invoke()
   }
}
#endregion

##region Main
#$csvDuPSUG  |
#Foreach-Object{
#   $Actual = $_
#   Describe "Processing User $($Actual.SamAccountName)"{
#      Context "Creating AD User account for $($Actual.SamAccountName) "{
#         #Convert to HashTable for splatting
#         $paramNewADUser = ConvertTo-HashTable -PSObject $Actual
#
#         #region Act
#         #1) Create ADUser from csv file
#
#         It "Created an account for $($Actual.SamAccountName)"{
#            New-ADUser @paramNewADUser
#         }
#         #endregion
#      }
#
#      Context "Verifying AD User properties for $($Actual.SamAccountName)"{
#         #region Assert
#         #1) Verify AD user has been created correctly
#
#         #Get AD user properties
#         #Get-ADUser doesn't have a Path parameter that's why it's been removed
#         $Expected = Get-ADUser -Identity $Actual.SamAccountName -Properties $UserProperties
#
#         #Create TestCases for verifying Properties
#         $TestCases = Create-TestCasesUserProperties -objActual $Actual -objExpected $Expected -Properties $UserProperties
#
#         It 'Verified that property <property> expected value <expected> actually is <actual>' -TestCases $TestCases   {
#            param($Actual,$Expected,$Property)
#            $Actual.$Property  | should be $Expected.$Property
#         }
#         #endregion
#      }
#   }
#}
##endregion