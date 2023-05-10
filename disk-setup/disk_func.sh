# when only single ssd is present
single_ssd() {
    var_ssd=$1
    part_type=$2
    ssd_path=$3
    hdd_path=$4
    for n in ${var_ssd[0]}
    do
        if [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
            echo /dev/$n
            sudo parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
            # partprobe -s
            until sudo mkfs.ext4 /dev/${n}${part_type} &> /dev/null
            do
                echo "Waiting for disk format ..."
                sleep 1
            done
            sudo mkdir -p $ssd_path
            sudo mount /dev/${n}${part_type} ${ssd_path}
            sudo mkdir -p $hdd_path
            if grep -q $ssd_path /etc/fstab; then
                echo "Entry in fstab exists."
            else
                if [[ $(blkid /dev/${n}${part_type} -sUUID -ovalue)  == '' ]]; then
                    echo "Disk is not mounted."
                else
                    sudo echo "UUID=$(blkid /dev/${n}${part_type} -sUUID -ovalue) $ssd_path ext4 defaults 0 0" >> sudo /etc/fstab
                fi                  
            fi
        fi
    done
}

# when only multiple ssd are present
function multiple_ssd {
    # var_ssd=$1
    part_type=$2
    ssd_path=$3
    hdd_path=$4
    # ssd_partition=$5
    # echo "disks --> ${ssd[@]}"
    # echo "2-->  $2"
    # echo "disks partition --> ${ssd_partition[@]}"

    for n in ${ssd[@]}
    do
        echo "n --> $n"
        if [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
            echo /dev/$n
            sudo parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
            until sudo mkfs.ext4 /dev/${n}${part_type} &> /dev/null
            do
                echo "Waiting for disk format ..."
            done
        fi
    done
    echo "test"

    if [[ `sudo partprobe -d -s /dev/$n` == *"gpt partitions"* ]]; then
        # partprobe -s
        sudo pvcreate ${ssd_partition[@]} -f
        echo y | sudo vgcreate ssdvg ${ssd_partition[@]}
        echo y | sudo lvcreate -l 100%FREE -n lvssd ssdvg
        sudo mkfs.ext4 /dev/ssdvg/lvssd -F
        sudo mkdir -p $ssd_path
        sudo mount /dev/ssdvg/lvssd ${ssd_path}
        sudo mkdir -p $hdd_path
        if grep -q $ssd_path /etc/fstab; then
            echo "Entry in fstab exists."
        else
            if [[ $(sudo blkid /dev/ssdvg/lvssd -sUUID -ovalue)  == '' ]]; then
                echo "Disk is not mounted."
            else
                sudo echo "UUID=$(sudo blkid /dev/ssdvg/lvssd -sUUID -ovalue) $ssd_path ext4 defaults 0 0" >> sudo /etc/fstab
            fi               
        fi
    fi
}


# when only hdd is present
function single_hdd {
    var_hdd=$1
    part_type=$2
    ssd_path=$3
    hdd_path=$4
    for n in ${var_hdd[0]}
    do
        if [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
            echo /dev/$n
            sudo parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
            # partprobe -s
            until sudo mkfs.ext4 /dev/${n}${part_type} &> /dev/null
            do
                echo "Waiting for disk format ..."
                sleep 1
            done
            sudo mkdir -p $hdd_path
            sudo mount /dev/${n}${part_type} $hdd_path
            sudo mkdir -p $ssd_path
            if grep -q $hdd_path /etc/fstab; then
                echo "Entry in fstab exists."
            else
                if [[ $(blkid /dev/${n}${part_type} -sUUID -ovalue)  == '' ]]; then
                    echo "Disk is not mounted."
                else
                    echo "UUID=$(blkid /dev/${n}${part_type} -sUUID -ovalue) $hdd_path ext4 defaults 0 0" >> sudo /etc/fstab
                fi
                
            fi
        fi
    done
}

# when only multiple hdd are present
function multiple_hdd {
    var_hdd=$1
    part_type=$2
    ssd_path=$3
    hdd_path=$4
    for n in ${var_hdd[@]}
    do
        if [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
            sudo parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
            until sudo mkfs.ext4 /dev/${n}${part_type} &> /dev/null
            do
                echo "Waiting for disk format ..."
                sleep 1
            done
        fi
    done
    if [[ `sudo partprobe -d -s /dev/$n` == *"gpt partitions"* ]]; then
        # partprobe -s
        sudo pvcreate ${hdd_partition[@]} -f
        echo y | sudo vgcreate hddvg ${hdd_partition[@]}
        echo y | sudo lvcreate -l 100%FREE -n lvhdd hddvg
        sudo mkfs.ext4 /dev/hddvg/lvhdd -F
        sudo mkdir -p $hdd_path
        sudo mount /dev/hddvg/lvhdd ${hdd_path}
        sudo mkdir -p $ssd_path
        if grep -q ${hdd_path} /etc/fstab; then
            echo "Entry in fstab exists."
        else
            if [[ $(blkid /dev/hddvg/lvhdd -sUUID -ovalue)  == '' ]]; then
                echo "Disk is not mounted."
            else
                echo "UUID=$(blkid /dev/hddvg/lvhdd -sUUID -ovalue) ${hdd_path} ext4 defaults 0 0" >> sudo /etc/fstab
            fi
        fi
    fi
}