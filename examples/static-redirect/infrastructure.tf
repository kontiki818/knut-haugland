variable "region" {}
variable "acm_certificate_arn" {}
variable "route53_domain" {}
variable "route53_zone_id" {}
variable "s3_bucket_cdn_log" {}
variable "s3_bucket_site" {}
variable "enable_s3_bucket_extras" {}
variable "s3_bucket_extras" {}
variable "enable_lambda_viewer_request" {}
variable "lambda_viewer_request_arn" {}
variable "enable_lambda_origin_request" {}
variable "lambda_origin_request_arn" {}

module "kon_tiki" {
  source                       = "cliffano/kon-tiki/aws"
  version                      = "0.10.0"
  acm_certificate_arn          = var.acm_certificate_arn
  route53_domain               = var.route53_domain
  route53_zone_id              = var.route53_zone_id
  s3_bucket_cdn_log            = var.s3_bucket_cdn_log
  s3_bucket_site               = var.s3_bucket_site
  enable_s3_bucket_extras      = var.enable_s3_bucket_extras
  s3_bucket_extras             = var.s3_bucket_extras
  enable_lambda_viewer_request = var.enable_lambda_viewer_request
  lambda_viewer_request_arn    = var.lambda_viewer_request_arn
  enable_lambda_origin_request = var.enable_lambda_origin_request
  lambda_origin_request_arn    = var.lambda_origin_request_arn
  region                       = var.region
  tags = {
    project = "kon-tiki"
    site    = "knuthauglandexample"
  }
}

module "kon_tiki_addendum" {
  source              = "./stage/terraform-studio-kon-tiki/"
  region              = "ap-southeast-2"
  site_id             = "knuthauglandexample"
  site_cdn_id         =  module.kon_tiki.cloudfront_distribution_cdn.id
  site_gh_repo        = "kon-tiki"
  site_gh_secret_name = "KNUTHAUGLANDEXAMPLE_CLOUDFRONT_DISTRIBUTION"
}