From: andros@netapp.com
Subject: [PATCH 2/2] pnfs: fix pnfs_commit update_layout range
Date: Thu, 22 Oct 2009 09:15:43 -0400
Message-ID: <1256217343-6991-3-git-send-email-andros@netapp.com>
References: <1256217343-6991-1-git-send-email-andros@netapp.com>
 <1256217343-6991-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45899 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915AbZJVNPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2009 09:15:55 -0400
In-Reply-To: <1256217343-6991-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Whole file semantics are different for COMMIT (0,0) and layouts
(0,NFS4_MAX_UINT64).

Reported-by: Alexandros Batsakis <batsakis@netapp.com>

Translate COMMIT whole file semantics to LAYOUTGET whole file semantics.

The LAYOUTGET request uses u64 length, change pnfs_update_layout() count field
type to match.

Replace PAGE_SIZE with PAGE_CACHE_SIZE and PAGE_CACHE_SHIFT.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   36 ++++++++++++++++++++++++++++--------
 fs/nfs/pnfs.h |    2 +-
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 674d8b7..ffed515 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1052,7 +1052,7 @@ void drain_layoutreturns(struct pnfs_layout_type *lo)
 int
 pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
-		   size_t count,
+		   u64 count,
 		   loff_t pos,
 		   enum pnfs_iomode iomode,
 		   struct pnfs_layout_segment **lsegpp)
@@ -1518,17 +1518,29 @@ pnfs_update_layout_commit(struct inode *inode,
 {
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	struct nfs_page *nfs_page = nfs_list_entry(head->next);
+	u64 count;
+	loff_t start;
 	int status;
 
 	dprintk("--> %s inode %p layout range: %Zd@%llu\n", __func__, inode,
-		(size_t)(npages * PAGE_SIZE),
-		(u64)((u64)idx_start * PAGE_SIZE));
+		(size_t)(npages * PAGE_CACHE_SIZE),
+		(u64)((u64)idx_start << PAGE_CACHE_SHIFT));
 
 	if (!pnfs_enabled_sb(nfss))
 		return;
+
+	/* COMMIT indicates the whole file with offset = count = 0
+	 * whereas layout segments indicate whole file with offset = 0,
+	 * count = NFS4_MAX_UINT64.
+	 */
+	count = (size_t)npages * PAGE_CACHE_SIZE;
+	start = (loff_t)idx_start <<  PAGE_CACHE_SHIFT;
+	if (start == 0 && count == 0)
+		count = NFS4_MAX_UINT64;
+
 	status = pnfs_update_layout(inode, nfs_page->wb_context,
-				(size_t)npages * PAGE_SIZE,
-				(loff_t)idx_start * PAGE_SIZE,
+				count,
+				start,
 				IOMODE_RW,
 				NULL);
 	dprintk("%s  virt update status %d\n", __func__, status);
@@ -2057,6 +2069,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	struct nfs_page *first, *last, *p;
 	int npages;
 	enum pnfs_try_status trypnfs;
+	u64 count;
 
 	dprintk("%s: Begin\n", __func__);
 
@@ -2069,6 +2082,15 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 		last = p;
 		npages++;
 	}
+	/* COMMIT indicates the whole file with offset = count = 0
+	 * whereas layout segments indicate whole file with offset = 0,
+	 * count = NFS4_MAX_UINT64.
+	 */
+	count = ((npages - 1) << PAGE_CACHE_SHIFT) + first->wb_bytes +
+		(first != last) ? last->wb_bytes : 0;
+	if (first->wb_offset == 0 && count == 0)
+		count = NFS4_MAX_UINT64;
+
 	/* FIXME: we really ought to keep the layout segment that we used
 	   to write the page around for committing it and never ask for a
 	   new one.  If it was recalled we better commit the data first
@@ -2076,9 +2098,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	   either with a new layout or to the MDS */
 	result = pnfs_update_layout(data->inode,
 				    NULL,
-				    ((npages - 1) << PAGE_CACHE_SHIFT) +
-				     first->wb_bytes +
-				     (first != last) ? last->wb_bytes : 0,
+				    count,
 				    first->wb_offset,
 				    IOMODE_RW,
 				    &lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b06fde4..2f5dae4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -34,7 +34,7 @@ extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp);
 extern const nfs4_stateid zero_stateid;
 
 int pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-	size_t count, loff_t pos, enum pnfs_iomode access_type,
+	u64 count, loff_t pos, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
-- 
1.6.2.5

