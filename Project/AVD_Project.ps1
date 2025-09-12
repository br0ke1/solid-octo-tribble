#Register resource provider
az provider register --namespace Microsoft.DesktopVirtualization
#Verify registration
az provider show --namespace Microsoft.DesktopVirtualization

#Use Intune to install FSLogix
#FSLogix Registry
$VHDLocations = "\\<STORAGE-ACCOUNT-NAME>.file.core.windows.net\<SHARE-NAME>"
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name Enabled -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name DeleteLocalProfileWhenVHDShouldApply -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name FlipFlopProfileDirectoryName -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryCount -PropertyType dword -Value 3 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryInterval -PropertyType dword -Value 15 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ProfileType -PropertyType dword -Value 0 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ReAttachIntervalSeconds -PropertyType dword -Value 15 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ReAttachRetryCount -PropertyType dword -Value 3 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name SizeInMBs -PropertyType dword -Value 30000 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VHDLocations -PropertyType string -value $VHDLocations -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VolumeType -PropertyType string -Value vhdx -Force

#Check FSLogix configuration, list redirects
Get-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\
C:\Program Files\FSLogix\Apps
`frx list-redirects`
