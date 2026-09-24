Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EAD04A8FC0
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269828; cv=none; b=fPNyC2J8LItstlMU331UvnRiSjiJ7VznYgG2S2djCKuKXFHPxYGln9cgXxsaEqsCzj6kW0pbCDU+9X3D0wPwltrJMm5yqh6wCo+PkYfqIWnuCLul7NpZ+fBLbl+IviYElx4xqS63NKKPuCsQR18OfztbqwQ/PnGvyE9s5M/rDF4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269828; c=relaxed/simple;
	bh=1q4lHn2pq4kOBbgoc4b6xeC9hfSjPqLX17Kj5Q1h9hE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HswVDziHMCqWZfTnqH3OEFcv6WcsK66INFDcMUptcGs1YU+/HHPV+sR7+vmxj0buJzzNr3HBDli0wTmSI2d6nQoEqDVa97gz+AAL/QosXLwusRwZkszfMK3omApnYxlYMDJuOe8i2AbZ60AYHlCWeWF5bc0P+DKn7F2YtzlLnug=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MROXPOlB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MROXPOlB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 073711F00893;
	Thu, 24 Sep 2026 17:10:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269825;
	bh=+4fT70/Hbo6rVO19MptOoWnUxDwVMhax0HnVVsm7D2Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MROXPOlBQ4qQ4wHh1N3mWaNlq+d3h9wJaAcRQ3SC2cNcawW96bRtTLzkT8mhdANU3
	 YKeXVhx9rXHkq1InZeoeSFLNdtrZFT1oqXYV51BCIbTXY0UY/PO8QAHymex5HvriHn
	 9ayyafEqXs6dJHznuD8p84UbkRwGz6j+aL4+VvU6RNVXNk+wlSUcCkFC+0pvKImlCk
	 ERayAqt4Nugb85KGwG6wQLP2T7bqxPblROgIYxQka6PsEODVyLbAZdhRYi6inB/gn6
	 fR4AumyyQdxbEYxvhUSyUiXO8LTV9FBzK7SQ02e/iuQuNo9569hLoWQy5LP+IozZbG
	 QGvQXjPprmtIg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 13/33] NFSD: Use xdrgen XDR functions for NFSv3 READ procedure
Date: Thu, 24 Sep 2026 13:09:52 -0400
Message-ID: <20260924171012.3978-14-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260924171012.3978-1-cel@kernel.org>
References: <20260924171012.3978-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_READ entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_READ3args and nfs_svc_encode_READ3res. A wrapper
structure bridges the generated xdrgen READ3args type and the
legacy svc_fh representation the NFSD VFS layer still uses.

The file's data does not reside at the data pointer of the
READ3resok data member: nfsd_read() deposits it directly in the
pages of the Reply buffer, so the generic encoder that copies an
opaque from the member's data pointer cannot encode it. Mark the
member with the "pragma pages" directive so the generated encoder
calls svcxdr_encode_opaque_payload(), which encodes the length
prefix and inserts the payload pages into the stream by reference.
The page anchor that the result structure carried duplicated
rq_res.pages -- svc_process() points rq_res.pages at the first
Reply page before dispatch, and the READ3args decoder consumes no
pages -- so the helper locates the payload through the Reply
buffer itself, and the wrapper collapses to the generated READ3res
type.

The pc_argzero field is now set to zero for the NFSv3 READ
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_read() now fills in the post-op attributes,
the fh_getattr() calls are made in the proc function rather than
in the XDR result encoder, and the reference to the file handle
can be released directly by nfsd3_proc_read(). A separate
->pc_release callback is thus no longer needed. This makes it
straightforward to confirm that the file handle is properly
released during every error flow.

nfs3svc_decode_readargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |  1 +
 fs/nfsd/nfs3proc.c                 | 99 ++++++++++++++++++------------
 fs/nfsd/nfs3xdr.c                  | 48 ---------------
 fs/nfsd/nfs3xdr_gen.c              |  4 +-
 fs/nfsd/nfs3xdr_gen.h              |  2 +-
 fs/nfsd/xdr3.h                     | 16 -----
 include/linux/sunrpc/xdrgen/nfs3.h |  2 +-
 7 files changed, 66 insertions(+), 106 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index b50ffb77af54..b7571bc47f47 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -356,6 +356,7 @@ struct READ3resok {
 	bool		eof;
 	opaque		data<>;
 };
