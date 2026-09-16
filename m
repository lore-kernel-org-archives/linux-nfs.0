Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57B5C55D886
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576151; cv=none; b=Zov+rrNP+6xnCfu+JTVG9n2w5DpofngJ/3+Oj4h/QM99rfDQpgqAphkT+aP8zj8Fleo8bRxmX0RPuzDmKR4FlX5VIE/0WXNvBOr9icV+MSe1UP/d46uaSlz2aVMZ9Gy/dTtsTmmID/EysfuqBoZkuhSZhwh686rxGYjlraJk/vo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576151; c=relaxed/simple;
	bh=Cj3fpTyaEk/0zICZK4gUBr3Cos3EyBTIHy05Wb50lAs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aVG4QdERqoNw00fpLmaht4KML+B/82pU01FHfLIXnggGgPgboeNtPn9+A1sSfPFECNdOWb0ZDY2NBUoUfRr/IJyIFRIMbN/AUcqtGgp6piq+VBr7EpB8TsCym3DbOD/JJ+gzHsUX/Oy96nYACKT8saMVE49hejgobMS781Eb0rA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ec/93FmD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ec/93FmD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B5E251F000FF;
	Wed, 16 Sep 2026 16:29:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576148;
	bh=wNAM+EBovEHIkwLAonc2/U4jXRjrHqcNtvxNCng/ZZs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Ec/93FmD5NOckf1gDxDEtEBTBBfJ5BrH+h73zQuvbFDybs76MpS9ZqoFUh3umj8eY
	 yl9PvPrDEsjt/Mz8aLr18n03EqE4L/9oQ/RucwF4PfbYBahd/dJZmtK6feJVhttUt8
	 qgdYYDuJWUKUgTrkm4N8OYy7dqgkZCpUVxgLYaA0kRr5nIc/+S71IKbeIIbySJ6NLk
	 S4H4N983DG+Tz9lVNNYeq099nqYW/HjNtl3qzOTJZSce5yU3V1RqvKYRvw+09J4GtE
	 kaHZVq0bX8qdfwq/RDFj2Hlh2hcxPwZ8MhE+EGIhb2IrONdzLGPrXzwQM63v1FijiT
	 bUyLs1iqcb5cg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 08/27] NFSD: Use xdrgen XDR functions for NFSv2 SETATTR procedure
Date: Wed, 16 Sep 2026 12:28:39 -0400
Message-ID: <20260916162859.2051-11-cel@kernel.org>
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

Replace the NFSPROC_SETATTR entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_sattrargs and nfs_svc_encode_attrstat. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh, iattr, and kstat representations the NFSD VFS layer still
uses. The result reuses the attrstat wrapper from the GETATTR
conversion; the new nfsd_sattr_to_iattr() and
nfsd_timeval_to_timespec64() helpers translate the decoded sattr
into the iattr that nfsd_setattr() consumes.

The hand-coded svcxdr_decode_sattr() rejects a time-useconds value
greater than one second before converting it, preventing the
microsecond-to-nanosecond multiplication from wrapping to a valid
but incorrect value on 32-bit platforms. nfsd_sattr_to_iattr()
preserves that range check. Because it runs after the generated
decoder rather than inside it, an out-of-range value fails the
procedure with nfserr_io rather than the RPC GARBAGE_ARGS the
hand-coded decoder returned.

The pc_argzero field is now set to zero for the NFSv2 SETATTR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed. The wrapper's iattr is one of them: nfsd_sattr_to_iattr()
zeroes the whole structure rather than only ia_valid, because the
nfsd_vfs_setattr tracepoint records ia_size, ia_uid, and ia_gid
whether or not their ATTR bits are set.

