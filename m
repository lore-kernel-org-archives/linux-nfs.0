Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52883 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756717Ab1FGR06 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:58 -0400
Date: Tue, 7 Jun 2011 13:26:56 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 09/88] pnfs: HACK: adjust eof handling
Message-ID: <7609e41fa37bda125ad7a1502c7d237f6c84569e.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

This needs to be changed, but will require a major rewrite
of the block layout's IO code.  Including it here so I can
get some current code into the tree.

To deal with multipage blocks, the block driver sometimes needs to
write pages of zeros past the EOF without advancing the eof to the
written page.  This gives a minimal infrastructure to allow that to happen.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.h  |   14 ++++++++++++++
 fs/nfs/write.c |    3 ++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ac536bc..b50cf3a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -56,6 +56,7 @@ enum pnfs_try_status {
 
 struct pnfs_fsdata {
 	struct pnfs_layout_segment *lseg;
+	int bypass_eof;
 	void *private;
 };
 
@@ -313,6 +314,13 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
 		put_lseg(req->wb_commit_lseg);
 }
 
+static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
+			       struct pnfs_fsdata *fsdata)
+{
+	return !fsdata  || ((struct pnfs_layout_segment *)fsdata == lseg) ||
+		!fsdata->bypass_eof;
+}
+
 /* Should the pNFS client commit and return the layout upon a setattr */
 static inline bool
 pnfs_ld_layoutret_on_setattr(struct inode *inode)
@@ -427,6 +435,12 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	return NULL;
 }
 
+static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
+			       struct pnfs_fsdata *fsdata)
+{
+	return 1;
+}
+
 static inline enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fc36db8..75e2a6b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -683,7 +683,8 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 	/* Update file length */
-	nfs_grow_file(page, offset, count);
+	if (pnfs_grow_ok(lseg, fsdata))
+		nfs_grow_file(page, offset, count);
 	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
 	nfs_mark_request_dirty(req);
 	nfs_clear_page_tag_locked(req);
-- 
1.7.4.1

