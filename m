Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953Ab0LWMr5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 07:47:57 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/15] pnfs: serialize LAYOUTGET(openstateid)
Date: Thu, 23 Dec 2010 07:47:39 -0500
Message-Id: <1293108466-31768-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293108466-31768-1-git-send-email-iisaman@netapp.com>
References: <1293108466-31768-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We shouldn't send a LAYOUTGET(openstateid) unless all outstanding RPCs
using the previous stateid are completed.  This requires choosing the
stateid to encode earlier, so we can abort if one is not available (we
want to use the open stateid, but a LAYOUTGET is already out using
it), and adding a count of the number of outstanding rpc calls using
layout state (which for now consist solely of LAYOUTGETs).

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    7 ++++++-
 fs/nfs/nfs4xdr.c        |    5 +----
 fs/nfs/pnfs.c           |   24 +++++++++++++++++++-----
 fs/nfs/pnfs.h           |    1 +
 include/linux/nfs_xdr.h |    1 +
 5 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1609a07..3b059d3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5308,6 +5308,12 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	if (nfs4_setup_sequence(server, &lgp->args.seq_args,
 				&lgp->res.seq_res, 0, task))
 		return;
+	if (pnfs_choose_layoutget_stateid(&lgp->args.stateid,
+					  NFS_I(lgp->args.inode)->layout,
+					  lgp->args.ctx->state)) {
+		rpc_exit(task, NFS4_OK);
+		return;
+	}
 	rpc_call_start(task);
 }
 
@@ -5342,7 +5348,6 @@ static void nfs4_layoutget_release(void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	put_layout_hdr(lgp->args.inode);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	put_nfs_open_context(lgp->args.ctx);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e28242..3cbdd0c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1787,7 +1787,6 @@ encode_layoutget(struct xdr_stream *xdr,
 		      const struct nfs4_layoutget_args *args,
 		      struct compound_hdr *hdr)
 {
-	nfs4_stateid stateid;
 	__be32 *p;
 
 	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
@@ -1798,9 +1797,7 @@ encode_layoutget(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->range.offset);
 	p = xdr_encode_hyper(p, args->range.length);
 	p = xdr_encode_hyper(p, args->minlength);
-	pnfs_choose_layoutget_stateid(&stateid, NFS_I(args->inode)->layout,
-				args->ctx->state);
-	p = xdr_encode_opaque_fixed(p, &stateid.data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, &args->stateid.data, NFS4_STATEID_SIZE);
 	*p = cpu_to_be32(args->maxcount);
 
 	dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bbca2e5..60fbd41 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -362,6 +362,14 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 		memcpy(&lo->plh_stateid, &new->stateid, sizeof(new->stateid));
 }
 
+/* lget is set to 1 if called from inside send_layoutget call chain */
+static bool
+pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, int lget)
+{
+	return (list_empty(&lo->plh_segs) &&
+		 (atomic_read(&lo->plh_outstanding) > lget));
+}
+
 int
 pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			      struct nfs4_state *open_state)
@@ -370,7 +378,9 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
-	if (list_empty(&lo->plh_segs)) {
+	if (pnfs_layoutgets_blocked(lo, 1)) {
+		status = -EAGAIN;
+	} else if (list_empty(&lo->plh_segs)) {
 		int seq;
 
 		do {
@@ -405,10 +415,8 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	BUG_ON(ctx == NULL);
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
-	if (lgp == NULL) {
-		put_layout_hdr(lo->plh_inode);
+	if (lgp == NULL)
 		return NULL;
-	}
 	lgp->args.minlength = NFS4_MAX_UINT64;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	lgp->args.range.iomode = iomode;
@@ -604,10 +612,16 @@ pnfs_update_layout(struct inode *ino,
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
index 787253e..698380d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -69,6 +69,7 @@ struct pnfs_layout_hdr {
 	struct list_head	plh_layouts;   /* other client layouts */
 	struct list_head	plh_segs;      /* layout segments list */
 	nfs4_stateid		plh_stateid;
+	atomic_t		plh_outstanding; /* number of RPCs out */
 	unsigned long		plh_flags;
 	struct inode		*plh_inode;
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f923831..0843703 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -208,6 +208,7 @@ struct nfs4_layoutget_args {
 	struct inode *inode;
 	struct nfs_open_context *ctx;
 	struct nfs4_sequence_args seq_args;
+	nfs4_stateid stateid;
 };
 
 struct nfs4_layoutget_res {
-- 
1.7.2.1

