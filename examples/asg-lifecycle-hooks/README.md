# Example of basic ASG integration with lifecycle hooks

We use the [lifecycled](https://github.com/buildkite/lifecycled
"lifecycled") tool to run a script whenever an instance in an ASG gets
an scale-in event.

## lifecycled

lifecyled is an executable provided by buildkite. Note that the
executable will be run on the ASG's instance. Note that it
automatically creates an [SQS
queue](https://github.com/buildkite/lifecycled/commit/fa9f36f25a6ca6ceb3dae1814bacc26b3643392d
"SQS queue") and subscribes to the SNS topic you have created. So,
using this approaches makes you depend on two AWS services.

## Environment creation and deployment

To use this example set up AWS credentials and then run the commands in the
following order:

```
$ make ssh-key
$ make init
$ make plan-vpc
$ make apply
$ make plan-subnets
$ make apply
$ make plan-gateway
$ make apply
$ make plan
$ make apply
```

## Testing

SSH into the ASG instance with the command:

``` shellsession
$ ssh -i id_rsa ec2-user@<ec2-ip-address>
```

You can see in the machine that `lifecycled` daemon would be
running. You can check the status of the service using

``` shellsession
$ systemctl status lifecycled.service
[ec2-user@ip-10-23-11-146 ~]$ systemctl status lifecycled.service
● lifecycled.service - Autoscale Lifecycle Daemon
   Loaded: loaded (/etc/systemd/system/lifecycled.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-06-26 12:39:35 UTC; 3min 19s ago
 Main PID: 3412 (lifecycled)
   CGroup: /system.slice/lifecycled.service
           └─3412 /usr/local/bin/lifecycled --no-spot --sns-topic=arn:aws:sns:ap-south-1:xxxx:sibi-issue163-lifecycle --handler=/usr/local/scripts/lifecycle-handler.sh --json

Jun 26 12:39:35 ip-10-23-11-146.ap-south-1.compute.internal systemd[1]: Started Autoscale Lifecycle Daemon.
Jun 26 12:39:35 ip-10-23-11-146.ap-south-1.compute.internal systemd[1]: Starting Autoscale Lifecycle Daemon...
Jun 26 12:39:35 ip-10-23-11-146.ap-south-1.compute.internal lifecycled[3412]: {"level":"info","msg":"Looking up instance id from metadata service","time":"2020-06-26T12:39:35Z"}
Jun 26 12:39:35 ip-10-23-11-146.ap-south-1.compute.internal lifecycled[3412]: {"instanceId":"i-xxx","level":"info","listener":"autoscaling","msg":"Starting listener","time":"2020-06-26T12:39:35Z"}
Jun 26 12:39:35 ip-10-23-11-146.ap-south-1.compute.internal lifecycled[3412]: {"instanceId":"i-xxx","level":"info","msg":"Waiting for termination notices","time":"2020-06-26T12:39:35Z"}
```

## Note about lifecycle-handler.sh

For testing that the handler is working properly, you have to observe
that you are able to observe the side effect from the script.

One easy way to validate is by spawning a new EC2 instance with a
sample website deployed in it (You could use busybox for it) and then
doing a SSH and watching to see if you are able to observe any logs on
it whenever it's being hit with an HTTP request. Example:

``` shellsession
ubuntu@ip-10-23-11-56:~/test$ sudo busybox httpd -f -v -p 80 -h .
[::ffff:49.207.192.240]:38924: response:200
```

You can modify your [script](./cloud-config.yml) to have curl hit it:

``` shellsession
$ curl http://x.x.x.x
```

## Test the Notification

To generate a notification for a launch event, update the Auto Scaling
group by decreasing the desired capacity of the Auto Scaling group
by 1. That will make the lifecycle handler to get triggered. These are
the steps to decreased the desired capacity using AWS console:

* Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/.
* On the navigation pane, under Auto Scaling, choose Auto Scaling Groups.
* Select your Auto Scaling group.
* On the Details tab, choose Edit.
* For Desired, decrease the current value by 1.
* Choose Save.
* After a few minutes, you'll see that the lifecycle-handler.sh script
  will be executed and it's side effect operation will be performed.

## Destruction

To destroy the test environment run the following commands:

```
make destroy
make clean
```
