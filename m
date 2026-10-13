Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1282501F2D
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895782; cv=none; b=Gi2E0+z+2jxDXNf/p+/yAbTpzP/tbD5JOgKWkl9SXYtNRVFKOglYOmtJkKlwFCqACpovV2w3ioZNCHchvaMx/ABF9d1Wk0UUovDjTR9HCs/QFsEVs4L2IEvD64iZ+HdZvumadro/waKD+kPeqxP7DV4IOvPOY94HC3ea5rzm5tc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895782; c=relaxed/simple;
	bh=GWfu7KPF5dWNvQc2PsYh/ZQrr+lXZA3kwZLuELa3D1U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YOFckHTysT7maXSIrG282FaKItnEFn5Y9h/N+ziGUS2x3qQTAUtViLOOFSj5MrDdkJ7qcY+y2bdk4Uf7ozgRrNw8EzVlUC/OWC0YMwdzstVi9yaM5kAjvFrTIHoVK+hC7IeqqTc5QE00QoouNh79XnqwiB05hJoxvCmDFPczsTk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fW3N6lLW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fW3N6lLW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13A351F0089B;
	Tue, 13 Oct 2026 12:49:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895780;
	bh=0+f2q5Xa0Q1DmstsqlxGW0/rngH+uyA14NBmJUXNejU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fW3N6lLWZLDKWdN45TApgambAHXveu61c+vGjie4H3+oIUhGvsWe2Y90IFK9UjmZT
	 vsdEFF5tYYleHcWfNamiHYvxSkWHUZZM+qqHsVUcc8Mwxm8GGW0iz/y++BCQB2hY65
	 xcdeVUwDzvEfpzF1xoszVkbmWQlcyW98VEvbBIEHGLzeBO/9gR5+9NQbvwSF0oJ0TH
	 yPxJoV0utjhYhSLrJaVFLChY9t3gPt+48Jack23d+OvrllIOIjAVUZKQFALKPsMqfi
	 h9KGyMEff5ac1jwVvAfLGZFDdgUSgCoqfKSWgpuP21Pk7HmaxHSFZogoA7QrqGn+hV
	 9MTWvAVlLIhSw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 18/34] NFSD: Use xdrgen XDR functions for NFSv3 MKNOD procedure
Date: Tue, 13 Oct 2026 08:49:32 -0400
Message-ID: <20261013124933.316765-9-cel@kernel.org>
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

Replace the NFSPROC3_MKNOD entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_MKNOD3args and nfs_svc_encode_MKNOD3res. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh and iattr representations the NFSD VFS layer still uses.

Filename validity is now checked by nfsd3_proc_mknod() so that a
proper NFS3ERR status code can be returned to the client rather
than GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 MKNOD
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_mknod() now fills in the post-op file handle,
the post-op attributes, and the WCC data, the fh_getattr() calls
are made in the proc function rather than in the XDR result
encoder, and the references to the file handles can be released
directly by nfsd3_proc_mknod(). A separate ->pc_release callback
is thus no longer needed. This makes it straightforward to
confirm that the file handles are properly released during every
error flow.

