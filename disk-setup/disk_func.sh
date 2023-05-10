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
    var_ssd=$1
    part_type=$2
    ssd_path=$3
    hdd_path=$4
    for n in ${var_ssd[@]}
    do
        if [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `sudo partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
            echo 1
            echo /dev/$n
            echo 2
            sudo parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
            echo 3
            until sudo mkfs.ext4 /dev/${n}${part_type} &> /dev/null
            do
                echo 4
                echo "Waiting for disk format ..."
                sleep 5
            done
        fi
    done
    if [[ `sudo partprobe -d -s /dev/$n` == *"gpt partitions"* ]]; then
        # partprobe -s
        echo 6
        sudo pvcreate ${ssd_partition[@]}<<EOF
y
y
EOF
            echo 7
        echo y | sudo vgcreate ssdvg ${ssd_partition[@]}
            echo 8
        echo y | sudo lvcreate -l 100%FREE -n lvssd ssdvg
            echo 9
        sudo mkfs.ext4 /dev/ssdvg/lvssd -F
            echo 10
            sudo mkdir -p $ssd_path
        sudo mount /dev/ssdvg/lvssd ${ssd_path}
            sudo mkdir -p $hdd_path
            echo 11
        sudo mkdir -p $ssd_path
            echo 12
        sudo mkdir -p $hdd_path
            echo 13
        if grep -q $ssd_path /etc/fstab; then
            echo 14
            echo "Entry in fstab exists."
        else
            if [[ $(sudo blkid /dev/ssdvg/lvssd -sUUID -ovalue)  == '' ]]; then
            echo 15
                echo "Disk is not mounted."
            else
            echo 16
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
        if [[ `partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
            echo /dev/$n
            parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
            # partprobe -s
            until mkfs.ext4 /dev/${n}${part_type} &> /dev/null
            do
                echo "Waiting for disk format ..."
                sleep 1
            done
            mkdir -p $hdd_path
            mount /dev/${n}${part_type} $hdd_path
            mkdir -p $ssd_path
            if grep -q $hdd_path /etc/fstab; then
                echo "Entry in fstab exists."
            else
                if [[ $(blkid /dev/${n}${part_type} -sUUID -ovalue)  == '' ]]; then
                    echo "Disk is not mounted."
                else
                    echo "UUID=$(blkid /dev/${n}${part_type} -sUUID -ovalue) $hdd_path ext4 defaults 0 0" >> /etc/fstab
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
        if [[ `partprobe -d -s /dev/$n` = "/dev/$n: msdos partitions" ]] || [[ `partprobe -d -s /dev/$n` = "/dev/$n: gpt partitions" ]] ; then
            echo /dev/$n
            parted -a optimal --script /dev/$n mklabel gpt mkpart primary 0% 100%
            until mkfs.ext4 /dev/${n}${part_type} &> /dev/null
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
        mkdir -p $hdd_path
        mount /dev/hddvg/lvhdd ${hdd_path}
        mkdir -p $ssd_path
        if grep -q ${hdd_path} /etc/fstab; then
            echo "Entry in fstab exists."
        else
            if [[ $(blkid /dev/hddvg/lvhdd -sUUID -ovalue)  == '' ]]; then
                echo "Disk is not mounted."
            else
                echo "UUID=$(blkid /dev/hddvg/lvhdd -sUUID -ovalue) ${hdd_path} ext4 defaults 0 0" >> /etc/fstab
            fi
        fi
    fi
}