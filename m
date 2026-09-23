Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D46B5304A1
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170111; cv=none; b=HTnA8hyDiRDBqVoA4H5WWfwvGrjAH2qdiE7rSvXGg2qiVwVlAxDp+XZvzV29KMeqG01PHLAdhq3E8n0JSSYkatCuF12DA2LIJ4fZNTrxw+BhVwntqsfsG/3FuLMbKXuXT5UFRWdXjaQ8ecqwt3X3/SsLlYLCU95cdvcx5oVEByw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170111; c=relaxed/simple;
	bh=JaVbA1AY5c05i/6fSAdnCiiPuu0ESsv6f+AMEi6vYHA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hj07P9hbfE0FSCMtN3cK+QuGrMC2hvOLiIIlm1evVGCqaliGzxaU6I+9cKnLqyC/+BGdsb6VNY0GzSvvYu3ncskeSfXJ5ip4q74KGUEHV8hdHbSyyzZ7q/Wq/wmfNzR00pjaNT6U90/EnKXh5dQVXb5CO3h0ygUDf7ir7Hd9Q/U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LFkYY9X2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LFkYY9X2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BB9751F008A0;
	Wed, 23 Sep 2026 13:28:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170109;
	bh=9wZjycmpttwQT8gVlgTfYN6Sbj6QDEXuUA6WaqrlKpQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LFkYY9X2rWP4ZPISW46R1ZRTYk2M6wZL1m5+szGrYHv3zd2IzztpGpd6QE5oZkpUK
	 l8LrDXgAI80XnD80jTKNleRgeOP/VzDMU77+07LGv9HaPtZe7d854BSpJ7CjSs/S+D
	 ewJWg3jcus62rSFUsA2e8bQhJllXjrQR/WN48GTmR0f5gHRO0T1MZterdlf9MfdYcP
	 NkID/d5h894uP0M3AzXrDFPnyT5EiMgaOwPHAvDo+uFOntIAkFc7NWTr7x6zpfTffq
	 eMfyQKbR1WPaUaorDVakNDyUS5uYnKpG19X3TfMyuFHKoC7iYitAnaVrKxDHC+vfS1
	 njXcoZMyU86lw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 17/33] NFSD: Use xdrgen XDR functions for NFSv3 SYMLINK procedure
Date: Wed, 23 Sep 2026 09:27:55 -0400
Message-ID: <20260923132811.244160-18-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260923132811.244160-1-cel@kernel.org>
References: <20260923132811.244160-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_SYMLINK entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_SYMLINK3args and nfs_svc_encode_SYMLINK3res. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh and iattr representations the NFSD VFS layer still uses.

A SYMLINK request's target pathname can extend from the head of
the receive buffer into its page data; nfsd3_proc_symlink()
reassembles it from a head segment and a page via
svc_fill_symlink_pathname(). Annotate the symlink_data member of
symlinkdata3 with "pragma pages" so the generated decoder
represents the pathname as a struct xdr_buf and decodes it with
svcxdr_decode_opaque_payload(), which subsegments the receive
stream instead of pulling the string inline through the bounded
xdr scratch buffer.

Filename validity is now checked by nfsd3_proc_symlink() so that a
proper NFS3ERR status code can be returned to the client rather
than GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 SYMLINK
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_symlink() now fills in the post-op file handle,
the post-op attributes, and the WCC data, the fh_getattr() calls
are made in the proc function rather than in the XDR result
encoder, and the references to the file handles can be released
directly by nfsd3_proc_symlink(). A separate ->pc_release callback
is thus no longer needed. This makes it straightforward to
confirm that the file handles are properly released during every
error flow.

nfs3svc_decode_symlinkargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |   1 +
 fs/nfsd/nfs3proc.c                 | 122 +++++++++++++++++++++--------
 fs/nfsd/nfs3xdr.c                  |  19 -----
 fs/nfsd/nfs3xdr_gen.c              |   6 +-
 fs/nfsd/nfs3xdr_gen.h              |   2 +-
 fs/nfsd/xdr3.h                     |  11 ---
 include/linux/sunrpc/xdrgen/nfs3.h |   4 +-
 7 files changed, 95 insertions(+), 70 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index 61b87245be1e..c987788bf34c 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -464,6 +464,7 @@ struct symlinkdata3 {
 	sattr3		symlink_attributes;
 	nfspath3	symlink_data;
 };
