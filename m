Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45771 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbaHGHVf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:35 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/17] pnfs: add return_range method
Date: Thu,  7 Aug 2014 09:23:38 +0200
Message-Id: <1407396229-4785-7-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a layout driver keeps per-inode state outside of the layout segments it
needs to be notified of any layout returns or recalls on an inode, and not
just about the freeing of layout segments.  Add a method to acomplish this,
which will allow the block layout driver to handle the case of truncated
and re-expanded files properly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/callback_proc.c |  6 +++++-
 fs/nfs/pnfs.c          | 10 ++++++++++
 fs/nfs/pnfs.h          |  3 +++
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index bf017b0..86541e0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -179,8 +179,12 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 			&args->cbl_range)) {
 		need_commit = true;
 		rv = NFS4ERR_DELAY;
+	} else {
+		if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
+			NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
+				&args->cbl_range);
+		}
 	}
-
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 22183fc..13b1406 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -856,6 +856,16 @@ _pnfs_return_layout(struct inode *ino)
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
index 882387c..cab5259 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -93,6 +93,9 @@ struct pnfs_layoutdriver_type {
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

