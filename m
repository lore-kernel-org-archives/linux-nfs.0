Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:62191 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934635Ab0KQRpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:45:09 -0500
Received: by yxf34 with SMTP id 34so1262008yxf.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:45:08 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/17] NFS: Introduce new-style XDR encoding functions for
	NFSv3
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:45:03 -0500
Message-ID: <20101117174503.29177.52305.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We're interested in taking advantage of the safety benefits of
xdr_streams.  These data structures allow more careful checking for
buffer overflow while encoding.  More careful type checking is also
introduced in the new functions.

For efficiency, we also eventually want to be able to pass xdr_streams
from call_encode() to all XDR encoding functions, rather than building
an xdr_stream in every XDR encoding function in the kernel.  To do
this means all encoders must be ready to handle a passed-in
xdr_stream.

We follow the modern paradigm for encoders of BUGging on error and
always returning a zero status code.

Static helper functions are left without the "inline" directive.  This
allows the compiler to choose automatically how to optimize these for
size or speed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs3xdr.c     |  833 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs3.h |    2 
 2 files changed, 832 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d9a5e83..22c1d1c 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -37,6 +37,7 @@
 #define NFS3_filename_sz	(1+(NFS3_MAXNAMLEN>>2))
 #define NFS3_path_sz		(1+(NFS3_MAXPATHLEN>>2))
 #define NFS3_fattr_sz		(21)
+#define NFS3_cookieverf_sz	(NFS3_COOKIEVERFSIZE>>2)
 #define NFS3_wcc_attr_sz		(6)
 #define NFS3_pre_op_attr_sz	(1+NFS3_wcc_attr_sz)
 #define NFS3_post_op_attr_sz	(1+NFS3_fattr_sz)
@@ -59,7 +60,8 @@
 #define NFS3_mknodargs_sz	(NFS3_diropargs_sz+2+NFS3_sattr_sz)
 #define NFS3_renameargs_sz	(NFS3_diropargs_sz+NFS3_diropargs_sz)
 #define NFS3_linkargs_sz		(NFS3_fh_sz+NFS3_diropargs_sz)
-#define NFS3_readdirargs_sz	(NFS3_fh_sz+2)
+#define NFS3_readdirargs_sz	(NFS3_fh_sz+NFS3_cookieverf_sz+3)
+#define NFS3_readdirplusargs_sz	(NFS3_fh_sz+NFS3_cookieverf_sz+4)
 #define NFS3_commitargs_sz	(NFS3_fh_sz+3)
 
 #define NFS3_attrstat_sz	(1+NFS3_fattr_sz)
@@ -108,6 +110,22 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 }
 
 /*
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
+/*
  * Common NFS XDR functions as inlines
  */
 static inline __be32 *
@@ -153,7 +171,7 @@ out_overflow:
  * Encode/decode time.
  */
 static inline __be32 *
-xdr_encode_time3(__be32 *p, struct timespec *timep)
+xdr_encode_time3(__be32 *p, const struct timespec *timep)
 {
 	*p++ = htonl(timep->tv_sec);
 	*p++ = htonl(timep->tv_nsec);
@@ -205,7 +223,7 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 }
 
 static inline __be32 *
