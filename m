Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33615 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbbJPJXo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 05:23:44 -0400
Received: by pabrc13 with SMTP id rc13so115760096pab.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2015 02:23:43 -0700 (PDT)
Subject: [PATCH 2/2] NFSv4.1/pnfs: Retry through MDS when getting bad length
 of data
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55FF77DD.8070807@gmail.com> <561CFD01.3080201@gmail.com>
 <CAHQdGtSapCjT+ABSx=8maLN2KQJFFsW-v-F7BYy6wYykKfs0BA@mail.gmail.com>
 <561E01BA.4040109@gmail.com>
 <CAHQdGtSzTQLacptvPw0c73zHFn3ixynkpjavC2v-C5FBxNv8Hg@mail.gmail.com>
 <561F9FBA.7090501@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5620C211.2000200@gmail.com>
Date: Fri, 16 Oct 2015 17:23:29 +0800
MIME-Version: 1.0
In-Reply-To: <561F9FBA.7090501@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If non rpc-based layout driver return bad length of data, nfs retries
by calling rpc_restart_call_prepare() that cause an NULL reference panic.

This patch lets nfs retry through MDS for non rpc-based layout driver
return bad length of data.

[13034.883329] BUG: unable to handle kernel NULL pointer dereference at           (null)
[13034.884902] IP: [<ffffffffa00db372>] rpc_restart_call_prepare+0x62/0x90 [sunrpc]
[13034.886558] PGD 0
[13034.888126] Oops: 0000 [#1] KASAN
[13034.889710] Modules linked in: blocklayoutdriver(OE) nfsv4(OE) nfs(OE) fscache(E) nfsd(OE) xfs libcrc32c coretemp btrfs crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel ppdev vmw_balloon auth_rpcgss shpchp nfs_acl lockd vmw_vmci parport_pc xor raid6_pq grace parport sunrpc i2c_piix4 vmwgfx drm_kms_helper ttm drm mptspi e1000 serio_raw scsi_transport_spi mptscsih mptbase ata_generic pata_acpi [last unloaded: fscache]
[13034.898260] CPU: 0 PID: 10112 Comm: kworker/0:1 Tainted: G           OE   4.3.0-rc5+ #279
[13034.899932] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[13034.903342] Workqueue: events bl_read_cleanup [blocklayoutdriver]
[13034.905059] task: ffff88006a9148c0 ti: ffff880035e90000 task.ti: ffff880035e90000
[13034.906827] RIP: 0010:[<ffffffffa00db372>]  [<ffffffffa00db372>] rpc_restart_call_prepare+0x62/0x90 [sunrpc]
[13034.910522] RSP: 0018:ffff880035e97b58  EFLAGS: 00010282
[13034.912378] RAX: fffffbfff04a5a94 RBX: ffff880068fe4858 RCX: 0000000000000003
[13034.914339] RDX: dffffc0000000000 RSI: 0000000000000003 RDI: 0000000000000282
[13034.916236] RBP: ffff880035e97b68 R08: 0000000000000001 R09: 0000000000000001
[13034.918229] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
[13034.920007] R13: ffff880068fe4858 R14: ffff880068fe4a60 R15: 0000000000001000
[13034.921845] FS:  0000000000000000(0000) GS:ffffffff82247000(0000) knlGS:0000000000000000
[13034.923645] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[13034.925525] CR2: 0000000000000000 CR3: 00000000063dd000 CR4: 00000000001406f0
[13034.932808] Stack:
[13034.934813]  ffff880068fe4780 0000000000001000 ffff880035e97ba8 ffffffffa08800d2
[13034.936675]  ffffffffa088029d ffff880068fe4780 ffff880068fe4858 ffffffffa089c0a0
[13034.938593]  ffff880068fe47e0 ffff88005d59faf0 ffff880035e97be0 ffffffffa087e08f
[13034.940454] Call Trace:
[13034.942388]  [<ffffffffa08800d2>] nfs_readpage_result+0x112/0x200 [nfs]
[13034.944317]  [<ffffffffa088029d>] ? nfs_readpage_done+0xdd/0x160 [nfs]
[13034.946267]  [<ffffffffa087e08f>] nfs_pgio_result+0x9f/0x120 [nfs]
[13034.948166]  [<ffffffffa09266cc>] pnfs_ld_read_done+0x7c/0x1e0 [nfsv4]
[13034.950247]  [<ffffffffa03b07ee>] bl_read_cleanup+0x2e/0x60 [blocklayoutdriver]
[13034.952156]  [<ffffffff810ebf62>] process_one_work+0x412/0x870
[13034.954102]  [<ffffffff810ebe84>] ? process_one_work+0x334/0x870
[13034.955949]  [<ffffffff810ebb50>] ? queue_delayed_work_on+0x40/0x40
[13034.957985]  [<ffffffff810ec441>] worker_thread+0x81/0x6a0
[13034.959817]  [<ffffffff810ec3c0>] ? process_one_work+0x870/0x870
[13034.961785]  [<ffffffff810f43bd>] kthread+0x17d/0x1a0
[13034.963544]  [<ffffffff810f4240>] ? kthread_create_on_node+0x330/0x330
[13034.965479]  [<ffffffff81100428>] ? finish_task_switch+0x88/0x220
[13034.967223]  [<ffffffff810f4240>] ? kthread_create_on_node+0x330/0x330
[13034.968929]  [<ffffffff81b6ae5f>] ret_from_fork+0x3f/0x70
[13034.970534]  [<ffffffff810f4240>] ? kthread_create_on_node+0x330/0x330
[13034.972176] Code: c7 43 50 40 84 0d a0 e8 3d fe 1c e1 48 8d 7b 58 c7 83 e4 00 00 00 00 00 00 00 e8 ca fe 1c e1 4c 8b 63 58 4c 89 e7 e8 be fe 1c e1 <49> 83 3c 24 00 74 12 48 c7 43 50 f0 a2 0e a0 b8 01 00 00 00 5b
[13034.977148] RIP  [<ffffffffa00db372>] rpc_restart_call_prepare+0x62/0x90 [sunrpc]
[13034.978780]  RSP <ffff880035e97b58>
[13034.980399] CR2: 0000000000000000

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/pnfs.c  | 12 +++++++-----
 fs/nfs/read.c  |  9 ++++++++-
 fs/nfs/write.c |  7 +++++++
 3 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8abe271..93496c0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1912,12 +1912,13 @@ static void pnfs_ld_handle_write_error(struct nfs_pgio_header *hdr)
  */
 void pnfs_ld_write_done(struct nfs_pgio_header *hdr)
 {
-	trace_nfs4_pnfs_write(hdr, hdr->pnfs_error);
-	if (!hdr->pnfs_error) {
+	if (likely(!hdr->pnfs_error)) {
 		pnfs_set_layoutcommit(hdr->inode, hdr->lseg,
 				hdr->mds_offset + hdr->res.count);
 		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
-	} else
+	}
+	trace_nfs4_pnfs_write(hdr, hdr->pnfs_error);
+	if (unlikely(hdr->pnfs_error))
 		pnfs_ld_handle_write_error(hdr);
 	hdr->mds_ops->rpc_release(hdr);
 }
@@ -2028,11 +2029,12 @@ static void pnfs_ld_handle_read_error(struct nfs_pgio_header *hdr)
  */
 void pnfs_ld_read_done(struct nfs_pgio_header *hdr)
 {
-	trace_nfs4_pnfs_read(hdr, hdr->pnfs_error);
 	if (likely(!hdr->pnfs_error)) {
 		__nfs4_read_done_cb(hdr);
 		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
-	} else
+	}
+	trace_nfs4_pnfs_read(hdr, hdr->pnfs_error);
+	if (unlikely(hdr->pnfs_error))
 		pnfs_ld_handle_read_error(hdr);
 	hdr->mds_ops->rpc_release(hdr);
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 01b8cc8..0a5e33f 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -246,6 +246,13 @@ static void nfs_readpage_retry(struct rpc_task *task,
 		nfs_set_pgio_error(hdr, -EIO, argp->offset);
 		return;
 	}
+
+	/* For non rpc-based layout drivers, retry-through-MDS */
+	if (!task->tk_ops) {
+		hdr->pnfs_error = -EAGAIN;
+		return;
+	}
+
 	/* Yes, so retry the read at the end of the hdr */
 	hdr->mds_offset += resp->count;
 	argp->offset += resp->count;
@@ -268,7 +275,7 @@ static void nfs_readpage_result(struct rpc_task *task,
 			hdr->good_bytes = bound - hdr->io_start;
 		}
 		spin_unlock(&hdr->lock);
-	} else if (hdr->res.count != hdr->args.count)
+	} else if (hdr->res.count < hdr->args.count)
 		nfs_readpage_retry(task, hdr);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 75ab762..7b93164 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1505,6 +1505,13 @@ static void nfs_writeback_result(struct rpc_task *task,
 			task->tk_status = -EIO;
 			return;
 		}
+
+		/* For non rpc-based layout drivers, retry-through-MDS */
+		if (!task->tk_ops) {
+			hdr->pnfs_error = -EAGAIN;
+			return;
+		}
+
 		/* Was this an NFSv2 write or an NFSv3 stable write? */
 		if (resp->verf->committed != NFS_UNSTABLE) {
 			/* Resend from where the server left off */
-- 
2.5.0

