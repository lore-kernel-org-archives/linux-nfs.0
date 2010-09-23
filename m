Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58034 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754495Ab0IWLsU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 07:48:20 -0400
Message-ID: <4C9B3E81.8090505@panasas.com>
Date: Thu, 23 Sep 2010 13:48:17 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Oops in nfs-for-2.6.37
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond,

I hit the following crash running the cthon tests over a local mount
on your nfs-for-2.6.37 branch, 6095889 NFS: Convert nfsiod to use alloc_workqueue()

Sep 23 13:02:25 tl1 kernel: BUG: unable to handle kernel NULL pointer dereference at 00000000000000ac
Sep 23 13:02:25 tl1 kernel: IP: [<ffffffff81319411>] _raw_spin_lock+0xe/0x1f
Sep 23 13:02:25 tl1 kernel: PGD 773d2067 PUD 7d249067 PMD 0 
Sep 23 13:02:25 tl1 kernel: Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
Sep 23 13:02:25 tl1 kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1c.1/0000:02:00.0/irq
Sep 23 13:02:25 tl1 kernel: CPU 0 
Sep 23 13:02:25 tl1 kernel: Modules linked in: nfsd exportfs nfs lockd nfs_acl auth_rpcgss osd libosd crc32c sunrpc ip6table_filter ip6_tables ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi cpufreq_ondemand acpi_cpufreq freq_table mperf ext2 dm_mirror dm_region_hash dm_log dm_multipath dm_mod uinput snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd iTCO_wdt iTCO_vendor_support ppdev parport_pc soundcore atl1c snd_page_alloc rng_core parport i2c_i801 sg ata_generic ata_piix libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd i915 drm_kms_helper drm i2c_algo_bit button i2c_core video output [last unloaded: microcode]
Sep 23 13:02:25 tl1 kernel:
Sep 23 13:02:25 tl1 kernel: Pid: 2995, comm: cc1 Not tainted 2.6.36-rc3-00025-g6095889 #92 G41TM-P33 (MS-7592)/MS-7592
Sep 23 13:02:25 tl1 kernel: RIP: 0010:[<ffffffff81319411>]  [<ffffffff81319411>] _raw_spin_lock+0xe/0x1f
Sep 23 13:02:25 tl1 kernel: RSP: 0018:ffff88007702fbe8  EFLAGS: 00010246
Sep 23 13:02:25 tl1 kernel: RAX: 0000000000000100 RBX: ffff8800720ed600 RCX: ffff8800720ed600
Sep 23 13:02:25 tl1 kernel: RDX: 0000000000000001 RSI: 00000000000000ac RDI: 00000000000000ac
Sep 23 13:02:25 tl1 kernel: RBP: ffff88007702fbe8 R08: 00000004ac2a592a R09: ffff88007702f928
Sep 23 13:02:25 tl1 kernel: R10: ffff880001a12e80 R11: 0000000000000000 R12: 00000000000000ac
Sep 23 13:02:25 tl1 kernel: R13: 0000000000000000 R14: ffff8800720ed600 R15: fffffffffffffffe
Sep 23 13:02:25 tl1 kernel: FS:  00007f16266586f0(0000) GS:ffff880001a00000(0000) knlGS:0000000000000000
Sep 23 13:02:25 tl1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Sep 23 13:02:25 tl1 kernel: CR2: 00000000000000ac CR3: 000000007c4da000 CR4: 00000000000406f0
Sep 23 13:02:25 tl1 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep 23 13:02:25 tl1 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Sep 23 13:02:25 tl1 kernel: Process cc1 (pid: 2995, threadinfo ffff88007702e000, task ffff880072048000)
Sep 23 13:02:25 tl1 kernel: Stack:
Sep 23 13:02:25 tl1 kernel: ffff88007702fc08 ffffffff8117ede9 ffff8800720ed600 0000000000000000
Sep 23 13:02:25 tl1 kernel: <0> ffff88007702fc38 ffffffffa050ece5 ffff8800720ed600 ffff88007541f0c0
Sep 23 13:02:25 tl1 kernel: <0> ffff88007702fe28 ffff8800757cdc60 ffff88007702fc48 ffffffffa050ede0
Sep 23 13:02:25 tl1 kernel: Call Trace:
Sep 23 13:02:25 tl1 kernel: [<ffffffff8117ede9>] _atomic_dec_and_lock+0x31/0x4c
Sep 23 13:02:25 tl1 kernel: [<ffffffffa050ece5>] __put_nfs_open_context+0x2d/0x8e [nfs]
Sep 23 13:02:25 tl1 kernel: [<ffffffffa050ede0>] put_nfs_open_context+0x10/0x12 [nfs]
Sep 23 13:02:25 tl1 kernel: [<ffffffffa050bf3d>] nfs_atomic_lookup+0x17b/0x23d [nfs]
Sep 23 13:02:25 tl1 kernel: [<ffffffff810f697f>] d_alloc_and_lookup+0x55/0x74
Sep 23 13:02:25 tl1 kernel: [<ffffffff810f6aa4>] do_lookup+0xb9/0x10b
Sep 23 13:02:25 tl1 kernel: [<ffffffff810f7f15>] do_last+0x13e/0x520
Sep 23 13:02:25 tl1 kernel: [<ffffffff810f9bc8>] do_filp_open+0x208/0x59e
Sep 23 13:02:25 tl1 kernel: [<ffffffff81187f52>] ? __strncpy_from_user+0x2e/0x58
Sep 23 13:02:25 tl1 kernel: [<ffffffff81102839>] ? alloc_fd+0x7b/0x123
Sep 23 13:02:25 tl1 kernel: [<ffffffff810ec6df>] do_sys_open+0x60/0xfc
Sep 23 13:02:25 tl1 kernel: [<ffffffff810ec7ae>] sys_open+0x20/0x22
Sep 23 13:02:25 tl1 kernel: [<ffffffff81002c72>] system_call_fastpath+0x16/0x1b
Sep 23 13:02:25 tl1 kernel: Code: 8d 90 00 01 00 00 75 05 f0 66 0f b1 17 0f 94 c2 0f b6 c2 85 c0 c9 0f 95 c0 0f b6 c0 c3 55 48 89 e5 0f 1f 44 00 00 b8 00 01 00 00 <f0> 66 0f c1 07 38 e0 74 06 f3 90 8a 07 eb f6 c9 c3 55 48 89 e5 
Sep 23 13:02:25 tl1 kernel: RIP  [<ffffffff81319411>] _raw_spin_lock+0xe/0x1f
Sep 23 13:02:25 tl1 kernel: RSP <ffff88007702fbe8>
Sep 23 13:02:25 tl1 kernel: CR2: 00000000000000ac
Sep 23 13:02:25 tl1 kernel: ---[ end trace 3bc8c65827b41582 ]---

