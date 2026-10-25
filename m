Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050585;
	b=v6zDwcoqly0DvQ8f2pE8ep6Du6X0jV+YC/9ceTrKTqseMwoh/BdHI+N161KE66PvBnLm
	 oCSVVkESZObCR0SWzXa4LTBg/FEIe0lNOf4/r48x8/yJgOhM6NAzLzcEuJrEiJpTRIKVg
	 mhqS/1TDUlWytn0ewBZElIR6ephYX3iFwQ82gH8gSxVN9udiJbQzs2lVPuDYX1OJ8fPFJ
	 Wj93JqdmIVBnj7ehU8bG2qgAX78fMig8/PcDCYTLWsJpJSVz/zpzV43vK1Gnon2+0i1KI
	 eCsdXFkAoyeboK1lOHRxT8ims6HnCVQCTn/ky3gYkJsUcPqX08WU3r2lywTQ5eX5TsQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050585;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=p/fR15Mzp6sbxKjFQjLAiPmM1RX0tcuND1N5RNN/lfY=;
	b=hzH0S7mobsz2BAMlMS6tU6zw5OXvzaEPxTb/w646qKyjZWtWoP8AG6i6ba8IinAoh/00
	 6jZjqSh8co+Zv9xAYVBLE10r0AJZgr8XwJ2wCETxM+sOJGOvKVXTR4FYXWVPxCUlJ25Qw
	 K+Cy6GSCaral95r9v1GliwDbeg/w3y+KW9tsHfJX2/V5DtxvTkkvckq4SjmTbGB9v+X2z
	 w3I+NTJL+9PoBYQqZ18S/imwFIb2zBhGP5cp/H0Rc/xvNq2iiu2qAuJgU+KLhYw7mSeR4
	 0HKzg84EZOmO/L27Og/e5W0IU14u/6M10JF8qs3NWtRpZViEkdKyEhmJOLHs6KVYiiw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Jz/sZORn";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8799F606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Jz/sZORn
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C3EE1F01825;
	Mon, 26 Oct 2026 21:36:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050584;
	bh=p/fR15Mzp6sbxKjFQjLAiPmM1RX0tcuND1N5RNN/lfY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Jz/sZORnon/J5F4+eV58OK+MkZ6WyLKxGh2aevlTdzqrIispoSzlDYjNG2ieHqb4t
	 W++tu5YLgX0LtVug+07n1cmlsL69aubwDOUbP6ScNnLvh7e4IILqx9GGluHESp4/N2
	 nJbivX4EDEDWmec62eNWAWvVcqhyEGu9c6Y9E2JbROTll+LT5YdWWibzDj9/iruirx
	 fS5K8Hw+Uhx4uROzA7DQJiSixpn1xQutsW8WDIDHWDlA2YgycYjt/8wwy1lWAYwFxC
	 2+yWttgPBIiooIMyQpeYkNJmlEcGS0l2JMKqTIksoOB2HMtR7WUphIVCISLFKgbNEy
	 pQ3o4OmH0y3wg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 07/13] NFSD: Use xdrgen XDR functions for the NFS-ACL v3 GETACL procedure
Date: Sun, 25 Oct 2026 11:16:16 -0400
Message-ID: <20261025151622.141025-8-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
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

Continue migrating nfs3acl.c off its hand-written codecs. GETACL3res
encode carries a secattr, a post_op_attr, and an aclstat3 status, none
of which the hand-rolled path expresses in a form xdrgen can check
against the protocol description.

Convert GETACL to the generated codec. The preceding patch installed
the secattr aggregate hooks and the argument and result wrappers, so
the proc fills only the scalar secattr fields -- the request mask and
the two entry counts -- and the generated encoder streams the ACL
entries from the proc's posix_acls through those hooks. The
GETACL3args and GETACL3res wrappers carry the svc_fh and posix_acl
state the NFSD VFS layer still uses alongside the generated types.

