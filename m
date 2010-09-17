Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47728 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab0IQQ3A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:29:00 -0400
Received: by mail-gx0-f174.google.com with SMTP id 23so788861gxk.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:29:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/22] NFS: Introduce new-style XDR decoding functions for
	NFSv2
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:28:55 -0400
Message-ID: <20100917162855.19761.49769.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c     | 1494 ++++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/nfs3.h |    1 
 2 files changed, 1446 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d321d2e..f77ad7f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -119,6 +119,16 @@ static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, pages, base, len);
 }
 
+/*
+ * Handle decode buffer overflows out-of-line.
+ */
+static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
+{
+	dprintk("NFS: %s prematurely hit the end of our receive buffer. "
+		"Remaining buffer length is %tu words.\n",
+		func, xdr->end - xdr->p);
+}
+
 
 /*
  * Common NFS XDR functions as inlines
@@ -234,6 +244,20 @@ static void encode_uint32(struct xdr_stream *xdr, u32 value)
 	*p = cpu_to_be32(value);
 }
 
+static int decode_uint32(struct xdr_stream *xdr, u32 *value)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	*value = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 /*
  * filename3
  *
@@ -262,6 +286,39 @@ static void encode_nfspath3(struct xdr_stream *xdr, struct page **pages,
 	xdr_write_pages(xdr, pages, 0, length);
 }
 
+static int decode_nfspath3(struct xdr_stream *xdr)
+{
+	u32 recvd, count;
+	size_t hdrlen;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	count = be32_to_cpup(p);
+	if (unlikely(count >= xdr->buf->page_len || count > NFS3_MAXPATHLEN))
+		goto out_nametoolong;
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = xdr->buf->len - hdrlen;
+	if (unlikely(count > recvd))
+		goto out_cheating;
+
+	xdr_read_pages(xdr, count);
+	xdr_terminate_string(xdr->buf, count);
+	return 0;
+
+out_nametoolong:
+	dprintk("NFS: returned pathname too long: %u\n", count);
+	return -ENAMETOOLONG;
+out_cheating:
+	dprintk("NFS: server cheating in pathname result: "
+		"count %u > recvd %u\n", count, recvd);
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 /*
  * cookie3
  *
@@ -283,6 +340,20 @@ static __be32 *xdr_encode_cookieverf3(__be32 *p, const __be32 *verifier)
 	return p + XDR_QUADLEN(NFS3_COOKIEVERFSIZE);
 }
 
+static int decode_cookieverf3(struct xdr_stream *xdr, __be32 *verifier)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS3_COOKIEVERFSIZE);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	memcpy(verifier, p, NFS3_COOKIEVERFSIZE);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 /*
  * createverf3
  *
@@ -296,6 +367,54 @@ static void encode_createverf3(struct xdr_stream *xdr, const __be32 *verifier)
 	memcpy(p, verifier, NFS3_CREATEVERFSIZE);
 }
 
+static int decode_writeverf3(struct xdr_stream *xdr, __be32 *verifier)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS3_WRITEVERFSIZE);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	memcpy(verifier, p, NFS3_WRITEVERFSIZE);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ * size3
+ *
+ *	typedef uint64 size3;
+ */
+static __be32 *xdr_decode_size3(__be32 *p, u64 *size)
+{
+	return xdr_decode_hyper(p, size);
+}
+
+/*
+ * nfsstat3
+ *
+ *	enum nfsstat3 {
+ *		NFS3_OK = 0,
+ *		...
+ *	}
+ */
+#define NFS3_OK		NFS_OK
+
+static int decode_nfsstat3(struct xdr_stream *xdr, enum nfs_stat *status)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	*status = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 /*
  * ftype3
  *
@@ -348,6 +467,36 @@ static void encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh *fh)
 	xdr_encode_opaque(p, fh->data, fh->size);
 }
 
+static int decode_nfs_fh3(struct xdr_stream *xdr, struct nfs_fh *fh)
+{
+	u32 length;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	length = be32_to_cpup(p++);
+	if (unlikely(length > NFS3_FHSIZE))
+		goto out_toobig;
+	p = xdr_inline_decode(xdr, length);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	fh->size = length;
+	memcpy(fh->data, p, length);
+	return 0;
+out_toobig:
+	dprintk("NFS: file handle size (%u) too big\n", length);
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static void zero_nfs_fh3(struct nfs_fh *fh)
+{
+	memset(fh, 0, sizeof(*fh));
+}
+
 /*
  * nfstime3
  *
@@ -491,6 +640,153 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
 }
 
 /*
+ * fattr3
+ *
+ *	struct fattr3 {
+ *		ftype3		type;
+ *		mode3		mode;
+ *		uint32		nlink;
+ *		uid3		uid;
+ *		gid3		gid;
+ *		size3		size;
+ *		size3		used;
+ *		specdata3	rdev;
+ *		uint64		fsid;
+ *		fileid3		fileid;
+ *		nfstime3	atime;
+ *		nfstime3	mtime;
+ *		nfstime3	ctime;
+ *	};
+ */
+static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS3_fattr_sz << 2);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	xdr_decode_fattr(p, fattr);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ * post_op_attr
+ *
+ *	union post_op_attr switch (bool attributes_follow) {
+ *	case TRUE:
+ *		fattr3	attributes;
+ *	case FALSE:
+ *		void;
+ *	};
+ */
+static int decode_post_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	if (*p != xdr_zero)
+		return decode_fattr3(xdr, fattr);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ * wcc_attr
+ *	struct wcc_attr {
+ *		size3		size;
+ *		nfstime3	mtime;
+ *		nfstime3	ctime;
+ *	};
+ */
+static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS3_wcc_attr_sz << 2);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	xdr_decode_wcc_attr(p, fattr);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ * pre_op_attr
+ *	union pre_op_attr switch (bool attributes_follow) {
+ *	case TRUE:
+ *		wcc_attr	attributes;
+ *	case FALSE:
+ *		void;
+ *	};
+ *
+ * wcc_data
+ *
+ *	struct wcc_data {
+ *		pre_op_attr	before;
+ *		post_op_attr	after;
+ *	};
+ */
+static int decode_pre_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	if (*p != xdr_zero)
+		return decode_wcc_attr(xdr, fattr);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_wcc_data(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	int error;
+
+	error = decode_pre_op_attr(xdr, fattr);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(xdr, fattr);
+out:
+	return error;
+}
+
+/*
+ * post_op_fh3
+ *
+ *	union post_op_fh3 switch (bool handle_follows) {
+ *	case TRUE:
+ *		nfs_fh3  handle;
+ *	case FALSE:
+ *		void;
+ *	};
+ */
+static int decode_post_op_fh3(struct xdr_stream *xdr, struct nfs_fh *fh)
+{
+	__be32 *p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	if (*p != xdr_zero)
+		return decode_nfs_fh3(xdr, fh);
+	zero_nfs_fh3(fh);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
  * diropargs3
  *
  *	struct diropargs3 {
@@ -1132,45 +1428,6 @@ err_unmap:
 	goto out;
 }
 
-__be32 *
-nfs3_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
-{
-	struct nfs_entry old = *entry;
-
-	if (!*p++) {
-		if (!*p)
-			return ERR_PTR(-EAGAIN);
-		entry->eof = 1;
-		return ERR_PTR(-EBADCOOKIE);
-	}
-
-	p = xdr_decode_hyper(p, &entry->ino);
-	entry->len  = ntohl(*p++);
-	entry->name = (const char *) p;
-	p += XDR_QUADLEN(entry->len);
-	entry->prev_cookie = entry->cookie;
-	p = xdr_decode_hyper(p, &entry->cookie);
-
-	if (plus) {
-		entry->fattr->valid = 0;
-		p = xdr_decode_post_op_attr(p, entry->fattr);
-		/* In fact, a post_op_fh3: */
-		if (*p++) {
-			p = xdr_decode_fhandle(p, entry->fh);
-			/* Ugh -- server reply was truncated */
-			if (p == NULL) {
-				dprintk("NFS: FH truncated\n");
-				*entry = old;
-				return ERR_PTR(-EAGAIN);
-			}
-		} else
-			memset((u8*)(entry->fh), 0, sizeof(*entry->fh));
-	}
-
-	entry->eof = !p[0] && p[1];
-	return p;
-}
-
 /*
  * 3.3.21  COMMIT3args
  *
@@ -1266,6 +1523,40 @@ nfs3_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 }
 
 /*
+ * 3.3.1  GETATTR3res
+ *
+ *	struct GETATTR3resok {
+ *		fattr3		obj_attributes;
+ *	};
+ *
+ *	union GETATTR3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		GETATTR3resok  resok;
+ *	default:
+ *		void;
+ *	};
+ */
+static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req, __be32 *p,
+				    struct nfs_fattr *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_fattr3(&xdr, result);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode status+wcc_data reply
  * SATTR, REMOVE, RMDIR
  */
@@ -1280,6 +1571,46 @@ nfs3_xdr_wccstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	return status;
 }
 
