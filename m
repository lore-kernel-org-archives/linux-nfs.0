Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35905 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965557AbeF0SSw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2018 14:18:52 -0400
Received: by mail-io0-f196.google.com with SMTP id k3-v6so2774347iog.3
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 11:18:51 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([50.105.87.45])
        by smtp.gmail.com with ESMTPSA id x5-v6sm2105233ioa.65.2018.06.27.11.18.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 11:18:50 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] pNFS: Don't discard layout segments that are marked for return
Date: Wed, 27 Jun 2018 14:18:24 -0400
Message-Id: <20180627181828.27680-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there are layout segments that are marked for return, then we need
to ensure that pnfs_mark_matching_lsegs_return() does not just
silently discard them, but it should tell the caller that there is a
layoutreturn scheduled.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c | 21 ++++++++++++---------
 fs/nfs/pnfs.c          | 34 +++++++++++++++++++++++++++-------
 2 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 64c214fb9da6..af2322256aa4 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -283,19 +283,22 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto unlock;
 	}
 
-	if (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
+	switch (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
 				&args->cbl_range,
 				be32_to_cpu(args->cbl_stateid.seqid))) {
+	case 0:
+	case -EBUSY:
+		/* There are layout segments that need to be returned */
 		rv = NFS4_OK;
-		goto unlock;
-	}
-
-	/* Embrace your forgetfulness! */
-	rv = NFS4ERR_NOMATCHING_LAYOUT;
+		break;
+	case -ENOENT:
+		/* Embrace your forgetfulness! */
+		rv = NFS4ERR_NOMATCHING_LAYOUT;
 
-	if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
-		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
-			&args->cbl_range);
+		if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
+			NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
+				&args->cbl_range);
+		}
 	}
 unlock:
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bcc3addec3c5..17776ef734d7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2238,15 +2238,31 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	return ERR_PTR(-EAGAIN);
 }
 
+static int
+mark_lseg_invalid_or_return(struct pnfs_layout_segment *lseg,
+		struct list_head *tmp_list)
+{
+	if (!mark_lseg_invalid(lseg, tmp_list))
+		return 0;
+	pnfs_cache_lseg_for_layoutreturn(lseg->pls_layout, lseg);
+	return 1;
+}
+
 /**
  * pnfs_mark_matching_lsegs_return - Free or return matching layout segments
  * @lo: pointer to layout header
  * @tmp_list: list header to be used with pnfs_free_lseg_list()
  * @return_range: describe layout segment ranges to be returned
+ * @seq: stateid seqid to match
  *
  * This function is mainly intended for use by layoutrecall. It attempts
  * to free the layout segment immediately, or else to mark it for return
  * as soon as its reference count drops to zero.
+ *
+ * Returns
+ * - 0: a layoutreturn needs to be scheduled.
+ * - EBUSY: there are layout segment that are still in use.
+ * - ENOENT: there are no layout segments that need to be returned.
  */
 int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
@@ -2259,9 +2275,6 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
-	if (list_empty(&lo->plh_segs))
-		return 0;
-
 	assert_spin_locked(&lo->plh_inode->i_lock);
 
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
@@ -2271,16 +2284,23 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				lseg, lseg->pls_range.iomode,
 				lseg->pls_range.offset,
 				lseg->pls_range.length);
-			if (mark_lseg_invalid(lseg, tmp_list))
+			if (mark_lseg_invalid_or_return(lseg, tmp_list))
 				continue;
 			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
 		}
 
-	if (remaining)
+	if (remaining) {
 		pnfs_set_plh_return_info(lo, return_range->iomode, seq);
+		return -EBUSY;
+	}
 
-	return remaining;
+	if (!list_empty(&lo->plh_return_segs)) {
+		pnfs_set_plh_return_info(lo, return_range->iomode, seq);
+		return 0;
+	}
+
+	return -ENOENT;
 }
 
 void pnfs_error_mark_layout_for_return(struct inode *inode,
@@ -2305,7 +2325,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
 	 * for how it works.
 	 */
-	if (!pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, &range, 0)) {
+	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, &range, 0) != -EBUSY) {
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
 
-- 
2.17.1

