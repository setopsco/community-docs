variable "region" {
  description = "The region where the Droplet will be created."
  type        = string
  default     = "eu-central-1"
}

variable "timezone" {
  description = "Timezone to use for Nginx (e.g. Europe/Amsterdam)."
  type        = string
  default     = "Europe/Berlin"
}

variable "site_url" {
  description = "Domain name of your application in the format."
  type        = string
  default     = "SITE_URL"
}

variable "domain" {
  description = "Domain name where the Supabase instance is accessible. The final domain will be of the format `supabase.example.com`"
  type        = string
  default     = "DOMAIN"
}

variable "smtp_admin_user" {
  description = "`From` email address for all emails sent."
  type        = string
  default     = "sysad@zweitag.de"
}

variable "smtp_addr" {
  description = "Company Address of the Verified Sender. Max 100 characters. If more is needed use `smtp_addr_2`"
  type        = string
  default     = ""
}

variable "smtp_city" {
  description = "Company city of the verified sender."
  type        = string
  default     = "Münster"
}

variable "smtp_country" {
  description = "Company country of the verified sender."
  type        = string
  default     = "DE"
}

variable "smtp_host" {
  description = "The external mail server hostname to send emails through."
  type        = string
  default     = "smtp.sendgrid.net"
}

variable "smtp_port" {
  description = "Port number to connect to the external mail server on."
  type        = number
  default     = 465
}

variable "smtp_user" {
  description = "The username to use for mail server requires authentication"
  type        = string
  default     = "apikey"
}

variable "smtp_sender_name" {
  description = "Friendly name to show recipient rather than email address. Defaults to the email address specified in the `smtp_admin_user` variable."
  type        = string
  default     = "Zweitag"
}

variable "smtp_addr_2" {
  description = "Company Address Line 2. Max 100 characters."
  type        = string
  default     = ""
}

variable "smtp_state" {
  description = "Company State."
  type        = string
  default     = "NRW"
}

variable "smtp_zip_code" {
  description = "Company Zip Code."
  type        = string
  default     = "48143"
}

variable "smtp_nickname" {
  description = "Nickname to show recipient. Defaults to `smtp_sender_name` or the email address specified in the `smtp_admin_user` variable if neither are specified."
  type        = string
  default     = ""
}

variable "smtp_reply_to" {
  description = "Email address to show in the `reply-to` field within an email. Defaults to the email address specified in the `smtp_admin_user` variable."
  type        = string
  default     = "sysad@zweitag.de"
}

variable "smtp_reply_to_name" {
  description = "Friendly name to show recipient rather than email address in the `reply-to` field within an email. Defaults to `smtp_sender_name` or `smtp_reply_to` if `smtp_sender_name` is not set, or the email address specified in the `smtp_admin_user` variable if neither are specified."
  type        = string
  default     = "Zweitag"
}
