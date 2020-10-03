<#  
    Script Name: New-VM-SCCMTS-UEFI.ps1

    Author: Johan Koolen

    Date Created: Sunday, July 14, 2019

    Purpose: A simple script to create VMs in Hyper-V and boot to a specified ISO
#>

# Keeps track of the most recent VM number to use when creating new names for the VMs.
$vmnumberxmlpath = "$PSScriptRoot\vmnumber.xml"
if (Test-Path $vmnumberxmlpath) {$vmnumber = Import-Clixml $vmnumberxmlpath}
else {$vmnumber = 1}

# The prefix used in your VMs name.
$vmnameprefix = ""

# Enter the path to the directory that your VM will be located in.
$vmdirectory = ""

# The location of your Boot ISO
$bootiso = ""

# Enter the name of your vSwitch in Hyper-V.
$hypervswitch = "Default External Switch"

$vmname = $vmnameprefix + $vmnumber
$vhddirectory = "$vmdirectory\$vmname\Virtual Hard Disks"
$vhdfile = "$vhddirectory\$vmname.vhdx"

New-VM `
    -Name $vmname `
    -MemoryStartupBytes 4GB `
    -BootDevice VHD `
    -NewVHDPath "$vhdfile" `
    -Path "$vmdirectory" `
    -NewVHDSizeBytes 50GB `
    -Generation 2 `
    -Switch $hypervswitch

Set-VM `
    -Name $vmname `
    -AutomaticCheckpointsEnabled $false

Set-VMProcessor `
    -VMName $vmname `
    -Count 2

Add-VMDvdDrive `
    -VMName $vmname `
    -Path $bootiso `
    -Passthru

Set-VMFirmware `
    -VMName $vmname `
    -FirstBootDevice (Get-VMDvdDrive $vmname)

# Start-VM $vmname
$vmnumber++
$vmnumber | Export-Clixml $vmnumberxmlpath