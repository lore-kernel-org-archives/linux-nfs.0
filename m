Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A185C4A6CF6
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269824; cv=none; b=uKGKhp3e+s8lfzmB3Cp5P8VFHcGswT3iIJEi0b1e0o806ZN6OjoK70KGY1SpYSO4TIeeSOWAEegeYLbe5lAn+Gtv0wCu2GnC6v5VDcDG1k3LMSB/RcEibDykXgv7Jm9AWImsscjVx0NHNwY35Z1+o3kdncLZ59DaQJ9y0lsCsxo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269824; c=relaxed/simple;
	bh=q2zIG7MmzPhoEhUUnSivoyLOZRnKoYsMxB9GcqWT6ho=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iYS7funo0VHrjDtxfrIA8Ql7mLcCnMPnSnCdpURifv6TY+HS+RgeXRMzPYhJ8xmnRt3OkE13677Kn0tjXFw/bL10mijq2mq4H8P8tMUyO29BaYfK20XcXjuFO8EjdXBffS3/Ltu5JKCablvVPoWuSCBYcX2DSQ0SIIfGyRlVqyY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XoPUB/1E; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XoPUB/1E"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 017EE1F00893;
	Thu, 24 Sep 2026 17:10:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269822;
	bh=hlk/lCkmg3mIZ1lH7WWItQA++bMVra6NgPH2PhXihu4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XoPUB/1EPOe5JLs/dDjR+ZSAtlRDZSsGo/uiqqK8Pt+dilh0JLT0SXP3D+Iwy8tcM
	 Fr+SNAefoqY+Q06v32Ww47KZo+MMPZWn+IRlRlrE3RXVIZlvS2L41V8p2M8540eIt2
	 aG3yWVoi7b4tvBBQLayOs1esjrFAlZF8dN/1V5WrLW2G5KVA1iFfQjj0aOSNjrDeyh
	 glxYQ6M59g6JOBF1SVnv00XVmJVqn4GkNLg75pabZLcwI+Eq2eNGlsN+WGed3iVlsA
	 nBVgbvLO0Nte5LDsxrtiTnuSoCmjU9cyW1wBh4TettCU3DNG/YY7E4vybocci0ZdTz
	 7DQJbZPfEdVAg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 09/33] NFSD: Use xdrgen XDR functions for NFSv3 SETATTR procedure
Date: Thu, 24 Sep 2026 13:09:48 -0400
Message-ID: <20260924171012.3978-10-cel@kernel.org>
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

Replace the NFSPROC3_SETATTR entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_SETATTR3args and nfs_svc_encode_SETATTR3res. A
wrapper structure bridges the generated xdrgen argument type and
the legacy svc_fh and iattr representations the NFSD VFS layer
still uses; the result uses the generated SETATTR3res type
directly. The new nfsd3_sattr3_to_iattr() and
nfsd3_nfstime3_to_timespec64() helpers translate the decoded
sattr3 into the iattr that nfsd_setattr() consumes, and
nfsd3_fill_wcc_data() assembles the weak cache consistency data
that both the success and failure results carry.

When an operation leaves no post-op attributes saved,
svcxdr_encode_wcc_data() omits the pre-op attributes and fetches fresh
post-op attributes instead. nfsd3_fill_wcc_data() keeps that behavior
through a new nfsd3_fill_post_op_attr() helper, which later procedures
also use to fill in post-op attributes.

The pc_argzero field is now set to zero for the NFSv3 SETATTR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_setattr() now assembles the WCC data, that
work moves out of the XDR result encoder, and the reference to
the file handle can be released directly by nfsd3_proc_setattr().
A separate ->pc_release callback is thus no longer needed. This
makes it straightforward to confirm that the file handle is
properly released during every error flow.

