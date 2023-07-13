resource "random_password" "psql" {
  length           = 32
  special          = true
  override_special = "-_"
}

resource "random_password" "htpasswd" {
  length           = 32
  special          = true
  override_special = "-_"
}

resource "htpasswd_password" "hash" {
  password = random_password.htpasswd.result

  lifecycle {
    ignore_changes = [password]
  }
}

resource "time_static" "jwt_iat" {}

resource "time_static" "jwt_exp" {
  rfc3339 = timeadd(time_static.jwt_iat.rfc3339, "43829h") # Add 5 Years
}

resource "random_password" "jwt" {
  length           = 40
  special          = true
  override_special = "-_"
}

resource "jwt_hashed_token" "anon" {
  secret    = random_password.jwt.result
  algorithm = "HS256"
  claims_json = jsonencode(
    {
      role = "anon"
      iss  = "supabase"
      iat  = time_static.jwt_iat.unix
      exp  = time_static.jwt_exp.unix
    }
  )
}

resource "jwt_hashed_token" "service_role" {
  secret    = random_password.jwt.result
  algorithm = "HS256"
  claims_json = jsonencode(
    {
      role = "service_role"
      iss  = "supabase"
      iat  = time_static.jwt_iat.unix
      exp  = time_static.jwt_exp.unix
    }
  )
}

locals {
  default_tags = [
    "supabase",
    "digitalocean",
    "terraform"
  ]

  smtp_sender_name   = var.smtp_sender_name != "" ? var.smtp_sender_name : var.smtp_admin_user
  smtp_nickname      = var.smtp_nickname != "" ? var.smtp_nickname : var.smtp_sender_name != "" ? var.smtp_sender_name : var.smtp_admin_user
  smtp_reply_to      = var.smtp_reply_to != "" ? var.smtp_reply_to : var.smtp_admin_user
  smtp_reply_to_name = var.smtp_reply_to_name != "" ? var.smtp_reply_to_name : var.smtp_sender_name != "" ? var.smtp_sender_name : var.smtp_admin_user

  env_file = templatefile("${path.module}/files/.env.tftpl",
    {
      TF_PSQL_PASS            = "${random_password.psql.result}",
      TF_JWT_SECRET           = "${random_password.jwt.result}",
      TF_ANON_KEY             = "${jwt_hashed_token.anon.token}",
      TF_SERVICE_ROLE_KEY     = "${jwt_hashed_token.service_role.token}",
      TF_DOMAIN               = "${var.domain}",
      TF_SITE_URL             = "${var.site_url}",
      TF_TIMEZONE             = "${var.timezone}",
      TF_REGION               = "${var.region}",
      TF_SMTP_ADMIN_EMAIL     = "${var.smtp_admin_user}",
      TF_SMTP_HOST            = "${var.smtp_host}",
      TF_SMTP_PORT            = "${var.smtp_port}",
      TF_SMTP_USER            = "${var.smtp_user}",
      TF_SMTP_PASS            = "dummy",
      TF_SMTP_SENDER_NAME     = "${local.smtp_sender_name}",
      TF_DEFAULT_ORGANIZATION = "zweitag",
      TF_DEFAULT_PROJECT      = "DEFAULT",
    }
  )

  kong_file = templatefile("${path.module}/files/kong.yml.tftpl",
    {
      TF_ANON_KEY         = "${jwt_hashed_token.anon.token}",
      TF_SERVICE_ROLE_KEY = "${jwt_hashed_token.service_role.token}",
    }
  )

  cloud_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/root/supabase/.env"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode("${local.env_file}")
    },
    {
      path        = "/root/supabase/volumes/api/kong.yml"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode("${local.kong_file}")
    },
  ]
})}
  END
}

resource "local_file" "env_file" {
  content  = local.env_file
  filename = "${path.module}/.env"
}

resource "local_file" "kong_file" {
  content  = local.kong_file
  filename = "${path.module}/kong.yml"
}