-xdr_encode_sattr(__be32 *p, struct iattr *attr)
+xdr_encode_sattr(__be32 *p, const struct iattr *attr)
 {
 	if (attr->ia_valid & ATTR_MODE) {
 		*p++ = xdr_one;
@@ -306,6 +324,243 @@ xdr_decode_wcc_data(__be32 *p, struct nfs_fattr *fattr)
 	return xdr_decode_post_op_attr(p, fattr);
 }
 
+
+/*
+ * Encode/decode NFSv3 basic data types
+ *
+ * Basic NFSv3 data types are defined in section 2.5 of RFC 1813:
+ * "NFS Version 3 Protocol Specification".
+ *
+ * Not all basic data types have their own encoding and decoding
+ * functions.  For run-time efficiency, some data types are encoded
+ * or decoded inline.
+ */
+
+static void encode_uint32(struct xdr_stream *xdr, u32 value)
+{
+	__be32 *p = xdr_reserve_space(xdr, 4);
+	*p = cpu_to_be32(value);
+}
+
+/*
+ * filename3
+ *
+ *	typedef string filename3<>;
+ */
+static void encode_filename3(struct xdr_stream *xdr,
+			     const char *name, u32 length)
+{
+	__be32 *p;
+
+	BUG_ON(length > NFS3_MAXNAMLEN);
+	p = xdr_reserve_space(xdr, 4 + length);
+	xdr_encode_opaque(p, name, length);
+}
+
+/*
+ * nfspath3
+ *
+ *	typedef string nfspath3<>;
+ */
+static void encode_nfspath3(struct xdr_stream *xdr, struct page **pages,
+			    const u32 length)
+{
+	BUG_ON(length > NFS3_MAXPATHLEN);
+	encode_uint32(xdr, length);
+	xdr_write_pages(xdr, pages, 0, length);
+}
+
+/*
+ * cookie3
+ *
+ *	typedef uint64 cookie3
+ */
+static __be32 *xdr_encode_cookie3(__be32 *p, u64 cookie)
+{
+	return xdr_encode_hyper(p, cookie);
+}
+
+/*
+ * cookieverf3
+ *
+ *	typedef opaque cookieverf3[NFS3_COOKIEVERFSIZE];
+ */
+static __be32 *xdr_encode_cookieverf3(__be32 *p, const __be32 *verifier)
+{
+	memcpy(p, verifier, NFS3_COOKIEVERFSIZE);
+	return p + XDR_QUADLEN(NFS3_COOKIEVERFSIZE);
+}
+
+/*
+ * createverf3
+ *
+ *	typedef opaque createverf3[NFS3_CREATEVERFSIZE];
+ */
+static void encode_createverf3(struct xdr_stream *xdr, const __be32 *verifier)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, NFS3_CREATEVERFSIZE);
+	memcpy(p, verifier, NFS3_CREATEVERFSIZE);
+}
+
+/*
+ * ftype3
+ *
+ *	enum ftype3 {
+ *		NF3REG	= 1,
+ *		NF3DIR	= 2,
+ *		NF3BLK	= 3,
+ *		NF3CHR	= 4,
+ *		NF3LNK	= 5,
+ *		NF3SOCK	= 6,
+ *		NF3FIFO	= 7
+ *	};
+ */
+static void encode_ftype3(struct xdr_stream *xdr, const u32 type)
+{
+	BUG_ON(type > NF3FIFO);
+	encode_uint32(xdr, type);
+}
+
+/*
+ * specdata3
+ *
+ *     struct specdata3 {
+ *             uint32  specdata1;
+ *             uint32  specdata2;
+ *     };
+ */
+static void encode_specdata3(struct xdr_stream *xdr, const dev_t rdev)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 8);
+	*p++ = cpu_to_be32(MAJOR(rdev));
+	*p = cpu_to_be32(MINOR(rdev));
+}
+
+/*
+ * nfs_fh3
+ *
+ *	struct nfs_fh3 {
+ *		opaque       data<NFS3_FHSIZE>;
+ *	};
+ */
+static void encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh *fh)
+{
+	__be32 *p;
+
+	BUG_ON(fh->size > NFS3_FHSIZE);
+	p = xdr_reserve_space(xdr, 4 + fh->size);
+	xdr_encode_opaque(p, fh->data, fh->size);
+}
+
+/*
+ * sattr3
+ *
+ *	enum time_how {
+ *		DONT_CHANGE		= 0,
+ *		SET_TO_SERVER_TIME	= 1,
+ *		SET_TO_CLIENT_TIME	= 2
+ *	};
+ *
+ *	union set_mode3 switch (bool set_it) {
+ *	case TRUE:
+ *		mode3	mode;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	union set_uid3 switch (bool set_it) {
+ *	case TRUE:
+ *		uid3	uid;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	union set_gid3 switch (bool set_it) {
+ *	case TRUE:
+ *		gid3	gid;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	union set_size3 switch (bool set_it) {
+ *	case TRUE:
+ *		size3	size;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	union set_atime switch (time_how set_it) {
+ *	case SET_TO_CLIENT_TIME:
+ *		nfstime3	atime;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	union set_mtime switch (time_how set_it) {
+ *	case SET_TO_CLIENT_TIME:
+ *		nfstime3  mtime;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	struct sattr3 {
+ *		set_mode3	mode;
+ *		set_uid3	uid;
+ *		set_gid3	gid;
+ *		set_size3	size;
+ *		set_atime	atime;
+ *		set_mtime	mtime;
+ *	};
+ */
+static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
+{
+	u32 nbytes;
+	__be32 *p;
+
+	/*
+	 * In order to make only a single xdr_reserve_space() call,
+	 * pre-compute the total number of bytes to be reserved.
+	 * Six boolean values, one for each set_foo field, are always
+	 * present in the encoded result, so start there.
+	 */
+	nbytes = 6 * 4;
+	if (attr->ia_valid & ATTR_MODE)
+		nbytes += 4;
+	if (attr->ia_valid & ATTR_UID)
+		nbytes += 4;
+	if (attr->ia_valid & ATTR_GID)
+		nbytes += 4;
+	if (attr->ia_valid & ATTR_SIZE)
+		nbytes += 8;
+	if (attr->ia_valid & ATTR_ATIME_SET)
+		nbytes += 8;
+	if (attr->ia_valid & ATTR_MTIME_SET)
+		nbytes += 8;
+	p = xdr_reserve_space(xdr, nbytes);
+
+	xdr_encode_sattr(p, attr);
+}
+
+/*
+ * diropargs3
+ *
+ *	struct diropargs3 {
+ *		nfs_fh3		dir;
+ *		filename3	name;
+ *	};
+ */
+static void encode_diropargs3(struct xdr_stream *xdr, const struct nfs_fh *fh,
+			      const char *name, u32 length)
+{
+	encode_nfs_fh3(xdr, fh);
+	encode_filename3(xdr, name, length);
+}
+
+
 /*
  * NFS encode functions
  */
