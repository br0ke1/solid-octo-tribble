#Subnet /26 minimum - must be named AzureBastionSubnet
az network vnet subnet create --name AzureBastionSubnet --resource-group RG_PolicyTest --vnet-name vnet-eastus --address-prefix 172.16.1.64/26

#Create PIP standard/static
#Create bastion host - Basic SKU, max 2 instances, recommended 20 concurrent RDP per instance
$templateFile="bastion_PIP_template.json"
$ParameterFile="bastion_PIP_parameters.json"
az deployment group create --name deployBastion --resource-group RG_PolicyTest --template-file $templateFile --parameters $ParameterFile

#2 ways to connect
#HTML5 VM->Connect->Connect->Request JIT, make sure bastion IP is used
#Native RDP client, must use Azure CLI, only have to use --configure once for settings to stick(disable multi-monitor)
AZ login
az network bastion rdp --name "bastion-std-eastus" --resource-group "RG_PolicyTest" --target-resource-id "/subscriptions/4fc8cc73-1ff5-430f-a7a3-7015c2d26a46/resourceGroups/RG_PolicyTest/providers/Microsoft.Compute/virtualMachines/VM2022test" --configure
az network bastion rdp --name "bastion-std-eastus" --resource-group "RG_PolicyTest" --target-ip-address "172.16.0.5" --configure

#Azure user permissions for VM
#global variables
$userID="user1@Re5allcomphany29467890outlo.onmicrosoft.com"
$assignee=(az ad user show --id "$userID" --query "id")
#For Group
$assignee="19d9d3ed-75f1-4939-a800-db1edd949a90"
$Subscription="4fc8cc73-1ff5-430f-a7a3-7015c2d26a46"
$RG="RG_PolicyTest"
$VM="VM2022test"
$VMNic="vm2022test888"
$Bastion="bastion-std-eastus"
$VNet="vnet-eastus"

#In order to make a connection, the following roles are required:
#custom roles:
JIT_RoleDefinition.json
#Network access check fails if NetworkWatcher is in different RG, Get NetworkWatcher:
az network watcher list
Net_WatcherRoleDefinition.json

#    Reader role on the virtual machine.
$VMScope="/subscriptions/$Subscription/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/$VM"
#    Reader role on the NIC with private IP of the virtual machine.
$VMNicScope="/subscriptions/$Subscription/resourceGroups/$RG/providers/Microsoft.Network/networkInterfaces/$VMNic"
#    Reader role on the Azure Bastion resource.
$BastionScope="/subscriptions/$Subscription/resourceGroups/$RG/providers/Microsoft.Network/bastionHosts/$Bastion"
#    Reader role on the virtual network of the target virtual machine (if the Bastion deployment is in a peered virtual network).
$VNetScope="/subscriptions/$Subscription/resourceGroups/$RG/providers/Microsoft.Network/virtualNetworks/$VNet"
#    Custom JIT role on the RG for JIT access
$JITScope="/subscriptions/$Subscription/resourceGroups/$RG"
#    Custom NetworkWatcher write role on the NSG to check for JIT access
$NetworkWatcherScope="/subscriptions/$Subscription/resourcegroups/$RG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_eastus"

#Assign above roles
az role assignment create --assignee $assignee --role "Reader" --scope $VMScope
az role assignment create --assignee $assignee --role "Reader" --scope $VMNicScope
az role assignment create --assignee $assignee --role "Reader" --scope $BastionScope
az role assignment create --assignee $assignee --role "Reader" --scope $VNetScope
az role assignment create --assignee $assignee --role "Custom JIT" --scope $JITScope
az role assignment create --assignee $assignee --role "Custom Watcher Write" --scope $NetworkWatcherScope
#Delete roles
az role assignment delete --assignee $assignee --role "Reader" --scope $VMScope
az role assignment delete --assignee $assignee --role "Reader" --scope $VMNicScope
az role assignment delete --assignee $assignee --role "Reader" --scope $BastionScope
az role assignment delete --assignee $assignee --role "Reader" --scope $VNetScope
az role assignment delete --assignee $assignee --role "Custom JIT" --scope $JITScope
az role assignment delete --assignee $assignee --role "Custom Watcher Write" --scope $NetworkWatcherScope

#RDS
Install-WindowsFeature -Name RDS-Licensing, RDS-RD-Server –IncludeManagementTools
Get-WindowsFeature -Name RDS* | Where installed
#Set GPO, used EA 4965437
Use the specified Remote Desktop license servers: Localhost
Set the Remote Desktop licensing mode: Device

#Check licensing
$obj = gwmi -namespace "Root/CIMV2/TerminalServices" Win32_TerminalServiceSetting
$obj.GetSpecifiedLicenseServerList()
