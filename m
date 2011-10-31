Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:44122 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491Ab1JaWDs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 18:03:48 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Brent Welch <welch@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 4/8] pnfs-obj: Rename objlayout_io_state => objlayout_io_res
Date: Mon, 31 Oct 2011 15:03:35 -0700
Message-ID: <1320098615-972-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4EAF146D.5060507@panasas.com>
References: <4EAF146D.5060507@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* All instances of objlayout_io_state => objlayout_io_res
* All instances of state => oir;
* All instances of ol_state => oir;

Big but nothing to it

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   17 +++++------
 fs/nfs/objlayout/objlayout.c |   63 ++++++++++++++++++++---------------------
 fs/nfs/objlayout/objlayout.h |   15 ++++++----
 3 files changed, 48 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 48eb91a..2347e0a 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -146,7 +146,7 @@ struct objio_segment {
 
 struct objio_state {
 	/* Generic layer */
-	struct objlayout_io_state ol_state;
+	struct objlayout_io_res oir;
 
 	struct page **pages;
 	unsigned pgbase;
@@ -422,7 +422,7 @@ void objio_free_lseg(struct pnfs_layout_segment *lseg)
 	ios = &aos->objios;
 
 	ios->layout = objio_seg;
-	objlayout_init_ioerrs(&aos->objios.ol_state, objio_seg->num_comps,
+	objlayout_init_ioerrs(&aos->objios.oir, objio_seg->num_comps,
 			aos->ioerrs, rpcdata, pnfs_layout_type);
 
 	ios->pages = pages;
@@ -437,10 +437,9 @@ void objio_free_lseg(struct pnfs_layout_segment *lseg)
 	return 0;
 }
 
-void objio_free_result(struct objlayout_io_state *ol_state)
+void objio_free_result(struct objlayout_io_res *oir)
 {
-	struct objio_state *ios = container_of(ol_state, struct objio_state,
-					       ol_state);
+	struct objio_state *ios = container_of(oir, struct objio_state, oir);
 
 	kfree(ios);
 }
@@ -519,7 +518,7 @@ static int _io_check(struct objio_state *ios, bool is_write)
 
 			continue; /* we recovered */
 		}
-		objlayout_io_set_result(&ios->ol_state, i,
+		objlayout_io_set_result(&ios->oir, i,
 					&ios->layout->comps[i].oc_object_id,
 					osd_pri_2_pnfs_err(osi.osd_err_pri),
 					ios->per_dev[i].offset,
@@ -812,7 +811,7 @@ static int _read_done(struct objio_state *ios)
 	else
 		status = ret;
 
-	objlayout_read_done(&ios->ol_state, status, ios->sync);
+	objlayout_read_done(&ios->oir, status, ios->sync);
 	return ret;
 }
 
@@ -906,13 +905,13 @@ static int _write_done(struct objio_state *ios)
 	if (likely(!ret)) {
 		/* FIXME: should be based on the OSD's persistence model
 		 * See OSD2r05 Section 4.13 Data persistence model */
-		ios->ol_state.committed = NFS_FILE_SYNC;
+		ios->oir.committed = NFS_FILE_SYNC;
 		status = ios->length;
 	} else {
 		status = ret;
 	}
 
-	objlayout_write_done(&ios->ol_state, status, ios->sync);
+	objlayout_write_done(&ios->oir, status, ios->sync);
 	return ret;
 }
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index a82053a..72074e3 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -179,16 +179,16 @@ void _fix_verify_io_params(struct pnfs_layout_segment *lseg,
  * I/O done common code
  */
 static void
-objlayout_iodone(struct objlayout_io_state *state)
+objlayout_iodone(struct objlayout_io_res *oir)
 {
-	if (likely(state->status >= 0)) {
-		objio_free_result(state);
+	if (likely(oir->status >= 0)) {
+		objio_free_result(oir);
 	} else {
-		struct objlayout *objlay = state->objlay;
+		struct objlayout *objlay = oir->objlay;
 
 		spin_lock(&objlay->lock);
 		objlay->delta_space_valid = OBJ_DSU_INVALID;
-		list_add(&objlay->err_list, &state->err_list);
+		list_add(&objlay->err_list, &oir->err_list);
 		spin_unlock(&objlay->lock);
 	}
 }
@@ -200,13 +200,13 @@ void _fix_verify_io_params(struct pnfs_layout_segment *lseg,
  * the error for later reporting at layout-return.
  */
 void
-objlayout_io_set_result(struct objlayout_io_state *state, unsigned index,
+objlayout_io_set_result(struct objlayout_io_res *oir, unsigned index,
 			struct pnfs_osd_objid *pooid, int osd_error,
 			u64 offset, u64 length, bool is_write)
 {
-	struct pnfs_osd_ioerr *ioerr = &state->ioerrs[index];
+	struct pnfs_osd_ioerr *ioerr = &oir->ioerrs[index];
 
-	BUG_ON(index >= state->num_comps);
+	BUG_ON(index >= oir->num_comps);
 	if (osd_error) {
 		ioerr->oer_component = *pooid;
 		ioerr->oer_comp_offset = offset;
@@ -247,15 +247,15 @@ static void _rpc_read_complete(struct work_struct *work)
 }
 
 void
-objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
+objlayout_read_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 {
-	struct nfs_read_data *rdata = state->rpcdata;
+	struct nfs_read_data *rdata = oir->rpcdata;
 
-	state->status = rdata->task.tk_status = status;
+	oir->status = rdata->task.tk_status = status;
 	if (status >= 0)
 		rdata->res.count = status;
-	objlayout_iodone(state);
-	/* must not use state after this point */
+	objlayout_iodone(oir);
+	/* must not use oir after this point */
 
 	dprintk("%s: Return status=%zd eof=%d sync=%d\n", __func__,
 		status, rdata->res.eof, sync);
@@ -326,17 +326,16 @@ static void _rpc_write_complete(struct work_struct *work)
 }
 
 void
-objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
-		     bool sync)
+objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 {
-	struct nfs_write_data *wdata = state->rpcdata;
+	struct nfs_write_data *wdata = oir->rpcdata;
 
-	state->status = wdata->task.tk_status = status;
+	oir->status = wdata->task.tk_status = status;
 	if (status >= 0) {
 		wdata->res.count = status;
-		wdata->verf.committed = state->committed;
+		wdata->verf.committed = oir->committed;
 	}
-	objlayout_iodone(state);
+	objlayout_iodone(oir);
 	/* must not use oir after this point */
 
 	dprintk("%s: Return status %zd committed %d sync=%d\n", __func__,
@@ -475,14 +474,14 @@ enum pnfs_try_status
 static void
 encode_accumulated_error(struct objlayout *objlay, __be32 *p)
 {
-	struct objlayout_io_state *state, *tmp;
+	struct objlayout_io_res *oir, *tmp;
 	struct pnfs_osd_ioerr accumulated_err = {.oer_errno = 0};
 
-	list_for_each_entry_safe(state, tmp, &objlay->err_list, err_list) {
+	list_for_each_entry_safe(oir, tmp, &objlay->err_list, err_list) {
 		unsigned i;
 
-		for (i = 0; i < state->num_comps; i++) {
-			struct pnfs_osd_ioerr *ioerr = &state->ioerrs[i];
+		for (i = 0; i < oir->num_comps; i++) {
+			struct pnfs_osd_ioerr *ioerr = &oir->ioerrs[i];
 
 			if (!ioerr->oer_errno)
 				continue;
@@ -501,8 +500,8 @@ enum pnfs_try_status
 
 			merge_ioerr(&accumulated_err, ioerr);
 		}
-		list_del(&state->err_list);
-		objio_free_result(state);
+		list_del(&oir->err_list);
+		objio_free_result(oir);
 	}
 
 	pnfs_osd_xdr_encode_ioerr(p, &accumulated_err);
@@ -514,7 +513,7 @@ enum pnfs_try_status
 			      const struct nfs4_layoutreturn_args *args)
 {
 	struct objlayout *objlay = OBJLAYOUT(pnfslay);
-	struct objlayout_io_state *state, *tmp;
+	struct objlayout_io_res *oir, *tmp;
 	__be32 *start;
 
 	dprintk("%s: Begin\n", __func__);
@@ -523,13 +522,13 @@ enum pnfs_try_status
 
 	spin_lock(&objlay->lock);
 
-	list_for_each_entry_safe(state, tmp, &objlay->err_list, err_list) {
+	list_for_each_entry_safe(oir, tmp, &objlay->err_list, err_list) {
 		__be32 *last_xdr = NULL, *p;
 		unsigned i;
 		int res = 0;
 
-		for (i = 0; i < state->num_comps; i++) {
-			struct pnfs_osd_ioerr *ioerr = &state->ioerrs[i];
+		for (i = 0; i < oir->num_comps; i++) {
+			struct pnfs_osd_ioerr *ioerr = &oir->ioerrs[i];
 
 			if (!ioerr->oer_errno)
 				continue;
@@ -553,7 +552,7 @@ enum pnfs_try_status
 			}
 
 			last_xdr = p;
-			pnfs_osd_xdr_encode_ioerr(p, &state->ioerrs[i]);
+			pnfs_osd_xdr_encode_ioerr(p, &oir->ioerrs[i]);
 		}
 
 		/* TODO: use xdr_write_pages */
@@ -569,8 +568,8 @@ enum pnfs_try_status
 			encode_accumulated_error(objlay, last_xdr);
 			goto loop_done;
 		}
-		list_del(&state->err_list);
-		objio_free_result(state);
+		list_del(&oir->err_list);
+		objio_free_result(oir);
 	}
 loop_done:
 	spin_unlock(&objlay->lock);
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index d7b2ccfa..8ec3472 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -74,7 +74,7 @@ struct objlayout {
  * per-I/O operation state
  * embedded in objects provider io_state data structure
  */
-struct objlayout_io_state {
+struct objlayout_io_res {
 	struct objlayout *objlay;
 
 	void *rpcdata;
@@ -93,7 +93,7 @@ struct objlayout_io_state {
 };
 
 static inline
-void objlayout_init_ioerrs(struct objlayout_io_state *oir, unsigned num_comps,
+void objlayout_init_ioerrs(struct objlayout_io_res *oir, unsigned num_comps,
 			struct pnfs_osd_ioerr *ioerrs, void *rpcdata,
 			struct pnfs_layout_hdr *pnfs_layout_type)
 {
@@ -114,7 +114,10 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	gfp_t gfp_flags);
 extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
 
-extern void objio_free_result(struct objlayout_io_state *state);
+/* objio_free_result will free these @oir structs recieved from
+ * objlayout_{read,write}_done
+ */
+extern void objio_free_result(struct objlayout_io_res *oir);
 
 extern int objio_read_pagelist(struct nfs_read_data *rdata);
 extern int objio_write_pagelist(struct nfs_write_data *wdata, int how);
@@ -122,7 +125,7 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 /*
  * callback API
  */
-extern void objlayout_io_set_result(struct objlayout_io_state *state,
+extern void objlayout_io_set_result(struct objlayout_io_res *oir,
 			unsigned index, struct pnfs_osd_objid *pooid,
 			int osd_error, u64 offset, u64 length, bool is_write);
 
@@ -141,9 +144,9 @@ extern void objlayout_io_set_result(struct objlayout_io_state *state,
 	spin_unlock(&objlay->lock);
 }
 
-extern void objlayout_read_done(struct objlayout_io_state *state,
+extern void objlayout_read_done(struct objlayout_io_res *oir,
 				ssize_t status, bool sync);
-extern void objlayout_write_done(struct objlayout_io_state *state,
+extern void objlayout_write_done(struct objlayout_io_res *oir,
 				 ssize_t status, bool sync);
 
 extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
-- 
1.7.6.4