@@ -322,6 +577,23 @@ nfs3_xdr_fhandle(struct rpc_rqst *req, __be32 *p, struct nfs_fh *fh)
 }
 
 /*
+ * 3.3.1  GETATTR3args
+ *
+ *	struct GETATTR3args {
+ *		nfs_fh3  object;
+ *	};
+ */
+static int nfs3_xdr_enc_getattr3args(struct rpc_rqst *req, __be32 *p,
+				     const struct nfs_fh *fh)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_nfs_fh3(&xdr, fh);
+	return 0;
+}
+
+/*
  * Encode SETATTR arguments
  */
 static int
@@ -337,6 +609,49 @@ nfs3_xdr_sattrargs(struct rpc_rqst *req, __be32 *p, struct nfs3_sattrargs *args)
 }
 
 /*
+ * 3.3.2  SETATTR3args
+ *
+ *	union sattrguard3 switch (bool check) {
+ *	case TRUE:
+ *		nfstime3  obj_ctime;
+ *	case FALSE:
+ *		void;
+ *	};
+ *
+ *	struct SETATTR3args {
+ *		nfs_fh3		object;
+ *		sattr3		new_attributes;
+ *		sattrguard3	guard;
+ *	};
+ */
+static void encode_sattrguard3(struct xdr_stream *xdr,
+			       const struct nfs3_sattrargs *args)
+{
+	__be32 *p;
+
+	if (args->guard) {
+		p = xdr_reserve_space(xdr, 4 + 8);
+		*p++ = xdr_one;
+		xdr_encode_time3(p, &args->guardtime);
+	} else {
+		p = xdr_reserve_space(xdr, 4);
+		*p = xdr_zero;
+	}
+}
+
+static int nfs3_xdr_enc_setattr3args(struct rpc_rqst *req, __be32 *p,
+				     const struct nfs3_sattrargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_nfs_fh3(&xdr, args->fh);
+	encode_sattr3(&xdr, args->sattr);
+	encode_sattrguard3(&xdr, args);
+	return 0;
+}
+
+/*
  * Encode directory ops argument
  */
 static int
@@ -349,6 +664,23 @@ nfs3_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs3_diropargs *args)
 }
 
 /*
+ * 3.3.3  LOOKUP3args
+ *
+ *	struct LOOKUP3args {
+ *		diropargs3  what;
+ *	};
+ */
+static int nfs3_xdr_enc_lookup3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs3_diropargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs3(&xdr, args->fh, args->name, args->len);
+	return 0;
+}
+
+/*
  * Encode REMOVE argument
  */
 static int
