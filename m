Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35003 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753817AbcLAWT0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:26 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so4680138ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/26] pNFS: Fix a deadlock between read resends and layoutreturn
Date: Thu,  1 Dec 2016 17:18:57 -0500
Message-Id: <20161201221922.15657-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-1-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must not call nfs_pageio_init_read() on a new nfs_pageio_descriptor
while holding a reference to a layout segment, as that can deadlock
pnfs_update_layout().

Fixes: d67ae825a59d6 ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v4.0+
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++++
 fs/nfs/pnfs.c                          | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 98ace127bf86..a5c38889e7ae 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -28,6 +28,9 @@
 
 static struct group_info	*ff_zero_group;
 
+static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
+		struct nfs_pgio_header *hdr);
+
 static struct pnfs_layout_hdr *
 ff_layout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 {
@@ -1293,6 +1296,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 					hdr->pgio_mirror_idx + 1,
 					&hdr->pgio_mirror_idx))
 			goto out_eagain;
+		ff_layout_read_record_layoutstats_done(task, hdr);
 		pnfs_read_resend_pnfs(hdr);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 259ef85f435a..206d560c74f4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2286,6 +2286,10 @@ void pnfs_read_resend_pnfs(struct nfs_pgio_header *hdr)
 	struct nfs_pageio_descriptor pgio;
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		/* Prevent deadlocks with layoutreturn! */
+		pnfs_put_lseg(hdr->lseg);
+		hdr->lseg = NULL;
+
 		nfs_pageio_init_read(&pgio, hdr->inode, false,
 					hdr->completion_ops);
 		hdr->task.tk_status = nfs_pageio_resend(&pgio, hdr);
-- 
2.9.3

