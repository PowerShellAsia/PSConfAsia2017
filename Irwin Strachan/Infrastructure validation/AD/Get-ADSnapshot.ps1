
<#

Author: I. Strachan
Version:
Version History:

Purpose: Get ADConfiguration for current Domain
    
#>
[cmdletbinding()]
Param()

Import-Module ActiveDirectory -Verbose:$false

#HashTable to save ADReport
$ADSnapshot = @{}

#region Main
$ADSnapshot.RootDSE = $(Get-ADRootDSE)
$ADSnapshot.ForestInformation = $(Get-ADForest)
$ADSnapshot.DomainInformation = $(Get-ADDomain)
$ADSnapshot.DomainControllers = $(Get-ADDomainController -Filter *)
$ADSnapshot.DomainTrusts = (Get-ADTrust -Filter *)
$ADSnapshot.DefaultPassWordPoLicy = $(Get-ADDefaultDomainPasswordPolicy)
$ADSnapshot.AuthenticationPolicies = $(Get-ADAuthenticationPolicy -LDAPFilter '(name=AuthenticationPolicy*)')
$ADSnapshot.AuthenticationPolicySilos = $(Get-ADAuthenticationPolicySilo -Filter 'Name -like "*AuthenticationPolicySilo*"')
$ADSnapshot.CentralAccessPolicies = $(Get-ADCentralAccessPolicy -Filter *)
$ADSnapshot.CentralAccessRules = $(Get-ADCentralAccessRule -Filter *)
$ADSnapshot.ClaimTransformPolicies = $(Get-ADClaimTransformPolicy -Filter *)
$ADSnapshot.ClaimTypes = $(Get-ADClaimType -Filter *)
$ADSnapshot.DomainAdministrators =$( Get-ADGroup -Identity $('{0}-512' -f (Get-ADDomain).domainSID) | Get-ADGroupMember -Recursive)
$ADSnapshot.OrganizationalUnits = $(Get-ADOrganizationalUnit -Filter *)
$ADSnapshot.OptionalFeatures =  $(Get-ADOptionalFeature -Filter *)
$ADSnapshot.Sites = $(Get-ADReplicationSite -Filter *)
$ADSnapshot.Subnets = $(Get-ADReplicationSubnet -Filter *)
$ADSnapshot.SiteLinks = $(Get-ADReplicationSiteLink -Filter *)
$ADSnapshot.ReplicationMetaData = $(Get-ADReplicationPartnerMetadata -Target (Get-ADDomain).DNSRoot -Scope Domain)
#endregion

#region Export to XML
$exportDate = Get-Date -Format ddMMyyyy
$ADSnapshot | Export-Clixml .\export\dsa\ADReport-$($exportDate).xml -Encoding UTF8
#endregion

#region AD Queries
$ADSnapshot.DomainControllers | Format-Table Name,OperatingSystem,IPv4Address,Site 
$ADSnapshot.DomainAdministrators | Format-Table Name
$ADSnapshot.ForestInformation.GlobalCatalogs
$ADSnapshot.ForestInformation | Format-Table SchemaMaster,DomainNamingMaster
$ADSnapshot.DomainInformation | Format-Table PDCEmulator,RIDMaster,InfrastructureMaster
$ADSnapshot.OrganizationalUnits | Format-Table Name,DistinguishedName
$ADSnapshot.Sites | Format-Table Name
$ADSnapshot.Subnets | Format-Table Name
$ADSnapshot.SiteLinks | Format-Table Name,Cost,ReplicationFrequencyInMinutes
#endregion

#region Compare Objects

#Get previous ADReport
$SavedADSnapshot = Import-Clixml .\export\dsa\ADReport-22032016.xml 

#Compare Forest FSMO roles
Compare-Object $SavedADSnapshot.ForestInformation $ADSnapshot.ForestInformation -Property SchemaMaster,DomainNamingMaster -IncludeEqual

#Compare Domain FSMO roles
Compare-Object $SavedADSnapshot.DomainInformation $ADSnapshot.DomainInformation -Property PDCEmulator,RIDMaster,InfrastructureMaster -IncludeEqual
#endregion