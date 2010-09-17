Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47907 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab0IQQ0y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:26:54 -0400
Received: by mail-gx0-f174.google.com with SMTP id 23so788438gxk.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:26:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/22] NFS: Introduce new-style XDR encoding functions for
	NFSv2
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:26:51 -0400
Message-ID: <20100917162650.19761.76699.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Note that none of the helper functions are explicitly inlined.  The
compiler's optimizer is generally smart enough to figure out
automatically which functions may be inlined to conserve executable
size or streamline performance.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |  404 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 401 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 43413f2..86f867b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -61,6 +61,23 @@
 #define NFS_readdirres_sz	(1)
 #define NFS_statfsres_sz	(1+NFS_info_sz)
 
+
+/*
+ * While encoding arguments, set up the reply buffer in advance to
+ * receive reply data directly into the page cache.
+ */
+static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
+				 unsigned int base, unsigned int len,
+				 unsigned int bufsize)
+{
+	struct rpc_auth	*auth = req->rq_cred->cr_auth;
+	unsigned int replen;
+
+	replen = RPC_REPHDRSIZE + auth->au_rslack + bufsize;
+	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, pages, base, len);
+}
+
+
 /*
  * Common NFS XDR functions as inlines
  */
@@ -81,7 +98,7 @@ xdr_decode_fhandle(__be32 *p, struct nfs_fh *fhandle)
 }
 
 static inline __be32*
-xdr_encode_time(__be32 *p, struct timespec *timep)
+xdr_encode_time(__be32 *p, const struct timespec *timep)
 {
 	*p++ = htonl(timep->tv_sec);
 	/* Convert nanoseconds into microseconds */
@@ -90,7 +107,7 @@ xdr_encode_time(__be32 *p, struct timespec *timep)
 }
 
 static inline __be32*
-xdr_encode_current_server_time(__be32 *p, struct timespec *timep)
+xdr_encode_current_server_time(__be32 *p, const struct timespec *timep)
 {
 	/*
 	 * Passing the invalid value useconds=1000000 is a
@@ -174,6 +191,136 @@ xdr_encode_sattr(__be32 *p, struct iattr *attr)
 }
 
 /*
+ * Encode/decode NFSv2 basic data types
+ *
+ * Basic NFSv2 data types are defined in section 2.3 of RFC 1094:
+ * "NFS: Network File System Protocol Specification".
+ *
+ * Not all basic data types have their own encoding and decoding
+ * functions.  For run-time efficiency, some data types are encoded
+ * or decoded inline.
+ */
+
+/*
+ * 2.3.3.  fhandle
+ *
+ *	typedef opaque fhandle[FHSIZE];
+ */
+static void encode_fhandle(struct xdr_stream *xdr, const struct nfs_fh *fh)
+{
+	__be32 *p;
+
+	BUG_ON(fh->size != NFS2_FHSIZE);
+	p = xdr_reserve_space(xdr, NFS2_FHSIZE);
+	memcpy(p, fh->data, NFS2_FHSIZE);
+}
+
+/*
+ * 2.3.6.  sattr
+ *
+ *	struct sattr {
+ *		unsigned int	mode;
+ *		unsigned int	uid;
+ *		unsigned int	gid;
+ *		unsigned int	size;
+ *		timeval		atime;
+ *		timeval		mtime;
+ *	};
+ */
+
+#define NFS2_SATTR_NOT_SET	(0xffffffff)
+
+static __be32 *xdr_time_not_set(__be32 *p)
+{
+	*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	return p;
+}
+
+static void encode_sattr(struct xdr_stream *xdr, const struct iattr *attr)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, NFS_sattr_sz << 2);
+
+	if (attr->ia_valid & ATTR_MODE)
+		*p++ = cpu_to_be32(attr->ia_mode);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	if (attr->ia_valid & ATTR_UID)
+		*p++ = cpu_to_be32(attr->ia_uid);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	if (attr->ia_valid & ATTR_GID)
+		*p++ = cpu_to_be32(attr->ia_gid);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+	if (attr->ia_valid & ATTR_SIZE)
+		*p++ = cpu_to_be32((u32)attr->ia_size);
+	else
+		*p++ = cpu_to_be32(NFS2_SATTR_NOT_SET);
+
+	if (attr->ia_valid & ATTR_ATIME_SET)
+		p = xdr_encode_time(p, &attr->ia_atime);
+	else if (attr->ia_valid & ATTR_ATIME)
+		p = xdr_encode_current_server_time(p, &attr->ia_atime);
+	else
+		p = xdr_time_not_set(p);
+	if (attr->ia_valid & ATTR_MTIME_SET)
+		xdr_encode_time(p, &attr->ia_mtime);
+	else if (attr->ia_valid & ATTR_MTIME)
+		xdr_encode_current_server_time(p, &attr->ia_mtime);
+	else
+		xdr_time_not_set(p);
+}
+
+/*
+ * 2.3.7.  filename
+ *
+ *	typedef string filename<MAXNAMLEN>;
+ */
+static void encode_filename(struct xdr_stream *xdr,
+			    const char *name, u32 length)
+{
+	__be32 *p;
+
+	BUG_ON(length > NFS2_MAXNAMLEN);
+	p = xdr_reserve_space(xdr, 4 + length);
+	xdr_encode_opaque(p, name, length);
+}
+
+/*
+ * 2.3.8.  path
+ *
+ *	typedef string path<MAXPATHLEN>;
+ */
+static void encode_path(struct xdr_stream *xdr, struct page **pages, u32 length)
+{
+	__be32 *p;
+
+	BUG_ON(length > NFS2_MAXPATHLEN);
+	p = xdr_reserve_space(xdr, 4);
+	*p = cpu_to_be32(length);
+	xdr_write_pages(xdr, pages, 0, length);
+}
+
+/*
+ * 2.3.10.  diropargs
+ *
+ *	struct diropargs {
+ *		fhandle  dir;
+ *		filename name;
+ *	};
+ */
+static void encode_diropargs(struct xdr_stream *xdr, const struct nfs_fh *fh,
+			     const char *name, u32 length)
+{
+	encode_fhandle(xdr, fh);
+	encode_filename(xdr, name, length);
+}
+
+
+/*
  * NFS encode functions
  */
 /*
@@ -188,6 +335,16 @@ nfs_xdr_fhandle(struct rpc_rqst *req, __be32 *p, struct nfs_fh *fh)
 	return 0;
 }
 
+static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
+				const struct nfs_fh *fh)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, fh);
+	return 0;
+}
+
 /*
  * Encode SETATTR arguments
  */
