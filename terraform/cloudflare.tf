resource "cloudflare_zone" "rachaelwilliams" {
  zone = "rachaelwilliams.fit"
  plan = "free"
}

resource "cloudflare_record" "MX" {
  zone_id = cloudflare_zone.rachaelwilliams.id
  name    = "rachaelwilliams.fit"
  type    = "MX"
  value   = "1 SMTP.GOOGLE.COM"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "TXT" {
  zone_id = cloudflare_zone.rachaelwilliams.id
  name    = "rachaelwilliams.fit"
  type    = "TXT"
  value   = "google-site-verification=28CPcxZ23FqNlwb8op8P84tRd34DV4MwlHTNc-vNBqY"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "TXT_stripe" {
  zone_id = cloudflare_zone.rachaelwilliams.id
  name    = "rachaelwilliams.fit"
  type    = "TXT"
  value   = "stripe-verification=8b048cd8c83fe6c3751e9d930ab895efd83df9e2dbe1bd4ae7f3c8b916a9c6e5"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "TXT_ahrefs" {
  zone_id = cloudflare_zone.rachaelwilliams.id
  name    = "rachaelwilliams.fit"
  type    = "TXT"
  value   = "ahrefs-site-verification_22a88787daa4ff5f2eda77ba4e38f5d9e60b942e8b2337d1b8cd5c5565a01eb8"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "CNAME_bounce" {
  zone_id = cloudflare_zone.rachaelwilliams.id
  name    = "bounce"
  type    = "CNAME"
  value   = "custom-email-domain.stripe.com"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "CNAME_forms" {
  zone_id = cloudflare_zone.rachaelwilliams.id
  name    = "forms"
  type    = "CNAME"
  value   = "cname.tally.so"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "CNAME_blog" {
  zone_id = cloudflare_zone.rachaelwilliams.id
  name    = "blog"
  type    = "CNAME"
  value   = "ghs.google.com"
  ttl     = 300
  proxied = false
}

output "cloudflare_zone_id" {
  value = cloudflare_zone.rachaelwilliams.id
}