The NFSv3 file handle is variable-length, so the proc rejects an
unparseable handle as ACL3ERR_BADHANDLE before acquiring any
resources. The procedure fills the post_op_attr, records the inode's
owner ids, and fetches the ACLs while the file handle is verified,
then releases the file handle itself. When the file handle carries
fh_no_wcc or the attribute fetch fails, the post_op_attr stays absent
and the ACL is still returned, as the hand-rolled encoder left it.
The encoder reads the ACL owner ids from the recorded owner rather
than from a live inode, so nfs3svc_release_getacl() shrinks to the
two posix_acl_release() calls; those releases must stay a
release-time job because the encoder still consumes the posix_acls
after the reply is built.

Filling the fattr3 masks the mode with S_IALLUGO and reuses the fsid
and timestamp handling the native NFSv3 attribute encoder already
applies.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3acl.c | 282 +++++++++++++++++++++++++++-------------------
 1 file changed, 166 insertions(+), 116 deletions(-)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 1fb9d265bc03..beb51b9dc2f1 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -7,6 +7,7 @@
 
 #include <linux/gfp.h>
 #include <linux/fs.h>
+#include <linux/filelock.h>
 #include <linux/nfsacl.h>
 #include <linux/nfs4.h>
 
@@ -14,10 +15,19 @@
 
 #include "cache.h"
 #include "nfsd.h"
+#include "auth.h"
 #include "vfs.h"
 
 #define NFS_ACL_MASK		(NA_ACL | NA_ACLCNT | NA_DFACL | NA_DFACLCNT)
 
+/*
+ * The generated <linux/sunrpc/xdrgen/nfs_acl3.h> defines the NFSv3
+ * inherited types (nfs_fh3, fattr3, post_op_attr, ...), so the native
+ * NFSv3 headers that also define them cannot be included here. Define
+ * the one inherited NFSv3 constant needed for symlink size clamping.
+ */
+#define NFS3_MAXPATHLEN		PATH_MAX
+
 /*
  * Wrapper structures combine xdrgen types with legacy structures.
  * The xdrgen field must be first so the structure can be cast
@@ -30,15 +40,13 @@ struct GETACL3args_wrapper {
 
 static_assert(offsetof(struct GETACL3args_wrapper, xdrgen) == 0);
 
-/*
- * The ACL is encoded from the posix_acl fields below, so the
- * generated secattr (xdrgen.u.resok.acl) is left unused.
- */
 struct GETACL3res_wrapper {
 	struct GETACL3res	xdrgen;
 	int			mask;
 	struct posix_acl	*acl_access;
 	struct posix_acl	*acl_default;
+	kuid_t			uid;
+	kgid_t			gid;
 	struct kstat		stat;
 };
 
@@ -64,39 +72,6 @@ struct SETACL3args_wrapper {
 
 static_assert(offsetof(struct SETACL3args_wrapper, xdrgen) == 0);
 
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
-struct nfsd3_setaclargs {
-	struct svc_fh		fh;
-	__u32			mask;
-	struct posix_acl	*acl_access;
-	struct posix_acl	*acl_default;
-};
-
-struct nfsd3_attrstat {
-	__be32			status;
-	struct svc_fh		fh;
-	struct kstat            stat;
-};
-
-/* Helper functions for NFSv3 ACL code */
-bool svcxdr_decode_nfs_fh3(struct xdr_stream *xdr, struct svc_fh *fhp);
-bool svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status);
-bool svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-				const struct svc_fh *fhp);
-
 enum {
 	acl3_ok = __constant_cpu_to_be32(ACL3_OK),
 	acl3err_perm = __constant_cpu_to_be32(ACL3ERR_PERM),
@@ -156,6 +131,103 @@ static __be32 nfsd3_map_status(__be32 status)
 	return status;
 }
 
