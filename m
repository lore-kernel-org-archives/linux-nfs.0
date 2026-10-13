Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4BF14FD280
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895779; cv=none; b=R5LNBIbE1PeobFeJ0oVDbqV5HyNUyiNhkvqIUV1YjCtJGNnKHsn/qrD1X3BZ4tjD00jPKJiJkgdoTav5Uayc662ZPKXEknP78DjjTTqkOQNRionM501yhL4SfvrIK+Tsf+/izgmKi1fxQFtIncnxzZTQs1diK8Q2KxM80G9a9Bo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895779; c=relaxed/simple;
	bh=Sq9j9VZuR0si45j38UCUHi7YMSOHTiB2xeIBrmIT/ck=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=o4HILSaVKSBPtZR1y+Ve88/L8+9EIBT6iZdoiZTzVnS8H3ExdBQvoQS5Vizlr8jBLpU88/H2g4ZFZCvkZt5gLiH+t0+oykOdo58Eo1dOq48Sg1p3OGgi/n1LIe+HKms4JbpEvHWn5TbEITtlk+US7RA8tYzDM0jVhj6YhBzXYao=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZdxZJKJE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZdxZJKJE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0CBD61F00899;
	Tue, 13 Oct 2026 12:49:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895777;
	bh=qPyKBdTp6RiVXUJEuT7YrgjNwiLmiyF7XDmRJb8WHNM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZdxZJKJE5XRpCHxj3d8ohrjuizxy4TGFeBuruozDr9T1kd4TG8QGtmHf9y/wv5RbU
	 RMVtuejyB8+Mm+vDBItT5Kl+3E0LuUIr5ggxaD1yk1s3MGbmk+mcmoXp6x9ffL1il+
	 n4WUhYICNZU0wxnlnMeYhQ6j8rolkFNU9kAGX2qGg+cTVYzddcjNUsJ/peZdkSNyqI
	 GIoRH3IPuJlOc9CLjPdkPxQMBpusfe3Ee4on783jyGgAPgva8O2EFnlt6qjJZhBuE/
	 +9I9HmWt3lkZRRT0oCM+6FCGj6nBR9vplcJzlu94GH/lD+uYpDq8QR3uoU7sVpCo08
	 wTm9AKyLMPZYQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 14/34] NFSD: Use xdrgen XDR functions for NFSv3 WRITE procedure
Date: Tue, 13 Oct 2026 08:49:28 -0400
Message-ID: <20261013124933.316765-5-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124933.316765-1-cel@kernel.org>
References: <20261013124933.316765-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_WRITE entry in the nfsd_procedures3 array with
an entry that dispatches the xdrgen-generated nfs_svc_decode_WRITE3args
and nfs_svc_encode_WRITE3res. Wrapper structures bridge the generated
xdrgen types and the legacy svc_fh representation the NFSD VFS layer
still uses.

The NFSv3 WRITE argument decoder could not be generated before because
the write payload must be directed into the server's page cache and
decoded in place; a materializing decoder would copy every write. The
"pages" directive now expresses this: it represents the payload as a
struct xdr_buf and decodes it with svcxdr_decode_opaque_payload(), which
subsegments the source stream in place rather than copying it. Annotate
the data member of WRITE3args with "pragma pages".

Clamping the payload size when decoding serves no functional purpose and
is removed entirely. The transport layer has already guaranteed that the
incoming message, including the WRITE payload, does not exceed
svc_max_payload.

The WRITE count versus data length sanity check moves to the
proc function: if those values are ever not equal, that does not
count as GARBAGE_ARGS, since the server is able to decode these
arguments. Rather, the arguments are invalid.

The pc_argzero field is now set to zero for the NFSv3 WRITE
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive memset
unnecessary.

Because nfsd3_proc_write() now fills in the WCC data, including
both the pre-op and post-op attributes, the fh_getattr() calls are
made in the proc function rather than in the XDR result encoder,
and the reference to the file handle can be released directly by
nfsd3_proc_write(). A separate ->pc_release callback is thus no longer
needed. This makes it straightforward to confirm that the file handle
is properly released during every error flow.

nfs3svc_decode_writeargs() and nfs3svc_encode_writeres() no longer have
any callers, so they are removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |  1 +
 fs/nfsd/nfs3proc.c                 | 94 +++++++++++++++++++-----------
 fs/nfsd/nfs3xdr.c                  | 59 -------------------
 fs/nfsd/nfs3xdr_gen.c              |  8 +--
 fs/nfsd/nfs3xdr_gen.h              |  4 +-
 fs/nfsd/xdr3.h                     | 19 +-----
 include/linux/sunrpc/xdrgen/nfs3.h |  6 +-
 7 files changed, 73 insertions(+), 118 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index b7571bc47f47..61b87245be1e 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -382,6 +382,7 @@ struct WRITE3args {
 	stable_how	stable;
 	opaque		data<>;
 };
