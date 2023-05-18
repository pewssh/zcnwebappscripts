#!/bin/bash

export PATH=$PATH:/root/bin
source ~/.profile
source $PWD/disk-setup/disk_func.sh

hdd=()
ssd=()

ssd_path=/var/0chain/blobber
hdd_path=/var/0chain/blobber

sudo apt install parted -y

# Pick sda type disk
for n in `lsblk --noheadings --raw -o NAME | grep "sd" | cut -c 1-3 | sort | uniq -u`; do
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 1 ]]; then
    # echo "inside sdd"
        hdd+=("$n")
    fi
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 0 ]]; then
        ssd+=("$n")
    fi
done

# Pick nvme type disk
for n in `lsblk --noheadings --raw -o NAME | grep "nvme" | cut -c 1-5 | sort | uniq -u`; do
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 1 ]]; then
    # echo "inside nvm"
        hdd+=("$n")
    fi
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 0 ]]; then
        ssd+=("$n"n1)
    fi
done

#Getting ssd type of disk into variable
for x in ${ssd[@]}; do
  ssd_disk_type=$(echo ${x} | cut -b 1-2)
done

len_ssd=${#ssd[@]}

# Resolve the type of ssd disk type sda vs nvme
ssd_partition=()
if [[ $ssd_disk_type == "nv" ]]; then
    for i in "${ssd[@]}"; do
        ssd_partition+=(/dev/"$i"p1)
    done
elif [[ $ssd_disk_type == "sd" ]]; then
    for i in "${ssd[@]}"; do
        ssd_partition+=(/dev/"$i"1)
    done
else
    echo ""
fi

# echo "ssd_disk_type $ssd_disk_type"
# echo "disks ${ssd[@]}"
# echo "disks len $len_ssd"
# echo "disks partition ${ssd_partition[@]}"

if [[ $len_ssd == 1 ]] && [[ $ssd_disk_type == "nv" ]]; then
    echo "Only one ssd of nvme type is present" 
    single_ssd $ssd p1 $ssd_path $hdd_path
elif [[ $len_ssd > 1 ]] && [[ $ssd_disk_type == "nv" ]]; then
    echo "Multiple ssd's of nvme type are present" 
    multiple_ssd $ssd p1 $ssd_path $hdd_path $ssd_partition
elif [[ $len_ssd == 1 ]] && [[ $ssd_disk_type == "sd" ]]; then
    echo "Single ssd of sd type is present" 
    single_ssd $ssd 1 $ssd_path $hdd_path
elif [[ $len_ssd > 1 ]] && [[ $ssd_disk_type == "sd" ]]; then
    echo "Multiple ssd's of sd types are present" 
    multiple_ssd $ssd 1 $ssd_path $hdd_path $ssd_partition
else
    echo "No additional ssd's are present"
    sudo mkdir -p $hdd_path
    sudo mkdir -p $ssd_path
fi

#Getting hdd type of disk into variable
for x in ${hdd[@]}; do
  hdd_disk_type=$(echo ${x} | cut -b 1-2)
done

len_hdd=${#hdd[@]}

# Resolve the type of ssd disk type sda vs nvme
hdd_partition=()
if [[ $hdd_disk_type == "nv" ]]; then
    for i in "${hdd[@]}"; do
        ssd_partition+=(/dev/"$i"p1)
    done
elif [[ $hdd_disk_type == "sd" ]]; then
    for i in "${hdd[@]}"; do
        ssd_partition+=(/dev/"$i"1)
    done
else
    echo ""
fi

# echo "ssd_disk_type $ssd_disk_type"
# echo "disks ${ssd[@]}"
# echo "disks len $len_ssd"
# echo "disks partition ${ssd_partition[@]}"

if [[ $len_hdd == 1 ]] && [[ $hdd_disk_type == "nv" ]]; then
    echo "Only one hdd of nvme type is present" 
    single_hdd $hdd p1 $ssd_path $hdd_path
elif [[ $len_hdd > 1 ]] && [[ $hdd_disk_type == "nv" ]]; then
    echo "Multiple hdd's of nvme type are present" 
    multiple_hdd $hdd p1 $ssd_path $hdd_path $hdd_partition
elif [[ $len_hdd == 1 ]] && [[ $hdd_disk_type == "sd" ]]; then
    echo "Single hdd of sd type is present" 
    single_hdd $hdd 1 $ssd_path $hdd_path
elif [[ $len_hdd > 1 ]] && [[ $hdd_disk_type == "sd" ]]; then
    echo "Multiple hdd's of sd types are present" 
    multiple_hdd $hdd 1 $ssd_path $hdd_path $hdd_partition
else
    echo "No additional ssd's are present"
    sudo mkdir -p $hdd_path
    sudo mkdir -p $ssd_path
fi

# when there is no additional ssd/hdd
if [[ $len_hdd == 0 ]] && [[ $len_ssd == 0 ]]; then
    echo "no additional ssd or hdd present"
    sudo mkdir -p $hdd_path
    sudo mkdir -p $ssd_path
fi
