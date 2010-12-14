Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56545 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757903Ab0LNO44 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:56:56 -0500
Received: by gyb11 with SMTP id 11so373413gyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:56:55 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/31] NFS: Remove unused old NFSv3 decoder functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:56:52 -0500
Message-ID: <20101214145652.2293.59521.stgit@matisse.1015granger.net>
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

 fs/nfs/nfs3xdr.c |  512 ------------------------------------------------------
 1 files changed, 4 insertions(+), 508 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 19c7911..586587f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -129,38 +129,6 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 /*
  * Common NFS XDR functions as inlines
  */
-static inline __be32 *
-xdr_decode_fhandle(__be32 *p, struct nfs_fh *fh)
-{
-	if ((fh->size = ntohl(*p++)) <= NFS3_FHSIZE) {
-		memcpy(fh->data, p, fh->size);
-		return p + XDR_QUADLEN(fh->size);
-	}
-	return NULL;
-}
-
-static inline __be32 *
-xdr_decode_fhandle_stream(struct xdr_stream *xdr, struct nfs_fh *fh)
-{
-	__be32 *p;
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	fh->size = ntohl(*p++);
-
-	if (fh->size <= NFS3_FHSIZE) {
-		p = xdr_inline_decode(xdr, fh->size);
-		if (unlikely(!p))
-			goto out_overflow;
-		memcpy(fh->data, p, fh->size);
-		return p + XDR_QUADLEN(fh->size);
-	}
-	return NULL;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EIO);
-}
 
 /*
  * Encode/decode time.
@@ -221,51 +189,6 @@ xdr_decode_wcc_attr(__be32 *p, struct nfs_fattr *fattr)
 	return p;
 }
 
-static inline __be32 *
-xdr_decode_post_op_attr(__be32 *p, struct nfs_fattr *fattr)
-{
-	if (*p++)
-		p = xdr_decode_fattr(p, fattr);
-	return p;
-}
-
-static inline __be32 *
-xdr_decode_post_op_attr_stream(struct xdr_stream *xdr, struct nfs_fattr *fattr)
-{
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	if (ntohl(*p++)) {
-		p = xdr_inline_decode(xdr, 84);
-		if (unlikely(!p))
-			goto out_overflow;
-		p = xdr_decode_fattr(p, fattr);
-	}
-	return p;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EIO);
-}
-
-static inline __be32 *
-xdr_decode_pre_op_attr(__be32 *p, struct nfs_fattr *fattr)
-{
-	if (*p++)
-		return xdr_decode_wcc_attr(p, fattr);
-	return p;
-}
-
-
-static inline __be32 *
-xdr_decode_wcc_data(__be32 *p, struct nfs_fattr *fattr)
-{
-	p = xdr_decode_pre_op_attr(p, fattr);
-	return xdr_decode_post_op_attr(p, fattr);
-}
-
-
 /*
  * Encode/decode NFSv3 basic data types
  *
@@ -1404,52 +1327,6 @@ static int nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode the result of a readdir call.
- * We just check for syntactical correctness.
- */
-static int
-nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res)
-{
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	struct page **page;
-	size_t hdrlen;
-	u32 recvd, pglen;
-	int status;
-
-	status = ntohl(*p++);
-	/* Decode post_op_attrs */
-	p = xdr_decode_post_op_attr(p, res->dir_attr);
-	if (status)
-		return nfs_stat_to_errno(status);
-	/* Decode verifier cookie */
-	if (res->verf) {
-		res->verf[0] = *p++;
-		res->verf[1] = *p++;
-	} else {
-		p += 2;
-	}
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
-
-	return pglen;
-}
-
-/*
  * 3.3.21  COMMIT3args
  *
  *	struct COMMIT3args {
@@ -1526,22 +1403,11 @@ static int nfs3_xdr_enc_setacl3args(struct rpc_rqst *req, __be32 *p,
 #endif  /* CONFIG_NFS_V3_ACL */
 
 /*
- * NFS XDR decode functions
- */
-
-/*
- * Decode attrstat reply.
+ * NFSv3 XDR decode functions
+ *
+ * NFSv3 result types are defined in section 3.3 of RFC 1813:
+ * "NFS Version 3 Protocol Specification".
  */
