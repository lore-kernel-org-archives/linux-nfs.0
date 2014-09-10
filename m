Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:50995 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbaIJPV1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 11:21:27 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRji2-00007C-Cu
	for linux-nfs@vger.kernel.org; Wed, 10 Sep 2014 15:21:26 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] pnfs: add return_range method
Date: Wed, 10 Sep 2014 08:23:31 -0700
Message-Id: <1410362617-28018-4-git-send-email-hch@lst.de>
In-Reply-To: <1410362617-28018-1-git-send-email-hch@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a layout driver keeps per-inode state outside of the layout segments it
needs to be notified of any layout returns or recalls on an inode, and not
just about the freeing of layout segments.  Add a method to acomplish this,
which will allow the block layout driver to handle the case of truncated
and re-expanded files properly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/callback_proc.c | 12 +++++++++---
 fs/nfs/pnfs.c          | 10 ++++++++++
 fs/nfs/pnfs.h          |  3 +++
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 0d26951..56bd0ea 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -181,10 +181,16 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
-					&args->cbl_range))
+					&args->cbl_range)) {
 		rv = NFS4ERR_DELAY;
-	else
-		rv = NFS4ERR_NOMATCHING_LAYOUT;
+		goto unlock;
+	}
+
+	if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
+		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
+			&args->cbl_range);
+	}
+unlock:
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ce5d1ea..76de7f5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -857,6 +857,16 @@ _pnfs_return_layout(struct inode *ino)
 	empty = list_empty(&lo->plh_segs);
 	pnfs_clear_layoutcommit(ino, &tmp_list);
 	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
+
+	if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
+		struct pnfs_layout_range range = {
+			.iomode		= IOMODE_ANY,
+			.offset		= 0,
+			.length		= NFS4_MAX_UINT64,
+		};
+		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo, &range);
+	}
+
 	/* Don't send a LAYOUTRETURN if list was initially empty */
 	if (empty) {
 		spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a4c530e..2c24942 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,6 +94,9 @@ struct pnfs_layoutdriver_type {
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
+	void (*return_range) (struct pnfs_layout_hdr *lo,
+			      struct pnfs_layout_range *range);
+
 	/* test for nfs page cache coalescing */
 	const struct nfs_pageio_ops *pg_read_ops;
 	const struct nfs_pageio_ops *pg_write_ops;
-- 
1.9.1