@@ -373,6 +705,50 @@ nfs3_xdr_accessargs(struct rpc_rqst *req, __be32 *p, struct nfs3_accessargs *arg
 }
 
 /*
+ * 3.3.4  ACCESS3args
+ *
+ *	struct ACCESS3args {
+ *		nfs_fh3		object;
+ *		uint32		access;
+ *	};
+ */
+static void encode_access3args(struct xdr_stream *xdr,
+			       const struct nfs3_accessargs *args)
+{
+	encode_nfs_fh3(xdr, args->fh);
+	encode_uint32(xdr, args->access);
+}
+
+static int nfs3_xdr_enc_access3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs3_accessargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_access3args(&xdr, args);
+	return 0;
+}
+
+/*
+ * 3.3.5  READLINK3args
+ *
+ *	struct READLINK3args {
+ *		nfs_fh3	symlink;
+ *	};
+ */
+static int nfs3_xdr_enc_readlink3args(struct rpc_rqst *req, __be32 *p,
+				      const struct nfs3_readlinkargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_nfs_fh3(&xdr, args->fh);
+	prepare_reply_buffer(req, args->pages, args->pgbase,
+					args->pglen, NFS3_readlinkres_sz);
+	return 0;
+}
+
+/*
  * Arguments to a READ call. Since we read data directly into the page
  * cache, we also set up the reply iovec here so that iov[1] points
  * exactly to the page we want to fetch.
@@ -398,6 +774,40 @@ nfs3_xdr_readargs(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
 }
 
 /*
+ * 3.3.6  READ3args
+ *
+ *	struct READ3args {
+ *		nfs_fh3		file;
+ *		offset3		offset;
+ *		count3		count;
+ *	};
+ */
+static void encode_read3args(struct xdr_stream *xdr,
+			     const struct nfs_readargs *args)
+{
+	__be32 *p;
+
+	encode_nfs_fh3(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 8 + 4);
+	p = xdr_encode_hyper(p, args->offset);
+	*p = cpu_to_be32(args->count);
+}
+
+static int nfs3_xdr_enc_read3args(struct rpc_rqst *req, __be32 *p,
+				  const struct nfs_readargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_read3args(&xdr, args);
+	prepare_reply_buffer(req, args->pages, args->pgbase,
+					args->count, NFS3_readres_sz);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
+	return 0;
+}
+
+/*
  * Write arguments. Splice the buffer to be written into the iovec.
  */
 static int
@@ -420,6 +830,52 @@ nfs3_xdr_writeargs(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 }
 
 /*
+ * 3.3.7  WRITE3args
+ *
+ *	enum stable_how {
+ *		UNSTABLE  = 0,
+ *		DATA_SYNC = 1,
+ *		FILE_SYNC = 2
+ *	};
+ *
+ *	struct WRITE3args {
+ *		nfs_fh3		file;
+ *		offset3		offset;
+ *		count3		count;
+ *		stable_how	stable;
+ *		opaque		data<>;
+ *	};
+ */
+static void encode_write3args(struct xdr_stream *xdr,
+			      const struct nfs_writeargs *args)
+{
+	__be32 *p;
+
+	encode_nfs_fh3(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 8 + 4 + 4 + 4);
+	p = xdr_encode_hyper(p, args->offset);
+	*p++ = cpu_to_be32(args->count);
+
+	BUG_ON(args->stable > NFS_FILE_SYNC);
+	*p++ = cpu_to_be32(args->stable);
+
+	*p = cpu_to_be32(args->count);
+	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
+}
+
+static int nfs3_xdr_enc_write3args(struct rpc_rqst *req, __be32 *p,
+				   const struct nfs_writeargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_write3args(&xdr, args);
+	xdr.buf->flags |= XDRBUF_WRITE;
+	return 0;
+}
+
+/*
  * Encode CREATE arguments
  */
 static int
