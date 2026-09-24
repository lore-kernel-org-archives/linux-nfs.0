Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2885A4AA1CC
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269829; cv=none; b=FBiBYf8mFhWbnqtl+ZnTzh3GL9GSMyUvp0MR4EcI1V8Jzmr7W0vRFD/osaFNU6cOKLYOFV+XblDpUsooQOzbJRtazeJymFUkCiQ3sBBSjWF/gKJESoUuUsmbdbOSQd9pruiTuM1UjDVTNOaWXjYlP7j+mwfwvuNShzfVEOZ6Z/Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269829; c=relaxed/simple;
	bh=3ukEtdrGgiqAKraUnc4k1mKaP3bVfk/FdOXYxdAXA7A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OYwrZOzhhrG2zvVI/tWghCRaOgGEmf7WMcU1HGBUe0MYQV6TpJxd/oYnmca+d0Kor4ZIsBSwWL7qejWvIWMISEp55nNMmd2+skF1vruSiOghMmur8Nt3ZKsJnDY19ExD6acdzTPJ3QrMDhRODR2M4JkJ3IN0ak8L2DVV9DXpznk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LxlWhA+r; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LxlWhA+r"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8371E1F0089A;
	Thu, 24 Sep 2026 17:10:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269827;
	bh=22XYI/jL2E3XMeUD/jCrxor6nWFghaTfRJVX4lWdUdM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LxlWhA+rBssCp+pxd6s98UKl9kB90OiHHW8BOJxPTCd6UQSv5vbIsplSdoQ8l+ymV
	 5VDd7WkdouwfbwT+yXK/x5t5lAoPo0114Y2m5er6gcGv0v0UGJfCw/J5NMIdeNRcT4
	 MjwlPhpejiilral7aANo04TxnxXA1BnvuZU8VW16HUZcNVjVJAJ89YB4qEPlC/AYo9
	 DOp5YEI0nUFx6MYHCRjYOBTzMArRx66SOFsSz7zCgzWptpAczhVE/KvC6+mrod/92z
	 zHigXfDFzjTiKBtVO91R9xepkLSpowuyA5vaW/d44BJJxOfhbk2NM4RE+2UyJSZT9X
	 EyYApFdEApnig==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 15/33] NFSD: Use xdrgen XDR functions for NFSv3 CREATE procedure
Date: Thu, 24 Sep 2026 13:09:54 -0400
Message-ID: <20260924171012.3978-16-cel@kernel.org>
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

Replace the NFSPROC3_CREATE entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_CREATE3args and nfs_svc_encode_CREATE3res. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh and iattr representations the NFSD VFS layer still uses.

Introduce nfsd3_fill_post_op_fh3() to fill a post_op_fh3. It is
useful here and in subsequent patches.

Filename validity is now checked by nfsd3_create_file() so that a
proper NFS3ERR status code can be returned to the client rather
than GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 CREATE
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_create() now fills in the post-op file handle,
the post-op attributes, and the WCC data, the fh_getattr() calls
are made in the proc function rather than in the XDR result
encoder, and the references to the file handles can be released
directly by nfsd3_proc_create(). A separate ->pc_release callback
is thus no longer needed. This makes it straightforward to
confirm that the file handles are properly released during every
error flow.

