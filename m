Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54B725964FA
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576169; cv=none; b=b8kFE8eguBytljBDGAN3cByF6jou6w6cz/7f11VkLBhw5pt7XKwBdInBDsArKhUqVtf6/UqvV/Z3uXG02EpFJt9yptw6BYVyUkP7Zw6xPSjCtBWVEZaORFfZGPt5r5v9ztq2pFs+CSp9Dis29hsD/s5/rLLYzn+Ix81ls9vgmW0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576169; c=relaxed/simple;
	bh=IadMS1IApwckrHRnTV02wzbpEsjnBllOKTpSfW7l0g4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=t3RwShwx5pcbqPyV7rYAeotEAUxag4uDv4idbMFBy1+jJpT++LB2zLZgcDNYo6WKr+Ha/0JWufSJPGeGT+q7Fl3e6PYTfwVhWMLOQ5JhQFDmnee/hL5Mn3V29dAXikx+VmZsEfdGgZ61B6iXI/O/XdW/kMDIC9WkgMlxSnwL5fc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a0k0rMF/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a0k0rMF/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B64221F000FF;
	Wed, 16 Sep 2026 16:29:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576165;
	bh=zb2H+J+OyhQuC/DwA9c6lHWbTLxm9zt0ZmvATcvCiwo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=a0k0rMF/RbhZz8RqKMxqMHeyNAMLaZFR+XDaAZ6BLi8pGE48aeeCxuyFNr1XryEyB
	 mySE10CpAKNLGC2b0jzPQdx1lXd5RgpK8vqXV4Y97wX5KSk9ZBM66XN5meoHaGS7by
	 /3bEC3w97gbvLH3/821Z7gO3L3lutHBrX95pMifwquu8F3cAwitZcNOPVx/3eI5lDM
	 0FnENaqVYCWEHr+f4HZ9mKaen3KXXQbIBcGOJ3VyH7s2LInqE5Wc10ZwEM/IWYFtYm
	 LRbe6NTWTCt5jC9h+RznEhJWa9sF2U+XCe+PyPZtaDjIOhQlOTJUVETQ5oLDrsW0P/
	 jZfYt7j5fHuIA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 21/27] NFSD: Use xdrgen XDR functions for NFSv2 MKDIR procedure
Date: Wed, 16 Sep 2026 12:28:52 -0400
Message-ID: <20260916162859.2051-24-cel@kernel.org>
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

Replace the NFSPROC_MKDIR entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_createargs and nfs_svc_encode_diropres. MKDIR
reuses the createargs and diropres wrapper structures introduced
for the CREATE conversion, which bridge the generated xdrgen
types and the legacy svc_fh, iattr, and kstat representations the
NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 MKDIR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

This refactor replaces the use of svcxdr_encode_fattr(), so the
references to the parent directory and the new object file
handles can be released directly by nfsd_proc_mkdir(). A separate
->pc_release callback is thus no longer needed. This makes it
straightforward to confirm that the file handles are properly
released during every error flow.

