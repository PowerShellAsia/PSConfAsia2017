#region Simplistic tests
#region Example 01 Operational validation Simplistic test
#Even though the sets don't match the tests will still pass
$savedADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-04.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
 
$verifyADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-03.pshirwin.local'
   )
}
Describe 'Active Directory configuration operational readiness' {
   Context 'Verifying GlobalCatalogs count without Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs).Count |
         Should be @($verifyADConfig.GlobalCatalogs).Count
      }
   }
 
   Context 'Verifying GlobalCatalogs count with Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs  | Group-Object).Count |
         Should be @($verifyADConfig.GlobalCatalogs | Group-Object).Count
      }
   }
}
#endregion

#region Example 02 Operational validation Simplistic test
#Here verifyADConfig has a double entry. sets don't match the test will still pass
$savedADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
 
$verifyADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-01.pshirwin.local'
   )
}
Describe 'Active Directory configuration operational readiness' {
   Context 'Verifying GlobalCatalogs count without Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs).Count |
         Should be @($verifyADConfig.GlobalCatalogs).Count
      }
   }
 
   Context 'Verifying GlobalCatalogs count with Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs  | Group-Object).Count |
         Should be @($verifyADConfig.GlobalCatalogs | Group-Object).Count
      }
   }
}
#endregion

#region Example 03 Operational validation Simplistic test
#Here verifyADConfig has a double entry. sets don't match the test will still pass
$savedADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
 
$verifyADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
Describe 'Active Directory configuration operational readiness' {
   Context 'Verifying GlobalCatalogs count without Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs).Count |
         Should be @($verifyADConfig.GlobalCatalogs).Count
      }
   }
 
   Context 'Verifying GlobalCatalogs count with Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs  | Group-Object).Count |
         Should be @($verifyADConfig.GlobalCatalogs | Group-Object).Count
      }
   }
}
#endregion

#endregion

#region Comprehensive tests

#region Example 01 Operational validation Comprehensive test
$savedADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
 
$verifyADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-03.pshirwin.local'
      'DC-DSC-04.pshirwin.local'
   )
}
 
Describe 'Active Directory configuration operational readiness' {

   Context 'Verifying GlobalCatalogs count without Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs).Count |
         Should be @($verifyADConfig.GlobalCatalogs).Count
      }
   }
 
   Context 'Verifying GlobalCatalogs count with Group-Object'{
      it 'Total GlobalCatalogs match' {
         @($savedADConfig.GlobalCatalogs  | Group-Object).Count |
         Should be @($verifyADConfig.GlobalCatalogs | Group-Object).Count
      }
   }
   Context 'Verifying GlobalCatalogs enumerating from saved configuration'{
      $savedADConfig.GlobalCatalogs |
      ForEach-Object{
         it "Server $($_) is a GlobalCatalog"{
            $verifyADConfig.GlobalCatalogs.Contains($_) |
            Should be $true
         }
      }
   }

   Context 'Verifying GlobalCatalogs enumerating from verify configuration'{
      $verifyADConfig.GlobalCatalogs |
      ForEach-Object{
         it "Server $($_) is a GlobalCatalog"{
            $savedADConfig.GlobalCatalogs.Contains($_) |
            Should be $true
         }
      }
   }
}
#endregion

#region Example 02 Operational validation Comprehensive test
#Don't just rely on color feedback. 
$savedADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
 
$verifyADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
   )
}
 
Describe 'Active Directory configuration operational readiness' {
   Context 'Verifying GlobalCatalogs enumerating from saved configuration'{
      $savedADConfig.GlobalCatalogs |
      ForEach-Object{
         it "Server $($_) is a GlobalCatalog"{
            $verifyADConfig.GlobalCatalogs.Contains($_) |
            Should be $true
         }
      }
   }
   Context 'Verifying GlobalCatalogs enumerating from verify configuration'{
      $verifyADConfig.GlobalCatalogs |
      ForEach-Object{
         it "Server $($_) is a GlobalCatalog"{
            $savedADConfig.GlobalCatalogs.Contains($_) |
            Should be $true
         }
      }
   }
}
#endregion

#region Example 03 Operational validation Comprehensive test
#Don't just rely on color feedback. 
$savedADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
 
$verifyADConfig= @{
   GlobalCatalogs = @(
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-01.pshirwin.local'
      'DC-DSC-02.pshirwin.local'
   )
}
 
Describe 'Active Directory configuration operational readiness' {
   Context 'Verifying GlobalCatalogs enumerating from saved configuration'{
      $savedADConfig.GlobalCatalogs |
      ForEach-Object{
         it "Server $($_) is a GlobalCatalog"{
            $verifyADConfig.GlobalCatalogs.Contains($_) |
            Should be $true
         }
      }
   }
   Context 'Verifying GlobalCatalogs enumerating from verify configuration'{
      $verifyADConfig.GlobalCatalogs |
      ForEach-Object{
         it "Server $($_) is a GlobalCatalog"{
            $savedADConfig.GlobalCatalogs.Contains($_) |
            Should be $true
         }
      }
   }
}
#endregion

#endregion