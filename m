Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C405A3D3CEB
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576163; cv=none; b=pB0q2KbKuGFpS6TApoEk/ZbkiyvLyVQ1DZkWYoaykO1/SFNk3RTySLXFFBpbujeiGBOkTGgv8yLfTY8Wzn0uos8RGLUFjWyRAzHxv8MxHBm6pvZZ8VTPXm9Jer2j7Agi0i1GaufW0/MxmCsZ4IdJpuPD/DIB2cCl7RnhbeaslzQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576163; c=relaxed/simple;
	bh=fVgQxxCbDTcA5xMCVtt7VHIW/LEWPxXUnkzjLzgBB4A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YCsn7eyFPQD3ghok8N9yIv79kjVorb08XYn/jvzSWuALXd/C/qm60DTJbldVprmS8NdlPv8Dq15KJQNxBtUr8hBeyrfP7M8qQzUkbiO+sCNcCtKbgSUOYNbgKpFPrdoxau3nSrAgjwg4V4ukPagNfpqR8x2KHayBW9Mc4sq0cSE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bjSkR8lB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bjSkR8lB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB5401F0089A;
	Wed, 16 Sep 2026 16:29:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576161;
	bh=ocTIl8i40KVEwZlXxB06QvMAJOwzciXNDy+VpFrTIEY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bjSkR8lBT9AWvvKJRqnnFPRjvryvLaXD83NfVljAo3jb0FYI16cwS2PHt0culD1PS
	 iyuonVnNkss/XnN/LAtKX8RCVYxNWAkFpJg2g4Z1N2Rir+QYNjiS3A0zoUOUwOnb5/
	 RePNdfeP1Eh3Xf9RcAb5ni4w/R8mzvr47oZZ63147MeEzWHS0VP3bFp8bcuHUzj0zQ
	 cC2RNHVWs8H28jD2gtCSNWgAjtROSEMZVsa1uVpLTwJqAgLq/LlUVcpWF2nPpWf+/B
	 lHYvjLINrjsXiwAGVZDzWsN1D3dUOFObC0SPkpSRQ1MLKLROCCENOQAaveeGhDAO+w
	 U0lS7nYRQ40bA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 16/27] NFSD: Use xdrgen XDR functions for NFSv2 CREATE procedure
Date: Wed, 16 Sep 2026 12:28:47 -0400
Message-ID: <20260916162859.2051-19-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC_CREATE entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_createargs and nfs_svc_encode_diropres. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh, iattr, and kstat representations the NFSD VFS layer still
uses.

The pc_argzero field is now set to zero for the NFSv2 CREATE
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

This refactor replaces the use of svcxdr_encode_fattr(), so the
references to the parent directory and the new object file
handles can be released directly by nfsd_proc_create(). A
separate ->pc_release callback is thus no longer needed. This
makes it straightforward to confirm that the file handles are
properly released during every error flow.