+/*
+ * 3.3.2  SETATTR3res
+ *
+ *	struct SETATTR3resok {
+ *		wcc_data  obj_wcc;
+ *	};
+ *
+ *	struct SETATTR3resfail {
+ *		wcc_data  obj_wcc;
+ *	};
+ *
+ *	union SETATTR3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		SETATTR3resok   resok;
+ *	default:
+ *		SETATTR3resfail resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req, __be32 *p,
+				    struct nfs_fattr *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_wcc_data(&xdr, result);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
 static int
 nfs3_xdr_removeres(struct rpc_rqst *req, __be32 *p, struct nfs_removeres *res)
 {
@@ -1306,6 +1637,55 @@ nfs3_xdr_lookupres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
 }
 
 /*
+ * 3.3.3  LOOKUP3res
+ *
+ *	struct LOOKUP3resok {
+ *		nfs_fh3		object;
+ *		post_op_attr	obj_attributes;
+ *		post_op_attr	dir_attributes;
+ *	};
+ *
+ *	struct LOOKUP3resfail {
+ *		post_op_attr	dir_attributes;
+ *	};
+ *
+ *	union LOOKUP3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		LOOKUP3resok	resok;
+ *	default:
+ *		LOOKUP3resfail	resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs3_diropres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_nfs_fh3(&xdr, result->fh);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->dir_attr);
+out:
+	return error;
+out_default:
+	error = decode_post_op_attr(&xdr, result->dir_attr);
+	if (unlikely(error))
+		goto out;
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode ACCESS reply
  */
 static int