@@ -440,6 +896,56 @@ nfs3_xdr_createargs(struct rpc_rqst *req, __be32 *p, struct nfs3_createargs *arg
 }
 
 /*
+ * 3.3.8  CREATE3args
+ *
+ *	enum createmode3 {
+ *		UNCHECKED = 0,
+ *		GUARDED   = 1,
+ *		EXCLUSIVE = 2
+ *	};
+ *
+ *	union createhow3 switch (createmode3 mode) {
+ *	case UNCHECKED:
+ *	case GUARDED:
+ *		sattr3       obj_attributes;
+ *	case EXCLUSIVE:
+ *		createverf3  verf;
+ *	};
+ *
+ *	struct CREATE3args {
+ *		diropargs3	where;
+ *		createhow3	how;
+ *	};
+ */
+static void encode_createhow3(struct xdr_stream *xdr,
+			      const struct nfs3_createargs *args)
+{
+	encode_uint32(xdr, args->createmode);
+	switch (args->createmode) {
+	case NFS3_CREATE_UNCHECKED:
+	case NFS3_CREATE_GUARDED:
+		encode_sattr3(xdr, args->sattr);
+		break;
+	case NFS3_CREATE_EXCLUSIVE:
+		encode_createverf3(xdr, args->verifier);
+		break;
+	default:
+		BUG();
+	}
+}
+
+static int nfs3_xdr_enc_create3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs3_createargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs3(&xdr, args->fh, args->name, args->len);
+	encode_createhow3(&xdr, args);
+	return 0;
+}
+
+/*
  * Encode MKDIR arguments
  */
 static int
@@ -453,6 +959,25 @@ nfs3_xdr_mkdirargs(struct rpc_rqst *req, __be32 *p, struct nfs3_mkdirargs *args)
 }
 
 /*
+ * 3.3.9  MKDIR3args
+ *
+ *	struct MKDIR3args {
+ *		diropargs3	where;
+ *		sattr3		attributes;
+ *	};
+ */
+static int nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req, __be32 *p,
+				   const struct nfs3_mkdirargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs3(&xdr, args->fh, args->name, args->len);
+	encode_sattr3(&xdr, args->sattr);
+	return 0;
+}
+
+/*
  * Encode SYMLINK arguments
  */
 static int
@@ -470,6 +995,37 @@ nfs3_xdr_symlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs3_symlinkargs *a
 }
 
 /*
+ * 3.3.10  SYMLINK3args
+ *
+ *	struct symlinkdata3 {
+ *		sattr3		symlink_attributes;
+ *		nfspath3	symlink_data;
+ *	};
+ *
+ *	struct SYMLINK3args {
+ *		diropargs3	where;
+ *		symlinkdata3	symlink;
+ *	};
+ */
+static void encode_symlinkdata3(struct xdr_stream *xdr,
+				const struct nfs3_symlinkargs *args)
+{
+	encode_sattr3(xdr, args->sattr);
+	encode_nfspath3(xdr, args->pages, args->pathlen);
+}
+
+static int nfs3_xdr_enc_symlink3args(struct rpc_rqst *req, __be32 *p,
+				     const struct nfs3_symlinkargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs3(&xdr, args->fromfh, args->fromname, args->fromlen);
+	encode_symlinkdata3(&xdr, args);
+	return 0;
+}
+
+/*
  * Encode MKNOD arguments
  */
 static int
