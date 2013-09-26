Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:64211 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSlr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:47 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so4616997qaq.16
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:47 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 28/49] pnfsd: support layout segment merging
Date: Thu, 26 Sep 2013 14:41:45 -0400
Message-Id: <1380220905-13964-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 386afa3..8d16b85 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -364,6 +364,66 @@ struct super_block *
 	return id;
 }
 
+/*
+ * are two octet ranges overlapping or adjacent?
+ */
+static bool
+lo_seg_mergeable(struct nfsd4_layout_seg *l1, struct nfsd4_layout_seg *l2)
+{
+	u64 start1 = l1->offset;
+	u64 end1 = end_offset(start1, l1->length);
+	u64 start2 = l2->offset;
+	u64 end2 = end_offset(start2, l2->length);
+
+	/* is end1 == start2 ranges are adjacent */
+	return (end2 >= start1) && (end1 >= start2);
+}
+
+static void
+extend_layout(struct nfsd4_layout_seg *lo, struct nfsd4_layout_seg *lg)
+{
+	u64 lo_start = lo->offset;
+	u64 lo_end = end_offset(lo_start, lo->length);
+	u64 lg_start = lg->offset;
+	u64 lg_end = end_offset(lg_start, lg->length);
+
+	/* lo already covers lg? */
+	if (lo_start <= lg_start && lg_end <= lo_end)
+		return;
+
+	/* extend start offset */
+	if (lo_start > lg_start)
+		lo_start = lg_start;
+
+	/* extend end offset */
+	if (lo_end < lg_end)
+		lo_end = lg_end;
+
+	lo->offset = lo_start;
+	lo->length = (lo_end == NFS4_MAX_UINT64) ?
+		      lo_end : lo_end - lo_start;
+}
+
+static bool
+merge_layout(struct nfs4_layout_state *ls, struct nfsd4_layout_seg *seg)
+{
+	bool ret = false;
+	struct nfs4_layout *lp;
+
+	spin_lock(&layout_lock);
+	list_for_each_entry (lp, &ls->ls_layouts, lo_perstate)
+		if (lp->lo_seg.layout_type == seg->layout_type &&
+		    lp->lo_seg.clientid == seg->clientid &&
+		    lp->lo_seg.iomode == seg->iomode &&
+		    (ret = lo_seg_mergeable(&lp->lo_seg, seg))) {
+			extend_layout(&lp->lo_seg, seg);
+			break;
+		}
+	spin_unlock(&layout_lock);
+
+	return ret;
+}
+
 __be32
 nfs4_pnfs_get_layout(struct svc_rqst *rqstp,
 		     struct nfsd4_pnfs_layoutget *lgp,
@@ -373,6 +433,7 @@ struct super_block *
 	__be32 nfserr;
 	struct inode *ino = lgp->lg_fhp->fh_dentry->d_inode;
 	struct super_block *sb = ino->i_sb;
+	int can_merge;
 	struct nfs4_file *fp;
 	struct nfs4_client *clp;
 	struct nfs4_layout *lp = NULL;
@@ -412,6 +473,9 @@ struct super_block *
 		goto out;
 	}
 
+	can_merge = sb->s_pnfs_op->can_merge_layouts != NULL &&
+		    sb->s_pnfs_op->can_merge_layouts(lgp->lg_seg.layout_type);
+
 	nfs4_lock_state();
 	fp = find_alloc_file(ino, lgp->lg_fhp);
 	clp = find_confirmed_client((clientid_t *)&lgp->lg_seg.clientid, true,
@@ -430,6 +494,9 @@ struct super_block *
 	if (nfserr)
 		goto out_unlock;
 
+	/* pre-alloc layout in case we can't merge after we call
+	 * the file system
+	 */
 	lp = alloc_layout();
 	if (!lp) {
 		nfserr = nfserr_layouttrylater;
@@ -486,6 +553,14 @@ struct super_block *
 	lgp->lg_seg = res.lg_seg;
 	lgp->lg_roc = res.lg_return_on_close;
 
+	/* SUCCESS!
+	 * Can the new layout be merged into an existing one?
+	 * If so, free unused layout struct
+	 */
+	if (can_merge && merge_layout(ls, &res.lg_seg))
+		goto out_freelayout;
+
+	/* Can't merge, so let's initialize this new layout */
 	init_layout(lp, ls, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
 out_unlock:
 	if (ls)
-- 
1.8.3.1

