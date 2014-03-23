Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47855 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067AbaCWBMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/50] nfsd4: embed xdr_stream in nfsd4_compoundres
Date: Sat, 22 Mar 2014 21:11:40 -0400
Message-Id: <1395537141-10389-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is a mechanical transformation with no change in behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  | 12 +++++-----
 fs/nfsd/nfs4state.c |  8 +++----
 fs/nfsd/nfs4xdr.c   | 65 +++++++++++++++++++++++++++--------------------------
 fs/nfsd/xdr4.h      |  4 +---
 4 files changed, 44 insertions(+), 45 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9a914e8..27b8268 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1277,13 +1277,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	u32		plen = 0;
 	__be32		status;
 
-	resp->xbuf = &rqstp->rq_res;
-	resp->p = rqstp->rq_res.head[0].iov_base +
+	resp->xdr.buf = &rqstp->rq_res;
+	resp->xdr.p = rqstp->rq_res.head[0].iov_base +
 						rqstp->rq_res.head[0].iov_len;
-	resp->tagp = resp->p;
+	resp->tagp = resp->xdr.p;
 	/* reserve space for: taglen, tag, and opcnt */
-	resp->p += 2 + XDR_QUADLEN(args->taglen);
-	resp->end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
+	resp->xdr.p += 2 + XDR_QUADLEN(args->taglen);
+	resp->xdr.end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;
 	resp->opcnt = 0;
@@ -1335,7 +1335,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		 * failed response to the next operation.  If we don't
 		 * have enough room, fail with ERR_RESOURCE.
 		 */
-		slack_bytes = (char *)resp->end - (char *)resp->p;
+		slack_bytes = (char *)resp->xdr.end - (char *)resp->xdr.p;
 		if (slack_bytes < COMPOUND_SLACK_SPACE
 				+ COMPOUND_ERR_SLACK_SPACE) {
 			BUG_ON(slack_bytes < COMPOUND_ERR_SLACK_SPACE);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cb4cc4a..d98e282 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1560,10 +1560,10 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 		slot->sl_datalen = 0;
 		return;
 	}
-	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
+	slot->sl_datalen = (char *)resp->xdr.p - (char *)resp->cstate.datap;
 	base = (char *)resp->cstate.datap -
-					(char *)resp->xbuf->head[0].iov_base;
-	if (read_bytes_from_xdr_buf(resp->xbuf, base, slot->sl_data,
+					(char *)resp->xdr.buf->head[0].iov_base;
+	if (read_bytes_from_xdr_buf(resp->xdr.buf, base, slot->sl_data,
 				    slot->sl_datalen))
 		WARN("%s: sessions DRC could not cache compound\n", __func__);
 	return;
@@ -1617,7 +1617,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
 
 	resp->opcnt = slot->sl_opcnt;
-	resp->p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
+	resp->xdr.p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
 	status = slot->sl_status;
 
 	return status;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ea32674..484a8aa 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1748,10 +1748,10 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 }
 
 #define RESERVE_SPACE(nbytes)	do {				\
-	p = resp->p;						\
-	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->end);		\
+	p = resp->xdr.p;						\
+	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->xdr.end);		\
 } while (0)
-#define ADJUST_ARGS()		resp->p = p
+#define ADJUST_ARGS()		resp->xdr.p = p
 
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
@@ -2750,9 +2750,9 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	if (nfserr)
 		return nfserr;
 
-	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
+	buflen = resp->xdr.end - resp->xdr.p - (COMPOUND_ERR_SLACK_SPACE >> 2);
 	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
-				    &resp->p, buflen, getattr->ga_bmval,
+				    &resp->xdr.p, buflen, getattr->ga_bmval,
 				    resp->rqstp, 0);
 	return nfserr;
 }
@@ -2952,7 +2952,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	if (nfserr)
 		return nfserr;
-	if (resp->xbuf->page_len)
+	if (resp->xdr.buf->page_len)
 		return nfserr_resource;
 
 	RESERVE_SPACE(8); /* eof flag and byte count */
@@ -2990,18 +2990,18 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(eof);
 	WRITE32(maxcount);
 	ADJUST_ARGS();
-	resp->xbuf->head[0].iov_len = (char*)p
-					- (char*)resp->xbuf->head[0].iov_base;
-	resp->xbuf->page_len = maxcount;
+	resp->xdr.buf->head[0].iov_len = (char*)p
+				- (char*)resp->xdr.buf->head[0].iov_base;
+	resp->xdr.buf->page_len = maxcount;
 
 	/* Use rest of head for padding and remaining ops: */
-	resp->xbuf->tail[0].iov_base = p;
-	resp->xbuf->tail[0].iov_len = 0;
+	resp->xdr.buf->tail[0].iov_base = p;
+	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
 		RESERVE_SPACE(4);
 		WRITE32(0);