-static int
-nfs3_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	xdr_decode_fattr(p, fattr);
-	return 0;
-}
 
 /*
  * 3.3.1  GETATTR3res
@@ -1578,21 +1444,6 @@ out_default:
 }
 
 /*
- * Decode status+wcc_data reply
- * SATTR, REMOVE, RMDIR
- */
-static int
-nfs3_xdr_wccstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		status = nfs_stat_to_errno(status);
-	xdr_decode_wcc_data(p, fattr);
-	return status;
-}
-
-/*
  * 3.3.2  SETATTR3res
  *
  *	struct SETATTR3resok {
@@ -1632,31 +1483,6 @@ out_status:
 	return nfs_stat_to_errno(status);
 }
 
-static int
-nfs3_xdr_removeres(struct rpc_rqst *req, __be32 *p, struct nfs_removeres *res)
-{
-	return nfs3_xdr_wccstat(req, p, res->dir_attr);
-}
-
-/*
- * Decode LOOKUP reply
- */
-static int
-nfs3_xdr_lookupres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++))) {
-		status = nfs_stat_to_errno(status);
-	} else {
-		if (!(p = xdr_decode_fhandle(p, res->fh)))
-			return -errno_NFSERR_IO;
-		p = xdr_decode_post_op_attr(p, res->fattr);
-	}
-	xdr_decode_post_op_attr(p, res->dir_attr);
-	return status;
-}
-
 /*
  * 3.3.3  LOOKUP3res
  *
@@ -1707,21 +1533,6 @@ out_default:
 }
 
 /*
- * Decode ACCESS reply
- */
-static int
-nfs3_xdr_accessres(struct rpc_rqst *req, __be32 *p, struct nfs3_accessres *res)
-{
-	int	status = ntohl(*p++);
-
-	p = xdr_decode_post_op_attr(p, res->fattr);
-	if (status)
-		return nfs_stat_to_errno(status);
-	res->access = ntohl(*p++);
-	return 0;
-}
-
-/*
  * 3.3.4  ACCESS3res
  *
  *	struct ACCESS3resok {
@@ -1764,52 +1575,6 @@ out_default:
 }
 
 /*
- * Decode READLINK reply
- */
-static int
-nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
-{
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	size_t hdrlen;
-	u32 len, recvd;
-	int	status;
-
-	status = ntohl(*p++);
-	p = xdr_decode_post_op_attr(p, fattr);
-
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-
-	/* Convert length of symlink */
-	len = ntohl(*p++);
-	if (len >= rcvbuf->page_len) {
-		dprintk("nfs: server returned giant symlink!\n");
-		return -ENAMETOOLONG;
-	}
-
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READLINK reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READLINK header is short. "
-			"iovec will be shifted.\n");
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
  * 3.3.5  READLINK3res
  *
  *	struct READLINK3resok {
@@ -1852,59 +1617,6 @@ out_default:
 }
 
 /*
- * Decode READ reply
- */
-static int
-nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
-{
-	struct kvec *iov = req->rq_rcv_buf.head;
-	size_t hdrlen;
-	u32 count, ocount, recvd;
-	int status;
-
-	status = ntohl(*p++);
-	p = xdr_decode_post_op_attr(p, res->fattr);
-
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-
-	/* Decode reply count and EOF flag. NFSv3 is somewhat redundant
-	 * in that it puts the count both in the res struct and in the
-	 * opaque data count. */
-	count    = ntohl(*p++);
-	res->eof = ntohl(*p++);
-	ocount   = ntohl(*p++);
-
-	if (ocount != count) {
-		dprintk("NFS: READ count doesn't match RPC opaque count.\n");
-		return -errno_NFSERR_IO;
-	}
-
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READ reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-       		return -errno_NFSERR_IO;
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
-		res->eof = 0;
-	}
-
-	if (count < res->count)
-		res->count = count;
-
-	return count;
-}
-
-/*
  * 3.3.6  READ3res
  *
  *	struct READ3resok {
@@ -1989,28 +1701,6 @@ out_status:
 }
 
 /*
- * Decode WRITE response
- */
-static int
-nfs3_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
-{
-	int	status;
-
-	status = ntohl(*p++);
-	p = xdr_decode_wcc_data(p, res->fattr);
-
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-
-	res->count = ntohl(*p++);
-	res->verf->committed = (enum nfs3_stable_how)ntohl(*p++);
-	res->verf->verifier[0] = *p++;
-	res->verf->verifier[1] = *p++;
-
-	return res->count;
-}
-
-/*
  * 3.3.7  WRITE3res
  *
  *	enum stable_how {
@@ -2083,33 +1773,6 @@ out_status:
 }
 
 /*
- * Decode a CREATE response
- */
-static int
-nfs3_xdr_createres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
-{
-	int	status;
-
-	status = ntohl(*p++);
-	if (status == 0) {
-		if (*p++) {
-			if (!(p = xdr_decode_fhandle(p, res->fh)))
-				return -errno_NFSERR_IO;
-			p = xdr_decode_post_op_attr(p, res->fattr);
-		} else {
-			memset(res->fh, 0, sizeof(*res->fh));
-			/* Do decode post_op_attr but set it to NULL */
-			p = xdr_decode_post_op_attr(p, res->fattr);
-			res->fattr->valid = 0;
-		}
-	} else {
-		status = nfs_stat_to_errno(status);
-	}
-	p = xdr_decode_wcc_data(p, res->dir_attr);
-	return status;
-}
-
-/*
  * 3.3.8  CREATE3res
  *
  *	struct CREATE3resok {
@@ -2215,21 +1878,6 @@ out_status:
 }
 
 /*
- * Decode RENAME reply
- */
-static int
-nfs3_xdr_renameres(struct rpc_rqst *req, __be32 *p, struct nfs_renameres *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)) != 0)
-		status = nfs_stat_to_errno(status);
-	p = xdr_decode_wcc_data(p, res->old_fattr);
-	p = xdr_decode_wcc_data(p, res->new_fattr);
-	return status;
-}
-
-/*
  * 3.3.14  RENAME3res
  *
  *	struct RENAME3resok {
@@ -2275,21 +1923,6 @@ out_status:
 }
 
 /*
- * Decode LINK reply
- */
-static int
-nfs3_xdr_linkres(struct rpc_rqst *req, __be32 *p, struct nfs3_linkres *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)) != 0)
-		status = nfs_stat_to_errno(status);
-	p = xdr_decode_post_op_attr(p, res->fattr);
-	p = xdr_decode_wcc_data(p, res->dir_attr);
-	return status;
-}
-
-/*
  * 3.3.15  LINK3res
  *
  *	struct LINK3resok {
@@ -2533,31 +2166,6 @@ out_default:
 }
 
 /*
- * Decode FSSTAT reply
- */
-static int
-nfs3_xdr_fsstatres(struct rpc_rqst *req, __be32 *p, struct nfs_fsstat *res)
-{
-	int		status;
-
-	status = ntohl(*p++);
-
-	p = xdr_decode_post_op_attr(p, res->fattr);
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-
-	p = xdr_decode_hyper(p, &res->tbytes);
-	p = xdr_decode_hyper(p, &res->fbytes);
-	p = xdr_decode_hyper(p, &res->abytes);
-	p = xdr_decode_hyper(p, &res->tfiles);
-	p = xdr_decode_hyper(p, &res->ffiles);
-	p = xdr_decode_hyper(p, &res->afiles);
-
-	/* ignore invarsec */
-	return 0;
-}
-
-/*
  * 3.3.18  FSSTAT3res
  *
  *	struct FSSTAT3resok {
@@ -2627,35 +2235,6 @@ out_status:
 }
 
 /*
- * Decode FSINFO reply
- */
-static int
-nfs3_xdr_fsinfores(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *res)
-{
-	int		status;
-
-	status = ntohl(*p++);
-
-	p = xdr_decode_post_op_attr(p, res->fattr);
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-
-	res->rtmax  = ntohl(*p++);
-	res->rtpref = ntohl(*p++);
-	res->rtmult = ntohl(*p++);
-	res->wtmax  = ntohl(*p++);
-	res->wtpref = ntohl(*p++);
-	res->wtmult = ntohl(*p++);
-	res->dtpref = ntohl(*p++);
-	p = xdr_decode_hyper(p, &res->maxfilesize);
-	p = xdr_decode_time3(p, &res->time_delta);
-
-	/* ignore properties */
-	res->lease_time = 0;
-	return 0;
-}
-
-/*
  * 3.3.19  FSINFO3res
  *
  *	struct FSINFO3resok {
@@ -2733,26 +2312,6 @@ out_status:
 }
 
 /*
- * Decode PATHCONF reply
- */
-static int
-nfs3_xdr_pathconfres(struct rpc_rqst *req, __be32 *p, struct nfs_pathconf *res)
-{
-	int		status;
-
-	status = ntohl(*p++);
-
-	p = xdr_decode_post_op_attr(p, res->fattr);
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-	res->max_link = ntohl(*p++);
-	res->max_namelen = ntohl(*p++);
-
-	/* ignore remaining fields */
-	return 0;
-}
-
-/*
  * 3.3.20  PATHCONF3res
  *
  *	struct PATHCONF3resok {
@@ -2817,24 +2376,6 @@ out_status:
 }
 
 /*
- * Decode COMMIT reply
- */
-static int
-nfs3_xdr_commitres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
-{
-	int		status;
-
-	status = ntohl(*p++);
-	p = xdr_decode_wcc_data(p, res->fattr);
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-
-	res->verf->verifier[0] = *p++;
-	res->verf->verifier[1] = *p++;
-	return 0;
-}
-
-/*
  * 3.3.21  COMMIT3res
  *
  *	struct COMMIT3resok {
@@ -2877,37 +2418,6 @@ out_status:
 }
 
 #ifdef CONFIG_NFS_V3_ACL
-/*
- * Decode GETACL reply
- */
-static int
-nfs3_xdr_getaclres(struct rpc_rqst *req, __be32 *p,
-		   struct nfs3_getaclres *res)
-{
-	struct xdr_buf *buf = &req->rq_rcv_buf;
-	int status = ntohl(*p++);
-	struct posix_acl **acl;
-	unsigned int *aclcnt;
-	int err, base;
-
-	if (status != 0)
-		return nfs_stat_to_errno(status);
-	p = xdr_decode_post_op_attr(p, res->fattr);
-	res->mask = ntohl(*p++);
-	if (res->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
-		return -EINVAL;
-	base = (char *)p - (char *)req->rq_rcv_buf.head->iov_base;
-
-	acl = (res->mask & NFS_ACL) ? &res->acl_access : NULL;
-	aclcnt = (res->mask & NFS_ACLCNT) ? &res->acl_access_count : NULL;
-	err = nfsacl_decode(buf, base, aclcnt, acl);
-
-	acl = (res->mask & NFS_DFACL) ? &res->acl_default : NULL;
-	aclcnt = (res->mask & NFS_DFACLCNT) ? &res->acl_default_count : NULL;
-	if (err > 0)
-		err = nfsacl_decode(buf, base + err, aclcnt, acl);
-	return (err > 0) ? 0 : err;
-}
 
 static inline int decode_getacl3resok(struct xdr_stream *xdr,
 				      struct nfs3_getaclres *result)
@@ -2973,20 +2483,6 @@ out_default:
 	return nfs_stat_to_errno(status);
 }
 
-/*
- * Decode setacl reply.
- */
-static int
-nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
-{
-	int status = ntohl(*p++);
-
-	if (status)
-		return nfs_stat_to_errno(status);
-	xdr_decode_post_op_attr(p, fattr);
-	return 0;
-}
-
 static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req, __be32 *p,
 				   struct nfs_fattr *result)
 {

