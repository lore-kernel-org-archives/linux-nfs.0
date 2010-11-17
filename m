Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58231 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934871Ab0KQRo0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:44:26 -0500
Received: by yxf34 with SMTP id 34so1261313yxf.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:44:26 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/17] NFS: Introduce new-style XDR decoding functions for
	NFSv2
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:44:21 -0500
Message-ID: <20101117174421.29177.73508.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We'd like to prevent local buffer overflows caused by malicious or
broken servers.  New xdr_stream style decoders can do that.

For efficiency, we also eventually want to be able to pass xdr_streams
from call_decode() to all XDR decoding functions, rather than building
an xdr_stream in every XDR decoding function in the kernel.

nfs_decode_dirent() is renamed to follow the naming convention of the
other two dirent decoders.

Static helper functions are left without the "inline" directive.  This
allows the compiler to choose automatically how to optimize these for
size or speed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/internal.h |    2 
 fs/nfs/nfs2xdr.c  |  562 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/proc.c     |    2 
 3 files changed, 556 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index cddf49d..68313da 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -187,7 +187,7 @@ extern void nfs_destroy_directcache(void);
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(enum nfs_stat);
 extern struct rpc_procinfo nfs_procedures[];
-extern __be32 *nfs_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
+extern __be32 *nfs2_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 
 /* nfs3xdr.c */
 extern struct rpc_procinfo nfs3_procedures[];
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1c5a2fa..465d10d 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -77,6 +77,16 @@ static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
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
@@ -139,6 +149,74 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
  */
 
 /*
+ *	typedef opaque	nfsdata<>;
+ */
+static int decode_nfsdata(struct xdr_stream *xdr, struct nfs_readres *result)
+{
+	u32 recvd, count;
+	size_t hdrlen;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	count = be32_to_cpup(p);
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = xdr->buf->len - hdrlen;
+	if (unlikely(count > recvd))
+		goto out_cheating;
+out:
+	xdr_read_pages(xdr, count);
+	result->eof = 0;	/* NFSv2 does not pass EOF flag on the wire. */
+	result->count = count;
+	return count;
+out_cheating:
+	dprintk("NFS: server cheating in read result: "
+		"count %u > recvd %u\n", count, recvd);
+	count = recvd;
+	goto out;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ *	enum stat {
+ *		NFS_OK = 0,
+ *		NFSERR_PERM = 1,
+ *		NFSERR_NOENT = 2,
+ *		NFSERR_IO = 5,
+ *		NFSERR_NXIO = 6,
+ *		NFSERR_ACCES = 13,
+ *		NFSERR_EXIST = 17,
+ *		NFSERR_NODEV = 19,
+ *		NFSERR_NOTDIR = 20,
+ *		NFSERR_ISDIR = 21,
+ *		NFSERR_FBIG = 27,
+ *		NFSERR_NOSPC = 28,
+ *		NFSERR_ROFS = 30,
+ *		NFSERR_NAMETOOLONG = 63,
+ *		NFSERR_NOTEMPTY = 66,
+ *		NFSERR_DQUOT = 69,
+ *		NFSERR_STALE = 70,
+ *		NFSERR_WFLUSH = 99
+ *	};
+ */
+static int decode_stat(struct xdr_stream *xdr, enum nfs_stat *status)
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
+/*
  * 2.3.3.  fhandle
  *
  *	typedef opaque fhandle[FHSIZE];
@@ -152,6 +230,21 @@ static void encode_fhandle(struct xdr_stream *xdr, const struct nfs_fh *fh)
 	memcpy(p, fh->data, NFS2_FHSIZE);
 }
 
+static int decode_fhandle(struct xdr_stream *xdr, struct nfs_fh *fh)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS2_FHSIZE);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	fh->size = NFS2_FHSIZE;
+	memcpy(fh->data, p, NFS2_FHSIZE);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 /*
  * 2.3.4.  timeval
  *
@@ -186,6 +279,41 @@ static __be32 *xdr_encode_current_server_time(__be32 *p,
 }
 
 /*
+ * 2.3.5.  fattr
+ *
+ *	struct fattr {
+ *		ftype		type;
+ *		unsigned int	mode;
+ *		unsigned int	nlink;
+ *		unsigned int	uid;
+ *		unsigned int	gid;
+ *		unsigned int	size;
+ *		unsigned int	blocksize;
+ *		unsigned int	rdev;
+ *		unsigned int	blocks;
+ *		unsigned int	fsid;
+ *		unsigned int	fileid;
+ *		timeval		atime;
+ *		timeval		mtime;
+ *		timeval		ctime;
+ *	};
+ *
+ */
+static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS_fattr_sz << 2);
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
  * 2.3.6.  sattr
  *
  *	struct sattr {
@@ -259,6 +387,32 @@ static void encode_filename(struct xdr_stream *xdr,
 	xdr_encode_opaque(p, name, length);
 }
 
+static int decode_filename_inline(struct xdr_stream *xdr,
+				  const char **name, u32 *length)
+{
+	__be32 *p;
+	u32 count;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	count = be32_to_cpup(p);
+	if (count > NFS3_MAXNAMLEN)
+		goto out_nametoolong;
+	p = xdr_inline_decode(xdr, count);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	*name = (const char *)p;
+	*length = count;
+	return 0;
+out_nametoolong:
+	dprintk("NFS: returned filename too long: %u\n", count);
+	return -ENAMETOOLONG;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 /*
  * 2.3.8.  path
  *
@@ -274,6 +428,65 @@ static void encode_path(struct xdr_stream *xdr, struct page **pages, u32 length)
 	xdr_write_pages(xdr, pages, 0, length);
 }
 
+static int decode_path(struct xdr_stream *xdr)
+{
+	u32 length, recvd;
+	size_t hdrlen;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	length = be32_to_cpup(p);
+	if (unlikely(length >= xdr->buf->page_len || length > NFS_MAXPATHLEN))
+		goto out_size;
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = xdr->buf->len - hdrlen;
+	if (unlikely(length > recvd))
+		goto out_cheating;
+
+	xdr_read_pages(xdr, length);
+	xdr_terminate_string(xdr->buf, length);
+	return 0;
+out_size:
+	dprintk("NFS: returned pathname too long: %u\n", length);
+	return -ENAMETOOLONG;
+out_cheating:
+	dprintk("NFS: server cheating in pathname result: "
+		"length %u > received %u\n", length, recvd);
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ * 2.3.9.  attrstat
+ *
+ *	union attrstat switch (stat status) {
+ *	case NFS_OK:
+ *		fattr attributes;
+ *	default:
+ *		void;
+ *	};
+ */
+static int decode_attrstat(struct xdr_stream *xdr, struct nfs_fattr *result)
+{
+	enum nfs_stat status;
+	int error;
+
+	error = decode_stat(xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS_OK)
+		goto out_default;
+	error = decode_fattr(xdr, result);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
 /*
  * 2.3.10.  diropargs
  *
@@ -289,6 +502,48 @@ static void encode_diropargs(struct xdr_stream *xdr, const struct nfs_fh *fh,
 	encode_filename(xdr, name, length);
 }
 
+/*
+ * 2.3.11.  diropres
+ *
+ *	union diropres switch (stat status) {
+ *	case NFS_OK:
+ *		struct {
+ *			fhandle file;
+ *			fattr   attributes;
+ *		} diropok;
+ *	default:
+ *		void;
+ *	};
+ */
+static int decode_diropok(struct xdr_stream *xdr, struct nfs_diropok *result)
+{
+	int error;
+
+	error = decode_fhandle(xdr, result->fh);
+	if (unlikely(error))
+		goto out;
+	error = decode_fattr(xdr, result->fattr);
+out:
+	return error;
+}
+
+static int decode_diropres(struct xdr_stream *xdr, struct nfs_diropok *result)
+{
+	enum nfs_stat status;
+	int error;
+
+	error = decode_stat(xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS_OK)
+		goto out_default;
+	error = decode_diropok(xdr, result);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
 
 /*
  * NFSv2 XDR encode functions
@@ -630,13 +885,6 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	return nr;
 }
 
-static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
-{
-	dprintk("nfs: %s: prematurely hit end of receive buffer. "
-		"Remaining buffer length is %tu words.\n",
-		func, xdr->end - xdr->p);
-}
-
 __be32 *
 nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_server *server, int plus)
 {
@@ -698,6 +946,25 @@ nfs_xdr_stat(struct rpc_rqst *req, __be32 *p, void *dummy)
 	return status;
 }
 
+static int nfs2_xdr_dec_stat(struct rpc_rqst *req, __be32 *p,
+			     void *__unused)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_stat(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS_OK)
+		goto out_default;
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
 /*
  * Decode attrstat reply
  * GETATTR, SETATTR, WRITE
@@ -713,6 +980,15 @@ nfs_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	return 0;
 }
 
+static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, __be32 *p,
+				 struct nfs_fattr *result)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	return decode_attrstat(&xdr, result);
+}
+
 /*
  * Decode diropres reply
  * LOOKUP, CREATE, MKDIR
@@ -729,6 +1005,15 @@ nfs_xdr_diropres(struct rpc_rqst *req, __be32 *p, struct nfs_diropok *res)
 	return 0;
 }
 
+static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, __be32 *p,
+				 struct nfs_diropok *result)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	return decode_diropres(&xdr, result);
+}
+
 /*
  * Decode READLINK reply
  */
@@ -770,6 +1055,70 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 }
 
 /*
+ * 2.2.6.  readlinkres
+ *
+ *	union readlinkres switch (stat status) {
+ *	case NFS_OK:
+ *		path data;
+ *	default:
+ *		void;
+ *	};
+ */
+static int nfs2_xdr_dec_readlinkres(struct rpc_rqst *req, __be32 *p,
+				    void *__unused)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_stat(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS_OK)
+		goto out_default;
+	error = decode_path(&xdr);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
+/*
+ * 2.2.7.  readres
+ *
+ *	union readres switch (stat status) {
+ *	case NFS_OK:
+ *		fattr attributes;
+ *		nfsdata data;
+ *	default:
+ *		void;
+ *	};
+ */
+static int nfs2_xdr_dec_readres(struct rpc_rqst *req, __be32 *p,
+				struct nfs_readres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_stat(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS_OK)
+		goto out_default;
+	error = decode_fattr(&xdr, result->fattr);
+	if (unlikely(error))
+		goto out;
+	error = decode_nfsdata(&xdr, result);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
+/*
  * Decode WRITE reply
  */
 static int
@@ -779,6 +1128,148 @@ nfs_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
 	return nfs_xdr_attrstat(req, p, res->fattr);
 }
 
+static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
+				 struct nfs_writeres *result)
+{
+	struct xdr_stream xdr;
+
+	/* All NFSv2 writes are "file sync" writes */
+	result->verf->committed = NFS_FILE_SYNC;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	return decode_attrstat(&xdr, result->fattr);
+}
+
+/**
+ * nfs2_decode_dirent - Decode a single NFSv2 directory entry stored in
+ *                      the local page cache.
+ * @xdr: XDR stream where entry resides
+ * @entry: buffer to fill in with entry data
+ * @server: nfs_server data for this directory
+ * @plus: boolean indicating whether this should be a readdirplus entry
+ *
+ * Returns the position of the next item in the buffer, or an ERR_PTR.
+ *
+ * This function is not invoked during READDIR reply decoding, but
+ * rather whenever an application invokes the getdents(2) system call
+ * on a directory already in our cache.
+ *
+ * 2.2.17.  entry
+ *
+ *	struct entry {
+ *		unsigned	fileid;
+ *		filename	name;
+ *		nfscookie	cookie;
+ *		entry		*nextentry;
+ *	};
+ */
+__be32 *nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
+			   struct nfs_server *server, int plus)
+{
+	__be32 *p;
+	int error;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	if (*p++ == xdr_zero) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(p == NULL))
+			goto out_overflow;
+		if (*p++ == xdr_zero)
+			return ERR_PTR(-EAGAIN);
+		entry->eof = 1;
+		return ERR_PTR(-EBADCOOKIE);
+	}
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	entry->ino = be32_to_cpup(p);
+
+	error = decode_filename_inline(xdr, &entry->name, &entry->len);
+	if (unlikely(error))
+		return ERR_PTR(error);
+
+	/*
+	 * The type (size and byte order) of nfscookie isn't defined in
+	 * RFC 1094.  This implementation assumes that it's an XDR uint32.
+	 */
+	entry->prev_cookie = entry->cookie;
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	entry->cookie = be32_to_cpup(p);
+
+	/* Peek at the next entry to see if we're at EOD */
+	p = xdr_inline_peek(xdr, 4 + 4);
+	entry->eof = 0;
+	if (p != NULL)
+		entry->eof = (p[0] == xdr_zero) && (p[1] != xdr_zero);
+	return p;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return ERR_PTR(-EIO);
+}
+
+/*
+ * 2.2.17.  readdirres
+ *
+ *	union readdirres switch (stat status) {
+ *	case NFS_OK:
+ *		struct {
+ *			entry *entries;
+ *			bool eof;
+ *		} readdirok;
+ *	default:
+ *		void;
+ *	};
+ *
+ * Read the directory contents into the page cache, but don't
+ * touch them.  The actual decoding is done by nfs2_decode_dirent()
+ * during subsequent nfs_readdir() calls.
+ */
+static int decode_readdirok(struct xdr_stream *xdr)
+{
+	u32 recvd, pglen;
+	size_t hdrlen;
+
+	pglen = xdr->buf->page_len;
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = xdr->buf->len - hdrlen;
+	if (unlikely(pglen > recvd))
+		goto out_cheating;
+out:
+	xdr_read_pages(xdr, pglen);
+	return 0;
+out_cheating:
+	dprintk("NFS: server cheating in readdir result: "
+		"pglen %u > recvd %u\n", pglen, recvd);
+	pglen = recvd;
+	goto out;
+}
+
+static int nfs2_xdr_dec_readdirres(struct rpc_rqst *req, __be32 *p,
+				   void *__unused)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_stat(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS_OK)
+		goto out_default;
+	error = decode_readdirok(&xdr);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
 /*
  * Decode STATFS reply
  */
