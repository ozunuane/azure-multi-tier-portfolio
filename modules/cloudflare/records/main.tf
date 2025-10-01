
# provider "cloudflare" {
#   api_token = var.cloudflare_api_token
#   alias     = "dns"
# }

resource "cloudflare_record" "inafl" {
  #   provider = cloudflare.dns
  for_each = { for domain in var.domains : domain => domain }
  zone_id  = var.cloudflare_zone_id
  name     = each.key
  content  = var.ip_address
  type     = "A"
  ttl      = 1
  proxied  = true
}