-		resp->xbuf->tail[0].iov_base += maxcount&3;
-		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
+		resp->xdr.buf->tail[0].iov_base += maxcount&3;
+		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
 		ADJUST_ARGS();
 	}
 	return 0;
@@ -3016,7 +3016,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 
 	if (nfserr)
 		return nfserr;
-	if (resp->xbuf->page_len)
+	if (resp->xdr.buf->page_len)
 		return nfserr_resource;
 	if (!*resp->rqstp->rq_next_page)
 		return nfserr_resource;
@@ -3040,18 +3040,18 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 
 	WRITE32(maxcount);
 	ADJUST_ARGS();
-	resp->xbuf->head[0].iov_len = (char*)p
-				- (char*)resp->xbuf->head[0].iov_base;
-	resp->xbuf->page_len = maxcount;
+	resp->xdr.buf->head[0].iov_len = (char*)p
+				- (char*)resp->xdr.buf->head[0].iov_base;
+	resp->xdr.buf->page_len = maxcount;
 
 	/* Use rest of head for padding and remaining ops: */
-	resp->xbuf->tail[0].iov_base = p;
-	resp->xbuf->tail[0].iov_len = 0;
+	resp->xdr.buf->tail[0].iov_base = p;
+	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
 		RESERVE_SPACE(4);
 		WRITE32(0);
-		resp->xbuf->tail[0].iov_base += maxcount&3;
-		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
+		resp->xdr.buf->tail[0].iov_base += maxcount&3;
+		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
 		ADJUST_ARGS();
 	}
 	return 0;
@@ -3067,7 +3067,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	if (nfserr)
 		return nfserr;
-	if (resp->xbuf->page_len)
+	if (resp->xdr.buf->page_len)
 		return nfserr_resource;
 	if (!*resp->rqstp->rq_next_page)
 		return nfserr_resource;
@@ -3079,7 +3079,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	WRITE32(0);
 	WRITE32(0);
 	ADJUST_ARGS();
-	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
+	resp->xdr.buf->head[0].iov_len = ((char*)resp->xdr.p)
+				- (char*)resp->xdr.buf->head[0].iov_base;
 	tailbase = p;
 
 	maxcount = PAGE_SIZE;
@@ -3120,14 +3121,14 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	p = readdir->buffer;
 	*p++ = 0;	/* no more entries */
 	*p++ = htonl(readdir->common.err == nfserr_eof);
-	resp->xbuf->page_len = ((char*)p) -
+	resp->xdr.buf->page_len = ((char*)p) -
 		(char*)page_address(*(resp->rqstp->rq_next_page-1));
 
 	/* Use rest of head for padding and remaining ops: */
-	resp->xbuf->tail[0].iov_base = tailbase;
-	resp->xbuf->tail[0].iov_len = 0;
-	resp->p = resp->xbuf->tail[0].iov_base;
-	resp->end = resp->p + (PAGE_SIZE - resp->xbuf->head[0].iov_len)/4;
+	resp->xdr.buf->tail[0].iov_base = tailbase;
+	resp->xdr.buf->tail[0].iov_len = 0;
+	resp->xdr.p = resp->xdr.buf->tail[0].iov_base;
+	resp->xdr.end = resp->xdr.p + (PAGE_SIZE - resp->xdr.buf->head[0].iov_len)/4;
 
 	return 0;
 err_no_verf:
@@ -3586,10 +3587,10 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 	session = resp->cstate.session;
 
 	if (xb->page_len == 0) {
-		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
+		length = (char *)resp->xdr.p - (char *)xb->head[0].iov_base + pad;
 	} else {
 		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
-			tlen = (char *)resp->p - (char *)xb->tail[0].iov_base;
+			tlen = (char *)resp->xdr.p - (char *)xb->tail[0].iov_base;
 
 		length = xb->head[0].iov_len + xb->page_len + tlen + pad;
 	}
@@ -3636,7 +3637,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	}
 	if (so) {
 		so->so_replay.rp_status = op->status;
-		so->so_replay.rp_buflen = (char *)resp->p - (char *)(statp+1);
+		so->so_replay.rp_buflen = (char *)resp->xdr.p - (char *)(statp+1);
 		memcpy(so->so_replay.rp_buf, statp+1, so->so_replay.rp_buflen);
 	}
 status:
@@ -3732,7 +3733,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.tail[0];
 	else
 		iov = &rqstp->rq_res.head[0];
-	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
+	iov->iov_len = ((char*)resp->xdr.p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
 	if (nfsd4_has_session(cs)) {
 		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 5ea7df3..6884d70 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -506,9 +506,7 @@ struct nfsd4_compoundargs {
 
 struct nfsd4_compoundres {
 	/* scratch variables for XDR encode */
-	__be32 *			p;
-	__be32 *			end;
-	struct xdr_buf *		xbuf;
+	struct xdr_stream		xdr;
 	struct svc_rqst *		rqstp;
 
 	u32				taglen;
-- 
1.8.5.3

