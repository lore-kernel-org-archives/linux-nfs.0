From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: pnfs-obj: use new alloc/free_layout API
Date: Mon, 12 Jul 2010 21:43:04 +0300
Message-ID: <1278960184-32320-1-git-send-email-bhalevy@panasas.com>
References: <4C3B61FC.90306@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:10408 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753891Ab0GLSnL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 14:43:11 -0400
In-Reply-To: <4C3B61FC.90306@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |   14 +++++++-------
 fs/nfs/objlayout/objlayout.h |   10 +++++++++-
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index c380bf6..1381c60 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -49,7 +49,7 @@ struct pnfs_client_operations *pnfs_client_ops;
 /*
  * Create a objlayout layout structure for the given inode and return it.
  */
-static void *
+static struct pnfs_layout_type *
 objlayout_alloc_layout(struct inode *inode)
 {
 	struct objlayout *objlay;
@@ -60,16 +60,16 @@ objlayout_alloc_layout(struct inode *inode)
 		INIT_LIST_HEAD(&objlay->err_list);
 	}
 	dprintk("%s: Return %p\n", __func__, objlay);
-	return objlay;
+	return &objlay->pnfs_layout;
 }
 
 /*
  * Free an objlayout layout structure
  */
 static void
-objlayout_free_layout(void *p)
+objlayout_free_layout(struct pnfs_layout_type *lo)
 {
-	struct objlayout *objlay = p;
+	struct objlayout *objlay = OBJLAYOUT(lo);
 
 	dprintk("%s: objlay %p\n", __func__, objlay);
 
@@ -232,7 +232,7 @@ objlayout_iodone(struct objlayout_io_state *state)
 	if (likely(state->status >= 0)) {
 		objlayout_free_io_state(state);
 	} else {
-		struct objlayout *objlay = PNFS_LD_DATA(state->lseg->layout);
+		struct objlayout *objlay = OBJLAYOUT(state->lseg->layout);
 
 		spin_lock(&objlay->lock);
 		objlay->delta_space_valid = OBJ_DSU_INVALID;
@@ -485,7 +485,7 @@ objlayout_encode_layoutcommit(struct pnfs_layout_type *pnfslay,
 			      struct xdr_stream *xdr,
 			      const struct pnfs_layoutcommit_arg *args)
 {
-	struct objlayout *objlay = PNFS_LD_DATA(pnfslay);
+	struct objlayout *objlay = OBJLAYOUT(pnfslay);
 	struct pnfs_osd_layoutupdate lou;
 	__be32 *start;
 
@@ -621,7 +621,7 @@ objlayout_encode_layoutreturn(struct pnfs_layout_type *pnfslay,
 			      struct xdr_stream *xdr,
 			      const struct nfs4_pnfs_layoutreturn_arg *args)
 {
-	struct objlayout *objlay = PNFS_LD_DATA(pnfslay);
+	struct objlayout *objlay = OBJLAYOUT(pnfslay);
 	struct objlayout_io_state *state, *tmp;
 	__be32 *start, *uninitialized_var(last_xdr);
 
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 248a562..8bc3c94 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -59,6 +59,8 @@ struct objlayout_segment {
  * per-inode layout
  */
 struct objlayout {
+	struct pnfs_layout_type pnfs_layout;
+
 	 /* for layout_commit */
 	enum osd_delta_space_valid_enum {
 		OBJ_DSU_INIT = 0,
@@ -72,6 +74,12 @@ struct objlayout {
 	struct list_head err_list;
 };
 
+static inline struct objlayout *
+OBJLAYOUT(struct pnfs_layout_type *lo)
+{
+	return container_of(lo, struct objlayout, pnfs_layout);
+}
+
 /*
  * per-I/O operation state
  * embedded in objects provider io_state data structure
@@ -131,7 +139,7 @@ extern void objlayout_io_set_result(struct objlayout_io_state *state,
 static inline void
 objlayout_add_delta_space_used(struct objlayout_io_state *state, s64 space_used)
 {
-	struct objlayout *objlay = PNFS_LD_DATA(state->lseg->layout);
+	struct objlayout *objlay = OBJLAYOUT(state->lseg->layout);
 
 	/* If one of the I/Os errored out and the delta_space_used was
 	 * invalid we render the complete report as invalid. Protocol mandate
-- 
1.7.1.1

