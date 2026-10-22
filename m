Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677236;
	b=z8YidadlU4qu9eEKnIDH83ji5gSUWb4HAM+gqodBItL4c2HwehOii2GwAjd5UNTb7xwX
	 Sksugu+DhSxuLO/CrMeRHSkkykApzN1CH5KgZg4DNDf1YPqVI90OYezcXmiSTJ8ueiP7b
	 NwBzT8WDnKLyHFQ4nKAun4mLLb4NZdJYhIEjuyDn03zPnJrbrfDQuOOxJchcuHy1TnJKI
	 z4KqpnuCHAkGL5SRk1/iiqGBjaI7DQGwJCaAlI73NyJFo0MPWBfZb0TAmqg+ka+x5GIu1
	 oMUbIIv0S56i1N2QceO0qTuveiQTb3gWFSrpIX9qp+OPZQmCNtHtOrva9BSM1YonhFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677236;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=q+iwvML/7qKIFl8PaIpQnLKBz//nA/l3DQqq25OMVQk=;
	b=vHWe1Zg5gR7goQw/4lA2xg8xEGRHUgN6Qc+KSsLmNjUlkhqWGhX8M0L7HWnG58IVK9Os
	 WKH/QHpDubg3KuSFQh7Oawszb9KRfirfwg/HhC7lmJWO9YHbodyLei3vbUV9bbfi8bw+F
	 I9P97up2y2o1uC/jPjNtSKpmX3EqeFvyOVlXxJOhXIE75gqvUjGo89rDBZQtZMnjVGuy+
	 d6lV3Pu70yBSH5dCYesYoP/s4vzgLBWoo8vgBzM+JBHxC8cdNYo8ahP3n8LVVfeyEw3NN
	 92mUDkSlGgoid7ZhTjtfyIvsEZWL+SaZdJypf5VErqG9V+uROnzDgDakwpvPxX4wibA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="ZVued/pz";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 031BD60A382D
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZVued/pz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B14E1F00ADF;
	Thu, 22 Oct 2026 13:53:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677235;
	bh=q+iwvML/7qKIFl8PaIpQnLKBz//nA/l3DQqq25OMVQk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZVued/pzpJPiCNXOZwalXFegJhoG9WC7QRah4zlo2w9YDwpV1sK9aYhKfpNVaAQL6
	 jt6x+aYfeq/uBgJuisOcoWW6UMIpkRHA0w9aXQXNiMfA5DsmDoTIdhTXoASlCtsJcd
	 n3zGTZG5KrS6FQCy6uKU2TxnCToYXGVsdUBPY/luyH0KKDg+s9weGa5eH0wasPRLCt
	 C4ljXWu0FgTq61HU/hdDsd4PwvsRp7wZJYPUOishfQL41ZlVpTTG8hMNVyi1FdACF/
	 7c4lSbpORW+8T0Y4Yv824VJKxiiV1qiGmOKnWDRAfq03MKlRVM3UIN8imYYKfmlWAf
	 XDML2UTZOx+qw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 13/17] NFSD: Use xdrgen XDR functions for the NFS-ACL v2 GETACL procedure
Date: Thu, 22 Oct 2026 09:53:37 -0400
Message-ID: <20261022135341.14265-14-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Convert the NFS-ACL version 2 GETACL procedure to xdrgen. The
argument decoder is now the generated nfs_acl_svc_decode_GETACL2args,
and the reply's status word and file attributes are emitted by the
generated xdrgen_encode_aclstat2() and xdrgen_encode_fattr(). Wrapper
structures bridge the generated GETACL2args and GETACL2res types and
the legacy svc_fh and posix_acl representations the NFSD VFS layer
still uses. The procedure's pc_argzero is zero because the generated
decoder initializes argp->xdrgen, making the earlier defensive memset
of the argument buffer unnecessary.

