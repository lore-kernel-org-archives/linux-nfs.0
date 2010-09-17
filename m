Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:59796 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab0IQQ1f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:27:35 -0400
Received: by mail-gw0-f46.google.com with SMTP id 17so784191gwj.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:27:35 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/22] NFS: Introduce new-style XDR decoding functions for
	NFSv2
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:27:32 -0400
Message-ID: <20100917162731.19761.35683.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    2 
 fs/nfs/nfs2xdr.c  |  562 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/proc.c     |    2 
 3 files changed, 563 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 01da8d4..6246d40 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -181,7 +181,7 @@ extern void nfs_destroy_directcache(void);
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(enum nfs_stat);
 extern struct rpc_procinfo nfs_procedures[];
-extern __be32 * nfs_decode_dirent(__be32 *, struct nfs_entry *, int);
+extern __be32 *nfs2_decode_dirent(__be32 *, struct nfs_entry *, int);
 
 /* nfs3xdr.c */
 extern struct rpc_procinfo nfs3_procedures[];
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 186f591..eb3238c 100644
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
@@ -274,6 +402,65 @@ static void encode_path(struct xdr_stream *xdr, struct page **pages, u32 length)
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
@@ -289,6 +476,48 @@ static void encode_diropargs(struct xdr_stream *xdr, const struct nfs_fh *fh,
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
@@ -719,6 +948,25 @@ nfs_xdr_stat(struct rpc_rqst *req, __be32 *p, void *dummy)
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
@@ -734,6 +982,15 @@ nfs_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
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
@@ -750,6 +1007,15 @@ nfs_xdr_diropres(struct rpc_rqst *req, __be32 *p, struct nfs_diropok *res)
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
@@ -791,6 +1057,70 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
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
@@ -800,6 +1130,181 @@ nfs_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
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
+/*
+ * 2.2.17.  readdirres
+ *
+ *	struct entry {
+ *		unsigned	fileid;
+ *		filename	name;
+ *		nfscookie	cookie;
+ *		entry		*nextentry;
+ *	};
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
+ * The type (size) of nfscookie isn't defined in RFC 1094.
+ *
+ * The Linux implementation of readdir is limited to receiving not
+ * more than a single page of entries at a time.
+ *
+ * Here, the XDR buffer is checked for correct syntax.  The actual
+ * decoding is done by nfs_decode_entry() during subsequent
+ * nfs_readdir() calls on readdir data cached in the page cache.
+ */
+static int decode_readdirok(struct xdr_stream *xdr)
+{
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
+	/* Make sure the packet actually has a value_follows and EOF entry */
+	if (unlikely((entry + 1) > end))
+		goto out_short_reply;
+
+	nr = 0;
+	for (; *p++ != xdr_zero; nr++) {
+		if (unlikely(p + 2 > end))
+			goto out_short_reply;
+		p++;				/* fileid */
+		count = be32_to_cpup(p++);
+		if (unlikely(count > NFS2_MAXNAMLEN))
+			goto out_nametoolong;
+		p += XDR_QUADLEN(count) + 1;	/* name plus cookie */
+		if (unlikely(p + 2 > end))
+			goto out_short_reply;
+		entry = p;
+	}
+
+	/*
+	 * Apparently some server sends responses that are a valid size,
+	 * but contain no entries, and have value_follows==0 and EOF==0.
+	 * For those, just set the EOF marker.
+	 */
+	if (unlikely(!nr && entry[1] == xdr_zero))
+		goto out_truncated;
+out:
+	kunmap_atomic(kaddr, KM_USER0);
+	return nr;
+out_short_reply:
+	/*
+	 * When we get a short reply there are 2 possibilities.  We can
+	 * return an error, or fix up the response to look like a valid
+	 * response and return what we have so far.  If there are no
+	 * entries and the reply was short, then return -EIO.  If there
+	 * are valid entries in the response, return them and pretend
+	 * that the call was successful, but incomplete.  The caller can
+	 * retry the readdir starting at the last cookie.
+	 */
+	dprintk("NFS: short readdir reply at entry %d\n", nr);
+	entry[0] = entry[1] = xdr_zero;
+	if (!nr)
+		nr = -EIO;
+	goto out;
+out_nametoolong:
+	dprintk("NFS: filename too long during readdir (len 0x%x)\n", count);
+	nr = -EIO;
+	goto out;
+out_truncated:
+	dprintk("NFS: readdir reply truncated\n");
+	entry[1] = xdr_one;
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
+/**
+ * nfs2_decode_dirent - Decode a single NFSv2 directory entry stored in
+ *                     the local page cache.
+ * @p: pointer to buffer where entry resides
+ * @entry: entry struct to fill out with data
+ * @plus: boolean indicating whether this should be a readdirplus entry
+ *
+ * Returns the position of the next item in the buffer, or an ERR_PTR.
+ *
+ * This function is not invoked during READDIR reply decoding, but
+ * rather whenever an application invokes the getdents(2) system call.
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
+__be32 *nfs2_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
+{
+	if (*p++ == xdr_zero) {
+		if (*p == xdr_zero)
+			return ERR_PTR(-EAGAIN);
+		entry->eof = 1;
+		return ERR_PTR(-EBADCOOKIE);
+	}
+
+	entry->ino = be32_to_cpup(p++);
+	p = xdr_decode_string_inplace(p, (char **)&entry->name,
+					&entry->len, NFS2_MAXNAMLEN);
+	entry->prev_cookie = entry->cookie;
+	entry->cookie = be32_to_cpup(p++);
+
+	/* Peek at the next entry */
+	entry->eof = (p[0] == xdr_zero) && (p[1] != xdr_zero);
+	return p;
+}
+
 /*
  * Decode STATFS reply
  */
@@ -820,6 +1325,61 @@ nfs_xdr_statfsres(struct rpc_rqst *req, __be32 *p, struct nfs2_fsstat *res)
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
@@ -886,7 +1446,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  (kxdrproc_t) nfs2_xdr_enc_##argtype,		\
-	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
+	.p_decode   =  (kxdrproc_t) nfs2_xdr_dec_##restype,		\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 611bec2..12a0200 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -714,7 +714,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.statfs		= nfs_proc_statfs,
 	.fsinfo		= nfs_proc_fsinfo,
 	.pathconf	= nfs_proc_pathconf,
-	.decode_dirent	= nfs_decode_dirent,
+	.decode_dirent	= nfs2_decode_dirent,
 	.read_setup	= nfs_proc_read_setup,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,

