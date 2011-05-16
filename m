Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34920 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab1EPQYX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:24:23 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH v3 27/29] pnfs-obj: objlayout_encode_layoutcommit implementation
Date: Mon, 16 May 2011 09:24:20 -0700
Message-Id: <1305563060-8287-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD14D8E.1070701@panasas.com>
References: <4DD14D8E.1070701@panasas.com>
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
 fs/nfs/nfs4xdr.c                    |    6 +++++-
 fs/nfs/objlayout/objio_osd.c        |    1 +
 fs/nfs/objlayout/objlayout.c        |   30 ++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h        |   32 +++++++++++++++++++++++++++++++-
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |   23 +++++++++++++++++++++++
 5 files changed, 90 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c821c9c..f6da5f6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -336,7 +336,11 @@ static int nfs4_stat_to_errno(int);
 				2 /* last byte written */ + \
 				1 /* nt_timechanged (false) */ + \
 				1 /* layoutupdate4 layout type */ + \
-				1 /* NULL filelayout layoutupdate4 payload */)
+				/* pnfs-obj pnfs_osd_layoutupdate4 */ \
+				1 /* lou_body size */ + \
+				1 /* dsu_body */ + \
+				2 /* dsu_delta */ + \
+				1 /* ioerr_flag */ )
 #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
 #define encode_layoutreturn_maxsz (8 + op_encode_hdr_maxsz + \
 				encode_stateid_maxsz + \
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9c9dc9a..0988e1e 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -739,6 +739,7 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.write_pagelist          = objlayout_write_pagelist,
 
 	.encode_layoutreturn     = objlayout_encode_layoutreturn,
+	.encode_layoutcommit     = objlayout_encode_layoutcommit,
 };
 
 void *objio_init_mt(void)
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index c47e03d..0b5be4d 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -343,6 +343,7 @@ objlayout_iodone(struct objlayout_io_state *state)
 		struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.pls_layout);
 
 		spin_lock(&objlay->lock);
+		objlay->delta_space_valid = OBJ_DSU_INVALID;
 		list_add(&objlay->err_list, &state->err_list);
 		spin_unlock(&objlay->lock);
 	}
@@ -723,3 +724,32 @@ loop_done:
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 	dprintk("%s: Return\n", __func__);
 }
+
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
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 31fd34b..caee5c9 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -59,10 +59,18 @@ struct objlayout_segment {
  */
 struct objlayout {
 	struct pnfs_layout_hdr pnfs_layout;
+	spinlock_t lock;
 
 	 /* for layout_return */
-	spinlock_t lock;
 	struct list_head err_list;
+
+	 /* for layout_commit */
+	enum osd_delta_space_valid_enum {
+		OBJ_DSU_INIT = 0,
+		OBJ_DSU_VALID,
+		OBJ_DSU_INVALID,
+	} delta_space_valid;
+	s64 delta_space_used;  /* consumed by write ops */
 };
 
 static inline struct objlayout *
@@ -127,6 +135,23 @@ extern void objlayout_io_set_result(struct objlayout_io_state *state,
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
@@ -163,4 +188,9 @@ extern void objlayout_encode_layoutreturn(
 	struct xdr_stream *,
 	const struct nfs4_layoutreturn_args *);
 
+extern void objlayout_encode_layoutcommit(
+	struct pnfs_layout_hdr *,
+	struct xdr_stream *,
+	const struct nfs4_layoutcommit_args *);
+
 #endif /* _OBJLAYOUT_H */
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index 232b32c49..4ff2e3e 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -405,3 +405,26 @@ int pnfs_osd_xdr_encode_ioerr(struct xdr_stream *xdr,
 
 	return 0;
 }
+
+/*
+ * struct pnfs_osd_layoutupdate {
+ * 	u32	dsu_valid;
+ * 	s64	dsu_delta;
+ * 	u32	olu_ioerr_flag;
+ * };
+ */
+int
+pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
+				 struct pnfs_osd_layoutupdate *lou)
+{
+	__be32 *p = xdr_reserve_space(xdr, 16);
+
+	if (!p)
+		return -E2BIG;
+
+	*p++ = cpu_to_be32(lou->dsu_valid);
+	if (lou->dsu_valid)
+		p = xdr_encode_hyper(p, lou->dsu_delta);
+	*p++ = cpu_to_be32(lou->olu_ioerr_flag);
+	return 0;
+}
-- 
1.7.3.4

