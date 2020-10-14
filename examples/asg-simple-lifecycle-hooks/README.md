# Example of basic ASG integration with lifecycle hooks

The difference between this and the one one is that we aren't using
any load balancers in this example.

## Environment creation and deployment

To use this example set up AWS credentials and then run the commands in the
following order:

```
make ssh-key
make init
make plan-vpc
make apply
make plan-subnets
make apply
make plan-gateway
make apply
make plan
make apply
```

## Testing

Get the public IP address of the newly created ec2 web instance with the AWS console.

SSH into the machine with the command:

```
ssh -i id_rsa ec2-user@<ec2-ip-address>
```

You can see in the machine that `lifecycled` daemon would be
running. You can check the status of the service using

```
systemctl status lifecycled.service
```


## Test the Notification

To generate a notification for a launch event, update the Auto Scaling group by increasing the desired capacity of the Auto Scaling group by 1. You receive a notification within a few minutes after instance launch.

To change the desired capacity using the console

    Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/.

    On the navigation pane, under Auto Scaling, choose Auto Scaling Groups.

    Select your Auto Scaling group.

    On the Details tab, choose Edit.

    For Desired, decrease the current value by 1.

    Choose Save.

    After a few minutes, you'll see that the lifecycle-handler.sh script will be executed and it's side effect operation will be performed.


## Destruction

To destroy the test environment run the following commands:

```
make destroy
make clean
```

## Notes
- This example was last tested with `Terraform v0.11.11`
- This example assumes AWS credentials setup with access to the **us-east-2** region.