This refactor replaces the use of svcxdr_encode_fattr(), so the
reference to the file handle can be released directly by
nfsd_proc_setattr(). A separate ->pc_release callback is thus no
longer needed. This makes it straightforward to confirm that the
file handle is properly released during every error flow.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 165 ++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfsxdr.c  |   9 ---
 fs/nfsd/xdr.h     |   6 --
 3 files changed, 131 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0196a554de5e..7fb5895f24d5 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -40,6 +40,14 @@ struct attrstat_wrapper {
 
 static_assert(offsetof(struct attrstat_wrapper, xdrgen) == 0);
 
+struct sattrargs_wrapper {
+	struct sattrargs	xdrgen;
+	struct svc_fh		fh;
+	struct iattr		iattrs;
+};
+
+static_assert(offsetof(struct sattrargs_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -81,6 +89,13 @@ nfsd_timespec64_to_timeval(struct timeval *dst,
 	dst->useconds = src->tv_nsec / NSEC_PER_USEC;
 }
 
+static __always_inline void
+nfsd_timeval_to_timespec64(struct timespec64 *dst, const struct timeval *src)
+{
+	dst->tv_sec = src->seconds;
+	dst->tv_nsec = src->useconds * NSEC_PER_USEC;
+}
+
 static u32
 nfsd_mode_to_ftype(umode_t mode)
 {
@@ -162,6 +177,76 @@ static __be32 nfsd_map_io_status(__be32 status)
 	return nfsd_map_status(status);
 }
 
+/*
+ * Sun convention: a sattr time-useconds field of one full second (an
+ * otherwise out-of-range value) means "set this time to the current
+ * server time." It's needed to make permissions checks for the "touch"
+ * program across NFSv2 mounts work correctly. See description of
+ * sattr in section 6.1 of "NFS Illustrated" by Brent Callaghan,
+ * Addison-Wesley, ISBN 0-201-32750-5
+ */
+#define NFS2_SATTR_SET_TO_SERVER_TIME	(1000000)
+
+static bool
+nfsd_sattr_to_iattr(struct svc_rqst *rqstp, struct iattr *iap,
+		    const struct sattr *sattr)
+{
+	static const unsigned int dont_set_it = (unsigned int)-1;
+
+	/* Consumers read ia_size, ia_uid, and ia_gid unguarded by ia_valid */
+	memset(iap, 0, sizeof(*iap));
+
+	/*
+	 * Some Sun NFS clients put 0xffff in the mode field when they
+	 * mean 0xffffffff.
+	 */
+	if (sattr->mode != dont_set_it && sattr->mode != 0xffff) {
+		iap->ia_valid |= ATTR_MODE;
+		iap->ia_mode = sattr->mode;
+	}
+	if (sattr->uid != dont_set_it) {
+		iap->ia_uid = make_kuid(nfsd_user_namespace(rqstp), sattr->uid);
+		if (uid_valid(iap->ia_uid))
+			iap->ia_valid |= ATTR_UID;
+	}
+	if (sattr->gid != dont_set_it) {
+		iap->ia_gid = make_kgid(nfsd_user_namespace(rqstp), sattr->gid);
+		if (gid_valid(iap->ia_gid))
+			iap->ia_valid |= ATTR_GID;
+	}
+	if (sattr->size != dont_set_it) {
+		iap->ia_valid |= ATTR_SIZE;
+		iap->ia_size = sattr->size;
+	}
+	if (sattr->atime.seconds != dont_set_it &&
+	    sattr->atime.useconds != dont_set_it) {
+		/*
+		 * Reject out-of-range useconds so the conversion to
+		 * nanoseconds cannot wrap to a valid but incorrect
+		 * value on 32-bit platforms.
+		 */
+		if (sattr->atime.useconds > NFS2_SATTR_SET_TO_SERVER_TIME)
+			return false;
+		iap->ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
+		nfsd_timeval_to_timespec64(&iap->ia_atime, &sattr->atime);
+
+		if (sattr->atime.useconds == NFS2_SATTR_SET_TO_SERVER_TIME)
+			iap->ia_valid &= ~ATTR_ATIME_SET;
+	}
+	if (sattr->mtime.seconds != dont_set_it &&
+	    sattr->mtime.useconds != dont_set_it) {
+		if (sattr->mtime.useconds > NFS2_SATTR_SET_TO_SERVER_TIME)
+			return false;
+		iap->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
+		nfsd_timeval_to_timespec64(&iap->ia_mtime, &sattr->mtime);
+
+		if (sattr->mtime.useconds == NFS2_SATTR_SET_TO_SERVER_TIME)
+			iap->ia_valid &= ~(ATTR_ATIME_SET | ATTR_MTIME_SET);
+	}
+
+	return true;
+}
+
 /*
  * A full specification of each of the following NFSv2 procedures is
  * available in RFC 1094 Section 2.2.
@@ -218,27 +303,32 @@ static __be32 nfsd_proc_getattr(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Set a file's attributes
- * N.B. After this call resp->fh needs an fh_put
+/**
+ * nfsd_proc_setattr - SETATTR: Set file attributes
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   attrstat NFSPROC_SETATTR(sattrargs) = 2;
  */
-static __be32
-nfsd_proc_setattr(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_setattr(struct svc_rqst *rqstp)
 {
-	struct nfsd_sattrargs *argp = rqstp->rq_argp;
-	struct nfsd_attrstat *resp = rqstp->rq_resp;
-	struct iattr *iap = &argp->attrs;
-	struct nfsd_attrs attrs = {
+	struct sattrargs_wrapper *argp = rqstp->rq_argp;
+	struct attrstat_wrapper *resp = rqstp->rq_resp;
+	struct kstat *statp = &resp->stat;
+	struct iattr *iap = &argp->iattrs;
+	struct nfsd_attrs nattrs = {
 		.na_iattr	= iap,
 	};
-	struct svc_fh *fhp;
-	int hosterr;
+	struct svc_fh *fhp = &argp->fh;
 
-	dprintk("nfsd: SETATTR  %s, valid=%x, size=%ld\n",
-		SVCFH_fmt(&argp->fh),
-		argp->attrs.ia_valid, (long) argp->attrs.ia_size);
-
-	fhp = fh_copy(&resp->fh, &argp->fh);
+	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen.file);
+	if (!nfsd_sattr_to_iattr(rqstp, iap, &argp->xdrgen.attributes)) {
+		resp->xdrgen.status = nfserr_io;
+		goto out;
+	}
 
 	/*
 	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
@@ -255,6 +345,8 @@ nfsd_proc_setattr(struct svc_rqst *rqstp)
 #define	MAX_TOUCH_TIME_ERROR (30*60)
 	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
 	    iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec) {
+		int hosterr;
+
 		/*
 		 * Looks probable.
 		 *
@@ -264,13 +356,13 @@ nfsd_proc_setattr(struct svc_rqst *rqstp)
 		 */
 		time64_t delta = iap->ia_atime.tv_sec - ktime_get_real_seconds();
 
-		resp->status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
-		if (resp->status != nfs_ok)
+		resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
+		if (resp->xdrgen.status != nfs_ok)
 			goto out;
 
 		hosterr = fh_want_write(fhp);
 		if (hosterr) {
-			resp->status = nfserrno(hosterr);
+			resp->xdrgen.status = nfserrno(hosterr);
 			goto out;
 		}
 
@@ -287,13 +379,19 @@ nfsd_proc_setattr(struct svc_rqst *rqstp)
 		}
 	}
 
-	resp->status = nfsd_setattr(rqstp, fhp, &attrs, NULL);
-	if (resp->status != nfs_ok)
+	resp->xdrgen.status = nfsd_setattr(rqstp, fhp, &nattrs, NULL);
+	if (resp->xdrgen.status != nfs_ok)
 		goto out;
 
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
+	resp->xdrgen.status = fh_getattr(fhp, statp);
+
 out:
-	resp->status = nfsd_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok)
+		nfsd_stat_to_fattr(rqstp, &resp->xdrgen.u.attributes, statp, fhp);
+	else
+		resp->xdrgen.status = nfsd_map_status(resp->xdrgen.status);
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -827,16 +925,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "GETATTR",
 	},
 	[NFSPROC_SETATTR] = {
-		.pc_func = nfsd_proc_setattr,
-		.pc_decode = nfssvc_decode_sattrargs,
-		.pc_encode = nfssvc_encode_attrstatres,
-		.pc_release = nfssvc_release_attrstat,
-		.pc_argsize = sizeof(struct nfsd_sattrargs),
-		.pc_argzero = sizeof(struct nfsd_sattrargs),
-		.pc_ressize = sizeof(struct nfsd_attrstat),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+AT,
-		.pc_name = "SETATTR",
+		.pc_func	= nfsd_proc_setattr,
+		.pc_decode	= nfs_svc_decode_sattrargs,
+		.pc_encode	= nfs_svc_encode_attrstat,
+		.pc_argsize	= sizeof(struct sattrargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct attrstat_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS2_attrstat_sz,
+		.pc_name	= "SETATTR",
 	},
 	[NFSPROC_ROOT] = {
 		.pc_func = nfsd_proc_root,
@@ -1014,7 +1111,7 @@ static const struct svc_procedure nfsd_procedures2[18] = {
  */
 union nfsd_xdrstore {
 	struct fhandle_wrapper		fhandle;
-	struct nfsd_sattrargs	sattr;
+	struct sattrargs_wrapper	sattrargs;
 	struct nfsd_diropargs	dirop;
 	struct nfsd_readargs	read;
 	struct nfsd_writeargs	write;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index d55e7d6414a0..174e6f5622f9 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -302,15 +302,6 @@ nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_fhandle(xdr, &args->fh);
 }
 
-bool
-nfssvc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_sattrargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_fhandle(xdr, &args->fh) &&
-		svcxdr_decode_sattr(rqstp, xdr, &args->attrs);
-}
-
 bool
 nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 05b3a18c879a..9983fe212f3a 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -8,11 +8,6 @@
 
 #include "vfs.h"
 
-struct nfsd_sattrargs {
-	struct svc_fh		fh;
-	struct iattr		attrs;
-};
-
 struct nfsd_diropargs {
 	struct svc_fh		fh;
 	char *			name;
@@ -120,7 +115,6 @@ struct nfsd_statfsres {
 };
 
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0

