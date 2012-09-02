Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kms.syseleven.de ([176.74.58.26]:33704 "EHLO kms.syseleven.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595Ab2IBLQf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Sep 2012 07:16:35 -0400
Received: from [IPv6:::1] ([37.44.1.226])
	(authenticated user a.holway@syseleven.de)
	by kms.syseleven.de
	(using TLSv1/SSLv3 with cipher AES128-SHA (128 bits))
	for linux-nfs@vger.kernel.org;
	Sun, 2 Sep 2012 12:46:29 +0200
From: Andrew Holway <a.holway@syseleven.de>
Content-Type: text/plain; charset=us-ascii
Subject: KVM disk problem with NFS over RDMA
Date: Sun, 2 Sep 2012 12:46:26 +0200
Message-Id: <BF836CCD-701A-40F6-B776-01B49742943C@syseleven.de>
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Apple Message framework v1278)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am trying to host KVM machines on an NFSoRDMA mount.

This works:

-drive file=/mnt/vm001.img,if=none,id=drive-virtio-disk0,format=raw -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x5,drive=drive-virtio-disk0,id=virtio-disk0

This Doesn't!

-drive file=/mnt/vm001.img,if=none,id=drive-virtio-disk0,format=raw,cache=none -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x5,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=2

Any ideas why this could be? I have tried various kernel / ofed combinations.

Thanks,

Andrew



dmesg:

vda:
vda: vda1
vda: vda1
vda: vda1 vda2
vda: vda1 vda2
vda: vda1 vda2 vda3
vda: vda1 vda2 vda3
vda: vda1 vda2 vda3 vda4 < >
vda: vda1 vda2 vda3 vda4 < >
vda: vda1 vda2 vda3 vda4 < vda5 >
vda: vda1 vda2 vda3 vda4 < vda5 >
vda: vda1 vda2 vda3 vda4 < vda5 vda6 >
vda: vda1 vda2 vda3 vda4 < vda5 vda6 >
Adding 15998968k swap on /dev/vda5.  Priority:-1 extents:1 across:15998968k 
EXT3-fs (vda1): error: can't find ext3 filesystem on dev vda1.

/var/log/messages

Aug 31 18:53:46 (none) node-installer: Mounting disks.
Aug 31 18:53:46 (none) node-installer: Updating device status: mounting disks
Aug 31 18:53:46 (none) node-installer: Detecting device '/dev/sda': not found
Aug 31 18:53:46 (none) node-installer: Detecting device '/dev/hda': not found
Aug 31 18:53:46 (none) node-installer: Detecting device '/dev/vda': found
Aug 31 18:53:46 (none) node-installer: swapon /dev/vda5
Aug 31 18:53:46 (none) node-installer: mkdir -p /localdisk/
Aug 31 18:53:46 (none) kernel: Adding 15998968k swap on /dev/vda5.  Priority:-1 extents:1 across:15998968k 
Aug 31 18:53:46 (none) node-installer: Mounting /dev/vda1 on /localdisk/
Aug 31 18:53:46 (none) node-installer: mount -t ext3 -o defaults,noatime,nodiratime /dev/vda1 /localdisk/
Aug 31 18:53:46 (none) node-installer: mount: wrong fs type, bad option, bad superblock on /dev/vda1,
Aug 31 18:53:46 (none) node-installer:        missing codepage or helper program, or other error
Aug 31 18:53:46 (none) node-installer:        In some cases useful info is found in syslog - try
Aug 31 18:53:46 (none) node-installer:        dmesg | tail  or so
Aug 31 18:53:46 (none) node-installer: 
Aug 31 18:53:46 (none) node-installer: Command failed.
Aug 31 18:53:46 (none) node-installer: Running: "mount -t ext3 -o defaults,noatime,nodiratime /dev/vda1 /localdisk/" failed:
Aug 31 18:53:46 (none) node-installer: Non zero exit code: 32
Aug 31 18:53:46 (none) kernel: EXT3-fs (vda1): error: can't find ext3 filesystem on dev vda1.
Aug 31 18:53:46 (none) node-installer: Failed to mount disks. (Exit code 12, signal 0)
Aug 31 18:53:46 (none) node-installer: There was a fatal problem. This node can not be installed until the problem is corrected.
Aug 31 18:53:46 (none) node-installer: The error was: failed to mount disks
Aug 31 18:53:46 (none) node-installer: Updating device status: failed to mount disks