+pragma pages WRITE3args data;
 
 struct WRITE3resok {
 	wcc_data	file_wcc;
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 3d5d9bedc89c..73f58914c3d2 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -92,6 +92,13 @@ struct READ3args_wrapper {
 
 static_assert(offsetof(struct READ3args_wrapper, xdrgen) == 0);
 
+struct WRITE3args_wrapper {
+	struct WRITE3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct WRITE3args_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -696,35 +703,55 @@ static __be32 nfsd3_proc_read(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Write data to a file
+/**
+ * nfsd3_proc_write - WRITE: Write to file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   WRITE3res NFSPROC3_WRITE(WRITE3args) = 7;
  */
-static __be32
-nfsd3_proc_write(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_write(struct svc_rqst *rqstp)
 {
-	struct nfsd3_writeargs *argp = rqstp->rq_argp;
+	struct WRITE3args_wrapper *argp = rqstp->rq_argp;
 	struct nfsd3_writeres *resp = rqstp->rq_resp;
-	unsigned long cnt = argp->len;
+	struct svc_fh *fhp = &argp->fh;
+	unsigned long count;
 
-	dprintk("nfsd: WRITE(3)    %s %d bytes at %Lu%s\n",
-				SVCFH_fmt(&argp->fh),
-				argp->len,
-				(unsigned long long) argp->offset,
-				argp->stable ? " stable" : "");
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.file);
+	if (argp->xdrgen.count != argp->xdrgen.data.len) {
+		resp->xdrgen.status = nfserr_inval;
+		goto out;
+	}
+	count = min_t(u32, argp->xdrgen.count, svc_max_payload(rqstp));
+	if (argp->xdrgen.offset > (u64)OFFSET_MAX ||
+	    argp->xdrgen.offset + count > (u64)OFFSET_MAX) {
+		resp->xdrgen.status = nfserr_fbig;
+		goto out;
+	}
 
-	resp->status = nfserr_fbig;
-	if (argp->offset > (u64)OFFSET_MAX ||
-	    argp->offset + argp->len > (u64)OFFSET_MAX)
-		return rpc_success;
+	resp->xdrgen.status = nfsd_write(rqstp, fhp, argp->xdrgen.offset,
+					 &argp->xdrgen.data, &count,
+					 nfsd3_iocb_flags(argp->xdrgen.stable),
+					 (__be32 *)resp->xdrgen.u.resok.verf);
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->committed = argp->stable;
-	resp->status = nfsd_write(rqstp, &resp->fh, argp->offset,
-				  &argp->payload, &cnt,
-				  nfsd3_iocb_flags(resp->committed),
-				  resp->verf);
-	resp->count = cnt;
-	resp->status = nfsd3_map_status(resp->status);
+out:
+	if (resp->xdrgen.status == nfs_ok) {
+		struct WRITE3resok *resok = &resp->xdrgen.u.resok;
+
+		resok->count = count;
+		resok->committed = argp->xdrgen.stable;
+		nfsd3_fill_wcc_data(rqstp, &resok->file_wcc, fhp);
+	} else {
+		struct WRITE3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		nfsd3_fill_wcc_data(rqstp, &resfail->file_wcc, fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1405,16 +1432,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "READ",
 	},
 	[NFSPROC3_WRITE] = {
-		.pc_func = nfsd3_proc_write,
-		.pc_decode = nfs3svc_decode_writeargs,
-		.pc_encode = nfs3svc_encode_writeres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_writeargs),
-		.pc_argzero = sizeof(struct nfsd3_writeargs),
-		.pc_ressize = sizeof(struct nfsd3_writeres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+WC+4,
-		.pc_name = "WRITE",
+		.pc_func	= nfsd3_proc_write,
+		.pc_decode	= nfs_svc_decode_WRITE3args,
+		.pc_encode	= nfs_svc_encode_WRITE3res,
+		.pc_argsize	= sizeof(struct WRITE3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd3_writeres),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_WRITE3res_sz,
+		.pc_name	= "WRITE",
 	},
 	[NFSPROC3_CREATE] = {
 		.pc_func = nfsd3_proc_create,
@@ -1596,7 +1622,7 @@ union nfsd3_xdrstore {
 	struct READLINK3args_wrapper	readlinkargs;
 	struct READ3args_wrapper	readargs;
 	struct nfsd3_diropargs		diropargs;
-	struct nfsd3_writeargs		writeargs;
+	struct WRITE3args_wrapper	writeargs;
 	struct nfsd3_createargs		createargs;
 	struct nfsd3_renameargs		renameargs;
 	struct nfsd3_linkargs		linkargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 9cee503407f7..cc3aebd97959 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -490,38 +490,6 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_writeargs *args = rqstp->rq_argp;
-	u32 max_blocksize = svc_max_payload(rqstp);
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u64(xdr, &args->offset) < 0)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->count) < 0)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->stable) < 0)
-		return false;
-	if (args->stable > FILE_SYNC)
-		return false;
-
-	/* opaque data */
-	if (xdr_stream_decode_u32(xdr, &args->len) < 0)
-		return false;
-
-	/* request sanity */
-	if (args->count != args->len)
-		return false;
-	if (args->count > max_blocksize) {
-		args->count = max_blocksize;
-		args->len = max_blocksize;
-	}
-
-	return xdr_stream_subsegment(xdr, &args->payload, args->count);
-}
-
 bool
 nfs3svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -693,33 +661,6 @@ nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh);
 }
 