An undefined bit in the request mask now yields ACL2ERR_INVAL rather
than ACL2ERR_IO. draft-ietf-nfsv4-nfs-acl Section 4.6.2 permits a
server to respond with INVAL or to ignore the bit, and IO is neither;
the NFS_ACLv3 procedure already reports INVAL.

Only the two ACLs remain hand-written. They are built from the
object's struct posix_acl by nfs_stream_encode_acl(), a form the
generated encoder cannot express, so the generated secattr member of
GETACL2resok is left unused. As with the NFSv3 READ and READLINK
procedures, generated fixed-layout fields are followed by a
hand-written tail.

The procedure now fills the fattr and fetches the ACLs while the file
handle is verified, then releases the file handle itself. The encoder
reads the ACL owner ids from the captured attributes rather than from
a live inode, so nfsaclsvc_release_getacl() shrinks to the two
posix_acl_release() calls. Those releases must stay a release-time job
because the encoder still consumes the posix_acls after the reply is
built.

Filling the fattr reuses the NFSv2 GETATTR conversion's logic: the
mode is masked with S_IALLUGO, a socket reports the Linux-internal
NFSOCK value, and a FIFO reports NFCHR with an rdev of 0xffffffff,
the pairing the NFS client decodes as S_IFIFO. The wire result
matches what the NFSv2 GETATTR encoder already produces.

The generated <linux/sunrpc/xdrgen/nfs_acl.h> defines enum ftype,
which collides with the enum nfs_ftype in <uapi/linux/nfs.h> and with
the generated NFSv2 header, so neither can be included here. The
inherited NFSv2 constants this procedure needs, NFS_MAXPATHLEN and
NFSOCK, are defined locally instead.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 246 ++++++++++++++++++++++++++++------------------
 1 file changed, 151 insertions(+), 95 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 13e7415aa97b..8f0be7208e89 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -7,6 +7,7 @@
 
 #include <linux/gfp.h>
 #include <linux/fs.h>
+#include <linux/filelock.h>
 #include <linux/nfsacl.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
@@ -17,12 +18,21 @@
 
 #include "cache.h"
 #include "nfsd.h"
+#include "auth.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_PROC
 
 #define NFS_ACL_MASK		(NA_ACL | NA_ACLCNT | NA_DFACL | NA_DFACLCNT)
 