nfs3svc_decode_createargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 194 ++++++++++++++++++++++++++++++---------------
 fs/nfsd/nfs3xdr.c  |  24 ------
 fs/nfsd/xdr3.h     |   1 -
 3 files changed, 130 insertions(+), 89 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 6adb00a99052..eb8773e6ae17 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -99,6 +99,22 @@ struct WRITE3args_wrapper {
 
 static_assert(offsetof(struct WRITE3args_wrapper, xdrgen) == 0);
 
+struct CREATE3args_wrapper {
+	struct CREATE3args	xdrgen;
+	struct svc_fh		fh;
+	struct iattr		iattrs;
+};
+
+static_assert(offsetof(struct CREATE3args_wrapper, xdrgen) == 0);
+
+struct CREATE3res_wrapper {
+	struct CREATE3res	xdrgen;
+	struct svc_fh		fh;
+	u8			fh_data[NFS3_FHSIZE];
+};
+
+static_assert(offsetof(struct CREATE3res_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -422,6 +438,18 @@ nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
 	attr->attributes_follow = false;
 }
 
+static void
+nfsd3_fill_post_op_fh3(struct post_op_fh3 *post_op_fh,
+		       const struct svc_fh *fhp, u8 *data)
+{
+	if (fhp->fh_handle.fh_size != 0) {
+		post_op_fh->handle_follows = true;
+		nfsd3_svc_fh_to_fh3(&post_op_fh->u.handle, fhp, data);
+	} else {
+		post_op_fh->handle_follows = false;
+	}
+}
+
 /*
  * A full specification of each of the following NFSv3 procedures is
  * available in RFC 1813 Section 3.3.
@@ -761,59 +789,72 @@ static __be32 nfsd3_proc_write(struct svc_rqst *rqstp)
  * Implement NFSv3's unchecked, guarded, and exclusive CREATE
  * semantics for regular files. Except for the created file,
  * this operation is stateless on the server.
- *
- * Upon return, caller must release @fhp and @resfhp.
  */
 static __be32
-nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		  struct svc_fh *resfhp, struct nfsd3_createargs *argp)
+nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *dirfhp,
+		  struct svc_fh *resfhp, struct CREATE3args_wrapper *argp)
 {
-	struct iattr *iap = &argp->attrs;
+	struct diropargs3 *where = &argp->xdrgen.where;
+	struct createhow3 *how = &argp->xdrgen.how;
+	struct iattr *iattrs = &argp->iattrs;
 	struct dentry *parent, *child;
-	struct nfsd_attrs attrs = {
-		.na_iattr	= iap,
-	};
 	struct svc_export *exp;
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
+	struct nfsd_attrs nattrs = {
+		.na_iattr	= iattrs,
+	};
 	__be32 status;
 	int host_err;
 
-	trace_nfsd_vfs_create(rqstp, fhp, S_IFREG, argp->name, argp->len);
-
-	if (!nfsd3_time_in_range(iap))
-		return nfserr_inval;
-	if (name_is_dot_dotdot(argp->name, argp->len))
-		return nfserr_exist;
-	if (!(iap->ia_valid & ATTR_MODE))
-		iap->ia_mode = 0;
-
-	status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
+	status = nfsd3_check_filename(where->name.data, where->name.len);
 	if (status != nfs_ok)
 		return status;
 
-	parent = fhp->fh_dentry;
+	trace_nfsd_vfs_create(rqstp, dirfhp, S_IFREG, (char *)where->name.data,
+			      where->name.len);
+
+	if (name_is_dot_dotdot(where->name.data, where->name.len))
+		return nfserr_exist;
+
+	if (how->mode != EXCLUSIVE) {
+		nfsd3_sattr3_to_iattr(rqstp, iattrs,
+				      &how->u.obj_attributes);
+		if (!(iattrs->ia_valid & ATTR_MODE))
+			iattrs->ia_mode = 0;
+	} else {
+		memset(iattrs, 0, sizeof(*iattrs));
+	}
+
+	if (!nfsd3_time_in_range(iattrs))
+		return nfserr_inval;
+
+	status = fh_verify(rqstp, dirfhp, S_IFDIR, NFSD_MAY_EXEC);
+	if (status != nfs_ok)
+		return status;
+
+	parent = dirfhp->fh_dentry;
 	inode = d_inode(parent);
 
-	host_err = fh_want_write(fhp);
+	host_err = fh_want_write(dirfhp);
 	if (host_err)
 		return nfserrno(host_err);
 
 	child = start_creating(&nop_mnt_idmap, parent,
-			       &QSTR_LEN(argp->name, argp->len));
+			       &QSTR_LEN(where->name.data, where->name.len));
 	if (IS_ERR(child)) {
 		status = nfserrno(PTR_ERR(child));
 		goto out_write;
 	}
 
 	if (d_really_is_negative(child)) {
-		status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+		status = fh_verify(rqstp, dirfhp, S_IFDIR, NFSD_MAY_CREATE);
 		if (status != nfs_ok)
 			goto out;
 	}
 