@@ -201,6 +358,25 @@ nfs_xdr_sattrargs(struct rpc_rqst *req, __be32 *p, struct nfs_sattrargs *args)
 }
 
 /*
+ * 2.2.3.  sattrargs
+ *
+ *	struct sattrargs {
+ *		fhandle file;
+ *		sattr attributes;
+ *	};
+ */
+static int nfs2_xdr_enc_sattrargs(struct rpc_rqst *req, __be32 *p,
+				  const struct nfs_sattrargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fh);
+	encode_sattr(&xdr, args->sattr);
+	return 0;
+}
+
+/*
  * Encode directory ops argument
  * LOOKUP, RMDIR
  */
@@ -213,6 +389,16 @@ nfs_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs_diropargs *args)
 	return 0;
 }
 
+static int nfs2_xdr_enc_diropargs(struct rpc_rqst *req, __be32 *p,
+				  const struct nfs_diropargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fh, args->name, args->len);
+	return 0;
+}
+
 /*
  * Encode REMOVE argument
  */
@@ -225,6 +411,18 @@ nfs_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs
 	return 0;
 }
 
+static int nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req, __be32 *p,
+				     const struct nfs_readlinkargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fh);
+	prepare_reply_buffer(req, args->pages, args->pgbase,
+					args->pglen, NFS_readlinkres_sz);
+	return 0;
+}
+
 /*
  * Arguments to a READ call. Since we read data directly into the page
  * cache, we also set up the reply iovec here so that iov[1] points
@@ -253,6 +451,44 @@ nfs_xdr_readargs(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
 }
 
 /*
+ * 2.2.7.  readargs
+ *
+ *	struct readargs {
+ *		fhandle file;
+ *		unsigned offset;
+ *		unsigned count;
+ *		unsigned totalcount;
+ *	};
+ */
+static void encode_readargs(struct xdr_stream *xdr,
+			    const struct nfs_readargs *args)
+{
+	u32 offset = args->offset;
+	u32 count = args->count;
+	__be32 *p;
+
+	encode_fhandle(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 4 + 4 + 4);
+	*p++ = cpu_to_be32(offset);
+	*p++ = cpu_to_be32(count);
+	*p = cpu_to_be32(count);
+}
+
+static int nfs2_xdr_enc_readargs(struct rpc_rqst *req, __be32 *p,
+				 const struct nfs_readargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_readargs(&xdr, args);
+	prepare_reply_buffer(req, args->pages, args->pgbase,
+					args->count, NFS_readres_sz);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
+	return 0;
+}
+
+/*
  * Decode READ reply
  */
 static int
