resource "aws_route53_zone" "rachaelwilliams" {
  name = "rachaelwilliams.fit"
  lifecycle {
      prevent_destroy = true
  }  
}

resource "aws_route53_record" "MX" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "rachaelwilliams.fit"
  type    = "MX"
  ttl     = 300
  records = ["1 SMTP.GOOGLE.COM"]
}

resource "aws_route53_record" "TXT" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "rachaelwilliams.fit"
  type    = "TXT"
  ttl     = 3600
  records = [
    "google-site-verification=28CPcxZ23FqNlwb8op8P84tRd34DV4MwlHTNc-vNBqY",
    "stripe-verification=8b048cd8c83fe6c3751e9d930ab895efd83df9e2dbe1bd4ae7f3c8b916a9c6e5",
  ]
}

resource "aws_route53_record" "_8a49c471dedcb6c19bb68ec36d25deb4_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "_8a49c471dedcb6c19bb68ec36d25deb4.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["_4bc2bd49638b3c19dd633ef86e79d951.gnvqnzwrct.acm-validations.aws."]
}

resource "aws_route53_record" "bouzkulciypyqmslpmlrbk35du5wva4o_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "bouzkulciypyqmslpmlrbk35du5wva4o._domainkey.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["bouzkulciypyqmslpmlrbk35du5wva4o.dkim.custom-email-domain.stripe.com."]
}

resource "aws_route53_record" "it2nfr22wa4sptqjc3bbjf6kcawahzrc_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "it2nfr22wa4sptqjc3bbjf6kcawahzrc._domainkey.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["it2nfr22wa4sptqjc3bbjf6kcawahzrc.dkim.custom-email-domain.stripe.com."]
}

resource "aws_route53_record" "k3vq2vc4ghqxim3dkqik264f7a76prj7_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "k3vq2vc4ghqxim3dkqik264f7a76prj7._domainkey.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["k3vq2vc4ghqxim3dkqik264f7a76prj7.dkim.custom-email-domain.stripe.com."]
}

resource "aws_route53_record" "nhydso44jz24cg7m7h2g4lbhu4bz24jf_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "nhydso44jz24cg7m7h2g4lbhu4bz24jf._domainkey.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["nhydso44jz24cg7m7h2g4lbhu4bz24jf.dkim.custom-email-domain.stripe.com."]
}

resource "aws_route53_record" "q4nyxizimdjrkh4tsdlf7gpocl2men7s_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "q4nyxizimdjrkh4tsdlf7gpocl2men7s._domainkey.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["q4nyxizimdjrkh4tsdlf7gpocl2men7s.dkim.custom-email-domain.stripe.com."]
}

resource "aws_route53_record" "qxzpfza4yghqjehetj7pzqnhcn3kkr6t_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "qxzpfza4yghqjehetj7pzqnhcn3kkr6t._domainkey.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["qxzpfza4yghqjehetj7pzqnhcn3kkr6t.dkim.custom-email-domain.stripe.com."]
}

resource "aws_route53_record" "bounce_CNAME" {
  zone_id = aws_route53_zone.rachaelwilliams.zone_id
  name    = "bounce.rachaelwilliams.fit"
  type    = "CNAME"
  ttl     = 300
  records = ["custom-email-domain.stripe.com."]
}

output "route53_zone_id" {
  value = aws_route53_zone.rachaelwilliams.zone_id
}
