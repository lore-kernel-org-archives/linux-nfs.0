Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33038 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944Ab0IQQ3U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:29:20 -0400
Received: by yxp4 with SMTP id 4so789516yxp.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:29:19 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/22] NFS: Remove unused old NFSv3 decoder functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:29:16 -0400
Message-ID: <20100917162916.19761.59460.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c |  526 ------------------------------------------------------
 1 files changed, 4 insertions(+), 522 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 0b025b1..efa3dd6 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -206,22 +206,6 @@ xdr_decode_post_op_attr(__be32 *p, struct nfs_fattr *fattr)
 	return p;
 }
 
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
 
 /*
  * Encode/decode NFSv3 basic data types
@@ -1303,128 +1287,6 @@ static int nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req, __be32 *p,
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
-	u32 len, recvd, pglen;
-	int status, nr = 0;
-	__be32 *entry, *end, *kaddr;
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
-	kaddr = p = kmap_atomic(*page, KM_USER0);
-	end = (__be32 *)((char *)p + pglen);
-	entry = p;
-
-	/* Make sure the packet actually has a value_follows and EOF entry */
-	if ((entry + 1) > end)
-		goto short_pkt;
-
-	for (; *p++; nr++) {
-		if (p + 3 > end)
-			goto short_pkt;
-		p += 2;				/* inode # */
-		len = ntohl(*p++);		/* string length */
-		p += XDR_QUADLEN(len) + 2;	/* name + cookie */
-		if (len > NFS3_MAXNAMLEN) {
-			dprintk("NFS: giant filename in readdir (len 0x%x)!\n",
-						len);
-			goto err_unmap;
-		}
-
-		if (res->plus) {
-			/* post_op_attr */
-			if (p + 2 > end)
-				goto short_pkt;
-			if (*p++) {
-				p += 21;
-				if (p + 1 > end)
-					goto short_pkt;
-			}
-			/* post_op_fh3 */
-			if (*p++) {
-				if (p + 1 > end)
-					goto short_pkt;
-				len = ntohl(*p++);
-				if (len > NFS3_FHSIZE) {
-					dprintk("NFS: giant filehandle in "
-						"readdir (len 0x%x)!\n", len);
-					goto err_unmap;
-				}
-				p += XDR_QUADLEN(len);
-			}
-		}
-
-		if (p + 2 > end)
-			goto short_pkt;
-		entry = p;
-	}
-
-	/*
-	 * Apparently some server sends responses that are a valid size, but
-	 * contain no entries, and have value_follows==0 and EOF==0. For
-	 * those, just set the EOF marker.
-	 */
-	if (!nr && entry[1] == 0) {
-		dprintk("NFS: readdir reply truncated!\n");
-		entry[1] = 1;
-	}
- out:
-	kunmap_atomic(kaddr, KM_USER0);
-	return nr;
- short_pkt:
-	/*
-	 * When we get a short packet there are 2 possibilities. We can
-	 * return an error, or fix up the response to look like a valid
-	 * response and return what we have so far. If there are no
-	 * entries and the packet was short, then return -EIO. If there
-	 * are valid entries in the response, return them and pretend that
-	 * the call was successful, but incomplete. The caller can retry the
-	 * readdir starting at the last cookie.
-	 */
-	entry[0] = entry[1] = 0;
-	if (!nr)
-		nr = -errno_NFSERR_IO;
-	goto out;
-err_unmap:
-	nr = -errno_NFSERR_IO;
-	goto out;
-}
-
-/*
  * 3.3.21  COMMIT3args
  *
  *	struct COMMIT3args {
@@ -1501,24 +1363,13 @@ static int nfs3_xdr_enc_setacl3args(struct rpc_rqst *req, __be32 *p,
 #endif  /* CONFIG_NFS_V3_ACL */
 
 /*
- * NFS XDR decode functions
+ * NFSv3 XDR decode functions
+ *
+ * NFSv3 result types are defined in section 3.3 of RFC 1813:
+ * "NFS Version 3 Protocol Specification".
  */
 
 /*
- * Decode attrstat reply.
- */
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
-
-/*
  * 3.3.1  GETATTR3res
  *
  *	struct GETATTR3resok {
@@ -1553,21 +1404,6 @@ out_default:
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
@@ -1607,31 +1443,6 @@ out_status:
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
@@ -1682,21 +1493,6 @@ out_default:
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
@@ -1739,52 +1535,6 @@ out_default:
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
@@ -1827,59 +1577,6 @@ out_default:
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
@@ -1964,28 +1661,6 @@ out_status:
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
@@ -2058,33 +1733,6 @@ out_status:
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
@@ -2190,21 +1838,6 @@ out_status:
 }
 
 /*
- * Decode RENAME reply
- */
-static int
-nfs3_xdr_renameres(struct rpc_rqst *req, __be32 *p, struct nfs3_renameres *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)) != 0)
-		status = nfs_stat_to_errno(status);
-	p = xdr_decode_wcc_data(p, res->fromattr);
-	p = xdr_decode_wcc_data(p, res->toattr);
-	return status;
-}
-
-/*
  * 3.3.14  RENAME3res
  *
  *	struct RENAME3resok {
@@ -2250,21 +1883,6 @@ out_status:
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
@@ -2556,31 +2174,6 @@ out_truncated:
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
@@ -2650,34 +2243,6 @@ out_status:
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
-
-	/* ignore time_delta and properties */
-	res->lease_time = 0;
-	return 0;
-}
-
-/*
  * 3.3.19  FSINFO3res
  *
  *	struct FSINFO3resok {
@@ -2753,26 +2318,6 @@ out_status:
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
@@ -2837,24 +2382,6 @@ out_status:
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
@@ -2897,37 +2424,6 @@ out_status:
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
@@ -2993,20 +2489,6 @@ out_default:
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

