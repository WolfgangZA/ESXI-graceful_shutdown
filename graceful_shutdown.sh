#/bin/sh
 
##########################################################################################################################
#
#copy this file somewhere to datastore
#e.g. ‘/vmfs/volumes/myDataStore/scripts/’
#
# looks which vm's are running, sends them into suspend, waits until suspending-process is finished, then powers off esxi
# completely
##########################################################################################################################
 
VMS=`vim-cmd vmsvc/getallvms | grep -v Vmid | awk '{print $1}'`
for VM in $VMS ; do
  PWR=`vim-cmd vmsvc/power.getstate $VM | grep -v "Retrieved runtime info"`
  if [ "$PWR" == "Powered on" ] ; then
    name=`vim-cmd vmsvc/get.config $VM | grep -i "name =" | awk '{print $3}' | head -1 | cut -d "\"" -f2`
    echo "Powered on: $name"
    echo "Suspending: $name"
    vim-cmd vmsvc/power.suspend $VM > /dev/null &
  fi
done
 
while true ; do
  RUNNING=0
  for VM in $VMS ; do
    PWR=`vim-cmd vmsvc/power.getstate $VM | grep -v "Retrieved runtime info"`
    if [ "$PWR" == "Powered on" ] ; then
      echo "Waiting..."
      RUNNING=1
    fi
  done
  if [ $RUNNING -eq 0 ] ; then
    echo "Gone..."
    break
  fi
  sleep 1
done
 
echo "Now we shutdown the host..."
/sbin/shutdown.sh && /sbin/poweroff
exit 0
