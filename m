From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: NFS: nfsroot BUG() hit in latest -git
Date: Thu, 24 Sep 2009 09:49:21 +0200
Message-ID: <f861ec6f0909240049q69df95e5wba5260788931667c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-NFS <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:57559 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbZIXHtS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2009 03:49:18 -0400
Received: by fxm18 with SMTP id 18so1200997fxm.17
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2009 00:49:21 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck!

I'm seeing kernel panics when mounting my NFSroot, caused
by 9423a08ad5773d0a7612d434700561dc8346b6d6:

root=/dev/nfs nfsroot=192.168.44.70:/mnt/work/mips-rootfs,v3,tcp

Looking up port of RPC 100003/3 on 192.168.44.70
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
Looking up port of RPC 100005/3 on 192.168.44.70
Kernel bug detected[#1]:
Cpu 0
$ 0   : 00000000 10003c00 00000100 80510000
$ 4   : 8d011c18 00000000 00000000 00000000
$ 8   : 00000003 fffff000 00000001 00000000
$12   : 66008c77 3b9aca00 00000003 00000000
$16   : 8d011c18 8d1c2178 8d1c2004 8d1c236c
$20   : 8d1c5514 8d1c5514 8d1c6000 8d1c5100
$24   : 00000010 00000000
$28   : 8d010000 8d011c00 00008001 801ec1c0
Hi    : 00000000
Lo    : 00000000
epc   : 801ea174 nfs_init_timeout_values+0x10c/0x118
    Not tainted
ra    : 801ec1c0 nfs_create_server+0xf4/0x5b4
Status: 10003c03    KERNEL EXL IE
Cause : 00808024
PrId  : 04030202 (Au1250)
Modules linked in:
Process swapper (pid: 1, threadinfo=8d010000, task=8d007408, tls=00000000)
Stack : 805303b0 00000000 805303b0 80510000 8d1b5034 8d1c5100 00000000 80387d4c
        8d1c5100 00000000 8d1c5100 8d1c5190 8d1c20e0 00000010 80428a50 00000000
        00000000 ffff8d77 8052ba48 8052ba4c 8052ba64 811a38a0 00000000 80513830
        80513830 10003c01 00000009 80181470 00000174 ffffffff 00000004 811a38a0
        0000000e 0000000e 000000d0 8d1c305c 8d1c20e0 8d1c5514 8d1c6000 8d1c5100
        ...
Call Trace:
[<801ea174>] nfs_init_timeout_values+0x10c/0x118
[<801ec1c0>] nfs_create_server+0xf4/0x5b4
[<801f7ab8>] nfs_get_sb+0x680/0x9b8
[<801878a8>] vfs_kern_mount+0x68/0xd0
[<80187974>] do_kern_mount+0x54/0x118
[<8019f970>] do_mount+0x694/0x720
[<8019fa90>] sys_mount+0x94/0xec
[<80531b90>] do_mount_root+0x2c/0xc8
[<80531f24>] mount_root+0x9c/0x148
[<8053218c>] prepare_namespace+0x1bc/0x1f0
[<80531388>] kernel_init+0x11c/0x13c
[<8010f090>] kernel_thread_helper+0x10/0x18

It's hitting the "BUG()" in fs/nfs/client.c::nfs_init_timeout_values().
it does not show up if I remove the "v3,tcp" from nfsroot
parameters, but then the whole userspace boot process takes ages.

Any ideas?

Thank you!
        Manuel Lauss