@@ -799,6 +1290,61 @@ nfs_xdr_statfsres(struct rpc_rqst *req, __be32 *p, struct nfs2_fsstat *res)
 }
 
 /*
+ * 2.2.18.  statfsres
+ *
+ *	union statfsres (stat status) {
+ *	case NFS_OK:
+ *		struct {
+ *			unsigned tsize;
+ *			unsigned bsize;
+ *			unsigned blocks;
+ *			unsigned bfree;
+ *			unsigned bavail;
+ *		} info;
+ *	default:
+ *		void;
+ *	};
+ */
+static int decode_info(struct xdr_stream *xdr, struct nfs2_fsstat *result)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS_info_sz << 2);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	result->tsize  = be32_to_cpup(p++);
+	result->bsize  = be32_to_cpup(p++);
+	result->blocks = be32_to_cpup(p++);
+	result->bfree  = be32_to_cpup(p++);
+	result->bavail = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int nfs2_xdr_dec_statfsres(struct rpc_rqst *req, __be32 *p,
+				  struct nfs2_fsstat *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_stat(&xdr, &status);
+	if (unlikely(error))
+		goto out;
+	if (status != NFS_OK)
+		goto out_default;
+	error = decode_info(&xdr, result);
+out:
+	return error;
+out_default:
+	return nfs_stat_to_errno(status);
+}
+
+
+/*
  * We need to translate between nfs status return values and
  * the local errno values which may not be the same.
  */
@@ -865,7 +1411,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  (kxdrproc_t)nfs2_xdr_enc_##argtype,		\
-	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
+	.p_decode   =  (kxdrproc_t)nfs2_xdr_dec_##restype,		\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 58e7f84..00df605 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -731,7 +731,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.statfs		= nfs_proc_statfs,
 	.fsinfo		= nfs_proc_fsinfo,
 	.pathconf	= nfs_proc_pathconf,
-	.decode_dirent	= nfs_decode_dirent,
+	.decode_dirent	= nfs2_decode_dirent,
 	.read_setup	= nfs_proc_read_setup,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,

