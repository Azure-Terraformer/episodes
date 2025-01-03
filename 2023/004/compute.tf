
resource "azurerm_public_ip" "main" {
  name                = "pip-vm${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

data "azurerm_subnet" "default" {
  name                 = "snet-default"
  virtual_network_name = "vnet-ep2-mr8x8gxj"
  resource_group_name  = "rg-ep2-mr8x8gxj"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-vm${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = data.azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

data "azurerm_key_vault" "main" {
  name                = "kv-ep3-gz9fbcix"
  resource_group_name = "rg-ep3-gz9fbcix"
}
data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-public"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_DS2_v2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}
