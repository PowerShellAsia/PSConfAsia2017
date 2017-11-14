<#

      Author: I.C.A. Strachan
      Version:
      Version History:

      Purpose: Infrastructure Dependencies script to create AzureADUser from XML file

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

Function Test-NewADUserParameters{
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
#2) Veridy user can read AzureAD properties.


$dependencies = @(
   @{
      Label  = 'AzureADPreview module is available '
      Test   = {(Get-module -ListAvailable).Name -contains 'AzureADPreview'}
      Action = {
         #Import ActiveDirectory
         $null = Import-Module -Name AzureADPreview -Verbose:$false

         #Get New-ADUser Parameters available
         $script:parametersNewAzureADUser = (Get-Command New-AzureADUser -ErrorAction Stop).ParameterSets.Parameters | 
         Where-Object {$_.IsDynamic -eq $true}
      }
   }

   @{
      Label  = "XML File at $($xmlFile) exists"
      Test   = {Test-Path -Path $xmlFile}
      Action = {
         $script:xmlPSConfAsia       = Import-Clixml -Path $xmlFile 
         $script:xmlPSConfAsiaColumns = ($xmlPSConfAsia| Get-Member -MemberType NoteProperty).Name
         #Removing PasswordProfile from the equation as we can't verify this in hindsight
         $script:UserProperties   = $xmlPSConfAsiaColumns.Where{$_ -ne 'PasswordProfile'}
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
      Test   = {Test-NewADUserParameters -objActual $script:xmlPSConfAsiaColumns -objExpected $parametersNewAzureADUser}
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
      Write-Host $($dependency.Label) -ForegroundColor Magenta
      $dependency.Action.Invoke()
   }
}
#endregion

#region Main
$xmlPSConfAsia[15..19]  |
Foreach-Object{
   $Actual = $_
   Describe "Processing User $($Actual.DisplayName)"{
      Context "Creating AzureAD User account for $($Actual.DisplayName) "{
         #Convert to HashTable for splatting
         $paramNewAzureADUser = ConvertTo-HashTable -PSObject $Actual

         #region Act
         #1) Create ADUser from csv file

         It "Created an account for $($Actual.DisplayName)"{
            New-AzureADUser @paramNewAzureADUser
         }
         #endregion
      }

      Context "Verifying AD User properties for $($Actual.DisplayName)"{
         #region Assert
         #1) Verify AD user has been created correctly

         #Get AzureAD user properties
         $Expected = Get-AzureADUser -ObjectId $Actual.UserPrincipalName

         #Create TestCases for verifying Properties
         $TestCases = Create-TestCasesUserProperties -objActual $Actual -objExpected $Expected -Properties $UserProperties

         It 'Verified that property <property> expected value <expected> is <actual>' -TestCases $TestCases   {
            param($Actual,$Expected,$Property)
            $Actual.$Property  | should be $Expected.$Property
         }
         #endregion
      }
   }
}
#endregion