+/* Legacy structures for the hand-rolled SETACL codec. */
+struct nfsd3_setaclargs {
+	struct svc_fh		fh;
+	__u32			mask;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+};
+
+struct nfsd3_attrstat {
+	__be32			status;
+	struct svc_fh		fh;
+	struct kstat            stat;
+};
+
+/* Helper functions for NFSv3 ACL code */
+bool svcxdr_decode_nfs_fh3(struct xdr_stream *xdr, struct svc_fh *fhp);
+bool svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status);
+bool svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
+				const struct svc_fh *fhp);
+
+static bool
+nfs3acl_decode_fh(const struct nfs_fh3 *fh, struct svc_fh *fhp)
+{
+	if (fh->data.len == 0 || fh->data.len > NFS3_FHSIZE)
+		return false;
+	fh_init(fhp, NFS3_FHSIZE);
+	fhp->fh_handle.fh_size = fh->data.len;
+	memcpy(&fhp->fh_handle.fh_raw, fh->data.data, fh->data.len);
+	return true;
+}
+
+static u32
+nfs3acl_mode_to_ftype3(umode_t mode)
+{
+	switch (mode & S_IFMT) {
+	case S_IFREG:  return NF3REG;
+	case S_IFDIR:  return NF3DIR;
+	case S_IFBLK:  return NF3BLK;
+	case S_IFCHR:  return NF3CHR;
+	case S_IFLNK:  return NF3LNK;
+	case S_IFSOCK: return NF3SOCK;
+	case S_IFIFO:  return NF3FIFO;
+	}
+	return NF3REG;
+}
+
+static void
+nfs3acl_stat_to_fattr3(struct svc_rqst *rqstp, struct fattr3 *fattr,
+		       const struct kstat *stat, const struct svc_fh *fhp)
+{
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
+	u64 fsid;
+
+	fattr->type = nfs3acl_mode_to_ftype3(stat->mode);
+	fattr->mode = stat->mode & S_IALLUGO;
+	fattr->nlink = stat->nlink;
+	fattr->uid = from_kuid_munged(userns, stat->uid);
+	fattr->gid = from_kgid_munged(userns, stat->gid);
+	if (S_ISLNK(stat->mode) && stat->size > NFS3_MAXPATHLEN)
+		fattr->size = NFS3_MAXPATHLEN;
+	else
+		fattr->size = stat->size;
+	fattr->used = (u64)stat->blocks << 9;
+	fattr->rdev.specdata1 = MAJOR(stat->rdev);
+	fattr->rdev.specdata2 = MINOR(stat->rdev);
+
+	switch (fsid_source(fhp)) {
+	case FSIDSOURCE_FSID:
+		fsid = (u64)fhp->fh_export->ex_fsid;
+		break;
+	case FSIDSOURCE_UUID:
+		fsid = ((u64 *)fhp->fh_export->ex_uuid)[0];
+		fsid ^= ((u64 *)fhp->fh_export->ex_uuid)[1];
+		break;
+	default:
+		fsid = (u64)huge_encode_dev(fhp->fh_dentry->d_sb->s_dev);
+	}
+	fattr->fsid = fsid;
+	fattr->fileid = stat->ino;
+
+	fattr->atime.seconds = stat->atime.tv_sec;
+	fattr->atime.nseconds = stat->atime.tv_nsec;
+	fattr->mtime.seconds = stat->mtime.tv_sec;
+	fattr->mtime.nseconds = stat->mtime.tv_nsec;
+	fattr->ctime.seconds = stat->ctime.tv_sec;
+	fattr->ctime.nseconds = stat->ctime.tv_nsec;
+}
+
+static void
+nfs3acl_encode_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
+			    struct kstat *stat, const struct svc_fh *fhp)
+{
+	attr->attributes_follow = true;
+	lease_get_mtime(d_inode(fhp->fh_dentry), &stat->mtime);
+	nfs3acl_stat_to_fattr3(rqstp, &attr->u.attributes, stat, fhp);
+}
+
 /*
  * A minimal (three-entry) ACL travels as four wire entries: the
  * POSIX entries plus a synthesized NA_CLASS_OBJ mask. The wire
@@ -184,29 +256,48 @@ static __be32 nfsd3_proc_null(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get the Access and/or Default ACL of a file.
+/**
+ * nfsd3_proc_getacl - GETACL: Get the Access and/or Default ACL of a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   GETACL3res ACLPROC3_GETACL(GETACL3args) = 1;
  */
 static __be32 nfsd3_proc_getacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_getaclargs *argp = rqstp->rq_argp;