@@ -318,6 +554,47 @@ nfs_xdr_writeargs(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 }
 
 /*
+ * 2.2.9.  writeargs
+ *
+ *	struct writeargs {
+ *		fhandle file;
+ *		unsigned beginoffset;
+ *		unsigned offset;
+ *		unsigned totalcount;
+ *		nfsdata data;
+ *	};
+ */
+static void encode_writeargs(struct xdr_stream *xdr,
+			     const struct nfs_writeargs *args)
+{
+	u32 offset = args->offset;
+	u32 count = args->count;
+	__be32 *p;
+
+	encode_fhandle(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 4 + 4 + 4 + 4);
+	*p++ = cpu_to_be32(offset);
+	*p++ = cpu_to_be32(offset);
+	*p++ = cpu_to_be32(count);
+
+	/* nfsdata */
+	*p = cpu_to_be32(count);
+	xdr_write_pages(xdr, args->pages, args->pgbase, count);
+}
+
+static int nfs2_xdr_enc_writeargs(struct rpc_rqst *req, __be32 *p,
+				  const struct nfs_writeargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_writeargs(&xdr, args);
+	xdr.buf->flags |= XDRBUF_WRITE;
+	return 0;
+}
+
+/*
  * Encode create arguments
  * CREATE, MKDIR
  */
@@ -332,6 +609,35 @@ nfs_xdr_createargs(struct rpc_rqst *req, __be32 *p, struct nfs_createargs *args)
 }
 
 /*
+ * 2.2.10.  createargs
+ *
+ *	struct createargs {
+ *		diropargs where;
+ *		sattr attributes;
+ *	};
+ */
+static int nfs2_xdr_enc_createargs(struct rpc_rqst *req, __be32 *p,
+				   const struct nfs_createargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fh, args->name, args->len);
+	encode_sattr(&xdr, args->sattr);
+	return 0;
+}
+
+static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req, __be32 *p,
+				   const struct nfs_removeargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fh, args->name.name, args->name.len);
+	return 0;
+}
+
+/*
  * Encode RENAME arguments
  */
 static int
@@ -346,6 +652,25 @@ nfs_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
 }
 
 /*
+ * 2.2.12.  renameargs
+ *
+ *	struct renameargs {
+ *		diropargs from;
+ *		diropargs to;
+ *	};
+ */
+static int nfs2_xdr_enc_renameargs(struct rpc_rqst *req, __be32 *p,
+				   const struct nfs_renameargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fromfh, args->fromname, args->fromlen);
+	encode_diropargs(&xdr, args->tofh, args->toname, args->tolen);
+	return 0;
+}
+
+/*
  * Encode LINK arguments
  */
 static int
@@ -359,6 +684,25 @@ nfs_xdr_linkargs(struct rpc_rqst *req, __be32 *p, struct nfs_linkargs *args)
 }
 
 /*
+ * 2.2.13.  linkargs
+ *
+ *	struct linkargs {
+ *		fhandle from;
+ *		diropargs to;
+ *	};
+ */
+static int nfs2_xdr_enc_linkargs(struct rpc_rqst *req, __be32 *p,
+				 const struct nfs_linkargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fromfh);
+	encode_diropargs(&xdr, args->tofh, args->toname, args->tolen);
+	return 0;
+}
+
+/*
  * Encode SYMLINK arguments
  */
 static int
@@ -388,6 +732,27 @@ nfs_xdr_symlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs_symlinkargs *arg
 }
 
 /*
+ * 2.2.14.  symlinkargs
+ *
+ *	struct symlinkargs {
+ *		diropargs from;
+ *		path to;
+ *		sattr attributes;
+ *	};
+ */
+static int nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs_symlinkargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fromfh, args->fromname, args->fromlen);
+	encode_path(&xdr, args->pages, args->pathlen);
+	encode_sattr(&xdr, args->sattr);
+	return 0;
+}
+
+/*
  * Encode arguments to readdir call
  */
 static int
@@ -409,6 +774,39 @@ nfs_xdr_readdirargs(struct rpc_rqst *req, __be32 *p, struct nfs_readdirargs *arg
 }
 
 /*
+ * 2.2.17.  readdirargs
+ *
+ *	struct readdirargs {
+ *		fhandle dir;
+ *		nfscookie cookie;
+ *		unsigned count;
+ *	};
+ */
+static void encode_readdirargs(struct xdr_stream *xdr,
+			       const struct nfs_readdirargs *args)
+{
+	__be32 *p;
+
+	encode_fhandle(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 4 + 4);
+	*p++ = cpu_to_be32(args->cookie);
+	*p = cpu_to_be32(args->count);
+}
+
+static int nfs2_xdr_enc_readdirargs(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs_readdirargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_readdirargs(&xdr, args);
+	prepare_reply_buffer(req, args->pages, 0,
+					args->count, NFS_readdirres_sz);
+	return 0;
+}
+
+/*
  * Decode the result of a readdir call.
  * We're not really decoding anymore, we just leave the buffer untouched
  * and only check that it is syntactically correct.
@@ -719,7 +1117,7 @@ nfs_stat_to_errno(int stat)
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
-	.p_encode   =  (kxdrproc_t) nfs_xdr_##argtype,			\
+	.p_encode   =  (kxdrproc_t) nfs2_xdr_enc_##argtype,		\
 	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\

