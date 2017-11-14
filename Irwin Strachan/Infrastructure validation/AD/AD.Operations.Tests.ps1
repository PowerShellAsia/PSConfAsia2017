<#

      Author: I.C.A. Strachan
      Version: 1.1
      Version History:
         08-04-2016 1.0 - First Release
         12-05-2016 1.1 - Fixed issues with Sitelinks & Subnets.

      Purpose: Pester script to validate Active Directory configuration.

#>

[CmdletBinding()]
Param(
    $xmlFile = 'ADReport-20092016.xml'
)

#region Active Directory configuration as you expect it to be. Modify to reflect your AD
$ADConfiguration = @{
    Forest = @{
        FQDN = 'pshirwin.local'
        ForestMode = 'Windows2012R2Forest'
        GlobalCatalogs = @(
            'DC-DSC-01.pshirwin.local'
        )
        SchemaMaster = 'DC-DSC-01.pshirwin.local'
        DomainNamingMaster = 'DC-DSC-01.pshirwin.local'

    }
    Domain = @{
        NetBIOSName = 'PSHIRWIN'
        DomainMode = 'Windows2012R2Domain'
        RIDMaster = 'DC-DSC-01.pshirwin.local'
        PDCEmulator = 'DC-DSC-01.pshirwin.local'
        InfrastructureMaster = 'DC-DSC-01.pshirwin.local'
        DistinguishedName = 'DC=pshirwin,DC=local'
        DNSRoot = 'pshirwin.local'
        DomainControllers = @('DC-DSC-01')
    }
    PasswordPolicy = @{
        PasswordHistoryCount = 24
        LockoutThreshold = 0
        LockoutDuration = '00:30:00'
        LockoutObservationWindow = '00:30:00'
        MaxPasswordAge = '42.00:00:00'
        MinPasswordAge = '1.00:00:00'
        MinPasswordLength = 8
        ComplexityEnabled = $true
    }
    Sites = @('Default-First-Site-Name','Branch01')
    SiteLinks = @(
       [PSCustomObject]@{
            Name = 'DEFAULTIPSITELINK'
            Cost = 100
            ReplicationFrequencyInMinutes = 180
        }
    )
    SubNets = @(
        [PSCustomObject]@{
            Name = '192.168.0.0/24'
            Site = 'CN=Branch01,CN=Sites,CN=Configuration,DC=pshirwin,DC=local'
        }    
    )
}
#endregion

#Import saved AD snapshot
$SavedADReport = Import-Clixml $PSScriptRoot\$xmlFile

Describe 'Active Directory Forest operational readiness' -Tags Forest {

    Context 'Verifying Forest Configuration'{
        it "Forest FQDN $($ADConfiguration.Forest.FQDN)" {
            $ADConfiguration.Forest.FQDN | 
            Should be $SavedADReport.ForestInformation.RootDomain
        }
        it "ForestMode $($ADConfiguration.Forest.ForestMode)"{
            $ADConfiguration.Forest.ForestMode | 
            Should be $SavedADReport.ForestInformation.ForestMode.ToString()
        }
    }

    Context 'Verifying GlobalCatalogs'{
        $ADConfiguration.Forest.GlobalCatalogs | 
        ForEach-Object{
            it "Server $($_) is a GlobalCatalog"{
                $SavedADReport.ForestInformation.GlobalCatalogs.Contains($_) | 
                Should be $true
            }
        }
    }
}

Describe 'Active Directory Domain operational readiness' -Tags Domain {
    Context 'Verifying Domain Configuration'{
        it "Total Domain Controllers $($ADConfiguration.Domain.DomainControllers.Count)" {
            $ADConfiguration.Domain.DomainControllers.Count | 
            Should be @($SavedADReport.DomainControllers).Count
        }

        $ADConfiguration.Domain.DomainControllers | 
        ForEach-Object{
            it "DomainController $($_) exists"{
                $SavedADReport.DomainControllers.Name.Contains($_) | 
                Should be $true
            }
        }
        it "DNSRoot $($ADConfiguration.Domain.DNSRoot)"{
            $ADConfiguration.Domain.DNSRoot | 
            Should be $SavedADReport.DomainInformation.DNSRoot
        }
        it "NetBIOSName $($ADConfiguration.Domain.NetBIOSName)"{
            $ADConfiguration.Domain.NetBIOSName | 
            Should be $SavedADReport.DomainInformation.NetBIOSName
        }
        it "DomainMode $($ADConfiguration.Domain.DomainMode)"{
            $ADConfiguration.Domain.DomainMode | 
            Should be $SavedADReport.DomainInformation.DomainMode.ToString()
        }
        it "DistinguishedName $($ADConfiguration.Domain.DistinguishedName)"{
            $ADConfiguration.Domain.DistinguishedName | 
            Should be $SavedADReport.DomainInformation.DistinguishedName
        }
        it "Server $($ADConfiguration.Domain.RIDMaster) is RIDMaster"{
            $ADConfiguration.Domain.RIDMaster | 
            Should be $SavedADReport.DomainInformation.RIDMaster
        }
        it "Server $($ADConfiguration.Domain.PDCEmulator) is PDCEmulator"{
            $ADConfiguration.Domain.PDCEmulator | 
            Should be $SavedADReport.DomainInformation.PDCEmulator
        }
        it "Server $($ADConfiguration.Domain.InfrastructureMaster) is InfrastructureMaster"{
            $ADConfiguration.Domain.InfrastructureMaster | 
            Should be $SavedADReport.DomainInformation.InfrastructureMaster
        }
    }
}

