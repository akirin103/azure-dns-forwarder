variable "resource_group_name" {
  type        = string
  description = "(必須)DNSサーバに適用したいすでに存在するリソースグループ名"
}

variable "vnet_subnet_id" {
  type        = string
  description = "(必須)DNSサーバが属するサブネットID"
}

variable "ssh_key_path" {
  type        = string
  description = "(必須)DNSサーバにSSH接続するためのSSKキーのパス"
  default     = "~/.ssh/id_rsa.pub"
}

variable "virtual_machine_size" {
  type        = string
  default     = "Standard_B1ls"
  description = "DNSサーバのサイズ"
}

variable "source_address_prefix" {
  type        = list
  description = "送信元のIP(CIDR / source IP range / *)"
}

variable "tags" {
  default = {
    Name = "dnsserver"
  }
  description = "タグ名"
}

variable "private_ip_address" {
  type        = string
  description = "DNSServerの固定プライベートIP"
}