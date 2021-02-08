# single node asg tester

This example shows the basic usage of `single-node-asg` module, especially the multiple EBS attachments.

The module keeps one and only one instance up at all time. And the EBS volumes are reattached when a new instance is up. Hence they are always accessible.
