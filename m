Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:56525 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031833Ab2COUXD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 16:23:03 -0400
Received: by dajr28 with SMTP id r28so4998240daj.19
        for <linux-nfs@vger.kernel.org>; Thu, 15 Mar 2012 13:23:03 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 15 Mar 2012 17:23:03 -0300
Message-ID: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
Subject: About pNFS installation process.
From: Bruno Silva <bs@cin.ufpe.br>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

     I am PhD student and I intend to conduct performance experiments
adopting pNFS.   First of all, i need to build the pNFS Block Layout
environment. I apologize for the long mail, but i need to explain all
the steps conducted to build the environment. I followed the steps
presented in http://wiki.linux-nfs.org/wiki/index.php/PNFS_Block_Server_Setup_Instructions.

Steps.

(1) Building and install the kernel. And these configurations on .config file
i adopted this code: git clone git://linux-nfs.org/~bhalevy/linux-pnfs.git

CONFIG_NFSD=m
CONFIG_NFSD_V4=y
CONFIG_PNFSD=y
# CONFIG_PNFSD_LOCAL_EXPORT is not set
CONFIG_PNFSD_BLOCK=y

(2) Building the nfsutils and utils/blkmapd

    git clone git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git

(3) Export the file system.

-----------------------------------------------------------------
For the block access to work properly the disks must have a signature.
Partitioned the disks using "parted". Disks partitioned with "fdisk"
doesn't have the signatures.

I have followed the below mentioned steps.

parted /dev/sdb
(parted) mklabel gpt
(parted) mkpart 1 <Provide start and end of the partetions>
(parted) print
Model: VMware Virtual disk (scsi)
Disk /dev/sdb: 53.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Number  Start   End     Size    File system  Name  Flags
1      17.4kB  53.7GB  53.7GB  ext3         1     msftres
I have tested with ext4 file system, create ext4 file system with 4K block size.

 # mkfs.ext4 -b 4096 /dev/sdb1
-----------------------------------------------------------------

The steps 1, 2 and 3 i did to all machines (data servers, metadata
server and client).

I adopted the export option in metadata server exports file.
/mnt *(rw,sync,fsid=0,insecure,no_subtree_check,no_root_squash,pnfs)

And run the following script to start the server.

#/bin/bash
# UMOUNT /mnt
umount /mnt
#start the service
service tgtd restart
sleep 8
# Create iSCSI target
tgtadm --lld iscsi --op new --mode target --tid 1 -T
iqn.1992-05.com.emc:openblock
# Expose LUN as iSCSI target
tgtadm --lld iscsi --mode logicalunit --op new --tid 1 --lun 1
--backing-store /dev/sdb
# Allow acces of all initiator
tgtadm --lld iscsi --mode target --op bind --tid 1 --initiator-address ALL
# show all the details
tgtadm --lld iscsi --op show --mode target
# mount the partetion
mount /dev/sdb1 /mnt
sleep 3
# start the nfs server
service nfs restart
sleep 3
# start the deamon
cd <CTL_SRC>/ctl/
./ctl -u &

If the data server and metadata server have been run on the same
machine everything works normally. My question is how do I add other
pNFS data servers in the environment. I know that is related to
creating iscsi targets. But how the data servers are linked with the
metadata server. There is some configuration file to inform the
metadata server like in spNFS? How it works?

Thanks in advance.


--
Bruno Silva
Computer Engineer
Modcs Group
---------------------------------------------------------------------
Facebook goo.gl/QHaZx
Twitter goo.gl/yk4jf
Google+ goo.gl/xIbgk
