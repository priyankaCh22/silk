#!/bin/bash

# Script to check build change in a repo and run tests with latest build

function run_test()
{
  REPO_NAME=$1
  CHECK_BUILD_CHANGE=$2
  source /home/pi/silk/silk/shell/$CHECK_BUILD_CHANGE

echo "******* exporting output variable's value depicting build change from $CHECK_BUILD_CHANGE *******"
echo $output
if [[ $output == *"Already"* ]]; then
  echo "No need to run tests as $REPO_NAME version is same"
else
    if [[ $REPO_NAME == "openthread" ]]; then
      echo "Flash the dev boards with latest ot build"
      cd /home/pi/silk/silk/shell
      echo "Getting serial number of dev boards from hwconfig.ini"
      cat /opt/openthread_test/hwconfig.ini |grep DutSerial|egrep -o [0-9]\{9\} >/opt/openthread_test/serial_num_list.txt
      for serial_num in $(cat /opt/openthread_test/serial_num_list.txt); do
          ./nrfjprog.sh --erase-all $serial_num
          ./nrfjprog.sh --flash /opt/openthread_test/nrf52840_image/ot-ncp-ftd.hex $serial_num
      done
    fi
    echo "Running OT test suite with latest $REPO_NAME version"
    sudo python /home/pi/silk/silk/unit_tests/silk_run_test.py
fi
}

run_test wpantund flash_wpantund.sh
run_test openthread build_nrf52840.sh


