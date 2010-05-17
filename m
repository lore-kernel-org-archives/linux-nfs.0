From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/24] NFS: Replace old NFSv2 encoder functions with
	xdr_stream-based ones
Date: Sun, 16 May 2010 22:47:41 -0400
Message-ID: <20100517024741.20258.23739.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab0EQCrn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:47:43 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:47:43 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |  273 ------------------------------------------------------
 1 files changed, 1 insertions(+), 272 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 47809ac..eb86e55 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -407,13 +407,6 @@ static int decode_diropok(struct xdr_stream *xdr, struct nfs_fh *fh,
  * Common NFS XDR functions as inlines
  */
 static inline __be32 *
-xdr_encode_fhandle(__be32 *p, const struct nfs_fh *fhandle)
-{
-	memcpy(p, fhandle->data, NFS2_FHSIZE);
-	return p + XDR_QUADLEN(NFS2_FHSIZE);
-}
-
-static inline __be32 *
 xdr_decode_fhandle(__be32 *p, struct nfs_fh *fhandle)
 {
 	/* NFSv2 handles have a fixed length */
@@ -423,32 +416,6 @@ xdr_decode_fhandle(__be32 *p, struct nfs_fh *fhandle)
 }
 
 static inline __be32*
-xdr_encode_time(__be32 *p, struct timespec *timep)
-{
-	*p++ = htonl(timep->tv_sec);
-	/* Convert nanoseconds into microseconds */
-	*p++ = htonl(timep->tv_nsec ? timep->tv_nsec / 1000 : 0);
-	return p;
-}
-
-static inline __be32*
-xdr_encode_current_server_time(__be32 *p, struct timespec *timep)
-{
-	/*
-	 * Passing the invalid value useconds=1000000 is a
-	 * Sun convention for "set to current server time".
-	 * It's needed to make permissions checks for the
-	 * "touch" program across v2 mounts to Solaris and
-	 * Irix boxes work correctly. See description of
-	 * sattr in section 6.1 of "NFS Illustrated" by
-	 * Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5
-	 */
-	*p++ = htonl(timep->tv_sec);
-	*p++ = htonl(1000000);
-	return p;
-}
-
-static inline __be32*
 xdr_decode_time(__be32 *p, struct timespec *timep)
 {
 	timep->tv_sec = ntohl(*p++);
@@ -485,50 +452,9 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 	return p;
 }
 
-static inline __be32 *
-xdr_encode_sattr(__be32 *p, struct iattr *attr)
-{
-	const __be32 not_set = __constant_htonl(0xFFFFFFFF);
-
-	*p++ = (attr->ia_valid & ATTR_MODE) ? htonl(attr->ia_mode) : not_set;
-	*p++ = (attr->ia_valid & ATTR_UID) ? htonl(attr->ia_uid) : not_set;
-	*p++ = (attr->ia_valid & ATTR_GID) ? htonl(attr->ia_gid) : not_set;
-	*p++ = (attr->ia_valid & ATTR_SIZE) ? htonl(attr->ia_size) : not_set;
-
-	if (attr->ia_valid & ATTR_ATIME_SET) {
-		p = xdr_encode_time(p, &attr->ia_atime);
-	} else if (attr->ia_valid & ATTR_ATIME) {
-		p = xdr_encode_current_server_time(p, &attr->ia_atime);
-	} else {
-		*p++ = not_set;
-		*p++ = not_set;
-	}
-
-	if (attr->ia_valid & ATTR_MTIME_SET) {
-		p = xdr_encode_time(p, &attr->ia_mtime);
-	} else if (attr->ia_valid & ATTR_MTIME) {
-		p = xdr_encode_current_server_time(p, &attr->ia_mtime);
-	} else {
-		*p++ = not_set;	
-		*p++ = not_set;
-	}
-  	return p;
-}
-
 /*
  * NFS encode functions
  */
-/*
- * Encode file handle argument
- * GETATTR, READLINK, STATFS
- */
-static int
-nfs_xdr_fhandle(struct rpc_rqst *req, __be32 *p, struct nfs_fh *fh)
-{
-	p = xdr_encode_fhandle(p, fh);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
 
 static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
 				struct nfs_fh *fh)
@@ -541,18 +467,6 @@ static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode SETATTR arguments
- */
-static int
-nfs_xdr_sattrargs(struct rpc_rqst *req, __be32 *p, struct nfs_sattrargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_sattr(p, args->sattr);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 2.2.3.  sattrargs
  *
  *	struct sattrargs {
@@ -571,19 +485,6 @@ static int nfs2_xdr_enc_sattrargs(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-/*
- * Encode directory ops argument
- * LOOKUP, RMDIR
- */
-static int
-nfs_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs_diropargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name, args->len);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
 static int nfs2_xdr_enc_diropargs(struct rpc_rqst *req, __be32 *p,
 				  struct nfs_diropargs *args)
 {
@@ -594,18 +495,6 @@ static int nfs2_xdr_enc_diropargs(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-/*
- * Encode REMOVE argument
- */
-static int
-nfs_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name.name, args->name.len);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
 static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req, __be32 *p,
 				   struct nfs_removeargs *args)
 {
@@ -634,33 +523,6 @@ static int nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Arguments to a READ call. Since we read data directly into the page
- * cache, we also set up the reply iovec here so that iov[1] points
- * exactly to the page we want to fetch.
- */
-static int
-nfs_xdr_readargs(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
-{
-	struct rpc_auth	*auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
-	unsigned int replen;
-	u32 offset = (u32)args->offset;
-	u32 count = args->count;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	*p++ = htonl(offset);
-	*p++ = htonl(count);
-	*p++ = htonl(count);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	/* Inline the page array */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readres_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen,
-			 args->pages, args->pgbase, count);
-	req->rq_rcv_buf.flags |= XDRBUF_READ;
-	return 0;
-}
-
-/*
  * 2.2.7.  readargs
  *
  *	struct readargs {
@@ -738,29 +600,6 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 
 
 /*
- * Write arguments. Splice the buffer to be written into the iovec.
- */
-static int
-nfs_xdr_writeargs(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
-{
-	struct xdr_buf *sndbuf = &req->rq_snd_buf;
-	u32 offset = (u32)args->offset;
-	u32 count = args->count;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	*p++ = htonl(offset);
-	*p++ = htonl(offset);
-	*p++ = htonl(count);
-	*p++ = htonl(count);
-	sndbuf->len = xdr_adjust_iovec(sndbuf->head, p);
-
-	/* Copy the page array */
-	xdr_encode_pages(sndbuf, args->pages, args->pgbase, count);
-	sndbuf->flags |= XDRBUF_WRITE;
-	return 0;
-}
-
-/*
  * 2.2.9.  writeargs
  *
  *	struct writeargs {
@@ -796,20 +635,6 @@ static int nfs2_xdr_enc_writeargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode create arguments
- * CREATE, MKDIR
- */
-static int
-nfs_xdr_createargs(struct rpc_rqst *req, __be32 *p, struct nfs_createargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name, args->len);
-	p = xdr_encode_sattr(p, args->sattr);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 2.2.10.  createargs
  *
  *	struct createargs {
@@ -829,20 +654,6 @@ static int nfs2_xdr_enc_createargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode RENAME arguments
- */
-static int
-nfs_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fromfh);
-	p = xdr_encode_array(p, args->fromname, args->fromlen);
-	p = xdr_encode_fhandle(p, args->tofh);
-	p = xdr_encode_array(p, args->toname, args->tolen);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 2.2.12.  renameargs
  *
  *	struct renameargs {
@@ -862,19 +673,6 @@ static int nfs2_xdr_enc_renameargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode LINK arguments
- */
-static int
-nfs_xdr_linkargs(struct rpc_rqst *req, __be32 *p, struct nfs_linkargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fromfh);
-	p = xdr_encode_fhandle(p, args->tofh);
-	p = xdr_encode_array(p, args->toname, args->tolen);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 2.2.13.  linkargs
  *
  *	struct linkargs {
@@ -894,35 +692,6 @@ static int nfs2_xdr_enc_linkargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode SYMLINK arguments
- */
-static int
-nfs_xdr_symlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs_symlinkargs *args)
-{
-	struct xdr_buf *sndbuf = &req->rq_snd_buf;
-	size_t pad;
-
-	p = xdr_encode_fhandle(p, args->fromfh);
-	p = xdr_encode_array(p, args->fromname, args->fromlen);
-	*p++ = htonl(args->pathlen);
-	sndbuf->len = xdr_adjust_iovec(sndbuf->head, p);
-
-	xdr_encode_pages(sndbuf, args->pages, 0, args->pathlen);
-
-	/*
-	 * xdr_encode_pages may have added a few bytes to ensure the
-	 * pathname ends on a 4-byte boundary.  Start encoding the
-	 * attributes after the pad bytes.
-	 */
-	pad = sndbuf->tail->iov_len;
-	if (pad > 0)
-		p++;
-	p = xdr_encode_sattr(p, args->sattr);
-	sndbuf->len += xdr_adjust_iovec(sndbuf->tail, p) - pad;
-	return 0;
-}
-
-/*
  * 2.2.14.  symlinkargs
  *
  *	struct symlinkargs {
@@ -944,28 +713,6 @@ static int nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode arguments to readdir call
- */
-static int
-nfs_xdr_readdirargs(struct rpc_rqst *req, __be32 *p, struct nfs_readdirargs *args)
-{
-	struct rpc_task	*task = req->rq_task;
-	struct rpc_auth	*auth = task->tk_msg.rpc_cred->cr_auth;
-	unsigned int replen;
-	u32 count = args->count;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	*p++ = htonl(args->cookie);
-	*p++ = htonl(count); /* see above */
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	/* Inline the page array */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readdirres_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages, 0, count);
-	return 0;
-}
-
-/*
  * 2.2.17.  readdirargs
  *
  *	struct readdirargs {
@@ -1156,24 +903,6 @@ nfs_xdr_diropres(struct rpc_rqst *req, __be32 *p, struct nfs_diropok *res)
 }
 
 /*
- * Encode READLINK args
- */
-static int
-nfs_xdr_readlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs_readlinkargs *args)
-{
-	struct rpc_auth	*auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
-	unsigned int replen;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	/* Inline the page array */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readlinkres_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages, args->pgbase, args->pglen);
-	return 0;
-}
-
-/*
  * Decode READLINK reply
  */
 static int
@@ -1306,7 +1035,7 @@ nfs_stat_to_errno(int stat)
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
-	.p_encode   =  (kxdrproc_t) nfs_xdr_##argtype,			\
+	.p_encode   =  (kxdrproc_t) nfs2_xdr_enc_##argtype,		\
 	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\

