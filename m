Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20445 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933459Ab0LUCU6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 21:20:58 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/14] pnfs: wave 2: serialize LAYOUTGET(openstateid)
Date: Mon, 20 Dec 2010 21:20:39 -0500
Message-Id: <1292898046-7336-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We shouldn't send a LAYOUTGET(openstateid) unless all outstanding RPCs
using the previous stateid are completed.  This requires adding a
status to encode_layoutget() to handle the case where we can't choose
an appropriate stateid (we want to use the open stateid, but a
LAYOUTGET is already out using it), and adding a count of the number
of outstanding rpc calls using layout state (which for now consist
solely of LAYOUTGETs).

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    1 -
 fs/nfs/nfs4xdr.c  |   16 ++++++++++++----
 fs/nfs/pnfs.c     |   27 ++++++++++++++++++++++-----
 fs/nfs/pnfs.h     |    1 +
 4 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 408021a..58cebac 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5342,7 +5342,6 @@ static void nfs4_layoutget_release(void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	put_layout_hdr(lgp->args.inode);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	put_nfs_open_context(lgp->args.ctx);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 99effb2..57e5b94 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1784,13 +1784,14 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 	hdr->replen += decode_getdeviceinfo_maxsz;
 }
 
-static void
+static int
 encode_layoutget(struct xdr_stream *xdr,
 		      const struct nfs4_layoutget_args *args,
 		      struct compound_hdr *hdr)
 {
 	nfs4_stateid stateid;
 	__be32 *p;
+	int status;
 
 	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_LAYOUTGET);
@@ -1800,8 +1801,11 @@ encode_layoutget(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->range.offset);
 	p = xdr_encode_hyper(p, args->range.length);
 	p = xdr_encode_hyper(p, args->minlength);
-	pnfs_choose_layoutget_stateid(&stateid, NFS_I(args->inode)->layout,
-				args->ctx->state);
+	status = pnfs_choose_layoutget_stateid(&stateid,
+					       NFS_I(args->inode)->layout,
+					       args->ctx->state);
+	if (status)
+		return status;
 	p = xdr_encode_opaque_fixed(p, &stateid.data, NFS4_STATEID_SIZE);
 	*p = cpu_to_be32(args->maxcount);
 
@@ -1814,6 +1818,7 @@ encode_layoutget(struct xdr_stream *xdr,
 		args->maxcount);
 	hdr->nops++;
 	hdr->replen += decode_layoutget_maxsz;
+	return 0;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -2670,12 +2675,15 @@ static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
+	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, NFS_FH(args->inode), &hdr);
-	encode_layoutget(&xdr, args, &hdr);
+	status = encode_layoutget(&xdr, args, &hdr);
+	if (status)
+		return status;
 	encode_nops(&hdr);
 	return 0;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 49591e4..25b67bd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -362,6 +362,14 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 		memcpy(&lo->stateid, &new->stateid, sizeof(new->stateid));
 }
 
+/* lget is set to 1 if called from inside send_layoutget call chain */
+static bool
+pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, int lget)
+{
+	return (list_empty(&lo->segs) &&
+		 (atomic_read(&lo->plh_outstanding) > lget));
+}
+
 int
 pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			      struct nfs4_state *open_state)
@@ -370,7 +378,12 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->inode->i_lock);
-	if (list_empty(&lo->segs)) {
+	if (pnfs_layoutgets_blocked(lo, 1)) {
+		/* We avoid -EAGAIN, as that has special meaning to
+		 * some callers.
+		 */
+		status = -NFS4ERR_LAYOUTTRYLATER;
+	} else if (list_empty(&lo->segs)) {
 		int seq;
 
 		do {
@@ -405,10 +418,8 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	BUG_ON(ctx == NULL);
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
-	if (lgp == NULL) {
-		put_layout_hdr(lo->inode);
+	if (lgp == NULL)
 		return NULL;
-	}
 	lgp->args.minlength = NFS4_MAX_UINT64;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	lgp->args.range.iomode = iomode;
@@ -604,10 +615,16 @@ pnfs_update_layout(struct inode *ino,
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
-	get_layout_hdr_locked(lo); /* Matched in nfs4_layoutget_release */
+	if (pnfs_layoutgets_blocked(lo, 0))
+		goto out_unlock;
+	atomic_inc(&lo->plh_outstanding);
+
+	get_layout_hdr_locked(lo);
 	spin_unlock(&ino->i_lock);
 
 	lseg = send_layoutget(lo, ctx, iomode);
+	atomic_dec(&lo->plh_outstanding);
+	put_layout_hdr(ino);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 96b23bc..0b8070f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -69,6 +69,7 @@ struct pnfs_layout_hdr {
 	struct list_head	layouts;   /* other client layouts */
 	struct list_head	segs;      /* layout segments list */
 	nfs4_stateid		stateid;
+	atomic_t		plh_outstanding; /* number of RPCs out */
 	unsigned long		plh_flags;
 	struct inode		*inode;
 };
-- 
1.7.2.1