-	struct nfsd3_getaclres *resp = rqstp->rq_resp;
+	struct GETACL3args_wrapper *argp = rqstp->rq_argp;
+	struct GETACL3res_wrapper *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 	struct posix_acl *acl;
 	struct inode *inode;
-	svc_fh *fh;
 
-	fh = fh_copy(&resp->fh, &argp->fh);
-	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
-	if (resp->status != acl3_ok)
+	resp->xdrgen.u.resok.attr.attributes_follow = false;
+
+	/* An unparsable handle leaves @fhp uninitialized, so skip fh_put. */
+	if (!nfs3acl_decode_fh(&argp->xdrgen.fh, fhp)) {
+		resp->xdrgen.status = acl3err_badhandle;
+		return rpc_success;
+	}
+
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
+	if (resp->xdrgen.status != acl3_ok)
 		goto out;
+	inode = d_inode(fhp->fh_dentry);
 
-	inode = d_inode(fh->fh_dentry);
+	if (!fhp->fh_no_wcc && fh_getattr(fhp, &resp->stat) == acl3_ok)
+		nfs3acl_encode_post_op_attr(rqstp, &resp->xdrgen.u.resok.attr,
+					    &resp->stat, fhp);
 
-	if (argp->mask & ~NFS_ACL_MASK) {
-		resp->status = acl3err_inval;
+	if (argp->xdrgen.mask & ~NFS_ACL_MASK) {
+		resp->xdrgen.status = acl3err_inval;
 		goto out;
 	}
-	resp->mask = argp->mask;
+	resp->mask = argp->xdrgen.mask;
+	resp->uid = inode->i_uid;
+	resp->gid = inode->i_gid;
 
 	if (resp->mask & (NA_ACL | NA_ACLCNT)) {
 		acl = get_inode_acl(inode, ACL_TYPE_ACCESS);
@@ -215,25 +306,34 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst *rqstp)
 			acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		}
 		if (IS_ERR(acl)) {
-			resp->status = nfsd3_map_errno(PTR_ERR(acl));
+			resp->xdrgen.status = nfsd3_map_errno(PTR_ERR(acl));
 			goto fail;
 		}
 		resp->acl_access = acl;
 	}
 	if (resp->mask & (NA_DFACL | NA_DFACLCNT)) {
-		/* Check how Solaris handles requests for the Default ACL
-		   of a non-directory! */
 		acl = get_inode_acl(inode, ACL_TYPE_DEFAULT);
 		if (IS_ERR(acl)) {
-			resp->status = nfsd3_map_errno(PTR_ERR(acl));
+			resp->xdrgen.status = nfsd3_map_errno(PTR_ERR(acl));
 			goto fail;
 		}
 		resp->acl_default = acl;
 	}
 
-	/* resp->acl_{access,default} are released in nfs3svc_release_getacl. */
+	/*
+	 * The generated secattr encoder streams the ACL entries from
+	 * the posix_acls above via the encode hooks; the proc supplies
+	 * the scalar fields.  aclcnt/dfaclcnt carry the entry count
+	 * independent of whether the matching list is requested.
+	 */
+	resp->xdrgen.u.resok.acl.mask = resp->mask;
+	resp->xdrgen.u.resok.acl.aclcnt = nfs3acl_acl_entries(resp->acl_access);
+	resp->xdrgen.u.resok.acl.dfaclcnt = nfs3acl_acl_entries(resp->acl_default);
+
 out:
-	resp->status = nfsd3_map_status(resp->status);
+	/* resp->acl_{access,default} are released in nfs3svc_release_getacl. */
+	fh_put(fhp);
+	resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
 	return rpc_success;
 
 fail:
@@ -295,19 +395,6 @@ static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
  * XDR decode functions
  */
 
-static bool
-nfs3svc_decode_getaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_getaclargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_nfs_fh3(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->mask) < 0)
-		return false;
-
-	return true;
-}
-
 static bool
 nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -333,40 +420,6 @@ nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  * XDR encode functions
  */
 