-	exp = exp_get(fhp->fh_export);
-	if (argp->createmode == UNCHECKED) {
+	exp = exp_get(dirfhp->fh_export);
+	if (how->mode == UNCHECKED) {
 		/*
 		 * If name is already in dcache we need to check for mountpoints
 		 */
@@ -827,15 +868,15 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		}
 	}
 
-	status = fh_compose(resfhp, exp, child, fhp);
+	status = fh_compose(resfhp, exp, child, dirfhp);
 	exp_put(exp);
 	if (status != nfs_ok)
 		goto out;
 
 	v_mtime = 0;
 	v_atime = 0;
-	if (argp->createmode == EXCLUSIVE) {
-		u32 *verifier = (u32 *)argp->verf;
+	if (how->mode == EXCLUSIVE) {
+		u32 *verifier = (u32 *)how->u.verf;
 
 		/*
 		 * Solaris 7 gets confused (bugid 4218508) if these have
@@ -849,11 +890,11 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (d_really_is_positive(child)) {
 		status = nfs_ok;
 
-		switch (argp->createmode) {
+		switch (how->mode) {
 		case UNCHECKED:
 			if (!d_is_reg(child))
 				break;
-			iap->ia_valid &= ATTR_SIZE;
+			iattrs->ia_valid &= ATTR_SIZE;
 			goto set_attr;
 		case GUARDED:
 			status = nfserr_exist;
@@ -870,52 +911,77 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	if (!IS_POSIXACL(inode))
-		iap->ia_mode &= ~current_umask();
+		iattrs->ia_mode &= ~current_umask();
 
-	status = fh_fill_pre_attrs(fhp);
+	status = fh_fill_pre_attrs(dirfhp);
 	if (status != nfs_ok)
 		goto out;
-	host_err = vfs_create(&nop_mnt_idmap, child, iap->ia_mode, NULL);
+	host_err = vfs_create(&nop_mnt_idmap, child, iattrs->ia_mode, NULL);
 	if (host_err < 0) {
 		status = nfserrno(host_err);
 		goto out;
 	}
-	fh_fill_post_attrs(fhp);
+	fh_fill_post_attrs(dirfhp);
 
 	/* A newly created file already has a file size of zero. */
-	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
-		iap->ia_valid &= ~ATTR_SIZE;
-	if (argp->createmode == EXCLUSIVE) {
-		iap->ia_valid = ATTR_MTIME | ATTR_ATIME |
-				ATTR_MTIME_SET | ATTR_ATIME_SET;
-		iap->ia_mtime.tv_sec = v_mtime;
-		iap->ia_atime.tv_sec = v_atime;
-		iap->ia_mtime.tv_nsec = 0;
-		iap->ia_atime.tv_nsec = 0;
+	if ((iattrs->ia_valid & ATTR_SIZE) && iattrs->ia_size == 0)
+		iattrs->ia_valid &= ~ATTR_SIZE;
+	if (how->mode == EXCLUSIVE) {
+		iattrs->ia_valid = ATTR_MTIME | ATTR_ATIME |
+				   ATTR_MTIME_SET | ATTR_ATIME_SET;
+		iattrs->ia_mtime.tv_sec = v_mtime;
+		iattrs->ia_atime.tv_sec = v_atime;
+		iattrs->ia_mtime.tv_nsec = 0;
+		iattrs->ia_atime.tv_nsec = 0;
 	}
 
 set_attr:
-	status = nfsd_create_setattr(rqstp, fhp, resfhp, &attrs);
+	status = nfsd_create_setattr(rqstp, dirfhp, resfhp, &nattrs);
 
 out:
 	end_creating(child);
 out_write:
-	fh_drop_write(fhp);
+	fh_drop_write(dirfhp);
 	return status;
 }
 
-static __be32
-nfsd3_proc_create(struct svc_rqst *rqstp)
+/**
+ * nfsd3_proc_create - CREATE: Create a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   CREATE3res NFSPROC3_CREATE(CREATE3args) = 8;
+ */
+static __be32 nfsd3_proc_create(struct svc_rqst *rqstp)
 {
-	struct nfsd3_createargs *argp = rqstp->rq_argp;
-	struct nfsd3_diropres *resp = rqstp->rq_resp;
-	svc_fh *dirfhp, *newfhp;
+	struct CREATE3args_wrapper *argp = rqstp->rq_argp;
+	struct CREATE3res_wrapper *resp = rqstp->rq_resp;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
 
-	dirfhp = fh_copy(&resp->dirfh, &argp->fh);
-	newfhp = fh_init(&resp->fh, NFS3_FHSIZE);
+	nfsd3_fh3_to_svc_fh(dirfhp, &argp->xdrgen.where.dir);
 
-	resp->status = nfsd3_create_file(rqstp, dirfhp, newfhp, argp);
-	resp->status = nfsd3_map_status(resp->status);
+	fh_init(fhp, NFS3_FHSIZE);
+	resp->xdrgen.status = nfsd3_create_file(rqstp, dirfhp, fhp, argp);
+
+	if (resp->xdrgen.status == nfs_ok) {
+		struct CREATE3resok *resok = &resp->xdrgen.u.resok;
+
+		nfsd3_fill_post_op_fh3(&resok->obj, fhp, resp->fh_data);
+		nfsd3_fill_post_op_attr(rqstp, &resok->obj_attributes, fhp);
+		nfsd3_fill_wcc_data(rqstp, &resok->dir_wcc, dirfhp);
+	} else {
+		struct CREATE3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		nfsd3_fill_wcc_data(rqstp, &resfail->dir_wcc, dirfhp);
+	}
+
+	fh_put(fhp);
+	fh_put(dirfhp);
 	return rpc_success;
 }
 
@@ -1445,16 +1511,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "WRITE",
 	},
 	[NFSPROC3_CREATE] = {
-		.pc_func = nfsd3_proc_create,
-		.pc_decode = nfs3svc_decode_createargs,
-		.pc_encode = nfs3svc_encode_createres,
-		.pc_release = nfs3svc_release_fhandle2,
-		.pc_argsize = sizeof(struct nfsd3_createargs),
-		.pc_argzero = sizeof(struct nfsd3_createargs),
-		.pc_ressize = sizeof(struct nfsd3_diropres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+(1+FH+pAT)+WC,
-		.pc_name = "CREATE",
+		.pc_func	= nfsd3_proc_create,
+		.pc_decode	= nfs_svc_decode_CREATE3args,
+		.pc_encode	= nfs_svc_encode_CREATE3res,
+		.pc_argsize	= sizeof(struct CREATE3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct CREATE3res_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_CREATE3res_sz,
+		.pc_name	= "CREATE",
 	},
 	[NFSPROC3_MKDIR] = {
 		.pc_func = nfsd3_proc_mkdir,
@@ -1625,7 +1690,8 @@ union nfsd3_xdrstore {
 	struct READ3args_wrapper	readargs;
 	struct nfsd3_diropargs		diropargs;
 	struct WRITE3args_wrapper	writeargs;
-	struct nfsd3_createargs		createargs;
+	struct CREATE3args_wrapper	createargs;
+	struct CREATE3res_wrapper	createres;
 	struct nfsd3_renameargs		renameargs;
 	struct nfsd3_linkargs		linkargs;
 	struct nfsd3_symlinkargs	symlinkargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index cc3aebd97959..1bdfe5398031 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -490,30 +490,6 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfs3svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_createargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->createmode) < 0)
-		return false;
-	switch (args->createmode) {
-	case UNCHECKED:
-	case GUARDED:
-		return svcxdr_decode_sattr3(rqstp, xdr, &args->attrs);
-	case EXCLUSIVE:
-		args->verf = xdr_inline_decode(xdr, NFS3_CREATEVERFSIZE);
-		if (!args->verf)
-			return false;
-		break;
-	default:
-		return false;
-	}
-	return true;
-}
-
 bool
 nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 9c41244d27bb..30347cce5517 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -207,7 +207,6 @@ struct nfsd3_fhandle_pair {
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0

