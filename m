From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/33] nfs: return negative error value from nfs{,
	4}_stat_to_errno
Date: Sat, 19 Apr 2008 16:40:52 -0400
Message-ID: <20080419204052.14124.94887.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18330 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756257AbYDSUu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:26 -0400
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

All use sites for nfs{,4}_stat_to_errno negate their return value.
It's more efficient to return a negative error from the stat_to_errno convertors
rather than negating its return value everywhere. This also produces slightly
smaller code.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs2xdr.c |   76 ++++++++++++++++++++++++++-------------------------
 fs/nfs/nfs3xdr.c |   34 +++++++++++------------
 fs/nfs/nfs4xdr.c |   80 +++++++++++++++++++++++++++---------------------------
 3 files changed, 95 insertions(+), 95 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 86a80b3..28bab67 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -267,7 +267,7 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	int status;
 
 	if ((status = ntohl(*p++)))
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	p = xdr_decode_fattr(p, res->fattr);
 
 	count = ntohl(*p++);
@@ -432,7 +432,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	__be32 *end, *entry, *kaddr;
 
 	if ((status = ntohl(*p++)))
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
@@ -537,7 +537,7 @@ nfs_xdr_stat(struct rpc_rqst *req, __be32 *p, void *dummy)
 	int	status;
 
 	if ((status = ntohl(*p++)) != 0)
-		status = -nfs_stat_to_errno(status);
+		status = nfs_stat_to_errno(status);
 	return status;
 }
 
@@ -551,7 +551,7 @@ nfs_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	int	status;
 
 	if ((status = ntohl(*p++)))
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	xdr_decode_fattr(p, fattr);
 	return 0;
 }
@@ -566,7 +566,7 @@ nfs_xdr_diropres(struct rpc_rqst *req, __be32 *p, struct nfs_diropok *res)
 	int	status;
 
 	if ((status = ntohl(*p++)))
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	p = xdr_decode_fhandle(p, res->fh);
 	xdr_decode_fattr(p, res->fattr);
 	return 0;
