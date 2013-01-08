Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:40399 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab3AHWmW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 17:42:22 -0500
MIME-Version: 1.0
Date: Tue, 8 Jan 2013 20:42:21 -0200
Message-ID: <CAOMZO5Dpez4ffFQ0E1QH+PgAAMpOH8hjWr6mJaH+dkrfNpVSVQ@mail.gmail.com>
Subject: NFS crash on linux-next 20130108
From: Fabio Estevam <festevam@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Trying to mount NFS with linux 20130108 on a ARM mx51 board I get:

Unable to handle kernel NULL pointer dereference at virtual address 00000018
pgd = 80004000
[00000018] *pgd=00000000
Internal error: Oops: 5 [#1] SMP ARM
Modules linked in:
CPU: 0    Not tainted  (3.8.0-rc2-next-20130108+ #998)
PC is at xprt_release+0x1bc/0x248
LR is at rpc_do_put_task+0x40/0xa0
pc : [<804ed6f4>]    lr : [<804f1814>]    psr: 60000113
sp : 9f855b90  ip : 9f855bb8  fp : 9f855bb4
r10: 9f1fb300  r9 : 00000001  r8 : 9f855dac
r7 : 9f855d50  r6 : 9f1fa280  r5 : 00000000  r4 : 9f1fa280
r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : 9f1fa280
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 10c5387d  Table: 90004019  DAC: 00000017
Process swapper/0 (pid: 1, stack limit = 0x9f854238)
Stack: (0x9f855b90 to 0x9f856000)
5b80:                                     00000000 9f1fa280 00000000 00000000
5ba0: 9f855d50 9f855dac 9f855bd4 9f855bb8 804f1814 804ed544 00000002 00000000
5bc0: 9f1f6a00 00000011 9f855be4 9f855bd8 804f18a0 804f17e0 9f855c1c 9f855be8
5be0: 804eba8c 804f1898 9f855c1c 00000000 9f1f6a00 9f855c20 80558058 00000000
5c00: 00000000 00000600 80707300 9f1f6a00 9f855c44 9f855c20 804ebb3c 804eba3c
5c20: 8070c14c 00000000 00000000 8070c3f0 9f855d50 9f855cb8 9f855cb4 9f855c48
5c40: 804ebd60 804ebaf0 00000000 806e38c8 9f855c94 9f855c60 80046520 8003d9fc
5c60: b8c63f00 00000001 00000003 806e38d0 40000113 00000000 00000001 00000011
5c80: 80707300 00000000 9f1fe64c 00000010 9f1fcfc0 00000000 00000001 9f855d80
5ca0: 00000011 80707300 9f855d3c 9f855cb8 801a7fd4 804ebc0c 80707300 00000011
5cc0: 9f1fe64c 00000010 00000000 00000000 9f1fcfc0 80522438 00000000 00000001
5ce0: 00000001 00000000 00000000 00000000 00000000 9f1fb300 9f855dac 9f855d50
5d00: 00000000 9f1f7000 9f855cf0 00000000 9f801180 9f1fe600 9f855de4 806e6070
5d20: 00008001 9f1fcf40 00008001 9f1fcf40 9f855ddc 9f855d40 8019ee7c 801a7f10
5d40: 9f1fe600 00000000 00000000 9f1f8028 9f1fe600 00000000 9f855ddc 9f801180
5d60: 00000000 9f1fcf4d 806db178 00001000 00008001 9f1fcf40 9f855dbc 9f855d88
5d80: 9f1fe64c 00000010 9f1fcfc0 9f1f7000 00000001 00000011 9f1fb300 00000000
5da0: 9f855dac 9f855d50 80707300 0000000c 00000000 806e6070 9f1fe600 00000400
5dc0: 9f1fcf40 00001000 00008001 9f1fcf40 9f855e24 9f855de0 801a028c 8019ed5c
5de0: 00000005 8019e80c 8019d600 9f1fe600 00000000 9f1fb300 80754a08 9f1fb240
5e00: 806e5c70 806e5c70 00008001 9f1f8000 9f1fcf00 00008001 9f855e54 9f855e28
5e20: 800b728c 8019fe68 9f1f8000 00000060 806e5c70 9f1fb240 806e5c70 9f1fcf40
5e40: 9f1f8000 9f1fcf00 9f855e7c 9f855e58 800d15ac 800b727c 9f1f8000 00000060
5e60: 806e5c70 9f1f8000 806e21ec 9f1fcf40 9f855ecc 9f855e80 800d35e8 800d1564
5e80: 9f855e9c 9f855e90 9f80d250 9f4093b8 9f855ecc 9f855ea0 800d33f8 80514c38
5ea0: 00008001 9f82d000 806c6f94 00008001 00000000 000000a4 8069220c 806cea78
5ec0: 9f855f04 9f855ed0 800d3dbc 800d3490 9f1f8000 2e343432 80003238 9f1fcf00
5ee0: 9f1fcf40 9f1f8000 00000005 00000006 806dd678 000003e8 9f855f34 9f855f08
5f00: 80692ff0 800d3d3c 806c6a8c 00000010 806c6f94 806c6a8c 8070d4e0 806c43fd
5f20: 806c43c4 8070d480 9f855f54 9f855f38 8069320c 80692f9c 9f855f54 9f855f48
5f40: 806c43e4 00000007 9f855f94 9f855f58 806929fc 806930b0 00000007 00000007
5f60: 8069220c 00000000 00000000 00000000 8050b0b0 00000000 00000000 00000000
5f80: 00000000 00000000 9f855fac 9f855f98 8050b0c0 80692880 ffffffff 00000000
5fa0: 00000000 9f855fb0 8000e598 8050b0bc 00000000 00000000 00000000 00000000
5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
5fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
Backtrace:
[<804ed538>] (xprt_release+0x0/0x248) from [<804f1814>]
(rpc_do_put_task+0x40/0xa0)
 r8:9f855dac r7:9f855d50 r6:00000000 r5:00000000
r4:+-----------------------------+
r3:00000000                                         |
           |
[<804f17d4>] (rpc_do_put_task+0x0/0xa0) from [<804f1|  Cannot open
/dev/ttyUSB0!  |
 r6:00000011 r5:9f1f6a00 r4:00000000 r3:00000002    |
           |
[<804f188c>] (rpc_put_task+0x0/0x18) from
[<804eba8c+-----------------------------+
[<804eba30>] (rpc_call_sync+0x0/0xb4) from [<804ebb3c>] (rpc_ping+0x58/0x78)
 r4:9f1f6a00
[<804ebae4>] (rpc_ping+0x0/0x78) from [<804ebd60>] (rpc_create+0x160/0x1c0)
 r4:9f855cb8
[<804ebc00>] (rpc_create+0x0/0x1c0) from [<801a7fd4>] (nfs_mount+0xd0/0x11c)
 r6:80707300 r5:00000011 r4:9f855d80
[<801a7f04>] (nfs_mount+0x0/0x11c) from [<8019ee7c>] (nfs_try_mount+0x12c/0x244)
[<8019ed50>] (nfs_try_mount+0x0/0x244) from [<801a028c>]
(nfs_fs_mount+0x430/0x844)
[<8019fe5c>] (nfs_fs_mount+0x0/0x844) from [<800b728c>] (mount_fs+0x1c/0xd8)
[<800b7270>] (mount_fs+0x0/0xd8) from [<800d15ac>] (vfs_kern_mount+0x54/0xc8)
 r9:9f1fcf00 r8:9f1f8000 r6:9f1fcf40 r5:806e5c70 r4:9f1fb240
[<800d1558>] (vfs_kern_mount+0x0/0xc8) from [<800d35e8>] (do_mount+0x164/0x8ac)
 r8:9f1fcf40 r7:806e21ec r6:9f1f8000 r5:806e5c70 r4:00000060
r3:9f1f8000
[<800d3484>] (do_mount+0x0/0x8ac) from [<800d3dbc>] (sys_mount+0x8c/0xc0)
[<800d3d30>] (sys_mount+0x0/0xc0) from [<80692ff0>] (mount_root+0x60/0x114)
 r7:000003e8 r6:806dd678 r5:00000006 r4:00000005
[<80692f90>] (mount_root+0x0/0x114) from [<8069320c>]
(prepare_namespace+0x168/0x1cc)
 r7:8070d480 r6:806c43c4 r5:806c43fd r4:8070d4e0
[<806930a4>] (prepare_namespace+0x0/0x1cc) from [<806929fc>]
(kernel_init_freeable+0x188/0x1cc)
 r5:00000007 r4:806c43e4
[<80692874>] (kernel_init_freeable+0x0/0x1cc) from [<8050b0c0>]
(kernel_init+0x10/0xec)
[<8050b0b0>] (kernel_init+0x0/0xec) from [<8000e598>] (ret_from_fork+0x14/0x3c)
 r4:00000000 r3:ffffffff
Code: e5931038 eb005496 eaffff9f e590300c (e5935018)
---[ end trace 4a377447fb5cfae4 ]---
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

Any ideas or suggestions?

Thanks,

Fabio Estevam