nfs3svc_decode_sattrargs() no longer has any callers, so it and
its svcxdr_decode_sattrguard3() helper are removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 211 ++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs3xdr.c  |  27 ------
 fs/nfsd/xdr3.h     |   8 --
 3 files changed, 179 insertions(+), 67 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 1facaccf408b..815722afde9a 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -47,6 +47,15 @@ struct GETATTR3res_wrapper {
 
 static_assert(offsetof(struct GETATTR3res_wrapper, xdrgen) == 0);
 
+struct SETATTR3args_wrapper {
+	struct SETATTR3args	xdrgen;
+	struct svc_fh		fh;
+	struct iattr		iattrs;
+	struct timespec64	guard;
+};
+
+static_assert(offsetof(struct SETATTR3args_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -186,6 +195,14 @@ nfsd3_mode_to_ftype3(umode_t mode)
 	return NF3REG;
 }
 
+static __always_inline void
+nfsd3_nfstime3_to_timespec64(struct timespec64 *dst,
+			     const struct nfstime3 *src)
+{
+	dst->tv_sec = src->seconds;
+	dst->tv_nsec = src->nseconds;
+}
+
 static void
 nfsd3_stat_to_fattr3(struct svc_rqst *rqstp, struct fattr3 *fattr,
 		     const struct kstat *stat, const struct svc_fh *fhp)
@@ -223,6 +240,121 @@ nfsd3_stat_to_fattr3(struct svc_rqst *rqstp, struct fattr3 *fattr,
 	nfsd3_timespec64_to_nfstime3(&fattr->ctime, &stat->ctime);
 }
 
+static void
+nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
+			struct svc_fh *fhp);
+
+static void
+nfsd3_fill_wcc_data(struct svc_rqst *rqstp, struct wcc_data *wcc,
+		    struct svc_fh *fhp)
+{
+	/* Pre-op attributes are of no use to the client without post-op ones */
+	if (!fhp->fh_post_saved) {
+		wcc->before.attributes_follow = false;
+		nfsd3_fill_post_op_attr(rqstp, &wcc->after, fhp);
+		return;
+	}
+
+	wcc->before.attributes_follow = fhp->fh_pre_saved;
+	if (fhp->fh_pre_saved) {
+		struct wcc_attr *wattr = &wcc->before.u.attributes;
+
+		wattr->size = fhp->fh_pre_size;
+		nfsd3_timespec64_to_nfstime3(&wattr->mtime, &fhp->fh_pre_mtime);
+		nfsd3_timespec64_to_nfstime3(&wattr->ctime, &fhp->fh_pre_ctime);
+	}
+
+	wcc->after.attributes_follow = true;
+	nfsd3_stat_to_fattr3(rqstp, &wcc->after.u.attributes,
+			     &fhp->fh_post_attr, fhp);
+}
+
+static void
+nfsd3_sattr3_to_iattr(struct svc_rqst *rqstp, struct iattr *iap,
+		      const struct sattr3 *sattr)
+{
+	/* trace_nfsd_vfs_setattr() records fields ia_valid leaves unset */
+	memset(iap, 0, sizeof(*iap));
+
+	if (sattr->mode.set_it) {
+		iap->ia_valid |= ATTR_MODE;
+		iap->ia_mode = sattr->mode.u.mode;
+	}
+	if (sattr->uid.set_it) {
+		iap->ia_uid = make_kuid(nfsd_user_namespace(rqstp),
+					sattr->uid.u.uid);
+		if (uid_valid(iap->ia_uid))
+			iap->ia_valid |= ATTR_UID;
+	}
+	if (sattr->gid.set_it) {
+		iap->ia_gid = make_kgid(nfsd_user_namespace(rqstp),
+					sattr->gid.u.gid);
+		if (gid_valid(iap->ia_gid))
+			iap->ia_valid |= ATTR_GID;
+	}
+	if (sattr->size.set_it) {
+		iap->ia_valid |= ATTR_SIZE;
+		iap->ia_size = sattr->size.u.size;
+	}
+	switch (sattr->atime.set_it) {
+	case DONT_CHANGE:
+		break;
+	case SET_TO_SERVER_TIME:
+		iap->ia_valid |= ATTR_ATIME;
+		break;
+	case SET_TO_CLIENT_TIME:
+		nfsd3_nfstime3_to_timespec64(&iap->ia_atime,
+					     &sattr->atime.u.atime);
+		iap->ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
+		break;
+	}
+	switch (sattr->mtime.set_it) {
+	case DONT_CHANGE:
+		break;
+	case SET_TO_SERVER_TIME:
+		iap->ia_valid |= ATTR_MTIME;
+		break;
+	case SET_TO_CLIENT_TIME:
+		nfsd3_nfstime3_to_timespec64(&iap->ia_mtime,
+					     &sattr->mtime.u.mtime);
+		iap->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
+		break;
+	}
+}
+
+/*
+ * struct kstat is pretty huge. To reduce stack utilization, reuse @fhp's
+ * fh_post_attr field as the stat buffer passed to fh_getattr.
+ *
+ * This is safe to do as long as proc functions that need both WCC and
+ * post_op_attrs invoke nfsd3_fill_wcc_data() before invoking
+ * nfsd3_fill_post_op_attr() on the same fhp argument.
+ */
+static void
+nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
+			struct svc_fh *fhp)
+{
+	struct kstat *statp = &fhp->fh_post_attr;
+	struct dentry *dentry = fhp->fh_dentry;
+
+	/*
+	 * The inode may be NULL if the call failed because of a stale
+	 * file handle. In this case, no attributes are returned.
+	 */
+	if (fhp->fh_no_wcc || !dentry || !d_really_is_positive(dentry))
+		goto no_post_op_attrs;
+	if (fh_getattr(fhp, statp) != nfs_ok)
+		goto no_post_op_attrs;
+
+	attr->attributes_follow = true;
+	lease_get_mtime(d_inode(dentry), &statp->mtime);
+	nfsd3_stat_to_fattr3(rqstp, &attr->u.attributes, statp, fhp);
+	return;
+
+no_post_op_attrs:
+	attr->attributes_follow = false;
+}
+
 /*
  * A full specification of each of the following NFSv3 procedures is
  * available in RFC 1813 Section 3.3.
@@ -282,32 +414,47 @@ static __be32 nfsd3_proc_getattr(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Set a file's attributes
+/**
+ * nfsd3_proc_setattr - SETATTR: Set file attributes
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   SETATTR3res NFSPROC3_SETATTR(SETATTR3args) = 2;
  */
