Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35282 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237AbbHYBnL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 21:43:11 -0400
Received: by iodt126 with SMTP id t126so170659081iod.2
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 18:43:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv4.1/flexfiles: Remove mirror backpointer to lseg.
Date: Mon, 24 Aug 2015 21:43:04 -0400
Message-Id: <1440466986-36826-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440466986-36826-1-git-send-email-trond.myklebust@primarydata.com>
References: <1440466986-36826-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we start sharing mirrors between several lsegs, we won't be able to
keep it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 25 ++++++++++++-------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  1 -
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 62de0b8038c8..f3efff640989 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -290,7 +290,6 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		}
 
 		fls->mirror_array[i]->ds_count = ds_count;
-		fls->mirror_array[i]->lseg = &fls->generic_hdr;
 
 		/* deviceid */
 		rc = decode_deviceid(&stream, &devid);
@@ -513,7 +512,8 @@ nfs4_ff_layout_stat_io_update_completed(struct nfs4_ff_layoutstat *layoutstat,
 }
 
 static void
-nfs4_ff_layout_stat_io_start_read(struct nfs4_ff_layout_mirror *mirror,
+nfs4_ff_layout_stat_io_start_read(struct inode *inode,
+		struct nfs4_ff_layout_mirror *mirror,
 		__u64 requested, ktime_t now)
 {
 	bool report;
@@ -524,8 +524,7 @@ nfs4_ff_layout_stat_io_start_read(struct nfs4_ff_layout_mirror *mirror,
 	spin_unlock(&mirror->lock);
 
 	if (report)
-		pnfs_report_layoutstat(mirror->lseg->pls_layout->plh_inode,
-				GFP_KERNEL);
+		pnfs_report_layoutstat(inode, GFP_KERNEL);
 }
 
 static void
@@ -542,7 +541,8 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 }
 
 static void
-nfs4_ff_layout_stat_io_start_write(struct nfs4_ff_layout_mirror *mirror,
+nfs4_ff_layout_stat_io_start_write(struct inode *inode,
+		struct nfs4_ff_layout_mirror *mirror,
 		__u64 requested, ktime_t now)
 {
 	bool report;
@@ -553,8 +553,7 @@ nfs4_ff_layout_stat_io_start_write(struct nfs4_ff_layout_mirror *mirror,
 	spin_unlock(&mirror->lock);
 
 	if (report)
-		pnfs_report_layoutstat(mirror->lseg->pls_layout->plh_inode,
-				GFP_NOIO);
+		pnfs_report_layoutstat(inode, GFP_NOIO);
 }
 
 static void
@@ -1098,7 +1097,7 @@ ff_layout_reset_to_mds(struct pnfs_layout_segment *lseg, int idx)
 static int ff_layout_read_prepare_common(struct rpc_task *task,
 					 struct nfs_pgio_header *hdr)
 {
-	nfs4_ff_layout_stat_io_start_read(
+	nfs4_ff_layout_stat_io_start_read(hdr->inode,
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
 			hdr->args.count,
 			task->tk_start);
@@ -1285,7 +1284,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 static int ff_layout_write_prepare_common(struct rpc_task *task,
 					  struct nfs_pgio_header *hdr)
 {
-	nfs4_ff_layout_stat_io_start_write(
+	nfs4_ff_layout_stat_io_start_write(hdr->inode,
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
 			hdr->args.count,
 			task->tk_start);
@@ -1367,7 +1366,7 @@ static void ff_layout_write_count_stats(struct rpc_task *task, void *data)
 static void ff_layout_commit_prepare_common(struct rpc_task *task,
 		struct nfs_commit_data *cdata)
 {
-	nfs4_ff_layout_stat_io_start_write(
+	nfs4_ff_layout_stat_io_start_write(cdata->inode,
 			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
 			0, task->tk_start);
 }
@@ -1912,8 +1911,8 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 		devinfo->layout_type = LAYOUT_FLEX_FILES;
 		devinfo->layoutstats_encode = ff_layout_encode_layoutstats;
 		devinfo->layout_private = mirror;
-		/* lseg refcount put in cleanup_layoutstats */
-		pnfs_get_lseg(pls);
+		/* mirror refcount put in cleanup_layoutstats */
+		atomic_inc(&mirror->ref);
 
 		++(*dev_count);
 	}
@@ -1965,7 +1964,7 @@ ff_layout_cleanup_layoutstats(struct nfs42_layoutstat_data *data)
 	for (i = 0; i < data->args.num_dev; i++) {
 		mirror = data->args.devinfo[i].layout_private;
 		data->args.devinfo[i].layout_private = NULL;
-		pnfs_put_lseg(mirror->lseg);
+		ff_layout_put_mirror(mirror);
 	}
 }
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 26b8258e256f..fe9d3ff7cf85 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -67,7 +67,6 @@ struct nfs4_ff_layoutstat {
 };
 
 struct nfs4_ff_layout_mirror {
-	struct pnfs_layout_segment	*lseg; /* back pointer */
 	u32				ds_count;
 	u32				efficiency;
 	struct nfs4_ff_layout_ds	*mirror_ds;
-- 
2.4.3

