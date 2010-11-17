From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/17] NFS: Remove old NFSv2 encoder functions
Date: Wed, 17 Nov 2010 12:43:51 -0500
Message-ID: <20101117174351.29177.51865.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:39067 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934871Ab0KQRn4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:43:56 -0500
Received: by pzk28 with SMTP id 28so569886pzk.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:43:56 -0800 (PST)
In-Reply-To: <20101117174112.29177.69734.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Remove unused legacy argument encoder functions, and any
now unused encoder helper functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs2xdr.c |  249 +-----------------------------------------------------
 1 files changed, 4 insertions(+), 245 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 77a3eb9..0110108 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -82,13 +82,6 @@ static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
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
@@ -160,36 +153,6 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
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
  * Encode/decode NFSv2 basic data types
  *
@@ -321,19 +284,11 @@ static void encode_diropargs(struct xdr_stream *xdr, const struct nfs_fh *fh,
 
 
 /*
- * NFS encode functions
- */
-/*
- * Encode file handle argument
- * GETATTR, READLINK, STATFS
+ * NFSv2 XDR encode functions
+ *
+ * NFSv2 argument types are defined in section 2.2 of RFC 1094:
+ * "NFS: Network File System Protocol Specification".
  */
-static int
-nfs_xdr_fhandle(struct rpc_rqst *req, __be32 *p, struct nfs_fh *fh)
-{
-	p = xdr_encode_fhandle(p, fh);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
 
 static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
 				const struct nfs_fh *fh)
@@ -346,18 +301,6 @@ static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
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
@@ -376,19 +319,6 @@ static int nfs2_xdr_enc_sattrargs(struct rpc_rqst *req, __be32 *p,
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
 				  const struct nfs_diropargs *args)
 {
@@ -399,18 +329,6 @@ static int nfs2_xdr_enc_diropargs(struct rpc_rqst *req, __be32 *p,
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
 static int nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req, __be32 *p,
 				     const struct nfs_readlinkargs *args)
 {
@@ -424,33 +342,6 @@ static int nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Arguments to a READ call. Since we read data directly into the page
- * cache, we also set up the reply iovec here so that iov[1] points
- * exactly to the page we want to fetch.
- */
-static int
-nfs_xdr_readargs(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
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
@@ -531,29 +422,6 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 
 
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
@@ -595,20 +463,6 @@ static int nfs2_xdr_enc_writeargs(struct rpc_rqst *req, __be32 *p,
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
@@ -638,20 +492,6 @@ static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode RENAME arguments
- */
-static int
-nfs_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
-{
-	p = xdr_encode_fhandle(p, args->old_dir);
-	p = xdr_encode_array(p, args->old_name->name, args->old_name->len);
-	p = xdr_encode_fhandle(p, args->new_dir);
-	p = xdr_encode_array(p, args->new_name->name, args->new_name->len);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 2.2.12.  renameargs
  *
  *	struct renameargs {
@@ -673,19 +513,6 @@ static int nfs2_xdr_enc_renameargs(struct rpc_rqst *req, __be32 *p,
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
@@ -705,35 +532,6 @@ static int nfs2_xdr_enc_linkargs(struct rpc_rqst *req, __be32 *p,
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
@@ -755,27 +553,6 @@ static int nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode arguments to readdir call
- */
-static int
-nfs_xdr_readdirargs(struct rpc_rqst *req, __be32 *p, struct nfs_readdirargs *args)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
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
@@ -946,24 +723,6 @@ nfs_xdr_diropres(struct rpc_rqst *req, __be32 *p, struct nfs_diropok *res)
 }
 
 /*
- * Encode READLINK args
- */
-static int
-nfs_xdr_readlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs_readlinkargs *args)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
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