+pragma pages READ3resok data;
 
 struct READ3resfail {
 	post_op_attr	file_attributes;
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 0a465c68234e..ba140c2008f2 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -85,6 +85,13 @@ struct READLINK3args_wrapper {
 
 static_assert(offsetof(struct READLINK3args_wrapper, xdrgen) == 0);
 
+struct READ3args_wrapper {
+	struct READ3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct READ3args_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -637,41 +644,57 @@ static __be32 nfsd3_proc_readlink(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Read a portion of a file.
+/**
+ * nfsd3_proc_read - READ: Read from file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   READ3res NFSPROC3_READ(READ3args) = 6;
  */
-static __be32
-nfsd3_proc_read(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_read(struct svc_rqst *rqstp)
 {
-	struct nfsd3_readargs *argp = rqstp->rq_argp;
-	struct nfsd3_readres *resp = rqstp->rq_resp;
+	struct READ3args_wrapper *argp = rqstp->rq_argp;
+	struct READ3res *resp = rqstp->rq_resp;
+	unsigned long count = argp->xdrgen.count;
+	u64 offset = argp->xdrgen.offset;
+	struct svc_fh *fhp = &argp->fh;
+	u32 eof;
 
-	dprintk("nfsd: READ(3) %s %lu bytes at %Lu\n",
-				SVCFH_fmt(&argp->fh),
-				(unsigned long) argp->count,
-				(unsigned long long) argp->offset);
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.file);
+	count = min_t(u32, count, svc_max_payload(rqstp));
+	count = min_t(u32, count, rqstp->rq_res.buflen);
+	if (offset > (u64)OFFSET_MAX)
+		offset = (u64)OFFSET_MAX;
+	if (offset + count > (u64)OFFSET_MAX)
+		count = (u64)OFFSET_MAX - offset;
 
-	argp->count = min_t(u32, argp->count, svc_max_payload(rqstp));
-	argp->count = min_t(u32, argp->count, rqstp->rq_res.buflen);
-	if (argp->offset > (u64)OFFSET_MAX)
-		argp->offset = (u64)OFFSET_MAX;
-	if (argp->offset + argp->count > (u64)OFFSET_MAX)
-		argp->count = (u64)OFFSET_MAX - argp->offset;
-
-	resp->pages = rqstp->rq_next_page;
-
-	/* Obtain buffer pointer for payload.
+	/*
+	 * Obtain buffer pointer for payload.
 	 * 1 (status) + 22 (post_op_attr) + 1 (count) + 1 (eof)
 	 * + 1 (xdr opaque byte count) = 26
 	 */
-	resp->count = argp->count;
 	svc_reserve_auth(rqstp, ((1 + NFS3_post_op_attr_sz + 3) << 2) +
-			 resp->count + 4);
+			 count + 4);
+	resp->status = nfsd_read(rqstp, fhp, offset, &count, &eof);
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = nfsd_read(rqstp, &resp->fh, argp->offset,
-				 &resp->count, &resp->eof);
-	resp->status = nfsd3_map_status(resp->status);
+	if (resp->status == nfs_ok) {
+		struct READ3resok *resok = &resp->u.resok;
+
+		resok->count = count;
+		resok->eof = !!eof;
+		resok->data.len = count;
+		nfsd3_fill_post_op_attr(rqstp, &resok->file_attributes, fhp);
+	} else {
+		struct READ3resfail *resfail = &resp->u.resfail;
+
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_post_op_attr(rqstp, &resfail->file_attributes, fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1372,16 +1395,16 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "READLINK",
 	},
 	[NFSPROC3_READ] = {
-		.pc_func = nfsd3_proc_read,
-		.pc_decode = nfs3svc_decode_readargs,
-		.pc_encode = nfs3svc_encode_readres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_readargs),
-		.pc_argzero = sizeof(struct nfsd3_readargs),
-		.pc_ressize = sizeof(struct nfsd3_readres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+pAT+4+NFSSVC_MAXBLKSIZE/4,
-		.pc_name = "READ",
+		.pc_func	= nfsd3_proc_read,
+		.pc_decode	= nfs_svc_decode_READ3args,
+		.pc_encode	= nfs_svc_encode_READ3res,
+		.pc_argsize	= sizeof(struct READ3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct READ3res),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_READ3res_sz +
+				  XDR_QUADLEN(NFSSVC_MAXBLKSIZE),
+		.pc_name	= "READ",
 	},
 	[NFSPROC3_WRITE] = {
 		.pc_func = nfsd3_proc_write,
@@ -1573,8 +1596,8 @@ union nfsd3_xdrstore {
 	struct ACCESS3args_wrapper	accessargs;
 	struct ACCESS3res		accessres;
 	struct READLINK3args_wrapper	readlinkargs;
+	struct READ3args_wrapper	readargs;
 	struct nfsd3_diropargs		diropargs;
-	struct nfsd3_readargs		readargs;
 	struct nfsd3_writeargs		writeargs;
 	struct nfsd3_createargs		createargs;
 	struct nfsd3_renameargs		renameargs;
@@ -1583,7 +1606,7 @@ union nfsd3_xdrstore {
 	struct nfsd3_readdirargs	readdirargs;
 	struct nfsd3_diropres 		diropres;
 	struct READLINK3res		readlinkres;
-	struct nfsd3_readres		readres;
+	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
 	struct nfsd3_renameres		renameres;
 	struct nfsd3_linkres		linkres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index a77b5f7a7e27..9cee503407f7 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -490,21 +490,6 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfs3svc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_readargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u64(xdr, &args->offset) < 0)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->count) < 0)
-		return false;
-
-	return true;
-}
-
 bool
 nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -708,39 +693,6 @@ nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh);
 }
 
-/* READ */
-bool
-nfs3svc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_readres *resp = rqstp->rq_resp;
-	struct kvec *head = rqstp->rq_res.head;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->count) < 0)
-			return false;
-		if (xdr_stream_encode_bool(xdr, resp->eof) < 0)
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->count) < 0)
-			return false;
-		svcxdr_encode_opaque_pages(rqstp, xdr, resp->pages,
-					   rqstp->rq_res.page_base,
-					   resp->count);
-		if (svc_encode_result_payload(rqstp, head->iov_len, resp->count) < 0)
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-	}
-
-	return true;
-}
-
 /* WRITE */
 bool
 nfs3svc_encode_writeres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