@@ -1321,6 +1701,48 @@ nfs3_xdr_accessres(struct rpc_rqst *req, __be32 *p, struct nfs3_accessres *res)
 }
 
 /*
+ * 3.3.4  ACCESS3res
+ *
+ *	struct ACCESS3resok {
+ *		post_op_attr	obj_attributes;
+ *		uint32		access;
+ *	};
+ *
+ *	struct ACCESS3resfail {
+ *		post_op_attr	obj_attributes;
+ *	};
+ *
+ *	union ACCESS3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		ACCESS3resok	resok;
+ *	default:
+ *		ACCESS3resfail	resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_access3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs3_accessres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_uint32(&xdr, &result->access);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode READLINK reply
  */
 static int
@@ -1367,6 +1789,48 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 }
 
 /*
+ * 3.3.5  READLINK3res
+ *
+ *	struct READLINK3resok {
+ *		post_op_attr	symlink_attributes;
+ *		nfspath3	data;
+ *	};
+ *
+ *	struct READLINK3resfail {
+ *		post_op_attr	symlink_attributes;
+ *	};
+ *
+ *	union READLINK3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		READLINK3resok	resok;
+ *	default:
+ *		READLINK3resfail resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req, __be32 *p,
+				     struct nfs_fattr *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_nfspath3(&xdr);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode READ reply
  */
 static int
