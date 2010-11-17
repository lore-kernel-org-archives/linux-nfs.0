Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:56972 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934635Ab0KQRp3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:45:29 -0500
Received: by pwj1 with SMTP id 1so274829pwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:45:28 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/17] NFS: Remove unused old NFSv3 encoder functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:45:25 -0500
Message-ID: <20101117174524.29177.33886.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  Remove unused legacy argument encoder functions, and any
now unused encoder helper functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs3xdr.c |  328 +-----------------------------------------------------
 1 files changed, 4 insertions(+), 324 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index a3c54da..831a987 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -131,12 +131,6 @@ static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
  * Common NFS XDR functions as inlines
  */
 static inline __be32 *
-xdr_encode_fhandle(__be32 *p, const struct nfs_fh *fh)
-{
-	return xdr_encode_array(p, fh->data, fh->size);
-}
-
-static inline __be32 *
 xdr_decode_fhandle(__be32 *p, struct nfs_fh *fh)
 {
 	if ((fh->size = ntohl(*p++)) <= NFS3_FHSIZE) {
@@ -564,21 +558,13 @@ static void encode_diropargs3(struct xdr_stream *xdr, const struct nfs_fh *fh,
 
 
 /*
- * NFS encode functions
+ * NFSv3 XDR encode functions
+ *
+ * NFSv3 argument types are defined in section 3.3 of RFC 1813:
+ * "NFS Version 3 Protocol Specification".
  */
 
 /*
- * Encode file handle argument
- */
-static int
-nfs3_xdr_fhandle(struct rpc_rqst *req, __be32 *p, struct nfs_fh *fh)
-{
-	p = xdr_encode_fhandle(p, fh);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.1  GETATTR3args
  *
  *	struct GETATTR3args {
@@ -596,21 +582,6 @@ static int nfs3_xdr_enc_getattr3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode SETATTR arguments
- */
-static int
-nfs3_xdr_sattrargs(struct rpc_rqst *req, __be32 *p, struct nfs3_sattrargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_sattr(p, args->sattr);
-	*p++ = htonl(args->guard);
-	if (args->guard)
-		p = xdr_encode_time3(p, &args->guardtime);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.2  SETATTR3args
  *
  *	union sattrguard3 switch (bool check) {
@@ -654,18 +625,6 @@ static int nfs3_xdr_enc_setattr3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode directory ops argument
- */
-static int
-nfs3_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs3_diropargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name, args->len);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.3  LOOKUP3args
  *
  *	struct LOOKUP3args {
@@ -683,30 +642,6 @@ static int nfs3_xdr_enc_lookup3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode REMOVE argument
- */
-static int
-nfs3_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name.name, args->name.len);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
- * Encode access() argument
- */
-static int
-nfs3_xdr_accessargs(struct rpc_rqst *req, __be32 *p, struct nfs3_accessargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	*p++ = htonl(args->access);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.4  ACCESS3args
  *
  *	struct ACCESS3args {
@@ -751,31 +686,6 @@ static int nfs3_xdr_enc_readlink3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Arguments to a READ call. Since we read data directly into the page
- * cache, we also set up the reply iovec here so that iov[1] points
- * exactly to the page we want to fetch.
- */
-static int
-nfs3_xdr_readargs(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
-	unsigned int replen;
-	u32 count = args->count;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_hyper(p, args->offset);
-	*p++ = htonl(count);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	/* Inline the page array */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS3_readres_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen,
-			 args->pages, args->pgbase, count);
-	req->rq_rcv_buf.flags |= XDRBUF_READ;
-	return 0;
-}
-
-/*
  * 3.3.6  READ3args
  *
  *	struct READ3args {
@@ -810,28 +720,6 @@ static int nfs3_xdr_enc_read3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Write arguments. Splice the buffer to be written into the iovec.
- */
-static int
-nfs3_xdr_writeargs(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
-{
-	struct xdr_buf *sndbuf = &req->rq_snd_buf;
-	u32 count = args->count;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_hyper(p, args->offset);
-	*p++ = htonl(count);
-	*p++ = htonl(args->stable);
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
  * 3.3.7  WRITE3args
  *
  *	enum stable_how {
@@ -878,26 +766,6 @@ static int nfs3_xdr_enc_write3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode CREATE arguments
- */
-static int
-nfs3_xdr_createargs(struct rpc_rqst *req, __be32 *p, struct nfs3_createargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name, args->len);
-
-	*p++ = htonl(args->createmode);
-	if (args->createmode == NFS3_CREATE_EXCLUSIVE) {
-		*p++ = args->verifier[0];
-		*p++ = args->verifier[1];
-	} else
-		p = xdr_encode_sattr(p, args->sattr);
-
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.8  CREATE3args
  *
  *	enum createmode3 {
@@ -948,19 +816,6 @@ static int nfs3_xdr_enc_create3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode MKDIR arguments
- */
-static int
-nfs3_xdr_mkdirargs(struct rpc_rqst *req, __be32 *p, struct nfs3_mkdirargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name, args->len);
-	p = xdr_encode_sattr(p, args->sattr);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.9  MKDIR3args
  *
  *	struct MKDIR3args {
@@ -980,23 +835,6 @@ static int nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode SYMLINK arguments
- */
-static int
-nfs3_xdr_symlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs3_symlinkargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fromfh);
-	p = xdr_encode_array(p, args->fromname, args->fromlen);
-	p = xdr_encode_sattr(p, args->sattr);
-	*p++ = htonl(args->pathlen);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	/* Copy the page */
-	xdr_encode_pages(&req->rq_snd_buf, args->pages, 0, args->pathlen);
-	return 0;
-}
-
-/*
  * 3.3.10  SYMLINK3args
  *
  *	struct symlinkdata3 {
@@ -1028,25 +866,6 @@ static int nfs3_xdr_enc_symlink3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode MKNOD arguments
- */
-static int
-nfs3_xdr_mknodargs(struct rpc_rqst *req, __be32 *p, struct nfs3_mknodargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_array(p, args->name, args->len);
-	*p++ = htonl(args->type);
-	p = xdr_encode_sattr(p, args->sattr);
-	if (args->type == NF3CHR || args->type == NF3BLK) {
-		*p++ = htonl(MAJOR(args->rdev));
-		*p++ = htonl(MINOR(args->rdev));
-	}
-
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.11  MKNOD3args
  *
  *	struct devicedata3 {
@@ -1127,20 +946,6 @@ static int nfs3_xdr_enc_remove3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode RENAME arguments
- */
-static int
-nfs3_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
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
  * 3.3.14  RENAME3args
  *
  *	struct RENAME3args {
@@ -1162,19 +967,6 @@ static int nfs3_xdr_enc_rename3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode LINK arguments
- */
-static int
-nfs3_xdr_linkargs(struct rpc_rqst *req, __be32 *p, struct nfs3_linkargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fromfh);
-	p = xdr_encode_fhandle(p, args->tofh);
-	p = xdr_encode_array(p, args->toname, args->tolen);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.15  LINK3args
  *
  *	struct LINK3args {
@@ -1194,34 +986,6 @@ static int nfs3_xdr_enc_link3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Encode arguments to readdir call
- */
-static int
-nfs3_xdr_readdirargs(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirargs *args)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
-	unsigned int replen;
-	u32 count = args->count;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_hyper(p, args->cookie);
-	*p++ = args->verf[0];
-	*p++ = args->verf[1];
-	if (args->plus) {
-		/* readdirplus: need dircount + buffer size.
-		 * We just make sure we make dircount big enough */
-		*p++ = htonl(count >> 3);
-	}
-	*p++ = htonl(count);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	/* Inline the page array */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS3_readdirres_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages, 0, count);
-	return 0;
-}
-
-/*
  * 3.3.16  READDIR3args
  *
  *	struct READDIR3args {
@@ -1416,19 +1180,6 @@ out_overflow_exit:
 }
 
 /*
- * Encode COMMIT arguments
- */
-static int
-nfs3_xdr_commitargs(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
-{
-	p = xdr_encode_fhandle(p, args->fh);
-	p = xdr_encode_hyper(p, args->offset);
-	*p++ = htonl(args->count);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * 3.3.21  COMMIT3args
  *
  *	struct COMMIT3args {
@@ -1460,29 +1211,6 @@ static int nfs3_xdr_enc_commit3args(struct rpc_rqst *req, __be32 *p,
 }
 
 #ifdef CONFIG_NFS_V3_ACL
-/*
- * Encode GETACL arguments
- */
-static int
-nfs3_xdr_getaclargs(struct rpc_rqst *req, __be32 *p,
-		    struct nfs3_getaclargs *args)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
-	unsigned int replen;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	*p++ = htonl(args->mask);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	if (args->mask & (NFS_ACL | NFS_DFACL)) {
-		/* Inline the page array */
-		replen = (RPC_REPHDRSIZE + auth->au_rslack +
-			  ACL3_getaclres_sz) << 2;
-		xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages, 0,
-				 NFSACL_MAXPAGES << PAGE_SHIFT);
-	}
-	return 0;
-}
 
 static int nfs3_xdr_enc_getacl3args(struct rpc_rqst *req, __be32 *p,
 				    const struct nfs3_getaclargs *args)
@@ -1499,39 +1227,6 @@ static int nfs3_xdr_enc_getacl3args(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-/*
- * Encode SETACL arguments
- */
-static int
-nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
-                   struct nfs3_setaclargs *args)
-{
-	struct xdr_buf *buf = &req->rq_snd_buf;
-	unsigned int base;
-	int err;
-
-	p = xdr_encode_fhandle(p, NFS_FH(args->inode));
-	*p++ = htonl(args->mask);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	base = req->rq_slen;
-
-	if (args->npages != 0)
-		xdr_encode_pages(buf, args->pages, 0, args->len);
-	else
-		req->rq_slen = xdr_adjust_iovec(req->rq_svec,
-				p + XDR_QUADLEN(args->len));
-
-	err = nfsacl_encode(buf, base, args->inode,
-			    (args->mask & NFS_ACL) ?
-			    args->acl_access : NULL, 1, 0);
-	if (err > 0)
-		err = nfsacl_encode(buf, base + err, args->inode,
-				    (args->mask & NFS_DFACL) ?
-				    args->acl_default : NULL, 1,
-				    NFS_ACL_DEFAULT);
-	return (err > 0) ? 0 : err;
-}
-
 static int nfs3_xdr_enc_setacl3args(struct rpc_rqst *req, __be32 *p,
 				    const struct nfs3_setaclargs *args)
 {
@@ -1633,21 +1328,6 @@ nfs3_xdr_accessres(struct rpc_rqst *req, __be32 *p, struct nfs3_accessres *res)
 	return 0;
 }
 
-static int
-nfs3_xdr_readlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs3_readlinkargs *args)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
-	unsigned int replen;
-
-	p = xdr_encode_fhandle(p, args->fh);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-
-	/* Inline the page array */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS3_readlinkres_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages, args->pgbase, args->pglen);
-	return 0;
-}
-
 /*
  * Decode READLINK reply
  */