nfs3svc_decode_mknodargs() and nfs3svc_encode_createres() no
longer have any callers, so they are removed. MKNOD was the last
consumer of the hand-coded sattr3 decoder, so svcxdr_decode_sattr3()
and its helpers svcxdr_decode_nfstime3(), svcxdr_decode_specdata3(),
and svcxdr_decode_devicedata3() are removed as well.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 154 +++++++++++++++++++++++++++------------
 fs/nfsd/nfs3xdr.c  | 175 ---------------------------------------------
 fs/nfsd/xdr3.h     |  18 -----
 3 files changed, 107 insertions(+), 240 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index a068b9f157d7..d878391e63f8 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -147,17 +147,37 @@ struct SYMLINK3res_wrapper {
 
 static_assert(offsetof(struct SYMLINK3res_wrapper, xdrgen) == 0);
 
-static int	nfs3_ftypes[] = {
-	0,			/* NF3NON */
-	S_IFREG,		/* NF3REG */
-	S_IFDIR,		/* NF3DIR */
-	S_IFBLK,		/* NF3BLK */
-	S_IFCHR,		/* NF3CHR */
-	S_IFLNK,		/* NF3LNK */
-	S_IFSOCK,		/* NF3SOCK */
-	S_IFIFO,		/* NF3FIFO */
+struct MKNOD3args_wrapper {
+	struct MKNOD3args	xdrgen;
+	struct svc_fh		fh;
+	struct iattr		iattrs;
 };
 
+static_assert(offsetof(struct MKNOD3args_wrapper, xdrgen) == 0);
+
+struct MKNOD3res_wrapper {
+	struct MKNOD3res	xdrgen;
+	struct svc_fh		fh;
+	u8			fh_data[NFS3_FHSIZE];
+};
+
+static_assert(offsetof(struct MKNOD3res_wrapper, xdrgen) == 0);
+
+static int nfsd3_ftype3_to_mode(ftype3 ftype)
+{
+	switch (ftype) {
+	case NF3REG:  return S_IFREG;
+	case NF3DIR:  return S_IFDIR;
+	case NF3BLK:  return S_IFBLK;
+	case NF3CHR:  return S_IFCHR;
+	case NF3LNK:  return S_IFLNK;
+	case NF3SOCK: return S_IFSOCK;
+	case NF3FIFO: return S_IFIFO;
+	default:
+		return 0;
+	}
+}
+
 /*
  * Reject a client-supplied atime or mtime whose nanoseconds field is out
  * of range. Such a value is well-formed on the wire but is not a valid
@@ -1149,45 +1169,86 @@ static __be32 nfsd3_proc_symlink(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Make socket/fifo/device.
+/**
+ * nfsd3_proc_mknod - MKNOD: Create a special file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   MKNOD3res NFSPROC3_MKNOD(MKNOD3args) = 11;
  */
-static __be32
-nfsd3_proc_mknod(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_mknod(struct svc_rqst *rqstp)
 {
-	struct nfsd3_mknodargs *argp = rqstp->rq_argp;
-	struct nfsd3_diropres  *resp = rqstp->rq_resp;
-	struct nfsd_attrs attrs = {
-		.na_iattr	= &argp->attrs,
+	struct MKNOD3args_wrapper *argp = rqstp->rq_argp;
+	struct diropargs3 *where = &argp->xdrgen.where;
+	struct mknoddata3 *what = &argp->xdrgen.what;
+	struct MKNOD3res_wrapper *resp = rqstp->rq_resp;
+	struct iattr *iattrs = &argp->iattrs;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
+	struct nfsd_attrs nattrs = {
+		.na_iattr	= iattrs,
 	};
-	int type;
-	dev_t	rdev = 0;
+	dev_t rdev = 0;
 
-	fh_copy(&resp->dirfh, &argp->fh);
-	fh_init(&resp->fh, NFS3_FHSIZE);
-
-	if (argp->ftype == NF3CHR || argp->ftype == NF3BLK) {
-		rdev = MKDEV(argp->major, argp->minor);
-		if (MAJOR(rdev) != argp->major ||
-		    MINOR(rdev) != argp->minor) {
-			resp->status = nfserr_inval;
+	nfsd3_fh3_to_svc_fh(dirfhp, &where->dir);
+	resp->xdrgen.status = nfsd3_check_filename(where->name.data,
+						   where->name.len);
+	if (resp->xdrgen.status != nfs_ok)
+		goto out;
+	switch (what->type) {
+	case NF3CHR:
+	case NF3BLK:
+		rdev = MKDEV(what->u.device.spec.specdata1,
+			     what->u.device.spec.specdata2);
+		if (MAJOR(rdev) != what->u.device.spec.specdata1 ||
+		    MINOR(rdev) != what->u.device.spec.specdata2) {
+			resp->xdrgen.status = nfserr_inval;
 			goto out;
 		}
-	} else if (argp->ftype != NF3SOCK && argp->ftype != NF3FIFO) {
-		resp->status = nfserr_badtype;
+		nfsd3_sattr3_to_iattr(rqstp, iattrs,
+				      &what->u.device.dev_attributes);
+		break;
+	case NF3SOCK:
+	case NF3FIFO:
+		nfsd3_sattr3_to_iattr(rqstp, iattrs,
+				      &what->u.pipe_attributes);
+		break;
+	default:
+		resp->xdrgen.status = nfserr_badtype;
 		goto out;
 	}
 
-	if (!nfsd3_time_in_range(&argp->attrs)) {
-		resp->status = nfserr_inval;
+	if (!nfsd3_time_in_range(iattrs)) {
+		resp->xdrgen.status = nfserr_inval;
 		goto out;
 	}
 
-	type = nfs3_ftypes[argp->ftype];
-	resp->status = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
-				   &attrs, type, rdev, &resp->fh);
+	fh_init(fhp, NFS3_FHSIZE);
+	resp->xdrgen.status = nfsd_create(rqstp, dirfhp,
+					  (char *)where->name.data,
+					  where->name.len, &nattrs,
+					  nfsd3_ftype3_to_mode(what->type),
+					  rdev, fhp);
+
 out:
-	resp->status = nfsd3_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok) {
+		struct MKNOD3resok *resok = &resp->xdrgen.u.resok;
+
+		nfsd3_fill_post_op_fh3(&resok->obj, fhp, resp->fh_data);
+		nfsd3_fill_post_op_attr(rqstp, &resok->obj_attributes, fhp);
+		nfsd3_fill_wcc_data(rqstp, &resok->dir_wcc, dirfhp);
+	} else {
+		struct MKNOD3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		nfsd3_fill_wcc_data(rqstp, &resfail->dir_wcc, dirfhp);
+	}
+
+	fh_put(fhp);
+	fh_put(dirfhp);
 	return rpc_success;
 }
 
@@ -1510,7 +1571,6 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
 #define nfsd3_wccstatres		nfsd3_attrstat
 
 #define ST 1		/* status*/
-#define FH 17		/* filehandle with length */
 #define AT 21		/* attributes */
 #define pAT (1+AT)	/* post attributes - conditional */
 #define WC (7+pAT)	/* WCC attributes */
@@ -1641,16 +1701,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "SYMLINK",
 	},
 	[NFSPROC3_MKNOD] = {
-		.pc_func = nfsd3_proc_mknod,
-		.pc_decode = nfs3svc_decode_mknodargs,
-		.pc_encode = nfs3svc_encode_createres,
-		.pc_release = nfs3svc_release_fhandle2,
-		.pc_argsize = sizeof(struct nfsd3_mknodargs),
-		.pc_argzero = sizeof(struct nfsd3_mknodargs),
-		.pc_ressize = sizeof(struct nfsd3_diropres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+(1+FH+pAT)+WC,
-		.pc_name = "MKNOD",
+		.pc_func	= nfsd3_proc_mknod,
+		.pc_decode	= nfs_svc_decode_MKNOD3args,
+		.pc_encode	= nfs_svc_encode_MKNOD3res,
+		.pc_argsize	= sizeof(struct MKNOD3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct MKNOD3res_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_MKNOD3res_sz,
+		.pc_name	= "MKNOD",
 	},
 	[NFSPROC3_REMOVE] = {
 		.pc_func = nfsd3_proc_remove,
@@ -1791,10 +1850,11 @@ union nfsd3_xdrstore {
 	struct MKDIR3res_wrapper	mkdirres;
 	struct SYMLINK3args_wrapper	symlinkargs;
 	struct SYMLINK3res_wrapper	symlinkres;
+	struct MKNOD3args_wrapper	mknodargs;
+	struct MKNOD3res_wrapper	mknodres;
 	struct nfsd3_renameargs		renameargs;
 	struct nfsd3_linkargs		linkargs;
 	struct nfsd3_readdirargs	readdirargs;
-	struct nfsd3_diropres 		diropres;
 	struct READLINK3res		readlinkres;
 	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 68f00ff604be..53a82af80ad5 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -57,20 +57,6 @@ encode_nfstime3(__be32 *p, const struct timespec64 *time)
 	return p;
 }
 
-static bool
-svcxdr_decode_nfstime3(struct xdr_stream *xdr, struct timespec64 *timep)
-{
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, XDR_UNIT * 2);
-	if (!p)
-		return false;
-	timep->tv_sec = be32_to_cpup(p++);
-	timep->tv_nsec = be32_to_cpup(p);
-
-	return true;
-}
-
 /**
  * svcxdr_decode_nfs_fh3 - Decode an NFSv3 file handle
  * @xdr: XDR stream positioned at an undecoded NFSv3 FH
@@ -209,114 +195,6 @@ svcxdr_decode_diropargs3(struct xdr_stream *xdr, struct svc_fh *fhp,
 		svcxdr_decode_filename3(xdr, name, len);
 }
 
-static bool
-svcxdr_decode_sattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-		     struct iattr *iap)
-{
-	u32 set_it;
-
-	iap->ia_valid = 0;
-
-	if (xdr_stream_decode_bool(xdr, &set_it) < 0)
-		return false;
-	if (set_it) {
-		u32 mode;
-
-		if (xdr_stream_decode_u32(xdr, &mode) < 0)
-			return false;
-		iap->ia_valid |= ATTR_MODE;
-		iap->ia_mode = mode;
-	}
-	if (xdr_stream_decode_bool(xdr, &set_it) < 0)
-		return false;
-	if (set_it) {
-		u32 uid;
-
-		if (xdr_stream_decode_u32(xdr, &uid) < 0)
-			return false;
-		iap->ia_uid = make_kuid(nfsd_user_namespace(rqstp), uid);
-		if (uid_valid(iap->ia_uid))
-			iap->ia_valid |= ATTR_UID;
-	}
-	if (xdr_stream_decode_bool(xdr, &set_it) < 0)
-		return false;
-	if (set_it) {
-		u32 gid;
-
-		if (xdr_stream_decode_u32(xdr, &gid) < 0)
-			return false;
-		iap->ia_gid = make_kgid(nfsd_user_namespace(rqstp), gid);
-		if (gid_valid(iap->ia_gid))
-			iap->ia_valid |= ATTR_GID;
-	}
-	if (xdr_stream_decode_bool(xdr, &set_it) < 0)
-		return false;
-	if (set_it) {
-		u64 newsize;
-
-		if (xdr_stream_decode_u64(xdr, &newsize) < 0)
-			return false;
-		iap->ia_valid |= ATTR_SIZE;
-		iap->ia_size = newsize;
-	}
-	if (xdr_stream_decode_u32(xdr, &set_it) < 0)
-		return false;
-	switch (set_it) {
-	case DONT_CHANGE:
-		break;
-	case SET_TO_SERVER_TIME:
-		iap->ia_valid |= ATTR_ATIME;
-		break;
-	case SET_TO_CLIENT_TIME:
-		if (!svcxdr_decode_nfstime3(xdr, &iap->ia_atime))
-			return false;
-		iap->ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
-		break;
-	default:
-		return false;
-	}
-	if (xdr_stream_decode_u32(xdr, &set_it) < 0)
-		return false;
-	switch (set_it) {
-	case DONT_CHANGE:
-		break;
-	case SET_TO_SERVER_TIME:
-		iap->ia_valid |= ATTR_MTIME;
-		break;
-	case SET_TO_CLIENT_TIME:
-		if (!svcxdr_decode_nfstime3(xdr, &iap->ia_mtime))
-			return false;
-		iap->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
-		break;
-	default:
-		return false;
-	}
-
-	return true;
-}
-
-static bool
-svcxdr_decode_specdata3(struct xdr_stream *xdr, struct nfsd3_mknodargs *args)
-{
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, XDR_UNIT * 2);
-	if (!p)
-		return false;
-	args->major = be32_to_cpup(p++);
-	args->minor = be32_to_cpup(p);
-
-	return true;
-}
-
-static bool
-svcxdr_decode_devicedata3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-			  struct nfsd3_mknodargs *args)
-{
-	return svcxdr_decode_sattr3(rqstp, xdr, &args->attrs) &&
-		svcxdr_decode_specdata3(xdr, args);
-}
-
 static bool
 svcxdr_encode_fattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		     const struct svc_fh *fhp, const struct kstat *stat)
@@ -490,34 +368,6 @@ nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_mknodargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_diropargs3(xdr, &args->fh, &args->name, &args->len))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->ftype) < 0)
-		return false;
-	switch (args->ftype) {
-	case NF3CHR:
-	case NF3BLK:
-		return svcxdr_decode_devicedata3(rqstp, xdr, args);
-	case NF3SOCK:
-	case NF3FIFO:
-		return svcxdr_decode_sattr3(rqstp, xdr, &args->attrs);
-	case NF3REG:
-	case NF3DIR:
-	case NF3LNK:
-		/* Valid XDR but illegal file types */
-		break;
-	default:
-		return false;
-	}
-
-	return true;
-}
-
 bool
 nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -608,31 +458,6 @@ nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh);
 }
 
-/* CREATE, MKDIR, SYMLINK, MKNOD */
-bool
-nfs3svc_encode_createres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_diropres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_fh3(xdr, &resp->fh))
-			return false;
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-		if (!svcxdr_encode_wcc_data(rqstp, xdr, &resp->dirfh))
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_wcc_data(rqstp, xdr, &resp->dirfh))
-			return false;
-	}
-
-	return true;
-}
-
 /* RENAME */
 bool
 nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 43ded5cff892..6d5cea6baf3a 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -30,15 +30,6 @@ struct nfsd3_accessargs {
 	__u32			access;
 };
 
-struct nfsd3_mknodargs {
-	struct svc_fh		fh;
-	char *			name;
-	unsigned int		len;
-	__u32			ftype;
-	__u32			major, minor;
-	struct iattr		attrs;
-};
-
 struct nfsd3_renameargs {
 	struct svc_fh		ffh;
 	char *			fname;
@@ -87,13 +78,6 @@ struct nfsd3_attrstat {
 	struct kstat            stat;
 };
 
-/* LOOKUP, CREATE, MKDIR, SYMLINK, MKNOD */
-struct nfsd3_diropres  {
-	__be32			status;
-	struct svc_fh		dirfh;
-	struct svc_fh		fh;
-};
-
 struct nfsd3_accessres {
 	__be32			status;
 	struct svc_fh		fh;
@@ -188,7 +172,6 @@ struct nfsd3_fhandle_pair {
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_mknodargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
@@ -197,7 +180,6 @@ bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_createres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_renameres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_linkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0