@@ -1420,6 +1884,90 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 }
 
 /*
+ * 3.3.6  READ3res
+ *
+ *	struct READ3resok {
+ *		post_op_attr	file_attributes;
+ *		count3		count;
+ *		bool		eof;
+ *		opaque		data<>;
+ *	};
+ *
+ *	struct READ3resfail {
+ *		post_op_attr	file_attributes;
+ *	};
+ *
+ *	union READ3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		READ3resok	resok;
+ *	default:
+ *		READ3resfail	resfail;
+ *	};
+ */
+static int decode_read3resok(struct xdr_stream *xdr,
+			     struct nfs_readres *result)
+{
+	u32 eof, count, ocount, recvd;
+	size_t hdrlen;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4 + 4 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	count = be32_to_cpup(p++);
+	eof = be32_to_cpup(p++);
+	ocount = be32_to_cpup(p++);
+	if (unlikely(ocount != count))
+		goto out_mismatch;
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = xdr->buf->len - hdrlen;
+	if (unlikely(count > recvd))
+		goto out_cheating;
+
+out:
+	xdr_read_pages(xdr, count);
+	result->eof = eof;
+	result->count = count;
+	return count;
+out_mismatch:
+	dprintk("NFS: READ count doesn't match length of opaque: "
+		"count %u != ocount %u\n", count, ocount);
+	return -EIO;
+out_cheating:
+	dprintk("NFS: server cheating in read result: "
+		"count %u > recvd %u\n", count, recvd);
+	count = recvd;
+	eof = 0;
+	goto out;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, __be32 *p,
+				 struct nfs_readres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+	error = decode_read3resok(&xdr, result);
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode WRITE response
  */
 static int
@@ -1442,16 +1990,88 @@ nfs3_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
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
+ * 3.3.7  WRITE3res
+ *
+ *	enum stable_how {
+ *		UNSTABLE  = 0,
+ *		DATA_SYNC = 1,
+ *		FILE_SYNC = 2
+ *	};
+ *
+ *	struct WRITE3resok {
+ *		wcc_data	file_wcc;
+ *		count3		count;
+ *		stable_how	committed;
+ *		writeverf3	verf;
+ *	};
+ *
+ *	struct WRITE3resfail {
+ *		wcc_data	file_wcc;
+ *	};
+ *
+ *	union WRITE3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		WRITE3resok	resok;
+ *	default:
+ *		WRITE3resfail	resfail;
+ *	};
+ */
+static int decode_write3resok(struct xdr_stream *xdr,
+			      struct nfs_writeres *result)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4 + 4 + NFS3_WRITEVERFSIZE);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	result->count = be32_to_cpup(p++);
+	result->verf->committed = be32_to_cpup(p++);
+	if (unlikely(result->verf->committed > NFS_FILE_SYNC))
+		goto out_badvalue;
+	memcpy(result->verf->verifier, p, NFS3_WRITEVERFSIZE);
+	return result->count;
+out_badvalue:
+	dprintk("NFS: bad stable_how value: %u\n", result->verf->committed);
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, __be32 *p,
+				  struct nfs_writeres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_wcc_data(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+	error = decode_write3resok(&xdr, result);
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
+ * Decode a CREATE response
+ */
+static int
+nfs3_xdr_createres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
+{
+	int	status;
+
+	status = ntohl(*p++);
+	if (status == 0) {
+		if (*p++) {
 			if (!(p = xdr_decode_fhandle(p, res->fh)))
 				return -errno_NFSERR_IO;
 			p = xdr_decode_post_op_attr(p, res->fattr);
@@ -1469,6 +2089,111 @@ nfs3_xdr_createres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
 }
 
 /*
+ * 3.3.8  CREATE3res
+ *
+ *	struct CREATE3resok {
+ *		post_op_fh3	obj;
+ *		post_op_attr	obj_attributes;
+ *		wcc_data	dir_wcc;
+ *	};
+ *
+ *	struct CREATE3resfail {
+ *		wcc_data	dir_wcc;
+ *	};
+ *
+ *	union CREATE3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		CREATE3resok	resok;
+ *	default:
+ *		CREATE3resfail	resfail;
+ *	};
+ */
+static int decode_create3resok(struct xdr_stream *xdr,
+			       struct nfs3_diropres *result)
+{
+	int error;
+
+	error = decode_post_op_fh3(xdr, result->fh);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	/* The server isn't required to return a file handle.
+	 * If it didn't, force the client to perform a LOOKUP
+	 * to determine the correct file handle and attribute
+	 * values for the new object. */
+	if (result->fh->size == 0)
+		result->fattr->valid = 0;
+	error = decode_wcc_data(xdr, result->dir_attr);
+out:
+	return error;
+}
+
+static int nfs3_xdr_dec_create3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs3_diropres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_create3resok(&xdr, result);
+out:
+	return error;
+out_default:
+	error = decode_wcc_data(&xdr, result->dir_attr);
+	if (unlikely(error))
+		goto out;
+	return nfs_stat_to_errno(status);
+}
+
+/*
+ * 3.3.12  REMOVE3res
+ *
+ *	struct REMOVE3resok {
+ *		wcc_data    dir_wcc;
+ *	};
+ *
+ *	struct REMOVE3resfail {
+ *		wcc_data    dir_wcc;
+ *	};
+ *
+ *	union REMOVE3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		REMOVE3resok   resok;
+ *	default:
+ *		REMOVE3resfail resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs_removeres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_wcc_data(&xdr, result->dir_attr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode RENAME reply
  */
 static int
@@ -1484,6 +2209,51 @@ nfs3_xdr_renameres(struct rpc_rqst *req, __be32 *p, struct nfs3_renameres *res)
 }
 
 /*
+ * 3.3.14  RENAME3res
+ *
+ *	struct RENAME3resok {
+ *		wcc_data	fromdir_wcc;
+ *		wcc_data	todir_wcc;
+ *	};
+ *
+ *	struct RENAME3resfail {
+ *		wcc_data	fromdir_wcc;
+ *		wcc_data	todir_wcc;
+ *	};
+ *
+ *	union RENAME3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		RENAME3resok   resok;
+ *	default:
+ *		RENAME3resfail resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs3_renameres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_wcc_data(&xdr, result->fromattr);
+	if (unlikely(error))
+		goto out;
+	error = decode_wcc_data(&xdr, result->toattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode LINK reply
  */
 static int
@@ -1499,6 +2269,297 @@ nfs3_xdr_linkres(struct rpc_rqst *req, __be32 *p, struct nfs3_linkres *res)
 }
 
 /*
+ * 3.3.15  LINK3res
+ *
+ *	struct LINK3resok {
+ *		post_op_attr	file_attributes;
+ *		wcc_data	linkdir_wcc;
+ *	};
+ *
+ *	struct LINK3resfail {
+ *		post_op_attr	file_attributes;
+ *		wcc_data	linkdir_wcc;
+ *	};
+ *
+ *	union LINK3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		LINK3resok	resok;
+ *	default:
+ *		LINK3resfail	resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, __be32 *p,
+				 struct nfs3_linkres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	error = decode_wcc_data(&xdr, result->dir_attr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
+ * 3.3.16  entry3
+ *
+ *	struct entry3 {
+ *		fileid3		fileid;
+ *		filename3	name;
+ *		cookie3		cookie;
+ *		fhandle3	filehandle;
+ *		post_op_attr3	attributes;
+ *		entry3		*nextentry;
+ *	};
+ *
+ * 3.3.17  entryplus3
+ *	struct entryplus3 {
+ *		fileid3		fileid;
+ *		filename3	name;
+ *		cookie3		cookie;
+ *		post_op_attr	name_attributes;
+ *		post_op_fh3	name_handle;
+ *		entryplus3	*nextentry;
+ *	};
+ *
+ * The Linux implementation is limited to receiving not more
+ * than a single page of entries at a time.
+ *
+ * Here, the XDR buffer is checked for correct syntax.  The
+ * actual decoding is done by nfs_decode_entry() during
+ * subsequent nfs_readdir() calls.
+ */
+static int decode_dirlist3(struct xdr_stream *xdr, const int plus)
+{
+	const char *op = plus ? "readdirplus" : "readdir";
+	__be32 *p, *end, *entry, *kaddr;
+	unsigned int nr, pglen, recvd;
+	struct page **page;
+	size_t hdrlen;
+	u32 count;
+
+	pglen = xdr->buf->page_len;
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = xdr->buf->len - hdrlen;
+	if (pglen > recvd)
+		pglen = recvd;
+	xdr_read_pages(xdr, pglen);
+
+	page = xdr->buf->pages;
+	kaddr = p = kmap_atomic(*page, KM_USER0);
+	end = (__be32 *)((char *)p + pglen);
+	entry = p;
+
+	/* Make sure the reply actually has a value_follows and EOF entry */
+	if (unlikely((entry + 1) > end))
+		goto out_short_reply;
+
+	nr = 0;
+	for (; *p++ != xdr_zero; nr++) {
+		if (unlikely(p + 3 > end))
+			goto out_short_reply;
+		p += 2;				/* inode # */
+		count = be32_to_cpup(p++);	/* string length */
+		p += XDR_QUADLEN(count) + 2;	/* name + cookie */
+		if (unlikely(count > NFS3_MAXNAMLEN))
+			goto out_nametoolong;
+
+		if (plus) {
+			/* post_op_attr */
+			if (unlikely(p + 2 > end))
+				goto out_short_reply;
+			if (*p++ != xdr_zero) {
+				p += 21;
+				if (unlikely(p + 1 > end))
+					goto out_short_reply;
+			}
+			/* post_op_fh3 */
+			if (*p++ != xdr_zero) {
+				if (unlikely(p + 1 > end))
+					goto out_short_reply;
+				count = be32_to_cpup(p++);
+				if (unlikely(count > NFS3_FHSIZE))
+					goto out_fhtoolong;
+				p += XDR_QUADLEN(count);
+			}
+		}
+
+		if (unlikely(p + 2 > end))
+			goto out_short_reply;
+		entry = p;
+	}
+
+	/*
+	 * Apparently some server sends responses that are a valid size, but
+	 * contain no entries, and have value_follows==0 and EOF==0. For
+	 * those, just set the EOF marker.
+	 */
+	if (unlikely(!nr && entry[1] == xdr_zero))
+		goto out_truncated;
+
+out:
+	kunmap_atomic(kaddr, KM_USER0);
+	return nr;
+
+out_short_reply:
+	/*
+	 * When we get a short reply there are 2 possibilities. We can
+	 * return an error, or fix up the response to look like a valid
+	 * response and return what we have so far. If there are no
+	 * entries and the reply was short, then return -EIO. If there
+	 * are valid entries in the response, return them and pretend that
+	 * the call was successful, but incomplete. The caller can retry the
+	 * readdir starting at the last cookie.
+	 */
+	dprintk("NFS: short %s reply at entry %d\n", op, nr);
+	entry[0] = entry[1] = xdr_zero;
+	if (unlikely(!nr))
+		nr = -EIO;
+	goto out;
+out_nametoolong:
+	dprintk("NFS: filename too long during %s (len 0x%x)\n",
+			op, count);
+	nr = -EIO;
+	goto out;
+out_fhtoolong:
+	dprintk("NFS: filehandle too long during %s (len 0x%x)\n",
+			op, count);
+	nr = -EIO;
+	goto out;
+out_truncated:
+	dprintk("NFS: %s reply truncated\n", op);
+	entry[1] = xdr_one;
+	goto out;
+}
+
+/*
+ * 3.3.16  READDIR3res
+ *
+ *	struct dirlist3 {
+ *		entry3		*entries;
+ *		bool		eof;
+ *	};
+ *
+ *	struct READDIR3resok {
+ *		post_op_attr	dir_attributes;
+ *		cookieverf3	cookieverf;
+ *		dirlist3	reply;
+ *	};
+ *
+ *	struct READDIR3resfail {
+ *		post_op_attr	dir_attributes;
+ *	};
+ *
+ *	union READDIR3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		READDIR3resok	resok;
+ *	default:
+ *		READDIR3resfail	resfail;
+ *	};
+ */
+static int decode_readdir3resok(struct xdr_stream *xdr,
+				struct nfs3_readdirres *result)
+{
+	int error;
+
+	error = decode_post_op_attr(xdr, result->dir_attr);
+	if (unlikely(error))
+		goto out;
+	error = decode_cookieverf3(xdr, result->verf);
+	if (unlikely(error))
+		goto out;
+	error = decode_dirlist3(xdr, result->plus);
+out:
+	return error;
+}
+
+static int nfs3_xdr_dec_readdir3res(struct rpc_rqst *req, __be32 *p,
+				    struct nfs3_readdirres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_readdir3resok(&xdr, result);
+out:
+	return error;
+out_default:
+	error = decode_post_op_attr(&xdr, result->dir_attr);
+	if (unlikely(error))
+		goto out;
+	return nfs_stat_to_errno(status);
+}
+
+/**
+ * nfs3_decode_dirent - Decode a single NFSv3 directory entry stored in
+ *			the local page cache
+ * @p: pointer to buffer where entry resides
+ * @entry: entry struct to fill out with data
+ * @plus: boolean indicating whether this should be a readdirplus entry
+ *
+ * Returns the position of the next item in the buffer, or an ERR_PTR.
+ *
+ * This function is not invoked during READDIR reply processing, but
+ * rather whenever an application invokes the getdents(2) system call.
+ */
+__be32 *nfs3_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
+{
+	struct nfs_entry old = *entry;
+
+	if (*p++ == xdr_zero) {
+		if (*p == xdr_zero)
+			return ERR_PTR(-EAGAIN);
+		entry->eof = 1;
+		return ERR_PTR(-EBADCOOKIE);
+	}
+
+	p = xdr_decode_hyper(p, &entry->ino);
+	p = xdr_decode_string_inplace(p, (char **)&entry->name,
+					&entry->len, NFS3_MAXNAMLEN);
+	entry->prev_cookie = entry->cookie;
+	p = xdr_decode_hyper(p, &entry->cookie);
+
+	if (plus) {
+		entry->fattr->valid = 0;
+		p = xdr_decode_post_op_attr(p, entry->fattr);
+		/* In fact, a post_op_fh3: */
+		if (*p++ != xdr_zero) {
+			p = xdr_decode_fhandle(p, entry->fh);
+			if (unlikely(p == NULL))
+				goto out_truncated;
+		} else
+			zero_nfs_fh3(entry->fh);
+	}
+
+	entry->eof = (p[0] == xdr_zero) && (p[1] != xdr_zero);
+	return p;
+
+out_truncated:
+	dprintk("NFS: directory entry contains invalid file handle\n");
+	*entry = old;
+	return ERR_PTR(-EAGAIN);
+}
+
+/*
  * Decode FSSTAT reply
  */
 static int
