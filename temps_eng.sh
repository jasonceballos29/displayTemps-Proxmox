#!/bin/bash
# Enrique Gómez quique2010botoa@hotmail.com

# Disclaimer, use this code at your own risk

# Next revision: add checking for existing lines in the files

nodes=/usr/share/perl5/PVE/API2/Nodes.pm
pvemanager=/usr/share/pve-manager/js/pvemanagerlib.js
checkNode=$(grep -n temps $nodes >> /dev/null)
checkPveManager=$(grep -n thermal $pvemanager >> /dev/null)

function filesBackup() {
   if [ -f $nodes.backup ]; then
      echo "Backup file already exists"
   else
      cp $nodes $nodes.backup
      echo "An .original copy has been created as a backup"
   fi
   if [ -f $pvemanager.backup ]; then
      echo "Backup file already exists"
   else
      cp $pvemanager $pvemanager.backup
      echo "An .original copy has been created as a backup"
   fi
}

function displayOptions(){
   clear
   echo 
   echo "--------- Choose the operation you want to perform: ---------"
   echo 
   echo "1 - Average temperature of all cores"
   echo

   read -p "Specify the option you want to choose: " option
   clear
}

function addSensor(){
   sensors
   echo -e "Look at the sensor name you want to display in the Summary. (Composite, Sensor 1....)"
   read -p "Enter the name exactly as it appears: " 'sensorName'
}

function selectOperation(){
   grep -n thermal $pvemanager >> /dev/null

   if [ $? -eq 0 ]; then
      echo "This configuration already exists in the file"
   else
      line=$(grep -n pveversion $pvemanager | cut -d ':' -f 1)
      sumLine=$(($line+2))
      echo "The chosen sensor is: " $sensorName

      case $option in
         1) sed "$sumLine a \\\\r\n        {\n            itemId: 'thermalstate',\n            colspan: 2,\n            printBar: false,\n            title: gettext('CPU Temps'),\n            textField: 'temps',\n            renderer:function(value){\n                const c0 = value.match(/$sensorName.*?\\\\+([\\\d\\\\\\.]+)Â/)[1];\n                return \x60CPU: $\x7Bc0\x7D ºC\x60\n            }\n        }," -i $pvemanager
         ;;
         *) echo "failure"
         ;;
      esac
   fi
}

function infoAdd(){
   grep -n temps $nodes >> /dev/null
   if [ $? -eq 0 ]; then
      echo "This configuration already exists in the file"
   else
      line2=$(grep -n pveversion $nodes | cut -d ':' -f 1)
      sumLine2=$(($line2+1))
      sed ''$sumLine2' a \\n        $res->{temps} = `sensors`;' -i $nodes
   fi
}

clear
echo -e "Install lm-sensors if you don't have it (Press enter to continue)"
read -p ""

filesBackup
displayOptions
addSensor
selectOperation
infoAdd

echo 
echo "Reload the page to restart the service"
systemctl restart pveproxy.service