@@ -489,6 +1045,86 @@ nfs3_xdr_mknodargs(struct rpc_rqst *req, __be32 *p, struct nfs3_mknodargs *args)
 }
 
 /*
+ * 3.3.11  MKNOD3args
+ *
+ *	struct devicedata3 {
+ *		sattr3		dev_attributes;
+ *		specdata3	spec;
+ *	};
+ *
+ *	union mknoddata3 switch (ftype3 type) {
+ *	case NF3CHR:
+ *	case NF3BLK:
+ *		devicedata3	device;
+ *	case NF3SOCK:
+ *	case NF3FIFO:
+ *		sattr3		pipe_attributes;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	struct MKNOD3args {
+ *		diropargs3	where;
+ *		mknoddata3	what;
+ *	};
+ */
+static void encode_devicedata3(struct xdr_stream *xdr,
+			       const struct nfs3_mknodargs *args)
+{
+	encode_sattr3(xdr, args->sattr);
+	encode_specdata3(xdr, args->rdev);
+}
+
+static void encode_mknoddata3(struct xdr_stream *xdr,
+			      const struct nfs3_mknodargs *args)
+{
+	encode_ftype3(xdr, args->type);
+	switch (args->type) {
+	case NF3CHR:
+	case NF3BLK:
+		encode_devicedata3(xdr, args);
+		break;
+	case NF3SOCK:
+	case NF3FIFO:
+		encode_sattr3(xdr, args->sattr);
+		break;
+	case NF3REG:
+	case NF3DIR:
+		break;
+	default:
+		BUG();
+	}
+}
+
+static int nfs3_xdr_enc_mknod3args(struct rpc_rqst *req, __be32 *p,
+				   const struct nfs3_mknodargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs3(&xdr, args->fh, args->name, args->len);
+	encode_mknoddata3(&xdr, args);
+	return 0;
+}
+
+/*
+ * 3.3.12  REMOVE3args
+ *
+ *	struct REMOVE3args {
+ *		diropargs3  object;
+ *	};
+ */
+static int nfs3_xdr_enc_remove3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs_removeargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs3(&xdr, args->fh, args->name.name, args->name.len);
+	return 0;
+}
+
+/*
  * Encode RENAME arguments
  */
 static int
@@ -503,6 +1139,27 @@ nfs3_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args
 }
 
 /*
+ * 3.3.14  RENAME3args
+ *
+ *	struct RENAME3args {
+ *		diropargs3	from;
+ *		diropargs3	to;
+ *	};
+ */
+static int nfs3_xdr_enc_rename3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs_renameargs *args)
+{
+	const struct qstr *old = args->old_name;
+	const struct qstr *new = args->new_name;
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs3(&xdr, args->old_dir, old->name, old->len);
+	encode_diropargs3(&xdr, args->new_dir, new->name, new->len);
+	return 0;
+}
+
+/*
  * Encode LINK arguments
  */
 static int
@@ -516,6 +1173,25 @@ nfs3_xdr_linkargs(struct rpc_rqst *req, __be32 *p, struct nfs3_linkargs *args)
 }
 
 /*
+ * 3.3.15  LINK3args
+ *
+ *	struct LINK3args {
+ *		nfs_fh3		file;
+ *		diropargs3	link;
+ *	};
+ */
+static int nfs3_xdr_enc_link3args(struct rpc_rqst *req, __be32 *p,
+				  const struct nfs3_linkargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_nfs_fh3(&xdr, args->fromfh);
+	encode_diropargs3(&xdr, args->tofh, args->toname, args->tolen);
+	return 0;
+}
+
+/*
  * Encode arguments to readdir call
  */
 static int
@@ -544,6 +1220,84 @@ nfs3_xdr_readdirargs(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirargs *a
 }
 
 /*
+ * 3.3.16  READDIR3args
+ *
+ *	struct READDIR3args {
+ *		nfs_fh3		dir;
+ *		cookie3		cookie;
+ *		cookieverf3	cookieverf;
+ *		count3		count;
+ *	};
+ */
+static void encode_readdir3args(struct xdr_stream *xdr,
+				const struct nfs3_readdirargs *args)
+{
+	__be32 *p;
+
+	encode_nfs_fh3(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 8 + NFS3_COOKIEVERFSIZE + 4);
+	p = xdr_encode_cookie3(p, args->cookie);
+	p = xdr_encode_cookieverf3(p, args->verf);
+	*p = cpu_to_be32(args->count);
+}
+
+static int nfs3_xdr_enc_readdir3args(struct rpc_rqst *req, __be32 *p,
+				     const struct nfs3_readdirargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_readdir3args(&xdr, args);
+	prepare_reply_buffer(req, args->pages, 0,
+				args->count, NFS3_readdirres_sz);
+	return 0;
+}
+
+/*
+ * 3.3.17  READDIRPLUS3args
+ *
+ *	struct READDIRPLUS3args {
+ *		nfs_fh3		dir;
+ *		cookie3		cookie;
+ *		cookieverf3	cookieverf;
+ *		count3		dircount;
+ *		count3		maxcount;
+ *	};
+ */
+static void encode_readdirplus3args(struct xdr_stream *xdr,
+				    const struct nfs3_readdirargs *args)
+{
+	__be32 *p;
+
+	encode_nfs_fh3(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 8 + NFS3_COOKIEVERFSIZE + 4 + 4);
+	p = xdr_encode_cookie3(p, args->cookie);
+	p = xdr_encode_cookieverf3(p, args->verf);
+
+	/*
+	 * readdirplus: need dircount + buffer size.
+	 * We just make sure we make dircount big enough
+	 */
+	*p++ = cpu_to_be32(args->count >> 3);
+
+	*p = cpu_to_be32(args->count);
+}
+
+static int nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req, __be32 *p,
+					 const struct nfs3_readdirargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_readdirplus3args(&xdr, args);
+	prepare_reply_buffer(req, args->pages, 0,
+				args->count, NFS3_readdirres_sz);
+	return 0;
+}
+
+/*
  * Decode the result of a readdir call.
  * We just check for syntactical correctness.
  */