@@ -1524,6 +2585,75 @@ nfs3_xdr_fsstatres(struct rpc_rqst *req, __be32 *p, struct nfs_fsstat *res)
 }
 
 /*
+ * 3.3.18  FSSTAT3res
+ *
+ *	struct FSSTAT3resok {
+ *		post_op_attr	obj_attributes;
+ *		size3		tbytes;
+ *		size3		fbytes;
+ *		size3		abytes;
+ *		size3		tfiles;
+ *		size3		ffiles;
+ *		size3		afiles;
+ *		uint32		invarsec;
+ *	};
+ *
+ *	struct FSSTAT3resfail {
+ *		post_op_attr	obj_attributes;
+ *	};
+ *
+ *	union FSSTAT3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		FSSTAT3resok	resok;
+ *	default:
+ *		FSSTAT3resfail	resfail;
+ *	};
+ */
+static int decode_fsstat3resok(struct xdr_stream *xdr,
+			       struct nfs_fsstat *result)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 8 * 6 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	p = xdr_decode_size3(p, &result->tbytes);
+	p = xdr_decode_size3(p, &result->fbytes);
+	p = xdr_decode_size3(p, &result->abytes);
+	p = xdr_decode_size3(p, &result->tfiles);
+	p = xdr_decode_size3(p, &result->ffiles);
+	xdr_decode_size3(p, &result->afiles);
+	/* ignore invarsec */
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs_fsstat *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+	error = decode_fsstat3resok(&xdr, result);
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode FSINFO reply
  */
 static int
