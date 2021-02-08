export AWS_DEFAULT_REGION=${region}
VOLUME_ID=${volume_id}
echo "${log_prefix} will attach $${VOLUME_ID} via the AWS API in ${region}"
while ! aws ec2 attach-volume                     \
        --volume-id "$${VOLUME_ID}"     \
        --instance-id "$${INSTANCE_ID}" \
        --device '${device_path}'; do
  echo "Attaching command failed to run. Retrying."
  sleep '${wait_interval}'
done
echo "${log_prefix} $${VOLUME_ID} attached."
sleep '${wait_interval}' # Wait for device up

if [ ! -e ${device_path} ]; then
  vol_id="$(echo "$${VOLUME_ID}" | tr -d '-')"
  dev_id="$(ls /dev/disk/by-id/*-Amazon_Elastic_Block_Store_$${vol_id} | head -1)"
  dev_name="/dev/$(readlink "$${dev_id}" | tr / '\n' | tail -1)"
  [ "$${dev_name}" == "${device_path}" ] || ln -s "$${dev_name}" "${device_path}"
fi
