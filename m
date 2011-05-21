Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19777 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778Ab1EUKcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:32:48 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/13] SQUASHME: pnfs_osd_xdr: Avoid using xdr_rewind_stream
Date: Sat, 21 May 2011 13:32:32 +0300
Message-Id: <1305973952-17471-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

In encoding the io_err xdr. We used the xdr_rewind_stream
API when we run out of space and want to encode the last
accumulated error.

We can avoid that by splitting the encoding API into two.
first call: to reserved space.
Second: do the encoding.
If reserving space fails we can now use the previous
place for the accumulated error

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c        |   25 ++++++++++++--------
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |   41 ++++++++++++++--------------------
 include/linux/pnfs_osd_xdr.h        |   14 +++--------
 3 files changed, 36 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index e3c42fc..8892130 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -532,7 +532,7 @@ merge_ioerr(struct pnfs_osd_ioerr *dest_err,
 }
 
 static void
-encode_accumulated_error(struct objlayout *objlay, struct xdr_stream *xdr)
+encode_accumulated_error(struct objlayout *objlay, __be32 *p)
 {
 	struct objlayout_io_state *state, *tmp;
 	struct pnfs_osd_ioerr accumulated_err = {.oer_errno = 0};
@@ -564,7 +564,7 @@ encode_accumulated_error(struct objlayout *objlay, struct xdr_stream *xdr)
 		objlayout_free_io_state(state);
 	}
 
-	BUG_ON(pnfs_osd_xdr_encode_ioerr(xdr, &accumulated_err));
+	pnfs_osd_xdr_encode_ioerr(p, &accumulated_err);
 }
 
 void
@@ -574,7 +574,7 @@ objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
 {
 	struct objlayout *objlay = OBJLAYOUT(pnfslay);
 	struct objlayout_io_state *state, *tmp;
-	__be32 *start, *uninitialized_var(last_xdr);
+	__be32 *start;
 
 	dprintk("%s: Begin\n", __func__);
 	start = xdr_reserve_space(xdr, 4);
@@ -583,10 +583,11 @@ objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
 	spin_lock(&objlay->lock);
 
 	list_for_each_entry_safe(state, tmp, &objlay->err_list, err_list) {
+		__be32 *last_xdr = NULL, *p;
 		unsigned i;
 		int res = 0;
 
-		for (i = 0; i < state->num_comps && !res; i++) {
+		for (i = 0; i < state->num_comps; i++) {
 			struct pnfs_osd_ioerr *ioerr = &state->ioerrs[i];
 
 			if (!ioerr->oer_errno)
@@ -604,23 +605,27 @@ objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
 				ioerr->oer_comp_offset,
 				ioerr->oer_comp_length);
 
-			last_xdr = xdr->p;
-			res = pnfs_osd_xdr_encode_ioerr(xdr, &state->ioerrs[i]);
+			p = pnfs_osd_xdr_ioerr_reserve_space(xdr);
+			if (unlikely(!p)) {
+				res = -E2BIG;
+				break; /* accumulated_error */
+			}
+
+			last_xdr = p;
+			pnfs_osd_xdr_encode_ioerr(p, &state->ioerrs[i]);
 		}
 
 		/* TODO: use xdr_write_pages */
 		if (unlikely(res)) {
 			/* no space for even one error descriptor */
-			BUG_ON(last_xdr == start + 1);
+			BUG_ON(!last_xdr);
 
 			/* we've encountered a situation with lots and lots of
 			 * errors and no space to encode them all. Use the last
 			 * available slot to report the union of all the
 			 * remaining errors.
 			 */
-			xdr_rewind_stream(xdr, last_xdr -
-					       pnfs_osd_ioerr_xdr_sz() / 4);
-			encode_accumulated_error(objlay, xdr);
+			encode_accumulated_error(objlay, last_xdr);
 			goto loop_done;
 		}
 		list_del(&state->err_list);
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index b55131c..2aba671 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -369,22 +369,17 @@ pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
  * 	struct pnfs_deviceid	oid_device_id;
  * 	u64			oid_partition_id;
  * 	u64			oid_object_id;
+ * }; // xdr size 32 bytes
  */
-static inline int pnfs_osd_xdr_encode_objid(struct xdr_stream *xdr,
-					    struct pnfs_osd_objid *object_id)
+static inline __be32 *
+pnfs_osd_xdr_encode_objid(__be32 *p, struct pnfs_osd_objid *object_id)
 {
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, 32);
-	if (!p)
-		return -E2BIG;
-
 	p = xdr_encode_opaque_fixed(p, &object_id->oid_device_id.data,
 				    sizeof(object_id->oid_device_id.data));
 	p = xdr_encode_hyper(p, object_id->oid_partition_id);
 	p = xdr_encode_hyper(p, object_id->oid_object_id);
 
-	return 0;
+	return p;
 }
 
 /*
@@ -394,26 +389,24 @@ static inline int pnfs_osd_xdr_encode_objid(struct xdr_stream *xdr,
  * 	u64			oer_comp_length;
  * 	u32			oer_iswrite;
  * 	u32			oer_errno;
- * };
+ * }; // xdr size 32 + 24 bytes
  */