It appears like after cd9a1c0e NFSv4: Clean up nfs4_atomic_open
put_nfs_open_context can be called before dentry->d_inode is
set causing the atomic_dec_and_lock in __put_nfs_open_context to barf
trying to lock &inode->lock where inode is NULL.

How about the following?

>From e7019592dae2945ea4091f42ab54f2a1f13465f7 Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@panasas.com>
Date: Thu, 23 Sep 2010 13:26:43 +0200
Subject: [PATCH] NFS: handle inode==NULL in __put_nfs_open_context

inode may be NULL when put_nfs_open_context is called from nfs_atomic_lookup
before d_add_unique(dentry, inode)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2ff8142..a4e579c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -654,11 +654,14 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
 	struct inode *inode = ctx->path.dentry->d_inode;
 
-	if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
-		return;
-	list_del(&ctx->list);
-	spin_unlock(&inode->i_lock);
-	NFS_PROTO(inode)->close_context(ctx, is_sync);
+	if (inode) {
+		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
+			return;
+		list_del(&ctx->list);
+		spin_unlock(&inode->i_lock);
+		NFS_PROTO(inode)->close_context(ctx, is_sync);
+	} else
+		BUG_ON(atomic_dec_return(&ctx->lock_context.count) != 0);
 	if (ctx->cred != NULL)
 		put_rpccred(ctx->cred);
 	path_put(&ctx->path);
-- 
1.7.2.3

