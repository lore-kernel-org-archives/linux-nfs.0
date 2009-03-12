From: Bas van der Vlies <basv-mYZPGKKnAUw@public.gmane.org>
Subject: nfs clients crashes
Date: Thu, 12 Mar 2009 14:55:52 +0100
Message-ID: <49B91468.3020006@sara.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from planck.ka.sara.nl ([145.100.8.32]:13499 "EHLO planck.ka.sara.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754571AbZCLOBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Mar 2009 10:01:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OS: debian lenny
kernel release tested: 2.6.28.[1-7] , 2.6.29.rc5 and 2.6.29.rc7

NFS-server: solaris 10 zfs/nfs server

Is this a familiar bug?
{{{
------------[ cut here ]------------
kernel BUG at fs/nfs/write.c:252!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/class/infiniband/mlx4_0/ports/1/gids/0
CPU 2
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler autofs4 fuse
dm_snapshot dm_mirror dm_region_hash dm_log dm_mod mptctl rdma_ucm rdma_cm
iw_cm ib_addr ib_ipoib inet_lro ib_ucm ib_cm ib_sa ib_uverbs ib_umad
mlx4_ib ib_mad ib_core dcdbas ehci_hcd uhci_hcd mlx4_core bnx2 crc32
Pid: 262, comm: pdflush Not tainted 2.6.28.7-sara1 #1
RIP: 0010:[<ffffffff80309107>]  [<ffffffff80309107>]
nfs_do_writepage+0x107/0x1a0
RSP: 0000:ffff88043e0f7b10  EFLAGS: 00010202
RAX: 0000000000000001 RBX: ffffe2000e5c63e8 RCX: 0000000000000015
RDX: 0000000000000000 RSI: 0000000000600020 RDI: ffff8804354a7550
RBP: ffff88043e0f7b40 R08: ffff880435597268 R09: ffff8804386ea140
R10: 0000000000000000 R11: 0000000000000000 R12: ffff8804386ea140
R13: ffff8804354a769c R14: ffffe2000e5c63e8 R15: ffff8804354a75e8
FS:  0000000000000000(0000) GS:ffff88043f846840(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 000000005555c18c CR3: 0000000000201000 CR4: 00000000000406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process pdflush (pid: 262, threadinfo ffff88043e0f6000, task ffff88043faf9270)
Stack:
 ffff88043e0f7c90 ffffe2000e5c63e8 ffffe2000e5c63e8 ffff88043e0f7be0
 0000000000000001 0000000000000002 ffff88043e0f7b60 ffffffff803096a9
 ffffe2000e5c63e8 0000000000000001 ffff88043e0f7c80 ffffffff80272707
Call Trace:
 [<ffffffff803096a9>] nfs_writepages_callback+0x19/0x30
 [<ffffffff80272707>] write_cache_pages+0x227/0x460
 [<ffffffff80309690>] ? nfs_writepages_callback+0x0/0x30
 [<ffffffff8030adb1>] ? nfs_flush_one+0xb1/0xf0
 [<ffffffff80309642>] nfs_writepages+0xa2/0xf0
 [<ffffffff8030ad00>] ? nfs_flush_one+0x0/0xf0
 [<ffffffff80272998>] do_writepages+0x28/0x50
 [<ffffffff802b410b>] __writeback_single_inode+0x9b/0x470
 [<ffffffff8022a4e0>] ? update_curr+0xd0/0x120
 [<ffffffff8022e658>] ? dequeue_entity+0x18/0x190
 [<ffffffff802b4ac0>] generic_sync_sb_inodes+0x3a0/0x4d0
 [<ffffffff802b4dae>] writeback_inodes+0x4e/0xf0
 [<ffffffff80272b34>] wb_kupdate+0xa4/0x130
 [<ffffffff802736be>] pdflush+0x10e/0x1f0
 [<ffffffff80272a90>] ? wb_kupdate+0x0/0x130
 [<ffffffff802735b0>] ? pdflush+0x0/0x1f0
 [<ffffffff8024ba79>] kthread+0x49/0x90
 [<ffffffff8020d1b9>] child_rip+0xa/0x11
 [<ffffffff8024ba30>] ? kthread+0x0/0x90
 [<ffffffff8020d1af>] ? child_rip+0x0/0x11
Code: b4 00 00 00 31 db 48 83 c4 08 89 d8 5b 41 5c 41 5d 41 5e 41 5f c9 c3
0f 1f 44 00 00 41 f6 44 24 40 02 74 0b 41 fe 87 b4 00 00 00 <0f> 0b eb fe
4c 89 f7 e8 2d 8c f6 ff 85 c0 75 72 49 8b 46 18 ba
RIP  [<ffffffff80309107>] nfs_do_writepage+0x107/0x1a0
 RSP <ffff88043e0f7b10>
---[ end trace 4fac3d44a611662b ]---
}}}



-- 
********************************************************************
*  Bas van der Vlies                    e-mail: basv-mYZPGKKnAUw@public.gmane.org       *
*  SARA - Academic Computing Services   Amsterdam, The Netherlands *
********************************************************************
