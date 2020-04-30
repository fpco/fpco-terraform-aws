# (Unreleased)

### Summary

### Modules

* nat-gateways: Fix association issue caused between `nat_eip` and
  public subnets. This only affects resources using the `nat_eip` variable.

* `init-snippet-install-awscli`: new argument to allow not only `apt` as a
  command to install OS packages

### Examples

# v0.9.16

### Summary

* Improvements to 2 existing modules.
* 1 new module.
* 1 new example.

### Modules

* nat-gateways: Add additional variables `enable_nat_creation` and
  `nat_eip` for enabling support for migrating EIP between NAT
  gateways.
* `single-node-asg`: Pass the `alb_target_group_arns` to the `asg` module
* `single-port-sg-src`: This new module is a fork of the existin `single-port-sg` module (to support `source_security_group`).
*  `setup-meta-infrastructure`: Add all `Get*` and `List*` actions to `power-user` 

### Examples

* `simple-snag`:  Add a basic example for the Single-Node AutoScaling Group module/pattern 

# v0.9.15

### Summary

Updates to the ASG module

### Modules

* `asg` : Switch up how targets groups are associated with the ASG
* `asg` : add `protect_from_scale_in` to allow instance termination protection
* `asg` : add `suspended_processes`

### Examples

* No changes

# v0.9.14

### Summary

New modules and function extendings.

### Modules

* dlm-lifecycle-policy: Merge dlm-lifecycle-iam-role.

* init-snippet-install-docker-yum: CentOS script to install docker/docker-compose.

* init-snippet-attach-ebs-volume: Working on CentOS now. Generates required device name now despite Linux differences.

* single-node-asg: Output the attached EBS Name tag for DLM to match.

* rds: RDS database.

* s3-remote-state: fix for #286.

* asg: add protect_from_scale_in and suspended_processes attrs.

### Examples

* No changes


# v0.9.13

### Summary

Fix an issue with the `ami-centos` module where it would pull similarly named ami's
from untrusted 3rd parties

### Modules

* `ami-centos` in https://github.com/fpco/terraform-aws-foundation/pull/299

### Examples

* No changes

# v0.9.12

### Summary 

Small release to update the `tf-cloud-credential` module to use the `workspace_id`
instead of the workspace name to set credentials for that workspace.

### Modules

* `tf-cloud-credential` in https://github.com/fpco/terraform-aws-foundation/pull/293

### Examples

* No changes

# v0.9.11

### Summary

Quick release to address resource name bug in `single-port-sg` module. Will
review the others for the next release.

### Modules

* `single-port-sg`: fixup - to _ in resource names

### Examples

* No changes


# v0.9.10

### Summary

* Support encrypted EBS volumes on ASG, for root _and_ data volumes.
* Update linting tests
* Update 2 init snippets

### Modules