@@ -1552,6 +2682,81 @@ nfs3_xdr_fsinfores(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *res)
 }
 
 /*
+ * 3.3.19  FSINFO3res
+ *
+ *	struct FSINFO3resok {
+ *		post_op_attr	obj_attributes;
+ *		uint32		rtmax;
+ *		uint32		rtpref;
+ *		uint32		rtmult;
+ *		uint32		wtmax;
+ *		uint32		wtpref;
+ *		uint32		wtmult;
+ *		uint32		dtpref;
+ *		size3		maxfilesize;
+ *		nfstime3	time_delta;
+ *		uint32		properties;
+ *	};
+ *
+ *	struct FSINFO3resfail {
+ *		post_op_attr	obj_attributes;
+ *	};
+ *
+ *	union FSINFO3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		FSINFO3resok	resok;
+ *	default:
+ *		FSINFO3resfail	resfail;
+ *	};
+ */
+static int decode_fsinfo3resok(struct xdr_stream *xdr,
+			       struct nfs_fsinfo *result)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4 * 7 + 8 + 8 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	result->rtmax  = be32_to_cpup(p++);
+	result->rtpref = be32_to_cpup(p++);
+	result->rtmult = be32_to_cpup(p++);
+	result->wtmax  = be32_to_cpup(p++);
+	result->wtpref = be32_to_cpup(p++);
+	result->wtmult = be32_to_cpup(p++);
+	result->dtpref = be32_to_cpup(p++);
+	xdr_decode_size3(p, &result->maxfilesize);
+	/* ignore time_delta and properties */
+	result->lease_time = 0;
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs_fsinfo *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+	error = decode_fsinfo3resok(&xdr, result);
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode PATHCONF reply
  */
 static int