+pragma pages symlinkdata3 symlink_data;
 
 struct SYMLINK3args {
 	diropargs3	where;
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 64e5be5fecee..97c68c51f9a5 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -131,6 +131,22 @@ struct MKDIR3res_wrapper {
 
 static_assert(offsetof(struct MKDIR3res_wrapper, xdrgen) == 0);
 
+struct SYMLINK3args_wrapper {
+	struct SYMLINK3args	xdrgen;
+	struct svc_fh		fh;
+	struct iattr		iattrs;
+};
+
+static_assert(offsetof(struct SYMLINK3args_wrapper, xdrgen) == 0);
+
+struct SYMLINK3res_wrapper {
+	struct SYMLINK3res	xdrgen;
+	struct svc_fh		fh;
+	u8			fh_data[NFS3_FHSIZE];
+};
+
+static_assert(offsetof(struct SYMLINK3res_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -1059,43 +1075,81 @@ static __be32 nfsd3_proc_mkdir(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static __be32
-nfsd3_proc_symlink(struct svc_rqst *rqstp)
+/**
+ * nfsd3_proc_symlink - SYMLINK: Create a symbolic link
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   SYMLINK3res NFSPROC3_SYMLINK(SYMLINK3args) = 10;
+ */
+static __be32 nfsd3_proc_symlink(struct svc_rqst *rqstp)
 {
-	struct nfsd3_symlinkargs *argp = rqstp->rq_argp;
-	struct nfsd3_diropres *resp = rqstp->rq_resp;
-	struct nfsd_attrs attrs = {
-		.na_iattr	= &argp->attrs,
+	struct SYMLINK3args_wrapper *argp = rqstp->rq_argp;
+	struct symlinkdata3 *symlink = &argp->xdrgen.symlink;
+	struct xdr_buf *to = &symlink->symlink_data;
+	struct diropargs3 *where = &argp->xdrgen.where;
+	struct SYMLINK3res_wrapper *resp = rqstp->rq_resp;
+	struct iattr *iattrs = &argp->iattrs;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
+	struct nfsd_attrs nattrs = {
+		.na_iattr	= iattrs,
 	};
+	char *tname;
+	void *page;
 
-	if (!nfsd3_time_in_range(&argp->attrs)) {
-		resp->status = nfserr_inval;
+	nfsd3_fh3_to_svc_fh(dirfhp, &where->dir);
+	resp->xdrgen.status = nfsd3_check_filename(where->name.data,
+						   where->name.len);
+	if (resp->xdrgen.status != nfs_ok)
+		goto out;
+	nfsd3_sattr3_to_iattr(rqstp, iattrs, &symlink->symlink_attributes);
+	if (!nfsd3_time_in_range(iattrs)) {
+		resp->xdrgen.status = nfserr_inval;
 		goto out;
 	}
-	if (argp->tlen == 0) {
-		resp->status = nfserr_inval;
+	if (to->len == 0) {
+		resp->xdrgen.status = nfserr_inval;
 		goto out;
 	}
-	if (argp->tlen > NFS3_MAXPATHLEN) {
-		resp->status = nfserr_nametoolong;
+	if (to->len > NFS3_MAXPATHLEN) {
+		resp->xdrgen.status = nfserr_nametoolong;
 		goto out;
 	}
 
-	argp->tname = svc_fill_symlink_pathname(rqstp, &argp->first,
-						page_address(rqstp->rq_arg.pages[0]),
-						argp->tlen);
-	if (IS_ERR(argp->tname)) {
-		resp->status = nfserrno(PTR_ERR(argp->tname));
+	page = to->page_len ? page_address(to->pages[0]) + to->page_base : NULL;
+	tname = svc_fill_symlink_pathname(rqstp, &to->head[0], page, to->len);
+	if (IS_ERR(tname)) {
+		resp->xdrgen.status = nfserrno(PTR_ERR(tname));
 		goto out;
 	}
 
-	fh_copy(&resp->dirfh, &argp->ffh);
-	fh_init(&resp->fh, NFS3_FHSIZE);
-	resp->status = nfsd_symlink(rqstp, &resp->dirfh, argp->fname,
-				    argp->flen, argp->tname, &attrs, &resp->fh);
-	kfree(argp->tname);
+	fh_init(fhp, NFS3_FHSIZE);
+	resp->xdrgen.status = nfsd_symlink(rqstp, dirfhp,
+					   (char *)where->name.data,
+					   where->name.len, tname,
+					   &nattrs, fhp);
+	kfree(tname);
+
 out:
-	resp->status = nfsd3_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok) {
+		struct SYMLINK3resok *resok = &resp->xdrgen.u.resok;
+
+		nfsd3_fill_post_op_fh3(&resok->obj, fhp, resp->fh_data);
+		nfsd3_fill_post_op_attr(rqstp, &resok->obj_attributes, fhp);
+		nfsd3_fill_wcc_data(rqstp, &resok->dir_wcc, dirfhp);
+	} else {
+		struct SYMLINK3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		nfsd3_fill_wcc_data(rqstp, &resfail->dir_wcc, dirfhp);
+	}
+
+	fh_put(fhp);
+	fh_put(dirfhp);
 	return rpc_success;
 }
 
@@ -1580,16 +1634,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "MKDIR",
 	},
 	[NFSPROC3_SYMLINK] = {
-		.pc_func = nfsd3_proc_symlink,
-		.pc_decode = nfs3svc_decode_symlinkargs,
-		.pc_encode = nfs3svc_encode_createres,
-		.pc_release = nfs3svc_release_fhandle2,
-		.pc_argsize = sizeof(struct nfsd3_symlinkargs),
-		.pc_argzero = sizeof(struct nfsd3_symlinkargs),
-		.pc_ressize = sizeof(struct nfsd3_diropres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+(1+FH+pAT)+WC,
-		.pc_name = "SYMLINK",
+		.pc_func	= nfsd3_proc_symlink,
+		.pc_decode	= nfs_svc_decode_SYMLINK3args,
+		.pc_encode	= nfs_svc_encode_SYMLINK3res,
+		.pc_argsize	= sizeof(struct SYMLINK3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct SYMLINK3res_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_SYMLINK3res_sz,
+		.pc_name	= "SYMLINK",
 	},
 	[NFSPROC3_MKNOD] = {
 		.pc_func = nfsd3_proc_mknod,
@@ -1740,9 +1793,10 @@ union nfsd3_xdrstore {
 	struct CREATE3res_wrapper	createres;
 	struct MKDIR3args_wrapper	mkdirargs;
 	struct MKDIR3res_wrapper	mkdirres;
+	struct SYMLINK3args_wrapper	symlinkargs;
+	struct SYMLINK3res_wrapper	symlinkres;
 	struct nfsd3_renameargs		renameargs;
 	struct nfsd3_linkargs		linkargs;
-	struct nfsd3_symlinkargs	symlinkargs;
 	struct nfsd3_readdirargs	readdirargs;
 	struct nfsd3_diropres 		diropres;
 	struct READLINK3res		readlinkres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 67cf76c13636..68f00ff604be 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -490,25 +490,6 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_symlinkargs *args = rqstp->rq_argp;
-	struct kvec *head = rqstp->rq_arg.head;
-
-	if (!svcxdr_decode_diropargs3(xdr, &args->ffh, &args->fname, &args->flen))
-		return false;
-	if (!svcxdr_decode_sattr3(rqstp, xdr, &args->attrs))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->tlen) < 0)
-		return false;
-
-	/* symlink_data */
-	args->first.iov_len = head->iov_len - xdr_stream_pos(xdr);
-	args->first.iov_base = xdr_inline_decode(xdr, args->tlen);
-	return args->first.iov_base != NULL;
-}
-
 bool
 nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
index 159aff1a8567..3667c160e789 100644
--- a/fs/nfsd/nfs3xdr_gen.c
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: Documentation/sunrpc/xdr/nfs3.x
-// XDR specification modification time: Tue Jul 14 11:43:26 2026
+// XDR specification modification time: Tue Jul 14 12:13:57 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -915,7 +915,7 @@ xdrgen_decode_symlinkdata3(struct xdr_stream *xdr, struct symlinkdata3 *ptr)
 {
 	if (!xdrgen_decode_sattr3(xdr, &ptr->symlink_attributes))
 		return false;
-	if (!xdrgen_decode_nfspath3(xdr, &ptr->symlink_data))
+	if (!svcxdr_decode_opaque_payload(xdr, &ptr->symlink_data, 0))
 		return false;
 	return true;
 }
@@ -2748,7 +2748,7 @@ xdrgen_encode_symlinkdata3(struct xdr_stream *xdr, const struct symlinkdata3 *va
 {
 	if (!xdrgen_encode_sattr3(xdr, &value->symlink_attributes))
 		return false;
-	if (!xdrgen_encode_nfspath3(xdr, value->symlink_data))
+	if (!svcxdr_encode_opaque_payload(xdr, value->symlink_data.len))
 		return false;
 	return true;
 }
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
index 98e29c8efc5e..f336ffa92a7a 100644
--- a/fs/nfsd/nfs3xdr_gen.h
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 11:43:26 2026 */
+/* XDR specification modification time: Tue Jul 14 12:13:57 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DECL_H
 #define _LINUX_XDRGEN_NFS3_DECL_H
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 04eda3c9c0fb..11a4e7cb65f6 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -62,16 +62,6 @@ struct nfsd3_linkargs {
 	unsigned int		tlen;
 };
 
-struct nfsd3_symlinkargs {
-	struct svc_fh		ffh;
-	char *			fname;
-	unsigned int		flen;
-	char *			tname;
-	unsigned int		tlen;
-	struct iattr		attrs;
-	struct kvec		first;
-};
-
 struct nfsd3_readdirargs {
 	struct svc_fh		fh;
 	__u64			cookie;
@@ -208,7 +198,6 @@ bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 3b6738c0074b..3e24abb1d2e5 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 11:43:26 2026 */
+/* XDR specification modification time: Tue Jul 14 12:13:57 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DEF_H
 #define _LINUX_XDRGEN_NFS3_DEF_H
@@ -468,7 +468,7 @@ struct MKDIR3res {
 
 struct symlinkdata3 {
 	struct sattr3 symlink_attributes;
-	nfspath3 symlink_data;
+	struct xdr_buf symlink_data;
 };
 
 struct SYMLINK3args {
-- 
2.55.0