@@ -604,7 +604,7 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	int	status;
 
 	if ((status = ntohl(*p++)))
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	/* Convert length of symlink */
 	len = ntohl(*p++);
 	if (len >= rcvbuf->page_len) {
@@ -653,7 +653,7 @@ nfs_xdr_statfsres(struct rpc_rqst *req, __be32 *p, struct nfs2_fsstat *res)
 	int	status;
 
 	if ((status = ntohl(*p++)))
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	res->tsize  = ntohl(*p++);
 	res->bsize  = ntohl(*p++);
@@ -672,39 +672,39 @@ static struct {
 	int errno;
 } nfs_errtbl[] = {
 	{ NFS_OK,		0		},
-	{ NFSERR_PERM,		EPERM		},
-	{ NFSERR_NOENT,		ENOENT		},
-	{ NFSERR_IO,		errno_NFSERR_IO	},
-	{ NFSERR_NXIO,		ENXIO		},
-/*	{ NFSERR_EAGAIN,	EAGAIN		}, */
-	{ NFSERR_ACCES,		EACCES		},
-	{ NFSERR_EXIST,		EEXIST		},
-	{ NFSERR_XDEV,		EXDEV		},
-	{ NFSERR_NODEV,		ENODEV		},
-	{ NFSERR_NOTDIR,	ENOTDIR		},
-	{ NFSERR_ISDIR,		EISDIR		},
-	{ NFSERR_INVAL,		EINVAL		},
-	{ NFSERR_FBIG,		EFBIG		},
-	{ NFSERR_NOSPC,		ENOSPC		},
-	{ NFSERR_ROFS,		EROFS		},
-	{ NFSERR_MLINK,		EMLINK		},
-	{ NFSERR_NAMETOOLONG,	ENAMETOOLONG	},
-	{ NFSERR_NOTEMPTY,	ENOTEMPTY	},
-	{ NFSERR_DQUOT,		EDQUOT		},
-	{ NFSERR_STALE,		ESTALE		},
-	{ NFSERR_REMOTE,	EREMOTE		},
+	{ NFSERR_PERM,		-EPERM		},
+	{ NFSERR_NOENT,		-ENOENT		},
+	{ NFSERR_IO,		-errno_NFSERR_IO},
+	{ NFSERR_NXIO,		-ENXIO		},
+/*	{ NFSERR_EAGAIN,	-EAGAIN		}, */
+	{ NFSERR_ACCES,		-EACCES		},
+	{ NFSERR_EXIST,		-EEXIST		},
+	{ NFSERR_XDEV,		-EXDEV		},
+	{ NFSERR_NODEV,		-ENODEV		},
+	{ NFSERR_NOTDIR,	-ENOTDIR	},
+	{ NFSERR_ISDIR,		-EISDIR		},
+	{ NFSERR_INVAL,		-EINVAL		},
+	{ NFSERR_FBIG,		-EFBIG		},
+	{ NFSERR_NOSPC,		-ENOSPC		},
+	{ NFSERR_ROFS,		-EROFS		},
+	{ NFSERR_MLINK,		-EMLINK		},
+	{ NFSERR_NAMETOOLONG,	-ENAMETOOLONG	},
+	{ NFSERR_NOTEMPTY,	-ENOTEMPTY	},
+	{ NFSERR_DQUOT,		-EDQUOT		},
+	{ NFSERR_STALE,		-ESTALE		},
+	{ NFSERR_REMOTE,	-EREMOTE	},
 #ifdef EWFLUSH
-	{ NFSERR_WFLUSH,	EWFLUSH		},
+	{ NFSERR_WFLUSH,	-EWFLUSH	},
 #endif
-	{ NFSERR_BADHANDLE,	EBADHANDLE	},
-	{ NFSERR_NOT_SYNC,	ENOTSYNC	},
-	{ NFSERR_BAD_COOKIE,	EBADCOOKIE	},
-	{ NFSERR_NOTSUPP,	ENOTSUPP	},
-	{ NFSERR_TOOSMALL,	ETOOSMALL	},
-	{ NFSERR_SERVERFAULT,	ESERVERFAULT	},
-	{ NFSERR_BADTYPE,	EBADTYPE	},
-	{ NFSERR_JUKEBOX,	EJUKEBOX	},
-	{ -1,			EIO		}
+	{ NFSERR_BADHANDLE,	-EBADHANDLE	},
+	{ NFSERR_NOT_SYNC,	-ENOTSYNC	},
+	{ NFSERR_BAD_COOKIE,	-EBADCOOKIE	},
+	{ NFSERR_NOTSUPP,	-ENOTSUPP	},
+	{ NFSERR_TOOSMALL,	-ETOOSMALL	},
+	{ NFSERR_SERVERFAULT,	-ESERVERFAULT	},
+	{ NFSERR_BADTYPE,	-EBADTYPE	},
+	{ NFSERR_JUKEBOX,	-EJUKEBOX	},
+	{ -1,			-EIO		}
 };
 
 /*
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index fb03048..11cddde 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -515,7 +515,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 	/* Decode post_op_attrs */
 	p = xdr_decode_post_op_attr(p, res->dir_attr);
 	if (status)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	/* Decode verifier cookie */
 	if (res->verf) {
 		res->verf[0] = *p++;
@@ -751,7 +751,7 @@ nfs3_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	int	status;
 
 	if ((status = ntohl(*p++)))
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	xdr_decode_fattr(p, fattr);
 	return 0;
 }
@@ -766,7 +766,7 @@ nfs3_xdr_wccstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	int	status;
 
 	if ((status = ntohl(*p++)))
-		status = -nfs_stat_to_errno(status);
+		status = nfs_stat_to_errno(status);
 	xdr_decode_wcc_data(p, fattr);
 	return status;
 }
@@ -786,7 +786,7 @@ nfs3_xdr_lookupres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
 	int	status;
 
 	if ((status = ntohl(*p++))) {
-		status = -nfs_stat_to_errno(status);
+		status = nfs_stat_to_errno(status);
 	} else {
 		if (!(p = xdr_decode_fhandle(p, res->fh)))
 			return -errno_NFSERR_IO;
@@ -806,7 +806,7 @@ nfs3_xdr_accessres(struct rpc_rqst *req, __be32 *p, struct nfs3_accessres *res)
 
 	p = xdr_decode_post_op_attr(p, res->fattr);
 	if (status)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	res->access = ntohl(*p++);
 	return 0;
 }
@@ -843,7 +843,7 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	p = xdr_decode_post_op_attr(p, fattr);
 
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	/* Convert length of symlink */
 	len = ntohl(*p++);
