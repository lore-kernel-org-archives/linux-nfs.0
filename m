Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47898 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752210AbaCWBMa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 30/50] nfsd4: allow encoding across page boundaries
Date: Sat, 22 Mar 2014 21:12:01 -0400
Message-Id: <1395537141-10389-31-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

After this we can handle for example getattr of very large ACLs.

Read, readdir, readlink are still special cases with their own limits.

Also we can't handle a new operation starting close to the end of a
page.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c         |  4 +++
 fs/nfsd/nfs4xdr.c          | 59 +++++++++++++++++++++++++----------
 include/linux/sunrpc/svc.h |  1 +
 include/linux/sunrpc/xdr.h |  1 +
 net/sunrpc/svc_xprt.c      |  1 +
 net/sunrpc/xdr.c           | 78 ++++++++++++++++++++++++++++++++++++++++++++--
 6 files changed, 125 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 54081d27..bc221e4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1224,6 +1224,10 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp, struct nfsd4_compoundres
 	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
 	/* Tail and page_len should be zero at this point: */
 	buf->len = buf->head[0].iov_len;
+	xdr->scratch.iov_len = 0;
+	xdr->page_ptr = buf->pages;
+	buf->buflen = PAGE_SIZE * (1 + rqstp->rq_page_end - buf->pages)
+		- 2 * RPC_MAX_AUTH_SIZE;
 }
 
 /*
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 062559c..8dc65f5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1625,6 +1625,7 @@ static int nfsd4_max_reply(u32 opnum)
 		 * the head and tail in another page:
 		 */
 		return 2 * PAGE_SIZE;
+	case OP_GETATTR:
 	case OP_READ:
 		return INT_MAX;
 	default:
@@ -2546,21 +2547,30 @@ out_resource:
 	goto out;
 }
 
+static void svcxdr_init_encode_from_buffer(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p, int bytes)
+{
+	xdr->scratch.iov_len = 0;
+	memset(buf, 0, sizeof(struct xdr_buf));
+	buf->head[0].iov_base = p;
+	buf->head[0].iov_len = 0;
+	buf->len = 0;
+	xdr->buf = buf;
+	xdr->iov = buf->head;
+	xdr->p = p;
+	xdr->end = (void *)p + bytes;
+	buf->buflen = bytes;
+}
+
 __be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
 			struct svc_fh *fhp, struct svc_export *exp,
 			struct dentry *dentry, u32 *bmval,
 	                struct svc_rqst *rqstp, int ignore_crossmnt)
 {
-	struct xdr_buf dummy = {
-			.head[0] = {
-				.iov_base = *p,
-			},
-			.buflen = words << 2,
-		};
+	struct xdr_buf dummy;
 	struct xdr_stream xdr;
 	__be32 ret;
 
-	xdr_init_encode(&xdr, &dummy, NULL);
+	svcxdr_init_encode_from_buffer(&xdr, &dummy, *p, words << 2);
 	ret = nfsd4_encode_fattr(&xdr, fhp, exp, dentry, bmval, rqstp, ignore_crossmnt);
 	*p = xdr.p;
 	return ret;
@@ -3048,8 +3058,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	if (nfserr)
 		return nfserr;
-	if (resp->xdr.buf->page_len)
-		return nfserr_resource;
 
 	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
 	if (!p)
@@ -3059,6 +3067,9 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
+	if (resp->xdr.buf->page_len)
+		return nfserr_resource;
+
 	maxcount = svc_max_payload(resp->rqstp);
 	if (maxcount > read->rd_length)
 		maxcount = read->rd_length;
@@ -3098,6 +3109,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 				- (char*)resp->xdr.buf->head[0].iov_base);
 	resp->xdr.buf->page_len = maxcount;
 	xdr->buf->len += maxcount;
+	xdr->page_ptr += v;
+	xdr->buf->buflen = maxcount + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
 	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
@@ -3124,6 +3137,11 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 
 	if (nfserr)
 		return nfserr;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return nfserr_resource;
