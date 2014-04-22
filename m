Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:37665 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757067AbaDVUBe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 16:01:34 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so5726512iec.22
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 13:01:33 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v2] pnfs: fix race in filelayout commit path
Date: Tue, 22 Apr 2014 16:02:05 -0400
Message-Id: <1398196925-67410-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hold the lock while modifying commit info dataserver buckets.

The following oops can be reproduced by running iozone for a while against
a 2 DS pynfs filelayout server.

general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 nfs fscache
CPU: 0 PID: 903 Comm: iozone Not tainted 3.15.0-rc1-branch-dros_testing+ #44
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference
task: ffff880078164480 ti: ffff88006e972000 task.ti: ffff88006e972000
RIP: 0010:[<ffffffffa01936e1>]  [<ffffffffa01936e1>] nfs_init_commit+0x22/0x
RSP: 0018:ffff88006e973d30  EFLAGS: 00010246
RAX: ffff88006e973e00 RBX: ffff88006e828800 RCX: ffff88006e973e10
RDX: 0000000000000000 RSI: ffff88006e973e00 RDI: dead4ead00000000
RBP: ffff88006e973d38 R08: ffff88006e8289d8 R09: 0000000000000000
R10: ffff88006e8289d8 R11: 0000000000016988 R12: ffff88006e973b98
R13: ffff88007a0a6648 R14: ffff88006e973e10 R15: ffff88006e828800
FS:  00007f2ce396b740(0000) GS:ffff88007f200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f03278a1000 CR3: 0000000079043000 CR4: 00000000001407f0
Stack:
ffff88006e8289d8 ffff88006e973da8 ffffffffa00f144f ffff88006e9478c0
ffff88006e973e00 ffff88006de21080 0000000100000002 ffff880079be6c48
ffff88006e973d70 ffff88006e973d70 ffff88006e973e10 ffff88006de21080
Call Trace:
[<ffffffffa00f144f>] filelayout_commit_pagelist+0x1ae/0x34a [nfs_layout_nfsv
[<ffffffffa0194f72>] nfs_generic_commit_list+0x92/0xc4 [nfs]
[<ffffffffa0195053>] nfs_commit_inode+0xaf/0x114 [nfs]
[<ffffffffa01892bd>] nfs_file_fsync_commit+0x82/0xbe [nfs]
[<ffffffffa01ceb0d>] nfs4_file_fsync+0x59/0x9b [nfsv4]
[<ffffffff8114ee3c>] vfs_fsync_range+0x18/0x20
[<ffffffff8114ee60>] vfs_fsync+0x1c/0x1e
[<ffffffffa01891c2>] nfs_file_flush+0x7f/0x84 [nfs]
[<ffffffff81127a43>] filp_close+0x3c/0x72
[<ffffffff81140e12>] __close_fd+0x82/0x9a
[<ffffffff81127a9c>] SyS_close+0x23/0x4c
[<ffffffff814acd12>] system_call_fastpath+0x16/0x1b
Code: 5b 41 5c 41 5d 41 5e 5d c3 0f 1f 44 00 00 55 48 89 e5 53 48 89 fb 48 8
RIP  [<ffffffffa01936e1>] nfs_init_commit+0x22/0xe1 [nfs]
RSP <ffff88006e973d30>
---[ end trace 732fe6419b235e2f ]---

Suggested-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---

Version 1 was still missing some locks around wlseg and clseg.

My testing hasn't been able to reproduce the oops now for over 4 hours of
iozone runs on two different setups. I'll keep testing...

I'm not sure if this is something we want to CC to stable, AFAIK no
vendors currently support filelayout with commit (which is why this
codepath is seemingly untested).

 fs/nfs/nfs4filelayout.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b9a35c0..b6fc8c1 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -1067,6 +1067,7 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	 */
 	j = nfs4_fl_calc_j_index(lseg, req_offset(req));
 	i = select_bucket_index(fl, j);
+	spin_lock(cinfo->lock);
 	buckets = cinfo->ds->buckets;
 	list = &buckets[i].written;
 	if (list_empty(list)) {
@@ -1080,6 +1081,7 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	}
 	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 	cinfo->ds->nwritten++;
+	spin_unlock(cinfo->lock);
 	return list;
 }
 
@@ -1176,6 +1178,7 @@ transfer_commit_list(struct list_head *src, struct list_head *dst,
 	return ret;
 }
 
+/* Note called with cinfo->lock held. */
 static int
 filelayout_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 			       struct nfs_commit_info *cinfo,
@@ -1220,15 +1223,18 @@ static void filelayout_recover_commit_reqs(struct list_head *dst,
 					   struct nfs_commit_info *cinfo)
 {
 	struct pnfs_commit_bucket *b;
+	struct pnfs_layout_segment *freeme;
 	int i;
 
+restart:
 	spin_lock(cinfo->lock);
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
 		if (transfer_commit_list(&b->written, dst, cinfo, 0)) {
-			spin_unlock(cinfo->lock);
-			pnfs_put_lseg(b->wlseg);
+			freeme = b->wlseg;
 			b->wlseg = NULL;
-			spin_lock(cinfo->lock);
+			spin_unlock(cinfo->lock);
+			pnfs_put_lseg(freeme);
+			goto restart;
 		}
 	}
 	cinfo->ds->nwritten = 0;
@@ -1243,6 +1249,7 @@ alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 	struct nfs_commit_data *data;
 	int i, j;
 	unsigned int nreq = 0;
+	struct pnfs_layout_segment *freeme;
 
 	fl_cinfo = cinfo->ds;
 	bucket = fl_cinfo->buckets;
@@ -1253,8 +1260,10 @@ alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 		if (!data)
 			break;
 		data->ds_commit_index = i;
+		spin_lock(cinfo->lock);
 		data->lseg = bucket->clseg;
 		bucket->clseg = NULL;
+		spin_unlock(cinfo->lock);
 		list_add(&data->pages, list);
 		nreq++;
 	}
@@ -1264,8 +1273,11 @@ alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 		if (list_empty(&bucket->committing))
 			continue;
 		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
-		pnfs_put_lseg(bucket->clseg);
+		spin_lock(cinfo->lock);
+		freeme = bucket->clseg;
 		bucket->clseg = NULL;
+		spin_unlock(cinfo->lock);
+		pnfs_put_lseg(freeme);
 	}
 	/* Caller will clean up entries put on list */
 	return nreq;
-- 
1.8.5.2 (Apple Git-48)