index bc6fb9829397..0961f6c92ee6 100644
--- a/fs/nfsd/nfs3xdr_gen.c
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x
-// XDR specification modification time: Tue Jul 14 09:53:56 2026
+// XDR specification modification time: Tue Jul 14 11:24:16 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -2531,7 +2531,7 @@ xdrgen_encode_READ3resok(struct xdr_stream *xdr, const struct READ3resok *value)
 		return false;
 	if (!xdrgen_encode_bool(xdr, value->eof))
 		return false;
-	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+	if (!svcxdr_encode_opaque_payload(xdr, value->data.len))
 		return false;
 	return true;
 }
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
index 3fefbb797b69..d54b087b7748 100644
--- a/fs/nfsd/nfs3xdr_gen.h
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 09:53:56 2026 */
+/* XDR specification modification time: Tue Jul 14 11:24:16 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DECL_H
 #define _LINUX_XDRGEN_NFS3_DECL_H
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 39a2109a2c66..6ca1a2c84b42 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -30,12 +30,6 @@ struct nfsd3_accessargs {
 	__u32			access;
 };
 
-struct nfsd3_readargs {
-	struct svc_fh		fh;
-	__u64			offset;
-	__u32			count;
-};
-
 struct nfsd3_writeargs {
 	svc_fh			fh;
 	__u64			offset;
@@ -135,14 +129,6 @@ struct nfsd3_accessres {
 	struct kstat		stat;
 };
 
-struct nfsd3_readres {
-	__be32			status;
-	struct svc_fh		fh;
-	unsigned long		count;
-	__u32			eof;
-	struct page		**pages;
-};
-
 struct nfsd3_writeres {
 	__be32			status;
 	struct svc_fh		fh;
@@ -232,7 +218,6 @@ struct nfsd3_fhandle_pair {
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
@@ -246,7 +231,6 @@ bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_writeres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_createres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 3f8d1ecda7f2..75ff4a924cf4 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 09:53:56 2026 */
+/* XDR specification modification time: Tue Jul 14 11:24:16 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DEF_H
 #define _LINUX_XDRGEN_NFS3_DEF_H
-- 
2.55.0

