if which wget; then
  INSTANCE_ID="$(wget -O- http://169.254.169.254/latest/meta-data/instance-id)"
elif which curl; then
  INSTANCE_ID="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
fi

if [ "x$${INSTANCE_ID}" == "x" ]; then
  echo 'There is no wget or curl tool installed. Hence bootstrap cannot get instance ID.'
  exit 1
fi
