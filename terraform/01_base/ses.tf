resource "aws_sesv2_email_identity" "this" {
  email_identity = "rachaelwilliams.fit"
}

output "ses_identity_arn" {
  value = aws_sesv2_email_identity.this.arn
}