Aug 31 18:53:28 (none) node-installer: Creating primary partition /dev/vda3.
Aug 31 18:53:28 (none) node-installer: parted -s -- /dev/vda mkpart primary ext3 22530 24578
Aug 31 18:53:28 (none) kernel: vda: vda1 vda2 vda3
Aug 31 18:53:28 (none) node-installer: dd if=/dev/zero of=/dev/vda3 bs=1k count=4
Aug 31 18:53:28 (none) node-installer: 4+0 records in
Aug 31 18:53:28 (none) node-installer: 4+0 records out
Aug 31 18:53:28 (none) node-installer: 4096 bytes (4.1 kB) copied, 0.000842261 s, 4.9 MB/s
Aug 31 18:53:28 (none) node-installer: Running partprobe on device: /dev/vda
Aug 31 18:53:28 (none) kernel: vda: vda1 vda2 vda3

Aug 31 18:53:45 (none) node-installer: Creating ext3 filesystem on /dev/vda3
Aug 31 18:53:45 (none) node-installer: mke2fs -j /dev/vda3
Aug 31 18:53:45 (none) node-installer: mke2fs 1.41.12 (17-May-2010)
Aug 31 18:53:45 (none) node-installer: Filesystem label=
Aug 31 18:53:45 (none) node-installer: OS type: Linux
Aug 31 18:53:45 (none) node-installer: Block size=4096 (log=2)
Aug 31 18:53:45 (none) node-installer: Fragment size=4096 (log=2)
Aug 31 18:53:45 (none) node-installer: Stride=0 blocks, Stripe width=0 blocks
Aug 31 18:53:45 (none) node-installer: 125184 inodes, 499968 blocks
Aug 31 18:53:45 (none) node-installer: 24998 blocks (5.00%) reserved for the super user
Aug 31 18:53:45 (none) node-installer: First data block=0
Aug 31 18:53:45 (none) node-installer: Maximum filesystem blocks=515899392
Aug 31 18:53:45 (none) node-installer: 16 block groups
Aug 31 18:53:45 (none) node-installer: 32768 blocks per group, 32768 fragments per group
Aug 31 18:53:45 (none) node-installer: 7824 inodes per group
Aug 31 18:53:45 (none) node-installer: Superblock backups stored on blocks: 
Aug 31 18:53:45 (none) node-installer: #01132768, 98304, 163840, 229376, 294912
Aug 31 18:53:45 (none) node-installer: 
Aug 31 18:53:45 (none) node-installer: Writing inode tables:  0/16#010#010#010#010#010 1/16#010#010#010#010#010 2/16#010#010#010#010#010 3/16#010#010#010#010#010 4/16#010#010#010#010#010 5/16#010#010#010#010#010 6/16#010#010#010#010#010 7/16#010#010#010#010#010 8/16#010#010#010#010#010 9/16#010#010#010#010#01010/16#010#010#010#010#01011/16#010#010#010#010#01012/16#010#010#010#010#01013/16#010#010#010#010#01014/16#010#010#010#010#01015/16#010#010#010#010#010done                            
Aug 31 18:53:45 (none) node-installer: Creating journal (8192 blocks): done
Aug 31 18:53:45 (none) node-installer: Writing superblocks and filesystem accounting information: done
Aug 31 18:53:45 (none) node-installer: 
Aug 31 18:53:45 (none) node-installer: This filesystem will be automatically checked every 24 mounts or
Aug 31 18:53:45 (none) node-installer: 180 days, whichever comes first.  Use tune2fs -c or -i to override.