@@ -1572,6 +2777,70 @@ nfs3_xdr_pathconfres(struct rpc_rqst *req, __be32 *p, struct nfs_pathconf *res)
 }
 
 /*
+ * 3.3.20  PATHCONF3res
+ *
+ *	struct PATHCONF3resok {
+ *		post_op_attr	obj_attributes;
+ *		uint32		linkmax;
+ *		uint32		name_max;
+ *		bool		no_trunc;
+ *		bool		chown_restricted;
+ *		bool		case_insensitive;
+ *		bool		case_preserving;
+ *	};
+ *
+ *	struct PATHCONF3resfail {
+ *		post_op_attr	obj_attributes;
+ *	};
+ *
+ *	union PATHCONF3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		PATHCONF3resok	resok;
+ *	default:
+ *		PATHCONF3resfail resfail;
+ *	};
+ */
+static int decode_pathconf3resok(struct xdr_stream *xdr,
+				 struct nfs_pathconf *result)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4 * 6);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	result->max_link = be32_to_cpup(p++);
+	result->max_namelen = be32_to_cpup(p);
+	/* ignore remaining fields */
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req, __be32 *p,
+				     struct nfs_pathconf *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_post_op_attr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+	error = decode_pathconf3resok(&xdr, result);
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode COMMIT reply
  */
 static int
