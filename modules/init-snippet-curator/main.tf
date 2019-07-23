/**
 * ## Init Snippet: Curator
 *
 * This module generates an init snippet that does the following for an
 * ubuntu or other apt-based system:
 *
 * * `apt-get update`
 * * install `python-pip` with apt
 * * install `elasticsearch-curator` with `pip`
 * * add a user `curator`
 * * make the `/var/log/curator/` directory, owned by the `curator` user
 * * add a cronjob for this user, to run `/usr/local/bin/curator` at `30 1 * * *`
 * * write out the config files needed by the curator
 *
 */

data "template_file" "curator-setup" {
  template = file("${path.module}/snippet.tpl.sh")

  vars = {
    index_retention_unit   = var.index_retention_unit
    index_retention_period = var.index_retention_period
    extra_curator_actions  = var.extra_curator_actions
    elasticsearch_host     = var.elasticsearch_host
    elasticsearch_port     = var.elasticsearch_port
    master_only            = var.master_only
  }
}

variable "index_retention_unit" {
  default     = "days"
  description = "Units (seconds, minutes, hours, days, etc.) corresponding to index retention period."
  type        = string
  # See https://www.elastic.co/guide/en/elasticsearch/client/curator/current/filtertype_age.html for options
}

variable "index_retention_period" {
  default     = 60
  description = "Age of Elasticsearch indices in days before they will be considered old and be pruned by the curator. Set to 0 in order to disable."
  type        = number
}

variable "extra_curator_actions" {
  default     = ""
  description = "YAML formatted dictionary of actions, as described in documentation, but started at index '2', since action number '1' is the one that purges old indices."
  type        = string
}

variable "elasticsearch_host" {
  default     = "localhost"
  description = "Hostname for Elasticsearch API"
  type        = string
}

variable "elasticsearch_port" {
  default     = 9200
  description = "Port number for Elasticsearch API"
  type        = number
}

variable "master_only" {
  default     = true
  description = "If installed on master eligible nodes, will only run if current node is an elected master"
  type        = bool
}

output "init_snippet" {
  value = data.template_file.curator-setup.rendered
}

