Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:26621 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1IMLzf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 07:55:35 -0400
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>
CC: <linux-nfs@vger.kernel.org>
Date: Tue, 13 Sep 2011 07:55:21 -0400
Subject: NULL pointer dereference during mount
Message-ID: <F19688880B763E40B28B2B462677FBF805C3299FFE@MX09A.corp.emc.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny,

After rebasing to your pnfs-all-latest branch, I always got bellow NULL pointer dereference for both nfsv4 and pnfs. Do you know of any recent change that can cause this?

[   81.468606] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[   81.468919] IP: [<ffffffff8120ca85>] selinux_set_mnt_opts+0x4f/0x3fb
[   81.469174] PGD 2ffc067 PUD 2e84067 PMD 0
[   81.469455] Oops: 0000 [#1] SMP
[   81.469455] CPU 0
[   81.469455] Modules linked in: blocklayoutdriver nfs lockd fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE ipt
able_nat nf_nat xt_CHECKSUM iptable_mangle bridge stp llc sunrpc ip6t_REJECT be2iscsi nf_conntrack_ipv6 nf_defrag_ipv6 iscsi_boot
_sysfs bnx2i ip6table_filter cnic uio ip6_tables cxgb3i libcxgbi cxgb3 mdio iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi
pcspkr e1000 i2c_piix4 ppdev shpchp i2c_core parport_pc parport vmw_balloon microcode ipv6 mptspi mptscsih mptbase scsi_transport
_spi [last unloaded: nfs]
[   81.469455]
[   81.469455] Pid: 1919, comm: mount.nfs Not tainted 3.1.0-rc3+ #3 VMware, Inc. VMware Virtual Platform/440BX Desktop Reference
Platform
[   81.469455] RIP: 0010:[<ffffffff8120ca85>]  [<ffffffff8120ca85>] selinux_set_mnt_opts+0x4f/0x3fb
[   81.469455] RSP: 0018:ffff88000d22fb28  EFLAGS: 00010296
[   81.469455] RAX: 0000000000000000 RBX: ffff880008460200 RCX: 0000000000000000
[   81.469455] RDX: 0000000000000000 RSI: ffff880008460390 RDI: ffff8800003dc800
[   81.469455] RBP: ffff88000d22fbb8 R08: 0000000000000001 R09: 0000000000000000
[   81.469455] R10: 0000ffff00066c0a R11: 0000000000000000 R12: ffff880000019a00
[   81.469455] R13: ffff8800003dc800 R14: ffff880008460390 R15: ffff8800003dc800
[   81.469455] FS:  00007ffebe637720(0000) GS:ffff880017400000(0000) knlGS:0000000000000000
[   81.469455] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   81.469455] CR2: 0000000000000030 CR3: 000000000ce79000 CR4: 00000000000006f0
[   81.469455] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   81.469455] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   81.469455] Process mount.nfs (pid: 1919, threadinfo ffff88000d22e000, task ffff88000cb08000)
[   81.469455] Stack:
[   81.469455]  ffffea0000031880 ffff880000000008 0000000000000000 ffff88000d22fb48
[   81.469455]  ffff88000d22fb78 ffffffffa02fe5ee 0000000180150011 ffff88000a308cc0
[   81.469455]  0000000000000001 0000000000000001 ffff88000d22fbc8 ffffffffa02caac5
[   81.469455] Call Trace:
[   81.469455]  [<ffffffffa02caac5>] ? nfs4_get_root+0x20f/0x242 [nfs]
[   81.469455]  [<ffffffff8120504e>] security_sb_set_mnt_opts+0x16/0x18
[   81.469455]  [<ffffffffa02ce6bd>] nfs4_remote_mount+0x17c/0x1ff [nfs]
[   81.469455]  [<ffffffff8112fde6>] mount_fs+0x69/0x157
[   81.469455]  [<ffffffff810fb000>] ? __alloc_percpu+0x10/0x12
[   81.469455]  [<ffffffff811444ca>] vfs_kern_mount+0x63/0xa0
[   81.469455]  [<ffffffffa02ce9b8>] nfs_do_root_mount+0x7b/0x9a [nfs]
[   81.469455]  [<ffffffffa02cec8f>] nfs4_try_mount+0x58/0xba [nfs]
[   81.469455]  [<ffffffffa02cfff1>] nfs_fs_mount+0x48b/0x6e9 [nfs]
[   81.469455]  [<ffffffff8112fde6>] mount_fs+0x69/0x157
[   81.469455]  [<ffffffff810fb000>] ? __alloc_percpu+0x10/0x12
[   81.469455]  [<ffffffff811444ca>] vfs_kern_mount+0x63/0xa0
[   81.469455]  [<ffffffff811451be>] do_kern_mount+0x4d/0xdf
[   81.469455]  [<ffffffff8114685d>] do_mount+0x63c/0x69f
[   81.469455]  [<ffffffff81146185>] ? copy_mount_options+0xcb/0x12e
[   81.469455]  [<ffffffff81146b6e>] sys_mount+0x88/0xc2
[   81.469455]  [<ffffffff8147e502>] system_call_fastpath+0x16/0x1b
[   81.469455] Code: 00 00 4c 8b a7 a8 01 00 00 49 89 fd 48 8b 56 08 48 89 45 a8 48 8b 47 28 48 89 55 80 48 8b 00 48 89 45 98 49 8b 04 24 48 8b 40 60
[   81.469455]  8b 40 30 48 8b 40 38 48 89 45 a0 48 8b 06 8b 76 10 48 89 45
[   81.469455] RIP  [<ffffffff8120ca85>] selinux_set_mnt_opts+0x4f/0x3fb
[   81.469455]  RSP <ffff88000d22fb28>
[   81.469455] CR2: 0000000000000030
[   81.513181] ---[ end trace dccee53f6c438566 ]---



Cheers,
-Bergwolf