-/* GETACL */
-static bool
-nfs3svc_encode_getaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_getaclres *resp = rqstp->rq_resp;
-	struct dentry *dentry = resp->fh.fh_dentry;
-	struct inode *inode;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case acl3_ok:
-		inode = d_inode(dentry);
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->mask) < 0)
-			return false;
-
-		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_access,
-					   resp->mask & NA_ACL, 0))
-			return false;
-		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_default,
-					   resp->mask & NA_DFACL,
-					   NA_ACL_DEFAULT))
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
 /* SETACL */
 static bool
 nfs3svc_encode_setaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
@@ -433,10 +486,10 @@ bool nfs_acl3_secattr_encode(struct xdrgen_aggregate_cursor *c,
 	out->type = tag | typeflag;
 	switch (tag) {
 	case ACL_USER_OBJ:
-		out->id = from_kuid(&init_user_ns, resp->stat.uid);
+		out->id = from_kuid(&init_user_ns, resp->uid);
 		break;
 	case ACL_GROUP_OBJ:
-		out->id = from_kgid(&init_user_ns, resp->stat.gid);
+		out->id = from_kgid(&init_user_ns, resp->gid);
 		break;
 	case ACL_USER:
 		out->id = from_kuid(&init_user_ns, entry->e_uid);
@@ -594,9 +647,8 @@ bool nfs_acl3_secattr_decode_end(struct xdrgen_aggregate_cursor *c, bool ok)
  */
 static void nfs3svc_release_getacl(struct svc_rqst *rqstp)
 {
-	struct nfsd3_getaclres *resp = rqstp->rq_resp;
+	struct GETACL3res_wrapper *resp = rqstp->rq_resp;
 
-	fh_put(&resp->fh);
 	posix_acl_release(resp->acl_access);
 	posix_acl_release(resp->acl_default);
 }
@@ -614,7 +666,6 @@ static void nfs3svc_release_setacl(struct svc_rqst *rqstp)
 #define ST 1		/* status*/
 #define AT 21		/* attributes */
 #define pAT (1+AT)	/* post attributes - conditional */
-#define ACL (1+NFS_ACL_MAX_ENTRIES*3)  /* Access Control List */
 
 static const struct svc_procedure nfsd_acl_procedures3[3] = {
 	[ACLPROC3_NULL] = {
@@ -630,14 +681,14 @@ static const struct svc_procedure nfsd_acl_procedures3[3] = {
 	},
 	[ACLPROC3_GETACL] = {
 		.pc_func = nfsd3_proc_getacl,
-		.pc_decode = nfs3svc_decode_getaclargs,
-		.pc_encode = nfs3svc_encode_getaclres,
+		.pc_decode = nfs_acl_svc_decode_GETACL3args,
+		.pc_encode = nfs_acl_svc_encode_GETACL3res,
 		.pc_release = nfs3svc_release_getacl,
-		.pc_argsize = sizeof(struct nfsd3_getaclargs),
-		.pc_argzero = sizeof(struct nfsd3_getaclargs),
-		.pc_ressize = sizeof(struct nfsd3_getaclres),
+		.pc_argsize = sizeof(struct GETACL3args_wrapper),
+		.pc_argzero = 0,
+		.pc_ressize = sizeof(struct GETACL3res_wrapper),
 		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+1+2*(1+ACL),
+		.pc_xdrressize = NFS_ACL3_GETACL3res_sz,
 		.pc_name = "GETACL",
 	},
 	[ACLPROC3_SETACL] = {
@@ -658,9 +709,9 @@ static const struct svc_procedure nfsd_acl_procedures3[3] = {
  * Storage requirements for XDR arguments and results.
  */
 union nfsd_acl3_xdrstore {
-	struct nfsd3_getaclargs		getaclargs;
+	struct GETACL3args_wrapper	getaclargs;
 	struct nfsd3_setaclargs		setaclargs;
-	struct nfsd3_getaclres		getaclres;
+	struct GETACL3res_wrapper	getaclres;
 	struct nfsd3_attrstat		attrstat;
 };
 
@@ -671,4 +722,3 @@ const struct svc_version nfsd_acl_version3 = {
 	.vs_dispatch	= nfsd_dispatch,
 	.vs_xdrsize	= sizeof(union nfsd_acl3_xdrstore),
 };
-
-- 
2.56.0

