<#  
    Script Name: New-VM-SCCMTS-BIOS.ps1

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
    -BootDevice CD `
    -NewVHDPath "$vhdfile" `
    -NewVHDSizeBytes 50GB `
    -Path "$vmdirectory" `
    -Generation 1 `
    -Switch $hypervswitch

Set-VM `
    -Name $vmname `
    -ProcessorCount 4 `
    -DynamicMemory `
    -MemoryMinimumBytes 2048MB `
    -MemoryStartupBytes 2048MB `
    -MemoryMaximumBytes 4096MB `
    -AutomaticCheckpointsEnabled $false

Set-VMDvdDrive `
    -VMName $vmname `
    -Path $bootiso

Start-VM $vmname

$vmnumber++
$vmnumber | Export-Clixml $vmnumberxmlpath