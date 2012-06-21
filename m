Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50079 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932777Ab2FUVvf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:35 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFS: Let xdr_read_pages() check for buffer overflows
Date: Thu, 21 Jun 2012 17:51:23 -0400
Message-Id: <1340315487-18309-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340315487-18309-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xdr_read_pages will already do all of the buffer overflow checks that are
currently being open-coded in the various callers. This patch simplifies
the existing code by replacing the open coded checks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs2xdr.c |   22 +++-------------------
 fs/nfs/nfs3xdr.c |   23 +++--------------------
 fs/nfs/nfs4xdr.c |   39 ++++++---------------------------------
 3 files changed, 12 insertions(+), 72 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index db81166..d04f0df 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -106,19 +106,16 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 static int decode_nfsdata(struct xdr_stream *xdr, struct nfs_readres *result)
 {
 	u32 recvd, count;
-	size_t hdrlen;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		goto out_overflow;
 	count = be32_to_cpup(p);
-	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
-	recvd = xdr->buf->len - hdrlen;
+	recvd = xdr_read_pages(xdr, count);
 	if (unlikely(count > recvd))
 		goto out_cheating;
 out:
-	xdr_read_pages(xdr, count);
 	result->eof = 0;	/* NFSv2 does not pass EOF flag on the wire. */
 	result->count = count;
 	return count;
@@ -440,7 +437,6 @@ static void encode_path(struct xdr_stream *xdr, struct page **pages, u32 length)
 static int decode_path(struct xdr_stream *xdr)
 {
 	u32 length, recvd;
-	size_t hdrlen;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
@@ -449,12 +445,9 @@ static int decode_path(struct xdr_stream *xdr)
 	length = be32_to_cpup(p);
 	if (unlikely(length >= xdr->buf->page_len || length > NFS_MAXPATHLEN))
 		goto out_size;
-	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
-	recvd = xdr->buf->len - hdrlen;
+	recvd = xdr_read_pages(xdr, length);
 	if (unlikely(length > recvd))
 		goto out_cheating;
-
-	xdr_read_pages(xdr, length);
 	xdr_terminate_string(xdr->buf, length);
 	return 0;
 out_size:
@@ -972,16 +965,7 @@ out_overflow:
  */
 static int decode_readdirok(struct xdr_stream *xdr)
 {
-	u32 recvd, pglen;
-	size_t hdrlen;
-
-	pglen = xdr->buf->page_len;
-	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
-	recvd = xdr->buf->len - hdrlen;
-	if (pglen > recvd)
-		pglen = recvd;
-	xdr_read_pages(xdr, pglen);
-	return pglen;
+	return xdr_read_pages(xdr, xdr->buf->page_len);
 }
 
 static int nfs2_xdr_dec_readdirres(struct rpc_rqst *req,
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 3c61c7f..d64a00f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -246,7 +246,6 @@ static void encode_nfspath3(struct xdr_stream *xdr, struct page **pages,
 static int decode_nfspath3(struct xdr_stream *xdr)
 {
 	u32 recvd, count;
-	size_t hdrlen;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
@@ -255,12 +254,9 @@ static int decode_nfspath3(struct xdr_stream *xdr)
 	count = be32_to_cpup(p);
 	if (unlikely(count >= xdr->buf->page_len || count > NFS3_MAXPATHLEN))
 		goto out_nametoolong;
-	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
-	recvd = xdr->buf->len - hdrlen;
+	recvd = xdr_read_pages(xdr, count);
 	if (unlikely(count > recvd))
 		goto out_cheating;
-
-	xdr_read_pages(xdr, count);
 	xdr_terminate_string(xdr->buf, count);
 	return 0;
 
@@ -1587,7 +1583,6 @@ static int decode_read3resok(struct xdr_stream *xdr,
 			     struct nfs_readres *result)
 {
 	u32 eof, count, ocount, recvd;
-	size_t hdrlen;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 + 4 + 4);
@@ -1598,13 +1593,10 @@ static int decode_read3resok(struct xdr_stream *xdr,
 	ocount = be32_to_cpup(p++);
 	if (unlikely(ocount != count))
 		goto out_mismatch;
-	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
-	recvd = xdr->buf->len - hdrlen;
+	recvd = xdr_read_pages(xdr, count);
 	if (unlikely(count > recvd))
 		goto out_cheating;
-
 out:
-	xdr_read_pages(xdr, count);
 	result->eof = eof;
 	result->count = count;
 	return count;
@@ -2039,16 +2031,7 @@ out_truncated:
  */
 static int decode_dirlist3(struct xdr_stream *xdr)
 {
-	u32 recvd, pglen;
-	size_t hdrlen;
-
-	pglen = xdr->buf->page_len;
-	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
-	recvd = xdr->buf->len - hdrlen;
-	if (pglen > recvd)
-		pglen = recvd;
-	xdr_read_pages(xdr, pglen);
-	return pglen;
+	return xdr_read_pages(xdr, xdr->buf->page_len);
 }
 
 static int decode_readdir3resok(struct xdr_stream *xdr,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 18fae29..2754f72 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4920,9 +4920,8 @@ static int decode_putrootfh(struct xdr_stream *xdr)
 
 static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_readres *res)
 {
-	struct kvec *iov = req->rq_rcv_buf.head;
 	__be32 *p;
-	uint32_t count, eof, recvd, hdrlen;
+	uint32_t count, eof, recvd;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_READ);
@@ -4933,15 +4932,13 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 		goto out_overflow;
 	eof = be32_to_cpup(p++);
 	count = be32_to_cpup(p);
-	hdrlen = (u8 *) xdr->p - (u8 *) iov->iov_base;
-	recvd = req->rq_rcv_buf.len - hdrlen;
+	recvd = xdr_read_pages(xdr, count);
 	if (count > recvd) {
 		dprintk("NFS: server cheating in read reply: "
 				"count %u > recvd %u\n", count, recvd);
 		count = recvd;
 		eof = 0;
 	}
-	xdr_read_pages(xdr, count);
 	res->eof = eof;
 	res->count = count;
 	return 0;
@@ -4952,10 +4949,6 @@ out_overflow:
 
 static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_readdir_res *readdir)
 {
-	struct xdr_buf	*rcvbuf = &req->rq_rcv_buf;
-	struct kvec	*iov = rcvbuf->head;
-	size_t		hdrlen;
-	u32		recvd, pglen = rcvbuf->page_len;
 	int		status;
 	__be32		verf[2];
 
@@ -4967,22 +4960,12 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	memcpy(verf, readdir->verifier.data, sizeof(verf));
 	dprintk("%s: verifier = %08x:%08x\n",
 			__func__, verf[0], verf[1]);
-
-	hdrlen = (char *) xdr->p - (char *) iov->iov_base;
-	recvd = rcvbuf->len - hdrlen;
-	if (pglen > recvd)
-		pglen = recvd;
-	xdr_read_pages(xdr, pglen);
-
-
-	return pglen;
+	return xdr_read_pages(xdr, xdr->buf->page_len);
 }
 
 static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	size_t hdrlen;
 	u32 len, recvd;
 	__be32 *p;
 	int status;
@@ -5000,14 +4983,12 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
 	}
-	hdrlen = (char *) xdr->p - (char *) iov->iov_base;
-	recvd = req->rq_rcv_buf.len - hdrlen;
+	recvd = xdr_read_pages(xdr, len);
 	if (recvd < len) {
 		dprintk("NFS: server cheating in readlink reply: "
 				"count %u > recvd %u\n", len, recvd);
 		return -EIO;
 	}
-	xdr_read_pages(xdr, len);
 	/*
 	 * The XDR encode routine has set things up so that
 	 * the link text will be copied directly into the
@@ -5066,7 +5047,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 	__be32 *savep, *bm_p;
 	uint32_t attrlen,
 		 bitmap[3] = {0};
-	struct kvec *iov = req->rq_rcv_buf.head;
 	int status;
 	size_t page_len = xdr->buf->page_len;
 
@@ -5089,7 +5069,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
-		size_t hdrlen;
 
 		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
 		 * are stored with the acl data to handle the problem of
@@ -5098,7 +5077,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 
 		/* We ignore &savep and don't do consistency checks on
 		 * the attr length.  Let userspace figure it out.... */
-		hdrlen = (u8 *)xdr->p - (u8 *)iov->iov_base;
 		attrlen += res->acl_data_offset;
 		if (attrlen > page_len) {
 			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
@@ -5707,9 +5685,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 	__be32 *p;
 	int status;
 	u32 layout_count;
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	u32 hdrlen, recvd;
+	u32 recvd;
 
 	status = decode_op_hdr(xdr, OP_LAYOUTGET);
 	if (status)
@@ -5746,8 +5722,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		res->type,
 		res->layoutp->len);
 
-	hdrlen = (u8 *) xdr->p - (u8 *) iov->iov_base;
-	recvd = req->rq_rcv_buf.len - hdrlen;
+	recvd = xdr_read_pages(xdr, res->layoutp->len);
 	if (res->layoutp->len > recvd) {
 		dprintk("NFS: server cheating in layoutget reply: "
 				"layout len %u > recvd %u\n",
@@ -5755,8 +5730,6 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		return -EINVAL;
 	}
 
-	xdr_read_pages(xdr, res->layoutp->len);
-
 	if (layout_count > 1) {
 		/* We only handle a length one array at the moment.  Any
 		 * further entries are just ignored.  Note that this means
-- 
1.7.10.2