With CREATE and MKDIR both converted, nfssvc_decode_createargs(),
nfssvc_encode_diropres(), and nfssvc_release_diropres() no longer
have any callers, so they are removed, along with the
svcxdr_decode_sattr() and svcxdr_encode_fhandle() helpers they
relied on. The now-unused nfsd_createargs and nfsd_diropres
structures are removed as well.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c |  80 ++++++++++++++++-----------
 fs/nfsd/nfsxdr.c  | 134 ----------------------------------------------
 fs/nfsd/xdr.h     |  16 ------
 3 files changed, 49 insertions(+), 181 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 830d90d0ef9e..8317029850c9 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -1030,35 +1030,55 @@ static __be32 nfsd_proc_symlink(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Make directory. This operation is not idempotent.
- * N.B. After this call resp->fh needs an fh_put
+/**
+ * nfsd_proc_mkdir - MKDIR: Create a directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   diropres NFSPROC_MKDIR(createargs) = 14;
  */
-static __be32
-nfsd_proc_mkdir(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_mkdir(struct svc_rqst *rqstp)
 {
-	struct nfsd_createargs *argp = rqstp->rq_argp;
-	struct nfsd_diropres *resp = rqstp->rq_resp;
-	struct nfsd_attrs attrs = {
-		.na_iattr	= &argp->attrs,
+	struct createargs_wrapper *argp = rqstp->rq_argp;
+	struct diropargs *where = &argp->xdrgen.where;
+	struct diropres_wrapper *resp = rqstp->rq_resp;
+	struct kstat *statp = &resp->stat;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
+	struct nfsd_attrs nattrs = {
+		.na_iattr	= &argp->iattrs,
 	};
 
-	if (resp->fh.fh_dentry) {
-		printk(KERN_WARNING
-			"nfsd_proc_mkdir: response already verified??\n");
+	nfsd_fhandle_to_svc_fh(dirfhp, &where->dir);
+	fh_init(fhp, NFS_FHSIZE);
+	if (!nfsd_sattr_to_iattr(rqstp, &argp->iattrs, &argp->xdrgen.attributes)) {
+		resp->xdrgen.status = nfserr_io;
+		goto out;
 	}
 
-	argp->attrs.ia_valid &= ~ATTR_SIZE;
-	fh_init(&resp->fh, NFS_FHSIZE);
-	resp->status = nfsd_create(rqstp, &argp->fh, argp->name, argp->len,
-				   &attrs, S_IFDIR, 0, &resp->fh);
-	fh_put(&argp->fh);
-	if (resp->status != nfs_ok)
+	argp->iattrs.ia_valid &= ~ATTR_SIZE;
+	resp->xdrgen.status = nfsd_create(rqstp, dirfhp,
+					  (char *)where->name.data,
+					  where->name.len, &nattrs,
+					  S_IFDIR, 0, fhp);
+	if (resp->xdrgen.status != nfs_ok)
 		goto out;
+	resp->xdrgen.status = fh_getattr(fhp, statp);
 
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
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
 
@@ -1303,16 +1323,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "SYMLINK",
 	},
 	[NFSPROC_MKDIR] = {
-		.pc_func = nfsd_proc_mkdir,
-		.pc_decode = nfssvc_decode_createargs,
-		.pc_encode = nfssvc_encode_diropres,
-		.pc_release = nfssvc_release_diropres,
-		.pc_argsize = sizeof(struct nfsd_createargs),
-		.pc_argzero = sizeof(struct nfsd_createargs),
-		.pc_ressize = sizeof(struct nfsd_diropres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+FH+AT,
-		.pc_name = "MKDIR",
+		.pc_func	= nfsd_proc_mkdir,
+		.pc_decode	= nfs_svc_decode_createargs,
+		.pc_encode	= nfs_svc_encode_diropres,
+		.pc_argsize	= sizeof(struct createargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct diropres_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS2_diropres_sz,
+		.pc_name	= "MKDIR",
 	},
 	[NFSPROC_RMDIR] = {
 		.pc_func = nfsd_proc_rmdir,
@@ -1361,7 +1380,6 @@ union nfsd_xdrstore {
 	struct renameargs_wrapper	renameargs;
 	struct linkargs_wrapper		linkargs;
 	struct symlinkargs_wrapper	symlinkargs;
-	struct nfsd_readdirargs	readdir;
 	struct attrstat_wrapper		attrstat;
 	struct diropres_wrapper		diropres;
 	struct readlinkres	readlinkres;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index eb87ee218f12..8989957a94e0 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -13,16 +13,6 @@
 #include "nfs2xdr_gen.h"
 #include "auth.h"
 
-/*
- * Sun convention: a sattr time-useconds field of one full second (an
- * otherwise out-of-range value) means "set this time to the current
- * server time." It's needed to make permissions checks for the "touch"
- * program across NFSv2 mounts work correctly. See description of
- * sattr in section 6.1 of "NFS Illustrated" by Brent Callaghan,
- * Addison-Wesley, ISBN 0-201-32750-5
- */
-#define NFS2_SATTR_SET_TO_SERVER_TIME	(1000000)
-
 /*
  * Linux-internal ftype values for socket and unknown inodes, not
  * in RFC 1094's wire enum; values match enum nfs_ftype.
@@ -91,19 +81,6 @@ svcxdr_decode_fhandle(struct xdr_stream *xdr, struct svc_fh *fhp)
 	return true;
 }
 
-static bool
-svcxdr_encode_fhandle(struct xdr_stream *xdr, const struct svc_fh *fhp)
-{
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, NFS_FHSIZE);
-	if (!p)
-		return false;
-	memcpy(p, &fhp->fh_handle.fh_raw, NFS_FHSIZE);
-
-	return true;
-}
-
 static __be32 *
 encode_timeval(__be32 *p, const struct timespec64 *time)
 {
@@ -147,81 +124,6 @@ svcxdr_decode_diropargs(struct xdr_stream *xdr, struct svc_fh *fhp,
 		svcxdr_decode_filename(xdr, name, len);
 }
 
-static bool
-svcxdr_decode_sattr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-		    struct iattr *iap)
-{
-	u32 tmp1, tmp2;
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, XDR_UNIT * 8);
-	if (!p)
-		return false;
-
-	iap->ia_valid = 0;
-
-	/*
-	 * Some Sun clients put 0xffff in the mode field when they
-	 * mean 0xffffffff.
-	 */
-	tmp1 = be32_to_cpup(p++);
-	if (tmp1 != (u32)-1 && tmp1 != 0xffff) {
-		iap->ia_valid |= ATTR_MODE;
-		iap->ia_mode = tmp1;
-	}
-
-	tmp1 = be32_to_cpup(p++);
-	if (tmp1 != (u32)-1) {
-		iap->ia_uid = make_kuid(nfsd_user_namespace(rqstp), tmp1);
-		if (uid_valid(iap->ia_uid))
-			iap->ia_valid |= ATTR_UID;
-	}
-
-	tmp1 = be32_to_cpup(p++);
-	if (tmp1 != (u32)-1) {
-		iap->ia_gid = make_kgid(nfsd_user_namespace(rqstp), tmp1);
-		if (gid_valid(iap->ia_gid))
-			iap->ia_valid |= ATTR_GID;
-	}
-
-	tmp1 = be32_to_cpup(p++);
-	if (tmp1 != (u32)-1) {
-		iap->ia_valid |= ATTR_SIZE;
-		iap->ia_size = tmp1;
-	}
-
-	tmp1 = be32_to_cpup(p++);
-	tmp2 = be32_to_cpup(p++);
-	if (tmp1 != (u32)-1 && tmp2 != (u32)-1) {
-		/*
-		 * Range test here to prevent the multiplication from
-		 * wrapping to a valid (but incorrect) value on 32-bit
-		 * platforms.
-		 */
-		if (tmp2 > NFS2_SATTR_SET_TO_SERVER_TIME)
-			return false;
-		iap->ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
-		iap->ia_atime.tv_sec = tmp1;
-		iap->ia_atime.tv_nsec = tmp2 * NSEC_PER_USEC;
-		if (tmp2 == NFS2_SATTR_SET_TO_SERVER_TIME)
-			iap->ia_valid &= ~ATTR_ATIME_SET;
-	}
-
-	tmp1 = be32_to_cpup(p++);
-	tmp2 = be32_to_cpup(p++);
-	if (tmp1 != (u32)-1 && tmp2 != (u32)-1) {
-		if (tmp2 > NFS2_SATTR_SET_TO_SERVER_TIME)
-			return false;
-		iap->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
-		iap->ia_mtime.tv_sec = tmp1;
-		iap->ia_mtime.tv_nsec = tmp2 * NSEC_PER_USEC;
-		if (tmp2 == NFS2_SATTR_SET_TO_SERVER_TIME)
-			iap->ia_valid &= ~(ATTR_ATIME_SET|ATTR_MTIME_SET);
-	}
-
-	return true;
-}
-
 /**
  * svcxdr_encode_fattr - Encode NFSv2 file attributes
  * @rqstp: Context of a completed RPC transaction
@@ -311,16 +213,6 @@ nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_createargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_diropargs(xdr, &args->fh,
-				       &args->name, &args->len) &&
-		svcxdr_decode_sattr(rqstp, xdr, &args->attrs);
-}
-
 bool
 nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -365,25 +257,6 @@ nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return true;
 }
 
-bool
-nfssvc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_diropres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_stat(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_fhandle(xdr, &resp->fh))
-			return false;
-		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
-			return false;
-		break;
-	}
-
-	return true;
-}
-
 bool
 nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -528,10 +401,3 @@ void nfssvc_release_attrstat(struct svc_rqst *rqstp)
 
 	fh_put(&resp->fh);
 }
-
-void nfssvc_release_diropres(struct svc_rqst *rqstp)
-{
-	struct nfsd_diropres *resp = rqstp->rq_resp;
-
-	fh_put(&resp->fh);
-}
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index eeea28caf19d..bd3123179f61 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -14,13 +14,6 @@ struct nfsd_diropargs {
 	unsigned int		len;
 };
 
-struct nfsd_createargs {
-	struct svc_fh		fh;
-	char *			name;
-	unsigned int		len;
-	struct iattr		attrs;
-};
-
 struct nfsd_readdirargs {
 	struct svc_fh		fh;
 	__u32			cookie;
@@ -37,12 +30,6 @@ struct nfsd_attrstat {
 	struct kstat		stat;
 };
 
-struct nfsd_diropres  {
-	__be32			status;
-	struct svc_fh		fh;
-	struct kstat		stat;
-};
-
 struct nfsd_readdirres {
 	/* Components of the reply */
 	__be32			status;
@@ -63,12 +50,10 @@ struct nfsd_statfsres {
 
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfssvc_encode_statres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
@@ -77,7 +62,6 @@ int nfssvc_encode_entry(void *data, const char *name, int namlen,
 			loff_t offset, u64 ino, unsigned int d_type);
 
 void nfssvc_release_attrstat(struct svc_rqst *rqstp);
-void nfssvc_release_diropres(struct svc_rqst *rqstp);
 
 /* Helper functions for NFSv2 ACL code */
 bool svcxdr_decode_fhandle(struct xdr_stream *xdr, struct svc_fh *fhp);
-- 
2.55.0

