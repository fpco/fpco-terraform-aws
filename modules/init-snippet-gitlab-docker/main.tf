/**
 * ## init-snippet to run gitlab w/ docker
 *
 * Generate a `docker run` command to run the gitlab server. The command is
 * both written out to `/etc/rc.local` and to executed directly in the snippet.
 *
 */

variable "init_prefix" {
  default     = ""
  description = "initial init (shellcode) to prefix this snippet with"
  type        = string
}

variable "init_suffix" {
  default     = ""
  description = "init (shellcode) to append to the end of this snippet"
  type        = string
}

variable "log_prefix" {
  default     = "OPS: "
  description = "string to prefix log messages with"
  type        = string
}

variable "registry_bucket_name" {
  description = "the name of the S3 bucket to write docker images to"
  type        = string
}

variable "registry_bucket_region" {
  description = "the region of the S3 bucket to write docker images to"
  default     = "us-east-1"
  type        = string
}

variable "gitlab_domain" {
  description = "The example.com in gitlab.example.com"
  type        = string
}

variable "gitlab_name" {
  description = "The name of the gitlab instance, to build URL (gitlab.example.com)"
  default     = "gitlab"
  type        = string
}

variable "gitlab_registry_name" {
  description = "The name for the gitlab registry, without the 'gitlab.example.com'"
  default     = "registry"
  type        = string
}

variable "gitlab_ssh_port" {
  default     = "8022"
  description = "The port to use for ssh access to the gitlab instance"
  type        = number
}

variable "gitlab_http_port" {
  default     = "80"
  description = "The port to use for http access to the gitlab instance"
  type        = number
}

variable "gitlab_https_port" {
  default     = "443"
  description = "The port to use for https access to the gitlab instance"
  type        = number
}

variable "gitlab_image_tag" {
  default     = "latest"
  description = "The tag for the docker image"
  type        = string
}

variable "gitlab_image_repo" {
  default     = "gitlab/gitlab-ce"
  description = "The name (repo) of the docker image"
  type        = string
}

variable "gitlab_data_path" {
  default     = "/gitlab"
  description = "path for gitlab data"
  type        = string
}

variable "config_elb" {
  default     = true
  description = "variable to determine how to set up gitlab configuration. The default uses the original version of module tuned to ELB"
  type        = bool
}

# render the "GITLAB_OMNIBUS_CONFIG" envvar for inclusion in our init snippet
# NOTE - leave the '\' at the end of the rendered template, as there will be a
# newline when using rendered()
# There are two possible templates. The first is opinionated, in that it's setting up SSL, nginx and the registry to
# work with SSL and the AWS ELB
data "template_file" "omnibus_config_elb" {
  count    = var.config_elb == true ? 1 : 0
  template = <<EOC
external_url '$${gitlab_url}'; registry_external_url '$${registry_url}'; registry_nginx['listen_port']=$${http_port}; registry_nginx['listen_https'] = false; registry_nginx['proxy_set_headers'] = {'X-Forwarded-Proto' => 'https', 'X-Forwarded-Ssl' => 'on'}; nginx['listen_port']=$${http_port}; nginx['listen_https'] = false; nginx['proxy_set_headers'] = {'X-Forwarded-Proto' => 'https', 'X-Forwarded-Ssl' => 'on'}; registry['storage']={'s3' => {'bucket' => '$${registry_bucket_name}', 'region' => '$${registry_bucket_region}' }};
EOC


  vars = {
    gitlab_url             = "https://${var.gitlab_name}.${var.gitlab_domain}"
    registry_url           = "https://${var.gitlab_registry_name}.${var.gitlab_domain}"
    registry_bucket_region = var.registry_bucket_region
    registry_bucket_name   = var.registry_bucket_name
    ssh_port               = var.gitlab_ssh_port
    http_port              = var.gitlab_http_port
  }
}

## The second is opinionated, in that it's setting up SSL, nginx and the registry to
# work with ASG EIP and uses default Let's Encrypt
data "template_file" "omnibus_config_eip" {
  count    = var.config_elb == false ? 1 : 0
  template = <<EOC
external_url '$${gitlab_url}'; registry_external_url '$${registry_url}'; nginx['redirect_http_to_https'] = true; registry['storage']={'s3' => {'bucket' => '$${registry_bucket_name}', 'region' => '$${registry_bucket_region}' }};
EOC


  vars = {
    gitlab_url             = "https://${var.gitlab_name}.${var.gitlab_domain}"
    registry_url           = "https://${var.gitlab_registry_name}.${var.gitlab_domain}"
    registry_bucket_region = var.registry_bucket_region
    registry_bucket_name   = var.registry_bucket_name
    ssh_port               = var.gitlab_ssh_port
    http_port              = var.gitlab_http_port
  }
}

# render init script snippet from the template
data "template_file" "init_snippet" {
  template = <<END_INIT
# start snippet - run gitlab docker image
${var.init_prefix}
cmd="#!/bin/sh
docker run --detach \
  --restart always \
  --hostname ${var.gitlab_name}.${var.gitlab_domain} \
  --publish ${var.gitlab_https_port}:443 \
  --publish ${var.gitlab_http_port}:80 \
  --publish ${var.gitlab_ssh_port}:22 \
  --volume ${var.gitlab_data_path}/config:/etc/gitlab \
  --volume ${var.gitlab_data_path}/logs:/var/log/gitlab \
  --volume ${var.gitlab_data_path}/data:/var/opt/gitlab \
  --env GITLAB_OMNIBUS_CONFIG=\"${element(concat(data.template_file.omnibus_config_elb.*.rendered,data.template_file.omnibus_config_eip.*.rendered),0,)}\" \
  ${var.gitlab_image_repo}:${var.gitlab_image_tag}"
echo "$cmd" > /etc/rc.local
chmod +x /etc/rc.local
/etc/rc.local
${var.init_suffix}
END_INIT

}

output "init_snippet" {
  value       = data.template_file.init_snippet.rendered
  description = "rendered init snippet to run gitlab with docker"
}

output "gitlab_config" {
  value = {
    external_url           = "https://${var.gitlab_name}.${var.gitlab_domain}"
    registry_external_url  = "https://${var.gitlab_registry_name}.${var.gitlab_domain}"
    registry_bucket_region = var.registry_bucket_region
    registry_bucket_name   = var.registry_bucket_name
    ssh_port               = var.gitlab_ssh_port
    http_port              = var.gitlab_http_port
    https_port             = var.gitlab_https_port
  }

  description = "connection details about gitlab"
}

