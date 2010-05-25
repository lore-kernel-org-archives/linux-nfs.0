Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:43312 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757057Ab0EYAkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 20:40:06 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1OGiBf-0001t8-Lx
	for linux-nfs@vger.kernel.org; Tue, 25 May 2010 02:40:04 +0200
Received: from softbank221086052216.bbtec.net ([221.86.52.216])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 02:40:03 +0200
Received: from redshield88888 by softbank221086052216.bbtec.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 02:40:03 +0200
To: linux-nfs@vger.kernel.org
From: redshield88888 <redshield88888@gmail.com>
Subject: Data has not been wrote to DSs
Date: Tue, 25 May 2010 00:23:41 +0000 (UTC)
Message-ID: <loom.20100525T014937-518@post.gmane.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

■Reference
http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd
http://osdir.com/ml/general/2010-05/msg10129.html

■My environment
kernel-2.6.32.11-107.2.3.pnfs.fc12.x86_64.rpm
kernel-devel-2.6.32.11-107.2.3.pnfs.fc12.x86_64.rpm
kernel-firmware-2.6.32.11-107.2.3.pnfs.fc12.noarch.rpm
kernel-headers-2.6.32.11-107.2.3.pnfs.fc12.x86_64.rpm
nfs-utils-1.2.2-4.1.pnfs.x86_64.rpm

MDS: 192.168.1.60
DS: 192.168.1.45
Client: 192.168.1.62 ( created on the KVM's virtual machine on the MDS )

■/etc/exports
- MDS's

/ *(rw,sync,pnfs,fsid=0,insecure,no_subtree_check,no_root_squash)

- DS's

/ *(rw,sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_squash)

■/etc/fstab
- MDS's

UUID=52ab88e8-5d93-440c-af45-0a85923898ec /                       ext4   
defaults        1 1
UUID=90d25a9c-54b4-4db4-979a-26ea0d67fe60 swap                    swap   
defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
192.168.1.45:/pnfs /spnfs/192.168.1.45 nfs4 minorversion=1 0 0

■/etc/spnfsd.conf of the MDS
[General]
Verbosity = 1
Stripe-size = 8192
Dense-striping = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
DS-Mount-Directory = /spnfs

[DataServers]
NumDS = 1
DS1_IP = 192.168.1.45
DS1_PORT = 2049
DS1_ROOT = /pnfs
DS1_ID = 1

■Preparation nad Assumption
-The NFS related ports has opened and has confirmed

- on the DS
$mkdir /pnfs

- on the MDS
$mkdir /spnfs
$mkdir /spnfs/192.168.1.45
$reboot
$touch /spnfs/192.168.1.45/test <- write succeeded to the DS's /spnfs

The MDS has mounted the exported directory of DS and able to read and write.
The MDS's /proc/self/mountstats includes lines that means the PNFS has turned on
like below

        PNFS_LAYOUTGET: 0 0 0 0 0 0 0 0
        PNFS_LAYOUTCOMMIT: 0 0 0 0 0 0 0 0
        PNFS_LAYOUTRETURN: 0 0 0 0 0 0 0 0
        PNFS_GETDEVICELIST: 0 0 0 0 0 0 0 0
        PNFS_GETDEVICEINFO: 0 0 0 0 0 0 0 0
          PNFS_WRITE: 0 0 0 0 0 0 0 0
         PNFS_COMMIT: 0 0 0 0 0 0 0 0

■issue
- on the client
$mkdir /mnt/pnfs
$modprobe nfslayoutdriver;modprobe blocklayoutdriver
$mount -t nfs4 -o minorversion=1 192.168.1.60:/ /mnt/pnfs  <- SUCCEEDED
$echo "heeeeeeeeeeeeeeeey" >> /mnt/pnfs/hello.txt  <- has not been wrote to the
DS but has been worte under / of the MDS.