+
 	if (resp->xdr.buf->page_len)
 		return nfserr_resource;
 	if (!*resp->rqstp->rq_next_page)
@@ -3133,10 +3151,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 
 	maxcount = PAGE_SIZE;
 
-	p = xdr_reserve_space(xdr, 4);
-	if (!p)
-		return nfserr_resource;
-
 	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
@@ -3159,6 +3173,8 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
 	xdr->buf->len += maxcount;
+	xdr->page_ptr += 1;
+	xdr->buf->buflen -= PAGE_SIZE;
 	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
@@ -3185,15 +3201,16 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	if (nfserr)
 		return nfserr;
-	if (resp->xdr.buf->page_len)
-		return nfserr_resource;
-	if (!*resp->rqstp->rq_next_page)
-		return nfserr_resource;
 
 	p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
 	if (!p)
 		return nfserr_resource;
 
+	if (resp->xdr.buf->page_len)
+		return nfserr_resource;
+	if (!*resp->rqstp->rq_next_page)
+		return nfserr_resource;
+
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
 	WRITE32(0);
 	WRITE32(0);
@@ -3245,6 +3262,10 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	xdr->iov = xdr->buf->tail;
 
+	xdr->page_ptr++;
+	xdr->buf->buflen -= PAGE_SIZE;
+	xdr->iov = xdr->buf->tail;
+
 	/* Use rest of head for padding and remaining ops: */
 	resp->xdr.buf->tail[0].iov_base = tailbase;
 	resp->xdr.buf->tail[0].iov_len = 0;
@@ -3777,6 +3798,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	       !nfsd4_enc_ops[op->opnum]);
 	encoder = nfsd4_enc_ops[op->opnum];
 	op->status = encoder(resp, op->status, &op->u);
+	xdr_commit_encode(xdr);
+
 	/* nfsd4_check_resp_size guarantees enough room for error status */
 	if (!op->status) {
 		int space_needed = 0;
@@ -3903,6 +3926,8 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	WARN_ON_ONCE(buf->len != buf->head[0].iov_len + buf->page_len +
 				 buf->tail[0].iov_len);
 
+	rqstp->rq_next_page = resp->xdr.page_ptr + 1;
+
 	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
 	memcpy(p, resp->tag, resp->taglen);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 04e7632..39c50e1 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -244,6 +244,7 @@ struct svc_rqst {
 	struct page *		rq_pages[RPCSVC_MAXPAGES];
 	struct page *		*rq_respages;	/* points into rq_pages */
 	struct page *		*rq_next_page; /* next reply page to use */
+	struct page *		*rq_page_end;  /* one past the last page */
 
 	struct kvec		rq_vec[RPCSVC_MAXPAGES]; /* generally useful.. */
 
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index e7bb2e3..b23d69f 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -215,6 +215,7 @@ typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
+extern void xdr_commit_encode(struct xdr_stream *xdr);
 extern void xdr_truncate_encode(struct xdr_stream *xdr, size_t len);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 80a6640..e455590 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -597,6 +597,7 @@ int svc_alloc_arg(struct svc_rqst *rqstp)
 			}
 			rqstp->rq_pages[i] = p;
 		}
+	rqstp->rq_page_end = &rqstp->rq_pages[i];
 	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
 
 	/* Make arg->head point to first page and arg->pages point to rest */
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 8ae8ee7..e65d6b6 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -462,6 +462,7 @@ void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 	struct kvec *iov = buf->head;
 	int scratch_len = buf->buflen - buf->page_len - buf->tail[0].iov_len;
 
+	xdr_set_scratch_buffer(xdr, NULL, 0);
 	BUG_ON(scratch_len < 0);
 	xdr->buf = buf;
 	xdr->iov = iov;
