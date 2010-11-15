Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27488 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758023Ab0KOTBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 14:01:03 -0500
Received: from localhost.localdomain (vpn2ntap-136191.hq.netapp.com [10.58.56.111])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAFJ0f4e028248
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 11:00:43 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pnfs-submit: remove has_layout_to_return()
Date: Mon, 15 Nov 2010 14:00:37 -0500
Message-Id: <1289847638-12175-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289847638-12175-1-git-send-email-iisaman@netapp.com>
References: <1289847638-12175-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Refactoring _pnfs_return_layout(), the only caller of
has_layout_to_return(), allows us to remove it entirely in favor of
pnfs_clear_lseg_list().

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   34 ++++++----------------------------
 fs/nfs/pnfs.h |    2 +-
 2 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index eefa440..d06bf16 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -375,11 +375,13 @@ static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 	}
 }
 
-void
+/* Returns false if there was nothing to do, true otherwise */
+bool
 pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		     struct pnfs_layout_range *range)
 {
 	struct pnfs_layout_segment *lseg, *next;
+	bool rv = false;
 
 	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
 		__func__, lo, range->offset, range->length, range->iomode);
@@ -392,8 +394,10 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 				lseg, lseg->range.iomode, lseg->range.offset,
 				lseg->range.length);
 			mark_lseg_invalid(lseg, tmp_list);
+			rv = true;
 		}
 	dprintk("%s:Return\n", __func__);
+	return rv;
 }
 
 void
@@ -566,25 +570,6 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	return lseg;
 }
 
-static struct pnfs_layout_segment *
-has_layout_to_return(struct pnfs_layout_hdr *lo,
-		     struct pnfs_layout_range *range)
-{
-	struct pnfs_layout_segment *out = NULL, *lseg;
-	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
-		__func__, lo, range->offset, range->length, range->iomode);
-
-	assert_spin_locked(&lo->inode->i_lock);
-	list_for_each_entry(lseg, &lo->segs, fi_list)
-		if (should_free_lseg(&lseg->range, range)) {
-			out = lseg;
-			break;
-		}
-
-	dprintk("%s:Return lseg=%p\n", __func__, out);
-	return out;
-}
-
 void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
 				int notify_bit, atomic_t *notify_count,
@@ -726,7 +711,6 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_range arg;
 	LIST_HEAD(tmp_list);
-	struct pnfs_layout_segment *lseg, *tmp;
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
@@ -737,18 +721,12 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (lo && !has_layout_to_return(lo, &arg))
-		lo = NULL;
-	if (!lo) {
+	if (!lo || !pnfs_clear_lseg_list(lo, &tmp_list, &arg)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("%s: no layout segments to return\n", __func__);
 		goto out;
 	}
-
 	lo->plh_block_lgets++;
-	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
-		if (should_free_lseg(&lseg->range, &arg))
-			mark_lseg_invalid(lseg, &tmp_list);
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a124ad2..3314f64 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -222,7 +222,7 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
-void pnfs_clear_lseg_list(struct pnfs_layout_hdr *, struct list_head *tmp_list,
+bool pnfs_clear_lseg_list(struct pnfs_layout_hdr *, struct list_head *tmp_list,
 			  struct pnfs_layout_range *);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
-- 
1.7.2.1