-int pnfs_osd_xdr_encode_ioerr(struct xdr_stream *xdr,
-			      struct pnfs_osd_ioerr *ioerr)
+void pnfs_osd_xdr_encode_ioerr(__be32 *p, struct pnfs_osd_ioerr *ioerr)
 {
-	__be32 *p;
-	int ret;
-
-	ret = pnfs_osd_xdr_encode_objid(xdr, &ioerr->oer_component);
-	if (ret)
-		return ret;
-
-	p = xdr_reserve_space(xdr, 24);
-	if (!p)
-		return -E2BIG;
-
+	p = pnfs_osd_xdr_encode_objid(p, &ioerr->oer_component);
 	p = xdr_encode_hyper(p, ioerr->oer_comp_offset);
 	p = xdr_encode_hyper(p, ioerr->oer_comp_length);
 	*p++ = cpu_to_be32(ioerr->oer_iswrite);
 	*p   = cpu_to_be32(ioerr->oer_errno);
+}
 
-	return 0;
+__be32 *pnfs_osd_xdr_ioerr_reserve_space(struct xdr_stream *xdr)
+{
+	__be32 * p;
+	
+	p = xdr_reserve_space(xdr, 32 + 24);
+	if (unlikely(!p))
+		dprintk("%s: out of xdr space\n", __func__);
+
+	return p;
 }
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index db22471..747d06d 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -279,14 +279,6 @@ struct pnfs_osd_ioerr {
 	u32			oer_errno;
 };
 
-/* FIXME: remove */
-static inline unsigned
-pnfs_osd_ioerr_xdr_sz(void)
-{
-	return pnfs_osd_objid_xdr_sz() + 2 + 2 + 1 + 1;
-}
-
-
 /* OSD XDR API */
 /* Layout helpers */
 /* Layout decoding is done in two parts:
@@ -348,8 +340,10 @@ extern __be32 *
 pnfs_osd_xdr_decode_layoutupdate(struct pnfs_osd_layoutupdate *lou, __be32 *p);
 
 /* osd_ioerror encoding/decoding (layout_return) */
-extern int
-pnfs_osd_xdr_encode_ioerr(struct xdr_stream *xdr, struct pnfs_osd_ioerr *ioerr);
+/* Client */
+extern __be32 *pnfs_osd_xdr_ioerr_reserve_space(struct xdr_stream *xdr);
+extern void pnfs_osd_xdr_encode_ioerr(__be32 *p, struct pnfs_osd_ioerr *ioerr);
+/* Server*/
 extern __be32 *
 pnfs_osd_xdr_decode_ioerr(struct pnfs_osd_ioerr *ioerr, __be32 *p);
 
-- 
1.7.2.3

