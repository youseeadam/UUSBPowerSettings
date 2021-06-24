$ErrorActionPreference = "Stop"
<#
.SYNOPSIS
    Manages Power Settings for USB devices.
.DESCRIPTION
    Will disable sleep and power settings on USB devices.  This will prevent perpherial devices like Rally, MeetUp, Swytch from loosing signal
    This should only be set on computers within a comnference room since it will drain a battery quickly. 
.NOTES 
    Author: Adam Berns (Logitech)
    Last Edit: 2021-25-5
    Version 1.0 - initial release of blah
.EXAMPLE
    Open a command prompt with elevated permmisions
    PowerShell.exe -executionPolicy unrestricted -file c:\rigel\oem\Set-USBPower.ps1
.INPUTS
    None
.OUTPUTS
    0 for no issues
    1 if setting USB sleep fails
    2 if setting USB power fails
    3 if both above fail
.ROLE
    Elevated permissions, ability to edit registry
#>
#Set USB Device Power Settings
function Set-USBSleep {
    try {
        $USBDevice = Get-WmiObject -Namespace "ROOT\CIMv2" -Class 'Win32_USBController' -Filter "caption like '% eXtensible Host Controller %'"
        foreach ($controller in $USBDevice) {
            $USBEX = Get-CimInstance -Namespace "ROOT\WMI" -Classname MSPower_DeviceEnable -Filter "InstanceName like '$($Controller.PNPDeviceID.Replace('\','\\'))%'" 
            $USBEX.Enable = $false
            $USBEX | Set-CimInstance
            Return 0
        }
    }
    Catch {
        Return 1
    }
}
function set-USBPower {
    try {
        $USBSleepSetting = new-item -path HKLM:\SYSTEM\CurrentControlSet\Services\ -Name "USB" -ItemType Key
        New-ItemProperty -Path $USBSleepSetting.PSPath -Name DisableSelectiveSuspend -PropertyType DWORD -Value 1 -Force | Out-Null
        Return 0
    }
    catch {
        Return 2
    }
}
$USBSleep = Set-USBSleep
$USBPower = set-USBPower
Write-Output ($USBSleep + $USBPower)
exit ($USBSleep + $USBPower)