@@ -672,6 +1426,37 @@ nfs3_xdr_commitargs(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 	return 0;
 }
 
+/*
+ * 3.3.21  COMMIT3args
+ *
+ *	struct COMMIT3args {
+ *		nfs_fh3		file;
+ *		offset3		offset;
+ *		count3		count;
+ *	};
+ */
+static void encode_commit3args(struct xdr_stream *xdr,
+			       const struct nfs_writeargs *args)
+{
+	__be32 *p;
+
+	encode_nfs_fh3(xdr, args->fh);
+
+	p = xdr_reserve_space(xdr, 8 + 4);
+	p = xdr_encode_hyper(p, args->offset);
+	*p = cpu_to_be32(args->count);
+}
+
+static int nfs3_xdr_enc_commit3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs_writeargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_commit3args(&xdr, args);
+	return 0;
+}
+
 #ifdef CONFIG_NFS_V3_ACL
 /*
  * Encode GETACL arguments
@@ -697,6 +1482,21 @@ nfs3_xdr_getaclargs(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int nfs3_xdr_enc_getacl3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs3_getaclargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_nfs_fh3(&xdr, args->fh);
+	encode_uint32(&xdr, args->mask);
+	if (args->mask & (NFS_ACL | NFS_DFACL))
+		prepare_reply_buffer(req, args->pages, 0,
+					NFSACL_MAXPAGES << PAGE_SHIFT,
+					ACL3_getaclres_sz);
+	return 0;
+}
+
 /*
  * Encode SETACL arguments
  */
@@ -729,6 +1529,33 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
 				    NFS_ACL_DEFAULT);
 	return (err > 0) ? 0 : err;
 }
+
+static int nfs3_xdr_enc_setacl3args(struct rpc_rqst *req, __be32 *p,
+				    const struct nfs3_setaclargs *args)
+{
+	struct xdr_stream xdr;
+	unsigned int base;
+	int error;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_nfs_fh3(&xdr, NFS_FH(args->inode));
+	encode_uint32(&xdr, args->mask);
+	if (args->npages != 0)
+		xdr_write_pages(&xdr, args->pages, 0, args->len);
+
+	base = req->rq_slen;
+	error = nfsacl_encode(xdr.buf, base, args->inode,
+			    (args->mask & NFS_ACL) ?
+			    args->acl_access : NULL, 1, 0);
+	BUG_ON(error < 0);
+	error = nfsacl_encode(xdr.buf, base + error, args->inode,
+			    (args->mask & NFS_DFACL) ?
+			    args->acl_default : NULL, 1,
+			    NFS_ACL_DEFAULT);
+	BUG_ON(error < 0);
+	return 0;
+}
+
 #endif  /* CONFIG_NFS_V3_ACL */
 
 /*
diff --git a/include/linux/nfs3.h b/include/linux/nfs3.h
index ac33806..e2ee14f 100644
--- a/include/linux/nfs3.h
+++ b/include/linux/nfs3.h
@@ -11,6 +11,8 @@
 #define NFS3_MAXGROUPS		16
 #define NFS3_FHSIZE		64
 #define NFS3_COOKIESIZE		4
+#define NFS3_CREATEVERFSIZE	8
+#define NFS3_COOKIEVERFSIZE	8
 #define NFS3_FIFO_DEV		(-1)
 #define NFS3MODE_FMT		0170000
 #define NFS3MODE_DIR		0040000