nfssvc_decode_createargs remains for the MKDIR procedure which
uses the same argument structure.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 89 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 60 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index e041598ce68e..69dcd482b77f 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -63,6 +63,14 @@ struct diropres_wrapper {
 
 static_assert(offsetof(struct diropres_wrapper, xdrgen) == 0);
 
+struct createargs_wrapper {
+	struct createargs	xdrgen;
+	struct svc_fh		fh;
+	struct iattr		iattrs;
+};
+
+static_assert(offsetof(struct createargs_wrapper, xdrgen) == 0);
+
 struct readargs_wrapper {
 	struct readargs		xdrgen;
 	struct svc_fh		fh;
@@ -634,9 +642,10 @@ static __be32 nfsd_proc_write(struct svc_rqst *rqstp)
  */
 static __be32
 nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		 struct svc_fh *resfhp, struct nfsd_createargs *argp)
+		 struct svc_fh *resfhp, struct createargs_wrapper *argp)
 {
-	struct iattr *attr = &argp->attrs;
+	struct diropargs *where = &argp->xdrgen.where;
+	struct iattr *attr = &argp->iattrs;
 	dev_t rdev = 0, wanted = new_decode_dev(attr->ia_size);
 	struct nfsd_attrs attrs = {
 		.na_iattr	= attr,
@@ -648,7 +657,7 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	__be32 status;
 	int host_err;
 
-	if (name_is_dot_dotdot(argp->name, argp->len))
+	if (name_is_dot_dotdot(where->name.data, where->name.len))
 		return nfserr_exist;
 
 	status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
@@ -660,7 +669,7 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		return nfserrno(host_err);
 
 	dchild = start_creating(&nop_mnt_idmap, fhp->fh_dentry,
-				&QSTR_LEN(argp->name, argp->len));
+				&QSTR_LEN(where->name.data, where->name.len));
 	if (IS_ERR(dchild)) {
 		status = nfserrno(PTR_ERR(dchild));
 		goto out_drop_write;
@@ -777,7 +786,7 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out_drop_write;
 	} else if (type == S_IFREG) {
 		dprintk("nfsd:   existing %s, valid=%x, size=%ld\n",
-			argp->name, attr->ia_valid, (long)attr->ia_size);
+			where->name.data, attr->ia_valid, (long)attr->ia_size);
 		/* File already exists. We ignore all attributes except
 		 * size, so that creat() behaves exactly like
 		 * open(..., O_CREAT|O_TRUNC|O_WRONLY).
@@ -794,24 +803,47 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	return status;
 }
 
-/*
- * N.B. After this call _both_ argp->fh and resp->fh need an fh_put
+/**
+ * nfsd_proc_create - CREATE: Create a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   diropres NFSPROC_CREATE(createargs) = 9;
  */
-static __be32
-nfsd_proc_create(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_create(struct svc_rqst *rqstp)
 {
-	struct nfsd_createargs *argp = rqstp->rq_argp;
-	struct nfsd_diropres *resp = rqstp->rq_resp;
-	svc_fh *dirfhp = &argp->fh;
-	svc_fh *newfhp = fh_init(&resp->fh, NFS_FHSIZE);
+	struct createargs_wrapper *argp = rqstp->rq_argp;
+	struct diropres_wrapper *resp = rqstp->rq_resp;
+	struct kstat *statp = &resp->stat;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
 
-	resp->status = nfsd_create_file(rqstp, dirfhp, newfhp, argp);
-	fh_put(dirfhp);
-	if (resp->status != nfs_ok)
+	nfsd_fhandle_to_svc_fh(dirfhp, &argp->xdrgen.where.dir);
+	fh_init(fhp, NFS_FHSIZE);
+	if (!nfsd_sattr_to_iattr(rqstp, &argp->iattrs, &argp->xdrgen.attributes)) {
+		resp->xdrgen.status = nfserr_io;
 		goto out;
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
+	}
+
+	resp->xdrgen.status = nfsd_create_file(rqstp, dirfhp, fhp, argp);
+	if (resp->xdrgen.status != nfs_ok)
+		goto out;
+	resp->xdrgen.status = fh_getattr(fhp, statp);
+
 out:
-	resp->status = nfsd_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok) {
+		nfsd_svc_fh_to_fhandle(&resp->xdrgen.u.diropok.file, fhp);
+		nfsd_stat_to_fattr(rqstp, &resp->xdrgen.u.diropok.attributes,
+				   statp, fhp);
+	} else {
+		resp->xdrgen.status = nfsd_map_status(resp->xdrgen.status);
+	}
+
+	fh_put(fhp);
+	fh_put(dirfhp);
 	return rpc_success;
 }
 
@@ -1110,16 +1142,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "WRITE",
 	},
 	[NFSPROC_CREATE] = {
-		.pc_func = nfsd_proc_create,
-		.pc_decode = nfssvc_decode_createargs,
-		.pc_encode = nfssvc_encode_diropres,
-		.pc_release = nfssvc_release_diropres,
-		.pc_argsize = sizeof(struct nfsd_createargs),
-		.pc_argzero = sizeof(struct nfsd_createargs),
-		.pc_ressize = sizeof(struct nfsd_diropres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+FH+AT,
-		.pc_name = "CREATE",
+		.pc_func	= nfsd_proc_create,
+		.pc_decode	= nfs_svc_decode_createargs,
+		.pc_encode	= nfs_svc_encode_diropres,
+		.pc_argsize	= sizeof(struct createargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct diropres_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS2_diropres_sz,
+		.pc_name	= "CREATE",
 	},
 	[NFSPROC_REMOVE] = {
 		.pc_func = nfsd_proc_remove,
@@ -1220,7 +1251,7 @@ union nfsd_xdrstore {
 	struct diropargs_wrapper	diropargs;
 	struct readargs_wrapper		readargs;
 	struct writeargs_wrapper	writeargs;
-	struct nfsd_createargs	create;
+	struct createargs_wrapper	createargs;
 	struct nfsd_renameargs	rename;
 	struct nfsd_linkargs	link;
 	struct nfsd_symlinkargs	symlink;
-- 
2.55.0

