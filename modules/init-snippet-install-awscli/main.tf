/**
 * ## Init Snippet: Install AWS CLI Tool
 *
 * Generate an init snippet to install the AWS cli tool on boot. This will:
 *
 * * use apt/yum to install `python-pip`
 * * use `pip` to upgrade `pip`
 * * us `pip` to install `awscli`
 *
 */

# variables used by this snippet of init shellcode
variable "init_prefix" {
  default     = ""
  description = "initial init (shellcode) to prefix this snippet with"
  type = string
}

variable "install_cmd" {
  default     = "apt install -y"
  description = "package manager install command (`apt install -y` by default)"
  type        = string
}

variable "init_suffix" {
  default     = ""
  description = "init (shellcode) to append to the end of this snippet"
  type = string
}

variable "log_prefix" {
  default     = "OPS: "
  description = "string to prefix log messages with"
  type = string
}

# render init script snippet from the template
data "template_file" "init_snippet" {
  template = file("${path.module}/snippet.tpl")

  vars = {
    init_prefix = var.init_prefix
    install_cmd = var.install_cmd
    init_suffix = var.init_suffix
    log_prefix  = var.log_prefix
  }
}

output "init_snippet" {
  value = data.template_file.init_snippet.rendered
}

