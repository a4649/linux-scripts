#/bin/bash

# Only handle snapshots for whitelisted VMs
vm_backup_whitelist=( "XXX" "YYY" "ZZZ" )

vms=( $(virsh list --all --name) )
for (( i=0; i<${#vms[@]}; i++ ));
do
  for (( j=0; j<${#vm_backup_whitelist[@]}; j++ ));
  do
    if [ "${vm_backup_whitelist[$j]}" = "${vms[$i]}" ];
    then
      # Retain only 5 cronjob snapshots (including the snapshot that will be created)
      snapshots=( $(virsh snapshot-list --domain ${vms[$i]} --name) )
      echo "${snapshots}"
      num_cronjob_snapshots=0
      echo "number of snapshots: ${#snapshots[@]}"

      for (( k=0; k<${#snapshots[@]}; k++ ));
      do
        if [[ ${snapshots[$k]} == cronjob_* ]];
        then
          echo "hello"
          num_cronjob_snapshots=$((num_cronjob_snapshots + 1))
        fi
      done
      for (( k=0; k<${#snapshots[@]} && $((num_cronjob_snapshots))>=5; k++ ));
      do
        if [[ ${snapshots[$k]} == cronjob_* ]];
        then
          echo "deleting ${snapshots[$k]}"
          virsh snapshot-delete --domain ${vms[$i]} --snapshotname ${snapshots[$k]}
          num_cronjob_snapshots=$((num_cronjob_snapshots - 1))
        fi
      done

      # Create snapshot
      timenow=$(date '+%Y_%m_%d')
      snapshot_name="cronjob_${timenow}"
      echo -e "\nCreating snapshot ${snapshot_name} for ${vms[$i]}..."
      virsh snapshot-create-as --domain ${vms[$i]} --name "${snapshot_name}"
    fi
  done
done