Describe 'Active Directory Password Policy operational readiness' -Tags Password {
    Context 'Verifying Default Password Policy'{
        it 'ComplexityEnabled'{
            $ADConfiguration.PasswordPolicy.ComplexityEnabled | 
            Should be $SavedADReport.DefaultPassWordPoLicy.ComplexityEnabled
        }
        it 'Password History count'{
            $ADConfiguration.PasswordPolicy.PasswordHistoryCount | 
            Should be $SavedADReport.DefaultPassWordPoLicy.PasswordHistoryCount
        }
        it "Lockout Threshold equals $($ADConfiguration.PasswordPolicy.LockoutThreshold)"{
            $ADConfiguration.PasswordPolicy.LockoutThreshold | 
            Should be $SavedADReport.DefaultPassWordPoLicy.LockoutThreshold
        }
        it "Lockout duration equals $($ADConfiguration.PasswordPolicy.LockoutDuration)"{
            $ADConfiguration.PasswordPolicy.LockoutDuration | 
            Should be $SavedADReport.DefaultPassWordPoLicy.LockoutDuration.ToString()
        }
        it "Lockout observation window equals $($ADConfiguration.PasswordPolicy.LockoutObservationWindow)"{
            $ADConfiguration.PasswordPolicy.LockoutObservationWindow | 
            Should be $SavedADReport.DefaultPassWordPoLicy.LockoutObservationWindow.ToString()
        }
        it "Min password age equals $($ADConfiguration.PasswordPolicy.MinPasswordAge)"{
            $ADConfiguration.PasswordPolicy.MinPasswordAge | 
            Should be $SavedADReport.DefaultPassWordPoLicy.MinPasswordAge.ToString()
        }
        it "Max password age equals $($ADConfiguration.PasswordPolicy.MaxPasswordAge)"{
            $ADConfiguration.PasswordPolicy.MaxPasswordAge | 
            Should be $SavedADReport.DefaultPassWordPoLicy.MaxPasswordAge.ToString()
        }
    }
}

Describe 'Active Directory Sites,Sitelinks & Subnets operational readiness' -Tags Sites,Sitelinks,Subnet {
    Context 'Verifying Active Directory Sites'{
        $ADConfiguration.Sites | 
        ForEach-Object{
            it "Site $($_)" {
                $SavedADReport.Sites.Name.Contains($_) | 
                Should be $true
            } 
        }
    }

    Context 'Verifying Active Directory Sitelinks'{
        $lookupSiteLinks = $SavedADReport.Sitelinks | Group-Object -AsHashTable -Property Name 
        $ADConfiguration.Sitelinks | 
        ForEach-Object{
            it "Sitelink $($_.Name)" {
                $_.Name | 
                Should be $($lookupSiteLinks.$($_.Name).Name)
            } 
            it "Sitelink $($_.Name) costs $($_.Cost)" {
                $_.Cost | 
                Should be $lookupSiteLinks.$($_.Name).Cost
            }
            it "Sitelink $($_.Name) replication interval $($_.ReplicationFrequencyInMinutes)" {
                $_.ReplicationFrequencyInMinutes | 
                Should be $lookupSiteLinks.$($_.Name).ReplicationFrequencyInMinutes
            }
        }
    }

    Context 'Verifying Active Directory Subnets'{
        $lookupSubnets = $SavedADReport.SubNets | Group-Object -AsHashTable -Property Name 
        $ADConfiguration.Subnets | 
        ForEach-Object{
            it "Subnet $($_.Name)" {
                $_.Name | 
                Should be $lookupSubnets.$($_.Name).Name
            }
            it "Site $($_.Site)" {
                $_.Site | 
                Should be $lookupSubnets.$($_.Name).Site
            }
        } 
    }
}

