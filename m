Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58235 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757549Ab0LNOzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:55:24 -0500
Received: by iwn9 with SMTP id 9so860443iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:55:23 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/31] NFS: Replace old NFSv2 decoder functions with
	xdr_stream-based ones
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:55:20 -0500
Message-ID: <20101214145520.2293.42628.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  Remove unused legacy result decoder functions, and any
now unused decoder helper functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs2xdr.c |  253 +-----------------------------------------------------
 1 files changed, 4 insertions(+), 249 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 827d1b8..ae75116 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -91,15 +91,6 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 /*
  * Common NFS XDR functions as inlines
  */
-static inline __be32 *
-xdr_decode_fhandle(__be32 *p, struct nfs_fh *fhandle)
-{
-	/* NFSv2 handles have a fixed length */
-	fhandle->size = NFS2_FHSIZE;
-	memcpy(fhandle->data, p, NFS2_FHSIZE);
-	return p + XDR_QUADLEN(NFS2_FHSIZE);
-}
-
 static inline __be32*
 xdr_decode_time(__be32 *p, struct timespec *timep)
 {
@@ -642,48 +633,6 @@ static int nfs2_xdr_enc_readargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode READ reply
- */
-static int
-nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
-{
-	struct kvec *iov = req->rq_rcv_buf.head;
-	size_t hdrlen;
-	u32 count, recvd;
-	int status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	p = xdr_decode_fattr(p, res->fattr);
-
-	count = ntohl(*p++);
-	res->eof = 0;
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READ reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READ header is short. iovec will be shifted.\n");
-		xdr_shift_buf(&req->rq_rcv_buf, iov->iov_len - hdrlen);
-	}
-
-	recvd = req->rq_rcv_buf.len - hdrlen;
-	if (count > recvd) {
-		dprintk("NFS: server cheating in read reply: "
-			"count %u > recvd %u\n", count, recvd);
-		count = recvd;
-	}
-
-	dprintk("RPC:      readres OK count %u\n", count);
-	if (count < res->count)
-		res->count = count;
-
-	return count;
-}
-
-
-/*
  * 2.2.9.  writeargs
  *
  *	struct writeargs {
@@ -848,105 +797,11 @@ static int nfs2_xdr_enc_readdirargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode the result of a readdir call.
- * We're not really decoding anymore, we just leave the buffer untouched
- * and only check that it is syntactically correct.
- * The real decoding happens in nfs_decode_entry below, called directly
- * from nfs_readdir for each entry.
- */
-static int
-nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
-{
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	struct page **page;
-	size_t hdrlen;
-	unsigned int pglen, recvd;
-	int status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READDIR reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READDIR header is short. iovec will be shifted.\n");
-		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
-	}
-
-	pglen = rcvbuf->page_len;
-	recvd = rcvbuf->len - hdrlen;
-	if (pglen > recvd)
-		pglen = recvd;
-	page = rcvbuf->pages;
-	return pglen;
-}
-
-__be32 *
-nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_server *server, int plus)
-{
-	__be32 *p;
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	if (!ntohl(*p++)) {
-		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p))
-			goto out_overflow;
-		if (!ntohl(*p++))
-			return ERR_PTR(-EAGAIN);
-		entry->eof = 1;
-		return ERR_PTR(-EBADCOOKIE);
-	}
-
-	p = xdr_inline_decode(xdr, 8);
-	if (unlikely(!p))
-		goto out_overflow;
-
-	entry->ino	  = ntohl(*p++);
-	entry->len	  = ntohl(*p++);
-
-	p = xdr_inline_decode(xdr, entry->len + 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	entry->name	  = (const char *) p;
-	p		 += XDR_QUADLEN(entry->len);
-	entry->prev_cookie	  = entry->cookie;
-	entry->cookie	  = ntohl(*p++);
-
-	entry->d_type = DT_UNKNOWN;
-
-	p = xdr_inline_peek(xdr, 8);
-	if (p != NULL)
-		entry->eof = !p[0] && p[1];
-	else
-		entry->eof = 0;
-
-	return p;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EAGAIN);
-}
-
-/*
- * NFS XDR decode functions
- */
-/*
- * Decode simple status reply
+ * NFSv2 XDR decode functions
+ *
+ * NFSv2 result types are defined in section 2.2 of RFC 1094:
+ * "NFS: Network File System Protocol Specification".
  */
-static int
-nfs_xdr_stat(struct rpc_rqst *req, __be32 *p, void *dummy)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)) != 0)
-		status = nfs_stat_to_errno(status);
-	return status;
-}
 
 static int nfs2_xdr_dec_stat(struct rpc_rqst *req, __be32 *p,
 			     void *__unused)
@@ -967,21 +822,6 @@ out_default:
 	return nfs_stat_to_errno(status);
 }
 
-/*
- * Decode attrstat reply
- * GETATTR, SETATTR, WRITE
- */
-static int
-nfs_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	xdr_decode_fattr(p, fattr);
-	return 0;
-}
-
 static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, __be32 *p,
 				 struct nfs_fattr *result)
 {
@@ -991,22 +831,6 @@ static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, __be32 *p,
 	return decode_attrstat(&xdr, result);
 }
 
-/*
- * Decode diropres reply
- * LOOKUP, CREATE, MKDIR
- */
-static int
-nfs_xdr_diropres(struct rpc_rqst *req, __be32 *p, struct nfs_diropok *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	p = xdr_decode_fhandle(p, res->fh);
-	xdr_decode_fattr(p, res->fattr);
-	return 0;
-}
-
 static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, __be32 *p,
 				 struct nfs_diropok *result)
 {
@@ -1017,46 +841,6 @@ static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode READLINK reply
- */
-static int
-nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
-{
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	size_t hdrlen;
-	u32 len, recvd;
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	/* Convert length of symlink */
-	len = ntohl(*p++);
-	if (len >= rcvbuf->page_len) {
-		dprintk("nfs: server returned giant symlink!\n");
-		return -ENAMETOOLONG;
-	}
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READLINK reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READLINK header is short. iovec will be shifted.\n");
-		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
-	}
-	recvd = req->rq_rcv_buf.len - hdrlen;
-	if (recvd < len) {
-		dprintk("NFS: server cheating in readlink reply: "
-				"count %u > recvd %u\n", len, recvd);
-		return -EIO;
-	}
-
-	xdr_terminate_string(rcvbuf, len);
-	return 0;
-}
-
-/*
  * 2.2.6.  readlinkres
  *
  *	union readlinkres switch (stat status) {
@@ -1120,16 +904,6 @@ out_default:
 	return nfs_stat_to_errno(status);
 }
 
-/*
- * Decode WRITE reply
- */
-static int
-nfs_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
-{
-	res->verf->committed = NFS_FILE_SYNC;
-	return nfs_xdr_attrstat(req, p, res->fattr);
-}
-
 static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
 				 struct nfs_writeres *result)
 {
@@ -1275,25 +1049,6 @@ out_default:
 }
 
 /*
- * Decode STATFS reply
- */
-static int
-nfs_xdr_statfsres(struct rpc_rqst *req, __be32 *p, struct nfs2_fsstat *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-
-	res->tsize  = ntohl(*p++);
-	res->bsize  = ntohl(*p++);
-	res->blocks = ntohl(*p++);
-	res->bfree  = ntohl(*p++);
-	res->bavail = ntohl(*p++);
-	return 0;
-}
-
-/*
  * 2.2.18.  statfsres
  *
  *	union statfsres (stat status) {

