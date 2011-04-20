Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57231 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1DTR3Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:29:24 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 25/27] pnfs-obj: objlayout_encode_layoutcommit implementation
Date: Wed, 20 Apr 2011 20:29:22 +0300
Message-Id: <1303320562-21898-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

* Define API for io-engines to report delta_space_used in IOs
* Encode the osd-layout specific information of the layoutcommit
  XDR buffer.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[check for OBJ_DSU_INVALID in objlayout_add_delta_space_used under lock]
[use new alloc/free_layout API]
[apply types rename]
[convert to new pnfs-submit changes]
[fixup encode_layoutcommit arguments]
[fixup layoutcommit methods args]
[use pnfs_layout_hdr and layout_segment field prefix]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    1 +
 fs/nfs/objlayout/objlayout.c |   30 ++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |   25 +++++++++++++++++++++++++
 3 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 027ba38..179dfbd 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -755,6 +755,7 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.write_pagelist          = objlayout_write_pagelist,
 
 	.encode_layoutreturn     = objlayout_encode_layoutreturn,
+	.encode_layoutcommit     = objlayout_encode_layoutcommit,
 };
 
 void *objio_init_mt(void)
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 322ffa3..2cf139c 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -247,6 +247,7 @@ objlayout_iodone(struct objlayout_io_state *state)
 		struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.pls_layout);
 
 		spin_lock(&objlay->lock);
+		objlay->delta_space_valid = OBJ_DSU_INVALID;
 		list_add(&objlay->err_list, &state->err_list);
 		spin_unlock(&objlay->lock);
 	}
@@ -455,6 +456,35 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	return PNFS_ATTEMPTED;
 }
 
+void
+objlayout_encode_layoutcommit(struct pnfs_layout_hdr *pnfslay,
+			      struct xdr_stream *xdr,
+			      const struct nfs4_layoutcommit_args *args)
+{
+	struct objlayout *objlay = OBJLAYOUT(pnfslay);
+	struct pnfs_osd_layoutupdate lou;
+	__be32 *start;
+
+	dprintk("%s: Begin\n", __func__);
+
+	spin_lock(&objlay->lock);
+	lou.dsu_valid = (objlay->delta_space_valid == OBJ_DSU_VALID);
+	lou.dsu_delta = objlay->delta_space_used;
+	objlay->delta_space_used = 0;
+	objlay->delta_space_valid = OBJ_DSU_INIT;
+	lou.olu_ioerr_flag = !list_empty(&objlay->err_list);
+	spin_unlock(&objlay->lock);
+
+	start = xdr_reserve_space(xdr, 4);
+
+	BUG_ON(pnfs_osd_xdr_encode_layoutupdate(xdr, &lou));
+
+	*start = cpu_to_be32((xdr->p - start - 1) * 4);
+
+	dprintk("%s: Return delta_space_used %lld err %d\n", __func__,
+		lou.dsu_delta, lou.olu_ioerr_flag);
+}
+
 static int
 err_prio(u32 oer_errno)
 {
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 65f8d44..fb0bf93 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -62,6 +62,14 @@ struct objlayout_segment {
 struct objlayout {
 	struct pnfs_layout_hdr pnfs_layout;
 
+	 /* for layout_commit */
+	enum osd_delta_space_valid_enum {
+		OBJ_DSU_INIT = 0,
+		OBJ_DSU_VALID,
+		OBJ_DSU_INVALID,
+	} delta_space_valid;
+	s64 delta_space_used;  /* consumed by write ops */
+
 	 /* for layout_return */
 	spinlock_t lock;
 	struct list_head err_list;
@@ -129,6 +137,23 @@ extern void objlayout_io_set_result(struct objlayout_io_state *state,
 				    unsigned index, int osd_error,
 				    u64 offset, u64 length, bool is_write);
 
+static inline void
+objlayout_add_delta_space_used(struct objlayout_io_state *state, s64 space_used)
+{
+	struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.pls_layout);
+
+	/* If one of the I/Os errored out and the delta_space_used was
+	 * invalid we render the complete report as invalid. Protocol mandate
+	 * the DSU be accurate or not reported.
+	 */
+	spin_lock(&objlay->lock);
+	if (objlay->delta_space_valid != OBJ_DSU_INVALID) {
+		objlay->delta_space_valid = OBJ_DSU_VALID;
+		objlay->delta_space_used += space_used;
+	}
+	spin_unlock(&objlay->lock);
+}
+
 extern void objlayout_read_done(struct objlayout_io_state *state,
 				ssize_t status, bool sync);
 extern void objlayout_write_done(struct objlayout_io_state *state,
-- 
1.7.3.4

