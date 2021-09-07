# Enable UAC
#==================================================================================
Try {
  Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 1
  Write-Host "UAC is now enabled. Please reboot the machine."
} 
Catch {
  Write-Host "Error - Exception caught in enabling UAC : $error[0]"
} 
New-Variable -Name Key 
New-Variable -Name PromptOnSecureDesktop_Name 
New-Variable -Name ConsentPromptBehaviorAdmin_Name 

#the following is used to tell the script where it is located
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

Function Set-RegistryValue($key, $name, $value, $type="Dword") {  
  If ((Test-Path -Path $key) -Eq $false) { New-Item -ItemType Directory -Path $key | Out-Null }  
       Set-ItemProperty -Path $key -Name $name -Value $value -Type $type  
}  

Function Get-RegistryValue($key, $value) {  
   (Get-ItemProperty $key $value).$value  
}  
#==========================================================================================
#Turn UAC to default levels
#==========================================================================================

$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop" 

Function Get-UACLevel(){ 
    $ConsentPromptBehaviorAdmin_Value = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name 
    $PromptOnSecureDesktop_Value = Get-RegistryValue $Key $PromptOnSecureDesktop_Name 
    If($ConsentPromptBehaviorAdmin_Value -Eq 0 -And $PromptOnSecureDesktop_Value -Eq 0){ 
        "Never notIfy" 
    } 
    ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 0){ 
        "NotIfy me only when apps try to make changes to my computer(do not dim my desktop)" 
    } 
    ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 1){ 
        "NotIfy me only when apps try to make changes to my computer(default)" 
    } 
    ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){ 
        "Always notIfy" 
    } 
    Else{ 
        "Unknown" 
    } 
} 

Function Set-UACLevel() { 
    Param([int]$Level= 2) 

    New-Variable -Name PromptOnSecureDesktop_Value 
    New-Variable -Name ConsentPromptBehaviorAdmin_Value 

    If($Level -In 0, 1, 2, 3) { 
        $ConsentPromptBehaviorAdmin_Value = 5 
        $PromptOnSecureDesktop_Value = 1 
        Switch ($Level)  
        {  
          0 { 
              $ConsentPromptBehaviorAdmin_Value = 0  
              $PromptOnSecureDesktop_Value = 0 
          }  
          1 { 
              $ConsentPromptBehaviorAdmin_Value = 5  
              $PromptOnSecureDesktop_Value = 0 
          }  
          2 { 
              $ConsentPromptBehaviorAdmin_Value = 5  
              $PromptOnSecureDesktop_Value = 1 
          }  
          3 { 
              $ConsentPromptBehaviorAdmin_Value = 2  
              $PromptOnSecureDesktop_Value = 1 
          }  
        } 
        Set-RegistryValue -Key $Key -Name $ConsentPromptBehaviorAdmin_Name -Value $ConsentPromptBehaviorAdmin_Value 
        Set-RegistryValue -Key $Key -Name $PromptOnSecureDesktop_Name -Value $PromptOnSecureDesktop_Value 

        Get-UACLevel 
    } 
    Else{ 
        "No supported level" 
    } 

}

Set-UACLevel(2)

#===========================================================================
# Add Admin user
#===========================================================================

net user /add Admin Password
net localgroup administrators /add Admin

#===========================================================================
# Power and sleep settings to never sleep
#===========================================================================

Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0

#==========================================================================
# Set Passwords to never expire
#==========================================================================
net accounts /maxpwage:unlimited

#==========================================================================
# Uninstall the stuff that TEC keeps putting on everything
#==========================================================================
Try{
  $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "paint.net"}
  $MyApp.Uninstall()
}
Catch{
  Write-Host "Paint.net not found"
  }
  
Try{
  $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -CLike "LibreOffice*"}
  $MyApp.Uninstall()
  }
Catch{
  Write-Host "LibreOffice not found"
  }
  Try{
    & 'C:\Program Files (x86)\Notepad++\uninstall.exe'
  }
Catch{
  Write-Host "Notepad++ not found"
  }
Try{
  &'C:\Program Files\CDBurnerXP\unins000.exe'
   }
Catch{
  Write-Host "CDBurnerXP not found"
  }
Try{
  &'C:\Program Files\7-Zip\Uninstall.exe'
   }
Catch{
  Write-Host "7-zip not found"
  }
Try{
  &'C:\Program Files (x86)\K-Lite Codec Pack\unins000.exe'
   }
Catch{
  Write-Host "Media Player Clasic not found"
  }
    
#===================================================
# Set Timezone to Eastern
#===================================================
Set-TimeZone -Id "Eastern Standard Time" -PassThru

#===================================================
# Install Adobe Reader
#===================================================

#the below part works, but it's ugly
<#
Copy-Item D:\adobe\readerdc_en_xa_crd_install.exe D:\not_adobe.exe
Rename-Item -path D:\not_adobe.exe -NewName readerdc_en_xa_crd_install.exe

&D:\readerdc_en_xa_crd_install.exe
#>