-static __be32
-nfsd3_proc_setattr(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_setattr(struct svc_rqst *rqstp)
 {
-	struct nfsd3_sattrargs *argp = rqstp->rq_argp;
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
-	struct nfsd_attrs attrs = {
-		.na_iattr	= &argp->attrs,
-	};
+	struct SETATTR3args_wrapper *argp = rqstp->rq_argp;
+	struct SETATTR3res *resp = rqstp->rq_resp;
 	const struct timespec64 *guardtime = NULL;
+	struct svc_fh *fhp = &argp->fh;
+	struct nfsd_attrs nattrs = {
+		.na_iattr	= &argp->iattrs,
+	};
 
-	dprintk("nfsd: SETATTR(3)  %s\n",
-				SVCFH_fmt(&argp->fh));
-
-	fh_copy(&resp->fh, &argp->fh);
-	if (!nfsd3_time_in_range(&argp->attrs)) {
-		resp->status = nfserr_inval;
-		goto out;
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.object);
+	nfsd3_sattr3_to_iattr(rqstp, &argp->iattrs, &argp->xdrgen.new_attributes);
+	if (argp->xdrgen.guard.check) {
+		nfsd3_nfstime3_to_timespec64(&argp->guard,
+					     &argp->xdrgen.guard.u.obj_ctime);
+		guardtime = &argp->guard;
 	}
-	if (argp->check_guard)
-		guardtime = &argp->guardtime;
-	resp->status = nfsd_setattr(rqstp, &resp->fh, &attrs, guardtime);
-out:
-	resp->status = nfsd3_map_status(resp->status);
+
+	if (nfsd3_time_in_range(&argp->iattrs))
+		resp->status = nfsd_setattr(rqstp, fhp, &nattrs, guardtime);
+	else
+		resp->status = nfserr_inval;
+
+	if (resp->status == nfs_ok) {
+		nfsd3_fill_wcc_data(rqstp, &resp->u.resok.obj_wcc, fhp);
+	} else {
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_wcc_data(rqstp, &resp->u.resfail.obj_wcc, fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1066,16 +1213,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "GETATTR",
 	},
 	[NFSPROC3_SETATTR] = {
-		.pc_func = nfsd3_proc_setattr,
-		.pc_decode = nfs3svc_decode_sattrargs,
-		.pc_encode = nfs3svc_encode_wccstatres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_sattrargs),
-		.pc_argzero = sizeof(struct nfsd3_sattrargs),
-		.pc_ressize = sizeof(struct nfsd3_wccstatres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+WC,
-		.pc_name = "SETATTR",
+		.pc_func	= nfsd3_proc_setattr,
+		.pc_decode	= nfs_svc_decode_SETATTR3args,
+		.pc_encode	= nfs_svc_encode_SETATTR3res,
+		.pc_argsize	= sizeof(struct SETATTR3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct SETATTR3res),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_SETATTR3res_sz,
+		.pc_name	= "SETATTR",
 	},
 	[NFSPROC3_LOOKUP] = {
 		.pc_func = nfsd3_proc_lookup,
@@ -1308,7 +1454,8 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 union nfsd3_xdrstore {
 	struct GETATTR3args_wrapper	getattrargs;
 	struct GETATTR3res_wrapper	getattrres;
-	struct nfsd3_sattrargs		sattrargs;
+	struct SETATTR3args_wrapper	setattrargs;
+	struct SETATTR3res		setattrres;
 	struct nfsd3_diropargs		diropargs;
 	struct nfsd3_readargs		readargs;
 	struct nfsd3_writeargs		writeargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 5802208f96b7..eb5f3148a0ab 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -295,23 +295,6 @@ svcxdr_decode_sattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	return true;
 }
 
-static bool
-svcxdr_decode_sattrguard3(struct xdr_stream *xdr, struct nfsd3_sattrargs *args)
-{
-	u32 check;
-
-	if (xdr_stream_decode_bool(xdr, &check) < 0)
-		return false;
-	if (check) {
-		if (!svcxdr_decode_nfstime3(xdr, &args->guardtime))
-			return false;
-		args->check_guard = 1;
-	} else
-		args->check_guard = 0;
-
-	return true;
-}
-
 static bool
 svcxdr_decode_specdata3(struct xdr_stream *xdr, struct nfsd3_mknodargs *args)
 {
@@ -499,16 +482,6 @@ nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_nfs_fh3(xdr, &args->fh);
 }
 
-bool
-nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_sattrargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_nfs_fh3(xdr, &args->fh) &&
-		svcxdr_decode_sattr3(rqstp, xdr, &args->attrs) &&
-		svcxdr_decode_sattrguard3(xdr, args);
-}
-
 bool
 nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 2dcd36160ced..354cff178b75 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -18,13 +18,6 @@
 #define NFS3_MAXNAMLEN			NAME_MAX
 #define NFS3_MAXPATHLEN			PATH_MAX
 
-struct nfsd3_sattrargs {
-	struct svc_fh		fh;
-	struct iattr		attrs;
-	int			check_guard;
-	struct timespec64	guardtime;
-};
-
 struct nfsd3_diropargs {
 	struct svc_fh		fh;
 	char *			name;
@@ -244,7 +237,6 @@ struct nfsd3_fhandle_pair {
 };
 
 bool nfs3svc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_accessargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0