+/*
+ * The generated <linux/sunrpc/xdrgen/nfs_acl2.h> defines enum ftype, so
+ * <uapi/linux/nfs.h> (which also defines enum nfs_ftype with the same
+ * NFNON..NFLNK enumerators) and the generated nfs2 header cannot be
+ * included here. Define the inherited NFSv2 constant we need.
+ */
+#define NFS_MAXPATHLEN 1024
+
 struct posix_acl;
 
 struct nfsd_attrstat {
@@ -70,20 +80,6 @@ struct SETACL2args_wrapper {
 
 static_assert(offsetof(struct SETACL2args_wrapper, xdrgen) == 0);
 
-struct nfsd3_getaclargs {
-	struct svc_fh		fh;
-	__u32			mask;
-};
-
-struct nfsd3_getaclres {
-	__be32			status;
-	struct svc_fh		fh;
-	int			mask;
-	struct posix_acl	*acl_access;
-	struct posix_acl	*acl_default;
-	struct kstat		stat;
-};
-
 struct nfsd3_setaclargs {
 	struct svc_fh		fh;
 	__u32			mask;
@@ -215,6 +211,89 @@ static u32 nfsacld_acl_entries(const struct posix_acl *acl)
 	return (acl && acl->a_count >= 3) ? max_t(int, acl->a_count, 4) : 0;
 }
 
+static __always_inline void
+nfsacld_fhandle_to_svc_fh(struct svc_fh *fhp, const fhandle *fhandle)
+{
+	fh_init(fhp, FHSIZE);
+	fhp->fh_handle.fh_size = FHSIZE;
+	memcpy(&fhp->fh_handle.fh_raw, fhandle, FHSIZE);
+}
+
+static __always_inline void
+nfsacld_timespec64_to_timeval(struct timeval *dst,
+			      const struct timespec64 *src)
+{
+	dst->seconds = src->tv_sec;
+	dst->useconds = src->tv_nsec / NSEC_PER_USEC;
+}
+
+static u32
+nfsacld_mode_to_ftype(umode_t mode)
+{
+	switch (mode & S_IFMT) {
+	case S_IFREG:  return NFREG;
+	case S_IFDIR:  return NFDIR;
+	case S_IFBLK:  return NFBLK;
+	case S_IFCHR:  return NFCHR;
+	case S_IFLNK:  return NFLNK;
+	/*
+	 * The NFSv2 protocol's ftype enum does not provide specific values
+	 * for sockets and FIFOs.
+	 */
+	case S_IFSOCK: return NFNON;
+	case S_IFIFO:  return NFNON;
+	}
+	return NFNON;
+}
+
+static void
+nfsacld_stat_to_fattr(struct svc_rqst *rqstp, struct fattr *fattr,
+		      const struct kstat *stat, const struct svc_fh *fhp)
+{
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
+	struct timespec64 time;
+	u32 fsid;
+
+	fattr->type = nfsacld_mode_to_ftype(stat->mode);
+	fattr->mode = stat->mode;
+	fattr->nlink = stat->nlink;
+	fattr->uid = from_kuid_munged(userns, stat->uid);
+	fattr->gid = from_kgid_munged(userns, stat->gid);
+	if (S_ISLNK(stat->mode) && stat->size > NFS_MAXPATHLEN)
+		fattr->size = NFS_MAXPATHLEN;
+	else
+		fattr->size = stat->size;
+	fattr->blocksize = stat->blksize;
+	if (S_ISCHR(stat->mode) || S_ISBLK(stat->mode))
+		fattr->rdev = new_encode_dev(stat->rdev);
+	else
+		fattr->rdev = 0xffffffff;
+	fattr->blocks = stat->blocks;
+
+	switch (fsid_source(fhp)) {
+	case FSIDSOURCE_FSID:
+		fsid = (u32)fhp->fh_export->ex_fsid;
+		break;
+	case FSIDSOURCE_UUID:
+		fsid = ((u32 *)fhp->fh_export->ex_uuid)[0];
+		fsid ^= ((u32 *)fhp->fh_export->ex_uuid)[1];
+		fsid ^= ((u32 *)fhp->fh_export->ex_uuid)[2];
+		fsid ^= ((u32 *)fhp->fh_export->ex_uuid)[3];
+		break;
+	default:
+		fsid = new_encode_dev(stat->dev);
+		break;
+	}
+	fattr->fsid = fsid;
+	fattr->fileid = stat->ino;
+
+	nfsacld_timespec64_to_timeval(&fattr->atime, &stat->atime);
+	time = stat->mtime;
+	lease_get_mtime(d_inode(fhp->fh_dentry), &time);
+	nfsacld_timespec64_to_timeval(&fattr->mtime, &time);
+	nfsacld_timespec64_to_timeval(&fattr->ctime, &stat->ctime);
+}
+
 /**
  * nfsacld_proc_null - NULL: Do nothing
  * @rqstp: RPC transaction context
@@ -230,62 +309,84 @@ static __be32 nfsacld_proc_null(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get the Access and/or Default ACL of a file.
+/**
+ * nfsacld_proc_getacl - GETACL: Get the Access and/or Default ACL of a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   GETACL2res ACLPROC2_GETACL(GETACL2args) = 1;
  */
 static __be32 nfsacld_proc_getacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_getaclargs *argp = rqstp->rq_argp;
-	struct nfsd3_getaclres *resp = rqstp->rq_resp;
+	struct GETACL2args_wrapper *argp = rqstp->rq_argp;
+	struct GETACL2res_wrapper *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 	struct posix_acl *acl;
 	struct inode *inode;
-	svc_fh *fh;
 
-	dprintk("nfsd: GETACL(2acl)   %s\n", SVCFH_fmt(&argp->fh));
+	nfsacld_fhandle_to_svc_fh(fhp, &argp->xdrgen.fh);
+	dprintk("nfsd: GETACL(2acl)   %s\n", SVCFH_fmt(fhp));
 
-	fh = fh_copy(&resp->fh, &argp->fh);
-	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
-	if (resp->status != acl2_ok)
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
+	if (resp->xdrgen.status != acl2_ok)
 		goto out;
+	inode = d_inode(fhp->fh_dentry);
 
-	inode = d_inode(fh->fh_dentry);
-
-	if (argp->mask & ~NFS_ACL_MASK) {
-		resp->status = acl2err_io;
+	if (argp->xdrgen.mask & ~NFS_ACL_MASK) {
+		resp->xdrgen.status = acl2err_inval;
 		goto out;
 	}
-	resp->mask = argp->mask;
+	resp->mask = argp->xdrgen.mask;
 
-	resp->status = fh_getattr(fh, &resp->stat);
-	if (resp->status != acl2_ok)
+	resp->xdrgen.status = fh_getattr(fhp, &resp->stat);
+	if (resp->xdrgen.status != acl2_ok)
 		goto out;
 
+	nfsacld_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr, &resp->stat,
+			      fhp);
+
 	if (resp->mask & (NA_ACL | NA_ACLCNT)) {
 		acl = get_inode_acl(inode, ACL_TYPE_ACCESS);
 		if (acl == NULL) {
-			/* Solaris returns the inode's minimum ACL. */
+			/*
+			 * When no ACL is present, emit a minimal ACL from
+			 * the mode bits, per draft-ietf-nfsv4-nfs-acl
+			 * Section 5.2.2.4.
+			 */
 			acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		}
 		if (IS_ERR(acl)) {
-			resp->status = nfsacld_map_errno(PTR_ERR(acl));
+			resp->xdrgen.status = nfsacld_map_errno(PTR_ERR(acl));
 			goto fail;
 		}
 		resp->acl_access = acl;
 	}
 	if (resp->mask & (NA_DFACL | NA_DFACLCNT)) {
-		/* Check how Solaris handles requests for the Default ACL
-		   of a non-directory! */
 		acl = get_inode_acl(inode, ACL_TYPE_DEFAULT);
 		if (IS_ERR(acl)) {
-			resp->status = nfsacld_map_errno(PTR_ERR(acl));
+			resp->xdrgen.status = nfsacld_map_errno(PTR_ERR(acl));
 			goto fail;
 		}
 		resp->acl_default = acl;
 	}
 
-	/* resp->acl_{access,default} are released in nfssvc_release_getacl. */
+	/*
+	 * The generated secattr encoder streams the ACL entries from
+	 * the posix_acls above via the encode hooks; the proc supplies
+	 * the scalar fields.  aclcnt/dfaclcnt carry the entry count
+	 * independent of whether the matching list is requested.
+	 */
+	resp->xdrgen.u.resok.acl.mask = resp->mask;
+	resp->xdrgen.u.resok.acl.aclcnt = nfsacld_acl_entries(resp->acl_access);
+	resp->xdrgen.u.resok.acl.dfaclcnt = nfsacld_acl_entries(resp->acl_default);
+
 out:
-	resp->status = nfsacld_map_status(resp->status);
+	/* resp->acl_{access,default} are released in nfsaclsvc_release_getacl. */
+	fh_put(fhp);
+	resp->xdrgen.status = nfsacld_map_status(resp->xdrgen.status);
 	return rpc_success;
 
 fail:
@@ -598,19 +699,6 @@ bool nfs_acl2_secattr_decode_end(struct xdrgen_aggregate_cursor *c, bool ok)
  * XDR decode functions
  */
 
-static bool
-nfsaclsvc_decode_getaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_getaclargs *argp = rqstp->rq_argp;
-
-	if (!svcxdr_decode_fhandle(xdr, &argp->fh))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &argp->mask) < 0)
-		return false;
-
-	return true;
-}
-
 static bool
 nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -649,35 +737,6 @@ nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  * XDR encode functions
  */
 
