Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33208 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755448AbbHYXxv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 19:53:51 -0400
Received: by iods203 with SMTP id s203so207097544iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 16:53:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4.1/pnfs: Allow pNFS device drivers to customise layout segment insertion
Date: Tue, 25 Aug 2015 19:53:45 -0400
Message-Id: <1440546826-51922-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440546826-51922-2-git-send-email-trond.myklebust@primarydata.com>
References: <1440546826-51922-1-git-send-email-trond.myklebust@primarydata.com>
 <1440546826-51922-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is needed in order to allow merging of contiguous layout segments,
and also to correct the ordering of layouts for those device drivers that
don't necessarily want to place the read-write layouts first.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/pnfs.h | 11 +++++++++++
 2 files changed, 61 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 68cc4b169769..914c1daf08df 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1188,16 +1188,41 @@ pnfs_lseg_range_cmp(const struct pnfs_layout_range *l1,
 	return (int)(l1->iomode == IOMODE_READ) - (int)(l2->iomode == IOMODE_READ);
 }
 
-static void
-pnfs_layout_insert_lseg(struct pnfs_layout_hdr *lo,
-		   struct pnfs_layout_segment *lseg)
+static bool
+pnfs_lseg_range_is_after(const struct pnfs_layout_range *l1,
+		const struct pnfs_layout_range *l2)
+{
+	return pnfs_lseg_range_cmp(l1, l2) > 0;
+}
+
+static bool
+pnfs_lseg_no_merge(struct pnfs_layout_segment *lseg,
+		struct pnfs_layout_segment *old)
+{
+	return false;
+}
+
+void
+pnfs_generic_layout_insert_lseg(struct pnfs_layout_hdr *lo,
+		   struct pnfs_layout_segment *lseg,
+		   bool (*is_after)(const struct pnfs_layout_range *,
+			   const struct pnfs_layout_range *),
+		   bool (*do_merge)(struct pnfs_layout_segment *,
+			   struct pnfs_layout_segment *),
+		   struct list_head *free_me)
 {
-	struct pnfs_layout_segment *lp;
+	struct pnfs_layout_segment *lp, *tmp;
 
 	dprintk("%s:Begin\n", __func__);
 
-	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
-		if (pnfs_lseg_range_cmp(&lseg->pls_range, &lp->pls_range) > 0)
+	list_for_each_entry_safe(lp, tmp, &lo->plh_segs, pls_list) {
+		if (test_bit(NFS_LSEG_VALID, &lp->pls_flags) == 0)
+			continue;
+		if (do_merge(lseg, lp)) {
+			mark_lseg_invalid(lp, free_me);
+			continue;
+		}
+		if (is_after(&lseg->pls_range, &lp->pls_range))
 			continue;
 		list_add_tail(&lseg->pls_list, &lp->pls_list);
 		dprintk("%s: inserted lseg %p "
@@ -1219,6 +1244,24 @@ out:
 
 	dprintk("%s:Return\n", __func__);
 }
+EXPORT_SYMBOL_GPL(pnfs_generic_layout_insert_lseg);
+
+static void
+pnfs_layout_insert_lseg(struct pnfs_layout_hdr *lo,
+		   struct pnfs_layout_segment *lseg,
+		   struct list_head *free_me)
+{
+	struct inode *inode = lo->plh_inode;
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
+
+	if (ld->add_lseg != NULL)
+		ld->add_lseg(lo, lseg, free_me);
+	else
+		pnfs_generic_layout_insert_lseg(lo, lseg,
+				pnfs_lseg_range_is_after,
+				pnfs_lseg_no_merge,
+				free_me);
+}
 
 static struct pnfs_layout_hdr *
 alloc_init_layout_hdr(struct inode *ino,
@@ -1311,8 +1354,6 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 			ret = pnfs_get_lseg(lseg);
 			break;
 		}
-		if (lseg->pls_range.offset > range->offset)
-			break;
 	}
 
 	dprintk("%s:Return lseg %p ref %d\n",
@@ -1637,7 +1678,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 
 	pnfs_get_lseg(lseg);
-	pnfs_layout_insert_lseg(lo, lseg);
+	pnfs_layout_insert_lseg(lo, lseg, &free_me);
 
 	if (res->return_on_close)
 		set_bit(NFS_LSEG_ROC, &lseg->pls_flags);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4df87ef3dccc..869069d8b996 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -128,6 +128,9 @@ struct pnfs_layoutdriver_type {
 
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
+	void (*add_lseg) (struct pnfs_layout_hdr *layoutid,
+			struct pnfs_layout_segment *lseg,
+			struct list_head *free_me);
 
 	void (*return_range) (struct pnfs_layout_hdr *lo,
 			      struct pnfs_layout_range *range);
@@ -285,6 +288,14 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       gfp_t gfp_flags);
 void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo);
 
+void pnfs_generic_layout_insert_lseg(struct pnfs_layout_hdr *lo,
+		   struct pnfs_layout_segment *lseg,
+		   bool (*is_after)(const struct pnfs_layout_range *lseg_range,
+			   const struct pnfs_layout_range *old),
+		   bool (*do_merge)(struct pnfs_layout_segment *lseg,
+			   struct pnfs_layout_segment *old),
+		   struct list_head *free_me);
+
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
 int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *);
 int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
-- 
2.4.3

