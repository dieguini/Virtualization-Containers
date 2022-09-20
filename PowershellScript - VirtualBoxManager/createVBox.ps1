# createVBox.ps1

#$ISO_IMAGE_ROUTE = "D:\PolarBackup\Sistemas Operativos\Windows 10 Lite Edition 19H2 x64.iso"
#$VBOX_MANAGE_ROUTE = "C:\Program Files\Oracle\VirtualBox"
Param (
    # Parameter help description
    [Parameter(
        Mandatory = $true, 
        HelpMessage="Porfavor ingrese la ruta de la imagen ISO"
        )]
    [string]$ISO_IMAGE_ROUTE,
    # Parameter help description
    [Parameter(
        Mandatory = $true,
        HelpMessage="Nombre de la VM"
    )]
    [string]$vmName
)

$osType = 'WindowsNT_64'
$vmPath="$home\VirtualBox VMs\$vmName"
$hdSizeMb = 20480 #20 GB
$vmMemory = 4096
$vmRam = 128
$userName = 'defaultUser'
$fullUserName='Default User'
$password='user'

# Agrega VBoxManage como variable global
if ( $null -eq (get-command VBoxManage.exe -errorAction silentlyContinue)) {
    $env:path="C:\Program Files\Oracle\VirtualBox;$env:path"
 }

if (-Not $ISO_IMAGE_ROUTE -eq '') {
    Write-Output "La ruta de la imagen a instalar es: '$ISO_IMAGE_ROUTE'"
    
    VBoxManage createvm --name $vmName --register --ostype $osType
    <# if (! (Test-Path $vmPath\$vmName.vbox)) {
        Write-Host "Se esperaba un path! $vmPath"
        return
    } #>

    VBoxManage createmedium --filename $vmPath\hard-drive.vdi --size $hdSizeMb

    Write-Host "Adding SATA controller..."
    VBoxManage storagectl    $vmName --name       'SATA Controller' --add sata --controller IntelAHCI
    VBoxManage storageattach $vmName --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium $vmPath/hard-drive.vdi

    Write-Host "Adding IDE controller..."
    VBoxManage storagectl    $vmName --name       'IDE Controller' --add ide
    VBoxManage storageattach $vmName --storagectl 'IDE Controller' --port 0 --device 0 --type dvddrive --medium $isoFile

    Write-Host "Enable APIC..."
    VBoxManage modifyvm $vmName --ioapic on

    Write-Host "Specify boot order..."
    VBoxManage modifyvm $vmName --boot1 dvd --boot2 disk --boot3 none --boot4 none

    Write-Host "Memory..."
    VBoxManage modifyvm $vmName --memory $vmMemory --vram $vmRam
    
    Write-Host "Unattended install..."
    VBoxManage unattended install $vmName   `
        --iso=$ISO_IMAGE_ROUTE                           `
        --user=$userName                         `
        --password=$password                     `
        --full-user-name=$fullUserName           `
        --install-additions                      `
        --time-zone=CET                          `
        --post-install-command='VBoxControl guestproperty set installation_finished y'

    Write-Host "Listando maquinas virtuales"
    Write-Host "###########################"
    VBoxManage list vms
    Write-Host "###########################"

    Write-Host "Iniciando el equipo..."
    VBoxManage startvm $vmName
} else {
    {<# Action when all if and elseif conditions are false #>}
    Write-Error "Ruta de la imagen ISO necesaria"
}

