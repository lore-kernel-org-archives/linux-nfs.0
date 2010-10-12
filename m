Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51392 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069Ab0JMSnR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 14:43:17 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] pnfs_submit: fix layoutreturn layout stateid processing
Date: Tue, 12 Oct 2010 06:13:27 -0400
Message-Id: <1286878408-10287-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Add missing layoutreturn stateid update.
This patch also enforces the following rfc 5661 requirement:

section 12.5.4
   "For LAYOUTRETURN results, the client MUST delete the range from its
   record of what ranges of the file's layout it had before using the
   seqid."

Reported-by: P.B.Shelley <shelleypt@gmail.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   10 +++++-----
 fs/nfs/pnfs.c     |    7 +++----
 fs/nfs/pnfs.h     |    3 ++-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7727f59..4c56d9b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5678,11 +5678,11 @@ static void nfs4_layoutreturn_release(void *calldata)
 	dprintk("--> %s return_type %d lo %p\n", __func__,
 		lrp->args.return_type, lo);
 
-	if (lrp->args.return_type == RETURN_FILE) {
-		if (!lrp->res.lrs_present)
-			pnfs_invalidate_layout_stateid(lo);
-		pnfs_layoutreturn_release(lo, &lrp->args.range);
-	}
+	pnfs_layoutreturn_release(lo, &lrp->args.range);
+	if (!lrp->res.lrs_present)
+		pnfs_invalidate_layout_stateid(lo);
+	else
+		pnfs_set_layout_stateid(lo, &lrp->res.stateid);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index eb4dfdf..124d3ca 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -400,8 +400,7 @@ pnfs_layoutreturn_release(struct pnfs_layout_hdr *lo,
 	LIST_HEAD(tmp_list);
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	if (range)
-		pnfs_clear_lseg_list(lo, &tmp_list, range);
+	pnfs_clear_lseg_list(lo, &tmp_list, range);
 	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
@@ -460,7 +459,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
  *
  * lo->stateid could be the open stateid, in which case we just use what given.
  */
-static void
+void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			const nfs4_stateid *new)
 {
@@ -625,7 +624,7 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (lrp == NULL) {
 		if (lo && (type == RETURN_FILE))
-			pnfs_layoutreturn_release(lo, NULL);
+			put_layout_hdr(lo->inode);
 		goto out;
 	}
 	lrp->args.reclaim = 0;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 235709e..3fd2bc3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -210,7 +210,8 @@ void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout_hdr(struct inode *inode);
 void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			     struct nfs4_state *open_state);
-
+void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
+				    const nfs4_stateid *new);
 
 static inline bool
 has_layout(struct nfs_inode *nfsi)
-- 
1.6.6