@@ -1589,6 +2858,48 @@ nfs3_xdr_commitres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
 	return 0;
 }
 
+/*
+ * 3.3.21  COMMIT3res
+ *
+ *	struct COMMIT3resok {
+ *		wcc_data	file_wcc;
+ *		writeverf3	verf;
+ *	};
+ *
+ *	struct COMMIT3resfail {
+ *		wcc_data	file_wcc;
+ *	};
+ *
+ *	union COMMIT3res switch (nfsstat3 status) {
+ *	case NFS3_OK:
+ *		COMMIT3resok	resok;
+ *	default:
+ *		COMMIT3resfail	resfail;
+ *	};
+ */
+static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs_writeres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	error = decode_wcc_data(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_status;
+	error = decode_writeverf3(&xdr, result->verf->verifier);
+out:
+	return error;
+out_status:
+	return nfs_stat_to_errno(status);
+}
+
 #ifdef CONFIG_NFS_V3_ACL
 /*
  * Decode GETACL reply
@@ -1622,6 +2933,70 @@ nfs3_xdr_getaclres(struct rpc_rqst *req, __be32 *p,
 	return (err > 0) ? 0 : err;
 }
 
+static inline int decode_getacl3resok(struct xdr_stream *xdr,
+				      struct nfs3_getaclres *result)
+{
+	struct posix_acl **acl;
+	unsigned int *aclcnt;
+	size_t hdrlen;
+	int error;
+
+	error = decode_post_op_attr(xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	error = decode_uint32(xdr, &result->mask);
+	if (unlikely(error))
+		goto out;
+	error = -EINVAL;
+	if (result->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
+		goto out;
+
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+
+	acl = NULL;
+	if (result->mask & NFS_ACL)
+		acl = &result->acl_access;
+	aclcnt = NULL;
+	if (result->mask & NFS_ACLCNT)
+		aclcnt = &result->acl_access_count;
+	error = nfsacl_decode(xdr->buf, hdrlen, aclcnt, acl);
+	if (unlikely(error <= 0))
+		goto out;
+
+	acl = NULL;
+	if (result->mask & NFS_DFACL)
+		acl = &result->acl_default;
+	aclcnt = NULL;
+	if (result->mask & NFS_DFACLCNT)
+		aclcnt = &result->acl_default_count;
+	error = nfsacl_decode(xdr->buf, hdrlen + error, aclcnt, acl);
+	if (unlikely(error <= 0))
+		return error;
+	error = 0;
+out:
+	return error;
+}
+
+static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs3_getaclres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_getacl3resok(&xdr, result);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
 /*
  * Decode setacl reply.
  */
@@ -1635,6 +3010,27 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	xdr_decode_post_op_attr(p, fattr);
 	return 0;
 }
+
+static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req, __be32 *p,
+				   struct nfs_fattr *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_nfsstat3(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS3_OK)
+		goto out_default;
+	error = decode_post_op_attr(&xdr, result);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
 #endif  /* CONFIG_NFS_V3_ACL */
 
 #define PROC(proc, argtype, restype, timer)				\
diff --git a/include/linux/nfs3.h b/include/linux/nfs3.h
index e2ee14f..6ccfe3b 100644
--- a/include/linux/nfs3.h
+++ b/include/linux/nfs3.h
@@ -13,6 +13,7 @@
 #define NFS3_COOKIESIZE		4
 #define NFS3_CREATEVERFSIZE	8
 #define NFS3_COOKIEVERFSIZE	8
+#define NFS3_WRITEVERFSIZE	8
 #define NFS3_FIFO_DEV		(-1)
 #define NFS3MODE_FMT		0170000
 #define NFS3MODE_DIR		0040000