@@ -891,7 +891,7 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	p = xdr_decode_post_op_attr(p, res->fattr);
 
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	/* Decode reply count and EOF flag. NFSv3 is somewhat redundant
 	 * in that it puts the count both in the res struct and in the
@@ -941,7 +941,7 @@ nfs3_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
 	p = xdr_decode_wcc_data(p, res->fattr);
 
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	res->count = ntohl(*p++);
 	res->verf->committed = (enum nfs3_stable_how)ntohl(*p++);
@@ -972,7 +972,7 @@ nfs3_xdr_createres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
 			res->fattr->valid = 0;
 		}
 	} else {
-		status = -nfs_stat_to_errno(status);
+		status = nfs_stat_to_errno(status);
 	}
 	p = xdr_decode_wcc_data(p, res->dir_attr);
 	return status;
@@ -987,7 +987,7 @@ nfs3_xdr_renameres(struct rpc_rqst *req, __be32 *p, struct nfs3_renameres *res)
 	int	status;
 
 	if ((status = ntohl(*p++)) != 0)
-		status = -nfs_stat_to_errno(status);
+		status = nfs_stat_to_errno(status);
 	p = xdr_decode_wcc_data(p, res->fromattr);
 	p = xdr_decode_wcc_data(p, res->toattr);
 	return status;
@@ -1002,7 +1002,7 @@ nfs3_xdr_linkres(struct rpc_rqst *req, __be32 *p, struct nfs3_linkres *res)
 	int	status;
 
 	if ((status = ntohl(*p++)) != 0)
-		status = -nfs_stat_to_errno(status);
+		status = nfs_stat_to_errno(status);
 	p = xdr_decode_post_op_attr(p, res->fattr);
 	p = xdr_decode_wcc_data(p, res->dir_attr);
 	return status;
@@ -1020,7 +1020,7 @@ nfs3_xdr_fsstatres(struct rpc_rqst *req, __be32 *p, struct nfs_fsstat *res)
 
 	p = xdr_decode_post_op_attr(p, res->fattr);
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	p = xdr_decode_hyper(p, &res->tbytes);
 	p = xdr_decode_hyper(p, &res->fbytes);
@@ -1045,7 +1045,7 @@ nfs3_xdr_fsinfores(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *res)
 
 	p = xdr_decode_post_op_attr(p, res->fattr);
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	res->rtmax  = ntohl(*p++);
 	res->rtpref = ntohl(*p++);
@@ -1073,7 +1073,7 @@ nfs3_xdr_pathconfres(struct rpc_rqst *req, __be32 *p, struct nfs_pathconf *res)
 
 	p = xdr_decode_post_op_attr(p, res->fattr);
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	res->max_link = ntohl(*p++);
 	res->max_namelen = ntohl(*p++);
 
@@ -1092,7 +1092,7 @@ nfs3_xdr_commitres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
 	status = ntohl(*p++);
 	p = xdr_decode_wcc_data(p, res->fattr);
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 
 	res->verf->verifier[0] = *p++;
 	res->verf->verifier[1] = *p++;
@@ -1114,7 +1114,7 @@ nfs3_xdr_getaclres(struct rpc_rqst *req, __be32 *p,
 	int err, base;
 
 	if (status != 0)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	p = xdr_decode_post_op_attr(p, res->fattr);
 	res->mask = ntohl(*p++);
 	if (res->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
@@ -1141,7 +1141,7 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	int status = ntohl(*p++);
 
 	if (status)
-		return -nfs_stat_to_errno(status);
+		return nfs_stat_to_errno(status);
 	xdr_decode_post_op_attr(p, fattr);
 	return 0;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b8b2e39..809ef0d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2241,7 +2241,7 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	}
 	READ32(nfserr);
 	if (nfserr != NFS_OK)
-		return -nfs4_stat_to_errno(nfserr);
+		return nfs4_stat_to_errno(nfserr);
 	return 0;
 }
 
@@ -3760,7 +3760,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 		READ_BUF(len);
 		return -NFSERR_CLID_INUSE;
 	} else
-		return -nfs4_stat_to_errno(nfserr);
+		return nfs4_stat_to_errno(nfserr);
 
 	return 0;
 }
@@ -4422,7 +4422,7 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
 	if (!status)
-		status = -nfs4_stat_to_errno(hdr.status);
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4512,7 +4512,7 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	if (!status)
 		status = decode_setclientid(&xdr, clp);
 	if (!status)
-		status = -nfs4_stat_to_errno(hdr.status);
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4534,7 +4534,7 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
 	if (!status)
-		status = -nfs4_stat_to_errno(hdr.status);
+		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4644,42 +4644,42 @@ static struct {
 	int errno;
 } nfs_errtbl[] = {
 	{ NFS4_OK,		0		},
-	{ NFS4ERR_PERM,		EPERM		},
-	{ NFS4ERR_NOENT,	ENOENT		},
-	{ NFS4ERR_IO,		errno_NFSERR_IO	},
-	{ NFS4ERR_NXIO,		ENXIO		},
-	{ NFS4ERR_ACCESS,	EACCES		},
-	{ NFS4ERR_EXIST,	EEXIST		},
-	{ NFS4ERR_XDEV,		EXDEV		},
-	{ NFS4ERR_NOTDIR,	ENOTDIR		},
-	{ NFS4ERR_ISDIR,	EISDIR		},
-	{ NFS4ERR_INVAL,	EINVAL		},
-	{ NFS4ERR_FBIG,		EFBIG		},
-	{ NFS4ERR_NOSPC,	ENOSPC		},
-	{ NFS4ERR_ROFS,		EROFS		},
-	{ NFS4ERR_MLINK,	EMLINK		},
-	{ NFS4ERR_NAMETOOLONG,	ENAMETOOLONG	},
-	{ NFS4ERR_NOTEMPTY,	ENOTEMPTY	},
-	{ NFS4ERR_DQUOT,	EDQUOT		},
-	{ NFS4ERR_STALE,	ESTALE		},
-	{ NFS4ERR_BADHANDLE,	EBADHANDLE	},
-	{ NFS4ERR_BADOWNER,	EINVAL		},
-	{ NFS4ERR_BADNAME,	EINVAL		},
-	{ NFS4ERR_BAD_COOKIE,	EBADCOOKIE	},
-	{ NFS4ERR_NOTSUPP,	ENOTSUPP	},
-	{ NFS4ERR_TOOSMALL,	ETOOSMALL	},
-	{ NFS4ERR_SERVERFAULT,	ESERVERFAULT	},
-	{ NFS4ERR_BADTYPE,	EBADTYPE	},
-	{ NFS4ERR_LOCKED,	EAGAIN		},
-	{ NFS4ERR_RESOURCE,	EREMOTEIO	},
-	{ NFS4ERR_SYMLINK,	ELOOP		},
-	{ NFS4ERR_OP_ILLEGAL,	EOPNOTSUPP	},
-	{ NFS4ERR_DEADLOCK,	EDEADLK		},
-	{ NFS4ERR_WRONGSEC,	EPERM		}, /* FIXME: this needs
+	{ NFS4ERR_PERM,		-EPERM		},
+	{ NFS4ERR_NOENT,	-ENOENT		},
+	{ NFS4ERR_IO,		-errno_NFSERR_IO},
+	{ NFS4ERR_NXIO,		-ENXIO		},
+	{ NFS4ERR_ACCESS,	-EACCES		},
+	{ NFS4ERR_EXIST,	-EEXIST		},
+	{ NFS4ERR_XDEV,		-EXDEV		},
+	{ NFS4ERR_NOTDIR,	-ENOTDIR	},
+	{ NFS4ERR_ISDIR,	-EISDIR		},
+	{ NFS4ERR_INVAL,	-EINVAL		},
+	{ NFS4ERR_FBIG,		-EFBIG		},
+	{ NFS4ERR_NOSPC,	-ENOSPC		},
+	{ NFS4ERR_ROFS,		-EROFS		},
+	{ NFS4ERR_MLINK,	-EMLINK		},
+	{ NFS4ERR_NAMETOOLONG,	-ENAMETOOLONG	},
+	{ NFS4ERR_NOTEMPTY,	-ENOTEMPTY	},
+	{ NFS4ERR_DQUOT,	-EDQUOT		},
+	{ NFS4ERR_STALE,	-ESTALE		},
+	{ NFS4ERR_BADHANDLE,	-EBADHANDLE	},
+	{ NFS4ERR_BADOWNER,	-EINVAL		},
+	{ NFS4ERR_BADNAME,	-EINVAL		},
+	{ NFS4ERR_BAD_COOKIE,	-EBADCOOKIE	},
+	{ NFS4ERR_NOTSUPP,	-ENOTSUPP	},
+	{ NFS4ERR_TOOSMALL,	-ETOOSMALL	},
+	{ NFS4ERR_SERVERFAULT,	-ESERVERFAULT	},
+	{ NFS4ERR_BADTYPE,	-EBADTYPE	},
+	{ NFS4ERR_LOCKED,	-EAGAIN		},
+	{ NFS4ERR_RESOURCE,	-EREMOTEIO	},
+	{ NFS4ERR_SYMLINK,	-ELOOP		},
+	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
+	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
+	{ NFS4ERR_WRONGSEC,	-EPERM		}, /* FIXME: this needs
 						    * to be handled by a
 						    * middle-layer.
 						    */
-	{ -1,			EIO		}
+	{ -1,			-EIO		}
 };
 
 /*
@@ -4696,14 +4696,14 @@ nfs4_stat_to_errno(int stat)
 	}
 	if (stat <= 10000 || stat > 10100) {
 		/* The server is looney tunes. */
-		return ESERVERFAULT;
+		return -ESERVERFAULT;
 	}
 	/* If we cannot translate the error, the recovery routines should
 	 * handle it.
 	 * Note: remaining NFSv4 error codes have values > 10000, so should
 	 * not conflict with native Linux error codes.
 	 */
-	return stat;
+	return -stat;
 }
 
 #define PROC(proc, argtype, restype)				\