-/* GETACL */
-static bool
-nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_getaclres *resp = rqstp->rq_resp;
-	struct dentry *dentry = resp->fh.fh_dentry;
-	struct inode *inode;
-
-	if (!svcxdr_encode_stat(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case acl2_ok:
-		inode = d_inode(dentry);
-		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->mask) < 0)
-			return false;
-		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_access,
-					   resp->mask & NA_ACL, 0))
-			return false;
-		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_default,
-					   resp->mask & NA_DFACL, NA_ACL_DEFAULT))
-			return false;
-		break;
-	}
-
-	return true;
-}
-
 /* ACCESS */
 static bool
 nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
@@ -703,9 +762,8 @@ nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  */
 static void nfsaclsvc_release_getacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_getaclres *resp = rqstp->rq_resp;
+	struct GETACL2res_wrapper *resp = rqstp->rq_resp;
 
-	fh_put(&resp->fh);
 	posix_acl_release(resp->acl_access);
 	posix_acl_release(resp->acl_default);
 }
@@ -729,8 +787,6 @@ static void nfsaclsvc_release_setacl(struct svc_rqst *rqstp)
 
 #define ST 1		/* status*/
 #define AT 21		/* attributes */
-#define pAT (1+AT)	/* post attributes - conditional */
-#define ACL (1+NFS_ACL_MAX_ENTRIES*3)  /* Access Control List */
 
 static const struct svc_procedure nfsd_acl_procedures2[5] = {
 	[ACLPROC2_NULL] = {
@@ -745,16 +801,16 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
 		.pc_name	= "NULL",
 	},
 	[ACLPROC2_GETACL] = {
-		.pc_func = nfsacld_proc_getacl,
-		.pc_decode = nfsaclsvc_decode_getaclargs,
-		.pc_encode = nfsaclsvc_encode_getaclres,
-		.pc_release = nfsaclsvc_release_getacl,
-		.pc_argsize = sizeof(struct nfsd3_getaclargs),
-		.pc_argzero = sizeof(struct nfsd3_getaclargs),
-		.pc_ressize = sizeof(struct nfsd3_getaclres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+1+2*(1+ACL),
-		.pc_name = "GETACL",
+		.pc_func	= nfsacld_proc_getacl,
+		.pc_decode	= nfs_acl_svc_decode_GETACL2args,
+		.pc_encode	= nfs_acl_svc_encode_GETACL2res,
+		.pc_release	= nfsaclsvc_release_getacl,
+		.pc_argsize	= sizeof(struct GETACL2args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct GETACL2res_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS_ACL2_GETACL2res_sz,
+		.pc_name	= "GETACL",
 	},
 	[ACLPROC2_SETACL] = {
 		.pc_func = nfsacld_proc_setacl,
@@ -798,11 +854,11 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
  * Storage requirements for XDR arguments and results.
  */
 union nfsd_acl2_xdrstore {
-	struct nfsd3_getaclargs		getaclargs;
+	struct GETACL2args_wrapper	getaclargs;
 	struct nfsd3_setaclargs		setaclargs;
 	struct nfsd3_accessargs		accessargs;
 	struct nfsd_fhandle		fhandle;
-	struct nfsd3_getaclres		getaclres;
+	struct GETACL2res_wrapper	getaclres;
 	struct nfsd_attrstat		attrstat;
 	struct nfsd3_accessres		accessres;
 };
-- 
2.56.0

