resource "cloudflare_zone" "theorangeonenet" {
  zone = "theorangeone.net"
}

resource "cloudflare_record" "theorangeonenet_git" {
  zone_id = cloudflare_zone.theorangeonenet.id
  name    = "git"
  value   = "theorange.com"
  type    = "A"
  ttl     = 1
}
