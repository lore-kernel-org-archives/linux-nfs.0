Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:61572 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbaILQXc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Sep 2014 12:23:32 -0400
Received: by mail-wg0-f50.google.com with SMTP id x13so949417wgg.33
        for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2014 09:23:30 -0700 (PDT)
Received: from vm1.localdomain (ip-94-113-17-61.net.upcbroadband.cz. [94.113.17.61])
        by mx.google.com with ESMTPSA id u10sm2273596wix.2.2014.09.12.09.23.27
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 09:23:28 -0700 (PDT)
Message-ID: <54131DFE.9020708@gmail.com>
Date: Fri, 12 Sep 2014 18:23:26 +0200
From: Zdenek Kaspar <zkaspar82@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFSv4 O_DIRECT with 3.16.2 kernel issue (qemu kvm cache=none / RHEL5
 guest)
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everyone, got this specific problem with RHEL5 guest under KVM
hypervisor.

client/server kernel version: 3.16.2

/etc/exports: rw,async,no_subtree_check,no_root_squash
/proc/mounts: nfs4 rw,relatime,vers=4.0,rsize=524288,wsize=524288,
              namlen=255,hard,proto=tcp,port=0,
              timeo=600,retrans=2,sec=sys,clientaddr=xxx.xxx.xxx.xxx,
              local_lock=none,addr=xxx.xxx.xxx.yyy 0 0

CONFIG_NFS_FS=m
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=m
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_NFS_COMMON=y

CentOS-5.10-i386-bin-1of8.iso -- did not test everything on centos,
behaved same as RHEL5. So let's use it as VM reproducer:

dd if=/dev/zero of=kvm-test1.img bs=1M count=2048

start VM using:
file=kvm-test1.img,cache=writeback,aio=native,if=virtio,boot=on

create custom layout: /dev/vda1 / ext3 max size primary
unselect Desktop-Gnome, select Customize now
use only: Base System/Base and install it..

[root@test1 ~]# find / >/dev/null
everything works as expected with writeback

shutdown, backup kvm-test1.img (fs will explode)
start VM using:
file=kvm-test1.img,cache=none,aio=native,if=virtio,boot=on

[root@test1 ~]# find / >/dev/null
and check dmesg, reboot etc, ie:
EXT3-fs error (device vda1): htree_dirblock_to_tree: bad entry in
directory #460317: rec_len is smaller than minimal - offset=0, inode=0,
rec_len=0, name_len=0
EXT3-fs error (device vda1): htree_dirblock_to_tree: bad entry in
directory #98503: rec_len is smaller than minimal - offset=0, inode=0,
rec_len=0, name_len=0

Tested locally on ext4, xfs          - WORK
Tested on NFSv4 share with ext4, xfs - FAIL
Tested NFSv4 share sync, async       - FAIL
Tested on NFSv3 share with xfs       - WORK
KVM with qemu rhel-6.5, 2.1.1        - SAME RESULTS

NOTE: it seems just the rhel5 guest triggers it easily..

HTH, Z.