@@ -482,6 +483,74 @@ void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 EXPORT_SYMBOL_GPL(xdr_init_encode);
 
 /**
+ * xdr_commit_encode - Ensure all data is written to buffer
+ * @xdr: pointer to xdr_stream
+ *
+ * We handle encoding across page boundaries by giving the caller a
+ * temporary location to write to, then later copying the data into
+ * place; xdr_commit_encode does that copying.
+ *
+ * Normally the caller doesn't need to call this directly, as the
+ * following xdr_reserve_space will do it.  But an explicit call may be
+ * required at the end of encoding, or any other time when the xdr_buf
+ * data might be read.
+ */
+void xdr_commit_encode(struct xdr_stream *xdr)
+{
+	int shift = xdr->scratch.iov_len;
+	void *page;
+
+	if (shift == 0)
+		return;
+	page = page_address(*xdr->page_ptr);
+	memcpy(xdr->scratch.iov_base, page, shift);
+	memmove(page, page + shift, (void *)xdr->p - page);
+	xdr->scratch.iov_len = 0;
+}
+EXPORT_SYMBOL_GPL(xdr_commit_encode);
+
+__be32 * xdr_get_next_encode_buffer(struct xdr_stream *xdr, size_t nbytes)
+{
+	static __be32 *p;
+	int space_left;
+	int frag1bytes, frag2bytes;
+
+	if (nbytes > PAGE_SIZE)
+		return NULL; /* Bigger buffers require special handling */
+	if (xdr->buf->len + nbytes > xdr->buf->buflen)
+		return NULL; /* Sorry, we're totally out of space */
+	frag1bytes = (xdr->end - xdr->p) << 2;
+	frag2bytes = nbytes - frag1bytes;
+	if (xdr->iov)
+		xdr->iov->iov_len += frag1bytes;
+	else {
+		xdr->buf->page_len += frag1bytes;
+		xdr->page_ptr++;
+	}
+	xdr->iov = NULL;
+	/*
+	 * If the last encode didn't end exactly on a page boundary, the
+	 * next one will straddle boundaries.  Encode into the next
+	 * page, then copy it back later in xdr_commit_encode.  We use
+	 * the "scratch" iov to track any temporarily unused fragment of
+	 * space at the end of the previous buffer:
+	 */
+	xdr->scratch.iov_base = xdr->p;
+	xdr->scratch.iov_len = frag1bytes;
+	p = page_address(*xdr->page_ptr);
+	/*
+	 * Note this is where the next encode will start after we've
+	 * shifted this one back:
+	 */
+	xdr->p = (void *)p + frag2bytes;
+	space_left = xdr->buf->buflen - xdr->buf->len;
+	xdr->end = (void *)p + min_t(int, space_left, PAGE_SIZE);
+	xdr->buf->page_len += frag2bytes;
+	xdr->buf->len += nbytes;
+	return p;
+}
+
+/**
  * xdr_reserve_space - Reserve buffer space for sending
  * @xdr: pointer to xdr_stream
  * @nbytes: number of bytes to reserve
@@ -495,14 +564,18 @@ __be32 * xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes)
 	__be32 *p = xdr->p;
 	__be32 *q;
 
+	xdr_commit_encode(xdr);
 	/* align nbytes on the next 32-bit boundary */
 	nbytes += 3;
 	nbytes &= ~3;
 	q = p + (nbytes >> 2);
 	if (unlikely(q > xdr->end || q < p))
-		return NULL;
+		return xdr_get_next_encode_buffer(xdr, nbytes);
 	xdr->p = q;
-	xdr->iov->iov_len += nbytes;
+	if (xdr->iov)
+		xdr->iov->iov_len += nbytes;
+	else
+		xdr->buf->page_len += nbytes;
 	xdr->buf->len += nbytes;
 	return p;
 }
@@ -539,6 +612,7 @@ void xdr_truncate_encode(struct xdr_stream *xdr, size_t len)
 		WARN_ON_ONCE(1);
 		return;
 	}
+	xdr_commit_encode(xdr);
 
 	fraglen = min_t(int, buf->len - len, tail->iov_len);
 	tail->iov_len -= fraglen;
-- 
1.8.5.3