-/* WRITE */
-bool
-nfs3svc_encode_writeres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_writeres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->count) < 0)
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->committed) < 0)
-			return false;
-		if (!svcxdr_encode_writeverf3(xdr, resp->verf))
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh))
-			return false;
-	}
-
-	return true;
-}
-
 /* CREATE, MKDIR, SYMLINK, MKNOD */
 bool
 nfs3svc_encode_createres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
index 0961f6c92ee6..159aff1a8567 100644
--- a/fs/nfsd/nfs3xdr_gen.c
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
-// XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x
-// XDR specification modification time: Tue Jul 14 11:24:16 2026
+// XDR specification file: Documentation/sunrpc/xdr/nfs3.x
+// XDR specification modification time: Tue Jul 14 11:43:26 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -731,7 +731,7 @@ xdrgen_decode_WRITE3args(struct xdr_stream *xdr, struct WRITE3args *ptr)
 		return false;
 	if (!xdrgen_decode_stable_how(xdr, &ptr->stable))
 		return false;
-	if (!xdrgen_decode_opaque(xdr, &ptr->data, 0))
+	if (!svcxdr_decode_opaque_payload(xdr, &ptr->data, 0))
 		return false;
 	return true;
 }
@@ -2578,7 +2578,7 @@ xdrgen_encode_WRITE3args(struct xdr_stream *xdr, const struct WRITE3args *value)
 		return false;
 	if (!xdrgen_encode_stable_how(xdr, value->stable))
 		return false;
-	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+	if (!svcxdr_encode_opaque_payload(xdr, value->data.len))
 		return false;
 	return true;
 }
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
index d54b087b7748..98e29c8efc5e 100644
--- a/fs/nfsd/nfs3xdr_gen.h
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
-/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 11:24:16 2026 */
+/* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
+/* XDR specification modification time: Tue Jul 14 11:43:26 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DECL_H
 #define _LINUX_XDRGEN_NFS3_DECL_H
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 6ca1a2c84b42..9c41244d27bb 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -30,15 +30,6 @@ struct nfsd3_accessargs {
 	__u32			access;
 };
 
-struct nfsd3_writeargs {
-	svc_fh			fh;
-	__u64			offset;
-	__u32			count;
-	__u32			stable;
-	__u32			len;
-	struct xdr_buf		payload;
-};
-
 struct nfsd3_createargs {
 	struct svc_fh		fh;
 	char *			name;
@@ -130,13 +121,11 @@ struct nfsd3_accessres {
 };
 
 struct nfsd3_writeres {
-	__be32			status;
-	struct svc_fh		fh;
-	unsigned long		count;
-	int			committed;
-	__be32			verf[2];
+	struct WRITE3res	xdrgen;
 };
 
+static_assert(offsetof(struct nfsd3_writeres, xdrgen) == 0);
+
 struct nfsd3_renameres {
 	__be32			status;
 	struct svc_fh		ffh;
@@ -218,7 +207,6 @@ struct nfsd3_fhandle_pair {
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
@@ -231,7 +219,6 @@ bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_writeres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_createres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_linkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 75ff4a924cf4..3b6738c0074b 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
-/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 11:24:16 2026 */
+/* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
+/* XDR specification modification time: Tue Jul 14 11:43:26 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DEF_H
 #define _LINUX_XDRGEN_NFS3_DEF_H
@@ -382,7 +382,7 @@ struct WRITE3args {
 	offset3 offset;
 	count3 count;
 	stable_how stable;
-	opaque data;
+	struct xdr_buf data;
 };
 
 struct WRITE3resok {
-- 
2.55.0