* `init-snippet-attach-ebs-volume`: Retrying attaching EBS
* `asg`: Add support for encrypting the root and additional attached EBS volumes.
* `init-snippet-install-awscli`: Uses Python3 for awscli. (#281)

### Examples

* No changes


# v0.9.9

### Summary

New feature for `asg` module and bugfix for `tf-cloud-credentials` module.

### Modules

* `asg`: Allow ASG instances to have additional EBS block devices
* `tf-cloud-credentials`: Switch the module to use a datasource to lookup an
  existing TF Cloud workspace instead of trying to create one.

### Examples

* No changes.


# v0.9.8

### Summary

* Fixes and updates to a few modules, mostly related to IAM.

### Modules

* `iam-users`: fixed error from zipmap in outputs when a user gets deleted
  from user list
* `tf-cloud-credential`: minor interpolation cleanup, added module to tests
* `setup-meta-infrastructure`: Parameterize password length and age for iam
  password policy.
* `iam-instance-profile`: Add role ID ouput for IAM instance profile module.

### Examples

* No changes.


# v0.9.7

### Summary

* Updates to `asg` and `vpc` modules, new example for AD w/ Windows Server.

### Modules

* `asg`: drop `availability_zones` parameter.
* `vpc`: Added variable `domain_name` to enable setting a custom domain_name
  in the VPC DHCP Options Set.

### Examples

* `ad-ec2`: Demonstrate how an Windows EC2 instance seamlessly joins an Active
  directory when it gets newly spawned.


# v0.9.6

### Summary

* New module: `tf-cloud-credentials`.
* Updates to DLM and other modules.

### Modules

* `tf-cloud-credentials`: Adds module for associating existing AWS credentials
  with a Terraform Cloud workspace.
* `dlm-lifecycle-iam-role`: Added DLM IAM role to allow create snapshots
* `dlm-lifecycle-policy`: Update DML module to tf 0.12 and move the IAM role to another role
* Module to enable DML lifecycle policies
* Revert removing output `asg_iam_role_name`
* Bugfix for `persistent-ebs`

### Examples

* No changes.


# v0.9.5

### Summary

* Various updates to the `setup-meta-infrastructure`, `asg`, and `nat-gateways`
  modules.

### Modules

* `setup-meta-infrastructure`: add "iam:Get{User,Role,Policy}" permissions for
  power-users.
* lifecycle hooks added to `asg` and so `asg-lifecycle` was removed
* `nat-gateways`: **Breaking change**: move the inline route route in the route
  table to a separate route, so that users of the module can add extra routes
  to it without causing conflicts.  Note: after you upgrade, you will likely
  get an error that the `aws_route.private_nat_gateway` route already exists.
  You will need to _manually_ remove the conflicting route (which was created
  by the old inline route), for example in the AWS console, and then re-apply
  to add it back.

### Examples

* No changes.


# v0.9.4

### Summary

* Update `iam-instance-profile` module.

### Modules

* `iam-instance-profile`: Add role ouput for IAM instance profile module.

### Examples

* No changes.


# v0.9.3

### Summary

* New module for IAM
* Fixes to ASG, single-node-ASG and persistent-ebs modules
* Drop deprecated nexus-asg example
* Fixes for VPC Scenario 2 example


### Modules

* `iam-instance-profile`: Add new module, abstract the usage pattern of IAM instance profile.
* `single-node-asg`:
  * update to use new `iam-instance-profile` module
  * whitespace fixup
  * use `locals{}` block to improve readability
* `persistent-ebs`: update to use new `iam-instance-profile` module and sync with recent updates to the `single-node-asg` module
* `asg`: parametize target group and health check type


### Examples

* `nexus-asg`: Drop deprecated example.
* `vpc-scenario-2`:
  * Fix updates missed during v0.12.x upgrade
  * Improve `Makefile`
  * Set name tag on ELB

# v0.9.2

### Summary

* Bug fixes for some network modules

### Modules

* subnets: use name subnets like 01, 02, 03, not with zero index (eg 00)
* nat-gateways: support adding tags for the aws_nat_gateway resource
* nat-gateways: accept a longer list of private subnets than public/NAT GWs

### Examples

* examples/vpc-scenario-2: fixup `all` target


# v0.9.1

### Summary

* Improve support for autoscaling ASG.
* Fixup `ami-centos` module for `v0.12.x`

### Modules

* `autoscaling-policy-metric-alarm-pair`: Add a new module that provides the autoscaling functions extracted from the `load-asg` example.
* `ami-centos`: simple module to get the ami id of the specified release of CentOS.

### Examples

* `load-asg`: updated to use new `autoscaling-policy-metric-alarm-pair` module


# v0.9.0

### Summary

Initial support for Terraform v0.12.x and HCL 2. Probably got bugs.

All modules and examples have been updated. Tests have been run, but that does
not mean bug free. More testing will likely find additional issues. New releases
will be made to accomodate.


# v0.8.5

### Summary

* Disable tests for the new new IAM user/group modules, which do not support v0.11.x
* New module for looking up CentOS AMIs on AWS

### Modules

* `ami-centos`: simple module to get the ami id of the specified release of CentOS.

### Examples

* `ami-centos-test`: New testing example for `ami-centos`.


# v0.8.4

### Summary

Breaking change in the `single-port-sg` module (if you are using UDP, TCP should
not see any break).

### Modules

* `single-port-sg`: Add support for UDP rules
* `kube-controller-sg`: Update to sync with `single-port-sg` module


# v0.8.3

### Modules

* `iam-group`: add new module to create a group and manage the members and policy attachments for that group, only for Terraform v0.12.x
* `iam-users`: add new module to create a bunch of IAM user resources from a list of usernames, only for Terraform v0.12.x
* `vpc-legacy`: drop deprecated module
* The following modules have templates that were updated to resolve issues related to
  [this upstream release of the template provider][1]:
  * `consul-agent-generic-init`
  * `consul-leaders-generic-init`
  * `ha-management-cluster`
  * `init-snippet-attach-ebs-volume`
  * `init-snippet-config-consul-leader`
  * `init-snippet-config-upstart-consul`
  * `init-snippet-consul-agent`
  * `init-snippet-consul-leader`
  * `init-snippet-consul-template`
  * `init-snippet-hostname-simple`
  * `init-snippet-hostname`
  * `init-snippet-install-consul`
  * `init-snippet-install-ops`
  * `init-snippet-nexus`
  * `init-snippet-nomad-agent`
  * `init-snippet-prometheus`
  * `init-snippet-write-bootstrap-pillar`
* `vpc-scenario-2`: minor bugfix for NAT count

[1]: https://github.com/terraform-providers/terraform-provider-template/blob/master/CHANGELOG.md#200-january-14-2019

### Examples

* `vpc-scenario-2`: Update for improved testing of the scenario and related modules
* `gitlab-ha`: Update `Makefile`
* `vpc-gateway`: correct module path reference
* `legacy`: drop deprecated example


# v0.8.2

### Summary

* Some minor module updates, a couple of new modules, and a couple of new examples
* New contributing guide and issue templates

### Modules

* `ami-ubuntu`: Add `bionic` (`18.04`) to the list of LTS AMIs
* `credstash-grant-reader` and `credstash-grant-writer`: Add new modules using AWS resources instead of bash scripts

### Examples

* `kops-with-vpc`: add new example, kops in a vpc made by terraform (#177)
* `lifecycle-hooks`: add new example, with lifecycle hooks for ASGs

# v0.8.1

### Summary

* Two minor updates

### Modules

* `credstash-grant`: add support for the AWS_PROFILE envvar

### Examples

* `gitlab-ha`: Update `Makefile` to respect the user's preferred shell when
  spawing an interactive shell.

# v0.8.0

### Summary

* breaking changes to modules that use ASG and previously had `desired_capacity`,
  this parameter is dropped to ensure scaling policies are ok.
* overhaul gitlab examples, see [pr-164][pr-164], [pr-167][pr-167] and [pr-168][pr-168]

### Modules

* `asg`: remove `desired_capacity` input
* `asg`: add `termination_policies` input
* `consul-cluster`: remove `desired_capacity` input
* `consul-leaders`: remove `desired_capacity` input
* `kube-stack`: remove `controller_desired_capacity`  and `worker_desired_capacity` inputs
* `kube-controller-asg`: add new module

### Examples

* refactor the workflow in the `gitlab-asg` example, adding support for TLS and much more
* rename `gitlab-asg` example --> `gitlab-simple-ha`, [pr-164][pr-164]
* duplicate `gitlab-simple-ha` as `gitlab-ha`, both can now get updates independent
  of one another, [pr-167][pr-167]
* update `gitlab-simple-ha` to use EIP instead of ELB, drop TLS, [pr-168][pr-168]

[pr-164]: https://github.com/fpco/terraform-aws-foundation/pull/164
[pr-167]: https://github.com/fpco/terraform-aws-foundation/pull/167
[pr-168]: https://github.com/fpco/terraform-aws-foundation/pull/168


# v0.7.6

### Summary

* enhancements to various modules

### Modules

* `ec2-auto-recover-instance`: fixup interpolation
* `kube-stack`: updates for ELB


# v0.7.5.1

### Summary

* quick bugfix release

### Modules

* `vpc-scenario-2`: drop redundant azs
* `aws-ipsec-vpn`: connection type is hardcoded to 'ipsec.1'


# v0.7.5

### Summary

* enhancements to various modules
* move `terraform-vpc` to examples and update packer build

### Modules

* `r53-subdomain`: added zone name outputs
* `single-node-asg`: drop az from the EBS volume name (it was redundant)
* `aws-ipsec-vpn`: add support for govcloud and FIPS endpoints
* `init-snippet-curator`:
  * bugfix for `master_only`
  * parametize index retention units
  * pin pip at 9.x

### Examples

* move `terraform-vpc` to `examples`


# v0.7.4

### Summary

* Refine test suite and get CI build green
* Improve type checking in module variables
* Demo how to validate S3 policies with new env and test suite
* Various module bugfixes

### Examples

* `s3-full-access-policy`: add env and initial test suite - [#122][122]
* `vpc-scenario-2`: refactor hardcoded AZ list, use locals - [#134][132]

### Modules

* `prometheus-server`: sync with changes to variables/modules - [#107][107]
* `credstash-setup`: pip 10 is a failure, use pip 9.x for now - [#145][145]
* `init-snippet-install-awscli`: pip 10 is a failure, use pip 9.x for now - [#145][145]
* `bind-server`: allow `db_records_folder` variable to be empty - [#135][135]
* add type definitions to all variables in all modules - [#108][108]

### Packer

* `kubespray`: parametize docker tag - [#123][123]

### Tests

* add `Makefile` to install tools and init Terraform
* use `tflint` 0.6.0 to resolve [#107][107]
* drop `vpc-legacy` module from the test suite
* enable tfinit for [#104][104], disable `undeclared-variables` for [#141][141]

[122]: https://github.com/fpco/terraform-aws-foundation/issues/122
[132]: https://github.com/fpco/terraform-aws-foundation/issues/132
[107]: https://github.com/fpco/terraform-aws-foundation/issues/107
[145]: https://github.com/fpco/terraform-aws-foundation/pull/145
[108]: https://github.com/fpco/terraform-aws-foundation/issues/108
[135]: https://github.com/fpco/terraform-aws-foundation/issues/135
[123]: https://github.com/fpco/terraform-aws-foundation/issues/123
[141]: https://github.com/fpco/terraform-aws-foundation/issues/141


# v0.7.3

### Examples

#### `cloud-dev-workspace`

* correct `vpc_cidr`

#### `kube-stack-private`

* fixup helpdoc in Makefile, #76
* refactor out hardcoded AZ list, use `locals`
* add `generate-ssh-key` target to Makefile
* `make network` should target `nat-gateways`

#### `vpc-scenario-1`

* az bugfix for web instance, #125
* update for consistency with other example env

#### `vpc-scenario-2`

* fixup README
* fixup `make test`
* add missing security group rule for ELB
* update for consistency with other example env

#### `vpc-scenario-2-nat-instance`

* fix build, improve Makefile

#### `vpc-scenario-2-nat-instance-per-az`

* fix build, improve Makefile


### Modules

#### `nat-gateways`:

* use `aws_subnet` data source to lookup subnets
* use `element()` instead of `var.foo[]` syntax

#### `bind-server`

* support empty private_ips, allow disabling DNS
* Initial CI setup, run `tflint`


### Documentation

* how to setup ci, #113


# v0.7.2

* `ex/kube-stack-private`: tag public subnets for ELBs
* `ex/kube-stack-private`: use `extra_tags` for changes in Kubernetes
* `kube-stack`: add missing tag for kubernetes
* `vpc-scenario-2`: refactor how extra_tags are used
* `vpc-scenario-2`: use `var.private_subnet_cidrs` for `nat_count`
* `vpc-scenario-4`: fixup outputs and subnet module parameters
* `examples/nexus-asg`: Use the `ubuntu-ami` module, drop hardcoded AMI
* `docs`: add `testing-design` doc
* `examples/vpc-scenario-peering`: Correct destroy target in Makefile, this was
  previously unable to properly destroy the deployment.
* `modules/vpc-scenario-2`: use `var.private_subnet_cidrs` for `nat_count`
* `vpc-scenario-2`: refactor how `extra_tags` are used. Support adding specific
  tags to specific components in the boxed VPC. Update the `kube-stack-private`
  env to use these new variables. This greatly simplifies how tags are supported
  and used in the kubernetes env.
* Refactor inline IAM policies into proper data sources
* Implement lightweight test framework to automate finding bugs in our modules
  and example Terraform env


# v0.7.1

Minor bugfix release

* Fixup quotes in `init-snippet-exec` module


# v0.7.0

Massive update to nearly all aspects of the module repo, including:

* New modules and example environments
* Refactored security group modules
* Updates to get modules visible on the Terraform registry
* Many updates to various modules
