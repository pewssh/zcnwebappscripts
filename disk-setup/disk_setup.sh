#!/bin/bash

export PATH=$PATH:/root/bin
source ~/.profile
source ~/disk_func.sh

hdd=()
ssd=()

ssd_path=/mnt/ssd
hdd_path=/mnt/hdd

# Pick sda type disk
for n in `lsblk  --noheadings --raw | awk '{print substr($0,0,3)}' | uniq -c | grep 1 | awk '{print $2}' | grep -E "(sd.)"`; do
    echo "inside sdd"
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 1 ]]; then
    echo "inside sdd"
        hdd+=("$n")
    fi
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 0 ]]; then
        ssd+=("$n")
    fi
done

# Pick nvme type disk
for n in `lsblk  --noheadings --raw | awk '{print substr($0,0,5)}' | uniq -c | grep 1 | awk '{print $2}' | grep -E "(nvme)[[:digit:]]"`; do
    echo "inside nvm"
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 1 ]]; then
    echo "inside nvm"
        hdd+=("$n")
    fi
    if [[ `lsblk -o name,rota | grep $n | awk '{print $2}'` == 0 ]]; then
        ssd+=("$n"n1)
    fi
done

#Getting type of disk into variable
for x in ${ssd[@]}; do
  disk_type=$(echo ${x} | cut -b 1-2)
done

for x in ${hdd[@]}; do
  echo ${x}
done

len_ssd=${#ssd[@]}
len_hdd=${#hdd[@]}

# Resolve the type of disk sda vs nvme
ssd_partition=()
for i in "${ssd[@]}"; do
    ssd_partition+=(/dev/"$i"p1)
done
echo "${ssd_partition[@]}"

hdd_partition=()
for i in "${hdd[@]}"; do
    hdd_partition+=(/dev/"$i"1)
done
echo "${hdd_partition[@]}"

# when there is no additional ssd/hdd
if [[ $len_hdd == 0 ]] && [[ $len_ssd == 0 ]]; then
    echo "no additional ssd or hdd present"
    mkdir -p $hdd_path
    mkdir -p $ssd_path
fi

if [[ $len_ssd == 1 ]] && [[ $disk_type == "nv" ]]; then
    echo "Only one ssd of nvme type is present" 
    single_ssd $ssd p1 $ssd_path $hdd_path
elif [[ $len_ssd > 1 ]] && [[ $disk_type == "nv" ]]; then
    echo "Multiple ssd's of nvme type are present" 
    multiple_ssd $ssd p1 $ssd_path $hdd_path
elif [[ $len_ssd == 1 ]] && [[ $disk_type == "sd" ]]; then
    echo "Single ssd of sd type is present" 
    single_ssd $ssd 1 $ssd_path $hdd_path
elif [[ $len_ssd > 1 ]] && [[ $disk_type == "sd" ]]; then
    echo "Multiple ssd's of sd types are present" 
    multiple_ssd $ssd 1 $ssd_path $hdd_path
else
    echo "No additional ssd's are present"
    mkdir -p $hdd_path
    mkdir -p $ssd_path
fi

exit
# when only hdd is present
if [[ $len_hdd != 0 ]] && [[ $len_ssd == 0 ]]; then
    echo "Only HDD"
    if [[ $len_hdd == 1 ]] ; then
        for n in ${hdd[0]}
        do
            if [[ `partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
                echo /dev/$n
                parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
                # partprobe -s
                until mkfs.ext4 /dev/${n}1 &> /dev/null
                do
                    echo "Waiting for disk format ..."
                    sleep 1
                done
                mount /dev/${n}1 /mnt
                mkdir -p $ssd_path
                mkdir -p $hdd_path
                if grep -q '/mnt' /etc/fstab; then
                    echo "Entry in fstab exists."
                else
                    if [[ $(blkid /dev/${n}1 -sUUID -ovalue)  == '' ]]; then
                        echo "Disk is not mounted."
                    else
                        echo "UUID=$(blkid /dev/${n}1 -sUUID -ovalue) /mnt ext4 defaults 0 0" >> /etc/fstab
                    fi
                    
                fi
            fi
        done
    fi

    if [[ $len_hdd > 1 ]] ; then
        for n in ${hdd[@]}
        do
            if [[ `partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
                echo /dev/$n
                parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
                until mkfs.ext4 /dev/${n}1 &> /dev/null
                do
                    echo "Waiting for disk format ..."
                    sleep 1
                done
            fi
        done
        if [[ `partprobe -d -s /dev/$n` == *"gpt partitions"* ]]; then
            # partprobe -s
            pvcreate ${hdd_partition[@]}
            vgcreate hddvg ${hdd_partition[@]}
            lvcreate -l 100%FREE -n lvhdd hddvg
            mkfs.ext4 /dev/hddvg/lvhdd
            mount /dev/hddvg/lvhdd /mnt
            mkdir -p $ssd_path
            mkdir -p $hdd_path
            if grep -q '/mnt' /etc/fstab; then
                echo "Entry in fstab exists."
            else
                if [[ $(blkid /dev/hddvg/lvhdd -sUUID -ovalue)  == '' ]]; then
                    echo "Disk is not mounted."
                else
                    echo "UUID=$(blkid /dev/hddvg/lvhdd -sUUID -ovalue) /mnt ext4 defaults 0 0" >> /etc/fstab
                fi
            fi
        fi

    fi
fi
