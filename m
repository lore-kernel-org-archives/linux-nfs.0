Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050589;
	b=DoQddkUgoUQjg9xxVZ2NlPAVAZDEEsvcBr2vug7y9OfHE0sYvlho73uk04nC80PFUWEN
	 bMIPHfqY6LJdUdR/QLj9RomXN2upEavKoA2BBt4uuk45rY+/CG+yKq3y2tEmlhq4GZLx4
	 Fd3Ay9itBXy1Ifum07QJ3OhI590dOnvTiSp8YK+VoYTWqoRSlXpKja7NgSz2GqC/seBsm
	 j4IQ2EJ60vGjHXp0154Kfy9H5tYIjEXpE9oKKs8LA0j+V2J32cYk5mWxg93S0ICkTG0Uk
	 agCIv4J/5zU/ADTDD7w/Vrdxgr6+PXDdbLQauQISKl1WkDBz8Vzr05dswCIrjZjn8Bw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050589;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=kN8NtnqvdYRT1NYa7F+ug7iwEdr5iPT3WCxCr93g4B8=;
	b=m537CTtmuIiKNuFgo42Cl25xNzkTz7vJEhzqob+R0xDMONvKd1Ln/NcmApcWtx9rFiZf
	 OqDS3d0Wl8xF6TmlvoitSTUtoptwdXJE4oHXD25UwA+eRCfTt+rxjt6V+drjiY5ncenZj
	 eJutDbvq8ZOIhbsFjVOHOPMZGsooxRctASNHjyEXbrdSMvQriVnwkhxdZqSdscwI+OPZ5
	 ZtyWQ7m4IPYV4E5HE+6N9EdUkZ3UTUcmtbynC6EdDqUfLKpwKkEJz12kGIL99ilw3WZ5B
	 t3fS+pBAZabZgMmbNH7NbPRKO1QxXwkH1RbIIZoSNqNld0Q3GrLFr4jPLenX1RjRj2g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="KpeWUhJ/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B51F606A323
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KpeWUhJ/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 661E31F01825;
	Mon, 26 Oct 2026 21:36:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050589;
	bh=kN8NtnqvdYRT1NYa7F+ug7iwEdr5iPT3WCxCr93g4B8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KpeWUhJ/p8aa2/2VJih/x/9279O4YT1zKSD14mbvZe5aRpiQ0lsphKbVjQXRnNn9O
	 r8A4td6g/+yxQeBdKmGfTwSnFYMPTlDq7TJmc1p0pvtUuuYlyEDlX+c0NLKhsYdLRZ
	 7/C3lWUZSgntOmGQLkCNencg4tb3VJ0cBJsqBLcvZqk+FwBaxLqqvNHubQZdm1HMJy
	 Ge1IXkIdyQwdusoSw7f/arMbhEdg2Iu3IwvOOQRzEFL1KFqc2KVMfpZG7eVYh/6sWk
	 rQlkih2M6RC8PMvWbmkcMZU28e7B9kC8Q4UYeJOwEzQSYLSbLaXPvp2ljiEmRsN8dA
	 vx4vgrSE3kC8A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 12/13] NFSD: Share the attribute conversion helpers with the NFS_ACL procs
Date: Sun, 25 Oct 2026 11:16:21 -0400
Message-ID: <20261025151622.141025-13-cel@kernel.org>
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

nfs2acl.c and nfs3acl.c each carry a private copy of the kstat to
fattr conversion that nfsproc.c and nfs3proc.c already implement,
down to the fsid selection and the symlink size clamp, along with a
private definition of the path length limit the clamp uses. The
copies exist because the NFS_ACL protocol descriptions define fattr,
fattr3, and post_op_attr themselves, so the NFS_ACL proc files cannot
include the native NFSv2 and NFSv3 generated headers, and xdr.h and
xdr3.h pull those in. A fix to a native helper has to be repeated by
hand in its NFS_ACL copy.

Add fattr.h, which declares nfsd_stat_to_fattr() and
nfsd3_fill_post_op_attr() against incomplete struct types. The
NFS_ACL copies of the attribute types match the native ones member
for member, so each translation unit completes the types from its
own protocol header and the helpers link across them. Export
nfsd_stat_to_fattr() from nfsproc.c, move the nfsd3_fill_post_op_attr()
prototype out of xdr3.h, and drop the NFS_ACL copies. With
nfsd3_fill_post_op_attr() fetching the attributes itself, the
NFS_ACLv3 result wrappers no longer carry a kstat.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/fattr.h   | 20 ++++++++++
 fs/nfsd/nfs2acl.c | 99 ++++-------------------------------------------
 fs/nfsd/nfs3acl.c | 87 ++---------------------------------------
 fs/nfsd/nfsproc.c |  3 +-
 fs/nfsd/xdr3.h    |  3 +-
 5 files changed, 34 insertions(+), 178 deletions(-)
 create mode 100644 fs/nfsd/fattr.h

diff --git a/fs/nfsd/fattr.h b/fs/nfsd/fattr.h
new file mode 100644
index 000000000000..7ea116c6a63c
--- /dev/null
+++ b/fs/nfsd/fattr.h
@@ -0,0 +1,20 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Attribute conversion helpers shared by the NFS and NFS_ACL procs.
+ */
+
+#ifndef _NFSD_FATTR_H
+#define _NFSD_FATTR_H
+
+struct fattr;
+struct kstat;
+struct post_op_attr;
+struct svc_fh;
+struct svc_rqst;
+
+void nfsd_stat_to_fattr(struct svc_rqst *rqstp, struct fattr *fattr,
+			const struct kstat *stat, const struct svc_fh *fhp);
+void nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
+			     struct svc_fh *fhp);
+
+#endif /* _NFSD_FATTR_H */
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 504dc57e9b8e..efb18b65217d 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -7,7 +7,6 @@
 
 #include <linux/gfp.h>
 #include <linux/fs.h>
-#include <linux/filelock.h>
 #include <linux/nfsacl.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
@@ -20,19 +19,12 @@
 #include "nfsd.h"
 #include "auth.h"
 #include "vfs.h"
+#include "fattr.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_PROC
 
 #define NFS_ACL_MASK		(NA_ACL | NA_ACLCNT | NA_DFACL | NA_DFACLCNT)
 
-/*
- * The generated <linux/sunrpc/xdrgen/nfs_acl2.h> defines enum ftype, so
- * <uapi/linux/nfs.h> (which also defines enum nfs_ftype with the same
- * NFNON..NFLNK enumerators) and the generated nfs2 header cannot be
- * included here. Define the inherited NFSv2 constant we need.
- */
-#define NFS_MAXPATHLEN 1024
-
 struct posix_acl;
 
 /*
@@ -232,81 +224,6 @@ nfsacld_fhandle_to_svc_fh(struct svc_fh *fhp, const fhandle *fhandle)
 	memcpy(&fhp->fh_handle.fh_raw, fhandle, FHSIZE);
 }
 
-static __always_inline void
-nfsacld_timespec64_to_timeval(struct timeval *dst,
-			      const struct timespec64 *src)
-{
-	dst->seconds = src->tv_sec;
-	dst->useconds = src->tv_nsec / NSEC_PER_USEC;
-}
-
-static u32
-nfsacld_mode_to_ftype(umode_t mode)
-{
-	switch (mode & S_IFMT) {
-	case S_IFREG:  return NFREG;
-	case S_IFDIR:  return NFDIR;
-	case S_IFBLK:  return NFBLK;
-	case S_IFCHR:  return NFCHR;
-	case S_IFLNK:  return NFLNK;
-	/*
-	 * The NFSv2 protocol's ftype enum does not provide specific values
-	 * for sockets and FIFOs.
-	 */
-	case S_IFSOCK: return NFNON;
-	case S_IFIFO:  return NFNON;
-	}
-	return NFNON;
-}
-
-static void
-nfsacld_stat_to_fattr(struct svc_rqst *rqstp, struct fattr *fattr,
-		      const struct kstat *stat, const struct svc_fh *fhp)
-{
-	struct user_namespace *userns = nfsd_user_namespace(rqstp);
-	struct timespec64 time;
-	u32 fsid;
-
-	fattr->type = nfsacld_mode_to_ftype(stat->mode);
-	fattr->mode = stat->mode;
-	fattr->nlink = stat->nlink;
-	fattr->uid = from_kuid_munged(userns, stat->uid);
-	fattr->gid = from_kgid_munged(userns, stat->gid);
-	if (S_ISLNK(stat->mode) && stat->size > NFS_MAXPATHLEN)
-		fattr->size = NFS_MAXPATHLEN;
-	else
-		fattr->size = stat->size;
-	fattr->blocksize = stat->blksize;
-	if (S_ISCHR(stat->mode) || S_ISBLK(stat->mode))
-		fattr->rdev = new_encode_dev(stat->rdev);
-	else
-		fattr->rdev = 0xffffffff;
-	fattr->blocks = stat->blocks;
-
-	switch (fsid_source(fhp)) {
-	case FSIDSOURCE_FSID:
-		fsid = (u32)fhp->fh_export->ex_fsid;
-		break;
-	case FSIDSOURCE_UUID:
-		fsid = ((u32 *)fhp->fh_export->ex_uuid)[0];
-		fsid ^= ((u32 *)fhp->fh_export->ex_uuid)[1];
-		fsid ^= ((u32 *)fhp->fh_export->ex_uuid)[2];
-		fsid ^= ((u32 *)fhp->fh_export->ex_uuid)[3];
-		break;
-	default:
-		fsid = new_encode_dev(stat->dev);
-		break;
-	}
-	fattr->fsid = fsid;
-	fattr->fileid = stat->ino;
-
-	nfsacld_timespec64_to_timeval(&fattr->atime, &stat->atime);
-	time = stat->mtime;
-	lease_get_mtime(d_inode(fhp->fh_dentry), &time);
-	nfsacld_timespec64_to_timeval(&fattr->mtime, &time);
-	nfsacld_timespec64_to_timeval(&fattr->ctime, &stat->ctime);
-}
-
 /**
  * nfsacld_proc_null - NULL: Do nothing
  * @rqstp: RPC transaction context
@@ -358,8 +275,8 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst *rqstp)
 	if (resp->xdrgen.status != acl2_ok)
 		goto out;
 
-	nfsacld_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr, &resp->stat,
-			      fhp);
+	nfsd_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr, &resp->stat,
+			   fhp);
 
 	if (resp->mask & (NA_ACL | NA_ACLCNT)) {
 		acl = get_inode_acl(inode, ACL_TYPE_ACCESS);
@@ -476,8 +393,8 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 
 out:
 	if (resp->xdrgen.status == acl2_ok)
-		nfsacld_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr,
-				      &resp->stat, fhp);
+		nfsd_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr,
+				   &resp->stat, fhp);
 	/* argp->acl_{access,default} are released in nfsaclsvc_release_setacl. */
 	fh_put(fhp);
 	resp->xdrgen.status = nfsacld_map_status(resp->xdrgen.status);
@@ -517,8 +434,8 @@ static __be32 nfsacld_proc_getattr(struct svc_rqst *rqstp)
 
 out:
 	if (resp->xdrgen.status == acl2_ok)
-		nfsacld_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr,
-				      &resp->stat, fhp);
+		nfsd_stat_to_fattr(rqstp, &resp->xdrgen.u.resok.attr,
+				   &resp->stat, fhp);
 	fh_put(fhp);
 	resp->xdrgen.status = nfsacld_map_status(resp->xdrgen.status);
 	return rpc_success;
@@ -555,7 +472,7 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 		struct ACCESS2resok *resok = &resp->xdrgen.u.resok;
 
 		resok->access = argp->xdrgen.access;
-		nfsacld_stat_to_fattr(rqstp, &resok->attr, &resp->stat, fhp);
+		nfsd_stat_to_fattr(rqstp, &resok->attr, &resp->stat, fhp);
 	}
 	fh_put(fhp);
 	resp->xdrgen.status = nfsacld_map_status(resp->xdrgen.status);
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 66bb650e99f4..2ba499422869 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -7,7 +7,6 @@
 
 #include <linux/gfp.h>
 #include <linux/fs.h>
-#include <linux/filelock.h>
 #include <linux/nfsacl.h>
 #include <linux/nfs4.h>
 
@@ -17,17 +16,10 @@
 #include "nfsd.h"
 #include "auth.h"
 #include "vfs.h"
+#include "fattr.h"
 
 #define NFS_ACL_MASK		(NA_ACL | NA_ACLCNT | NA_DFACL | NA_DFACLCNT)
 
-/*
- * The generated <linux/sunrpc/xdrgen/nfs_acl3.h> defines the NFSv3
- * inherited types (nfs_fh3, fattr3, post_op_attr, ...), so the native
- * NFSv3 headers that also define them cannot be included here. Define
- * the one inherited NFSv3 constant needed for symlink size clamping.
- */
-#define NFS3_MAXPATHLEN		PATH_MAX
-
 /*
  * Wrapper structures combine xdrgen types with legacy structures.
  * The xdrgen field must be first so the structure can be cast
@@ -47,7 +39,6 @@ struct GETACL3res_wrapper {
 	struct posix_acl	*acl_default;
 	kuid_t			uid;
 	kgid_t			gid;
-	struct kstat		stat;
 };
 
 static_assert(offsetof(struct GETACL3res_wrapper, xdrgen) == 0);
@@ -70,7 +61,6 @@ static_assert(offsetof(struct SETACL3args_wrapper, xdrgen) == 0);
 
 struct SETACL3res_wrapper {
 	struct SETACL3res	xdrgen;
-	struct kstat		stat;
 };
 
 static_assert(offsetof(struct SETACL3res_wrapper, xdrgen) == 0);
@@ -159,72 +149,6 @@ nfs3acl_decode_fh(const struct nfs_fh3 *fh, struct svc_fh *fhp)
 	return true;
 }
 
-static u32
-nfs3acl_mode_to_ftype3(umode_t mode)
-{
-	switch (mode & S_IFMT) {
-	case S_IFREG:  return NF3REG;
-	case S_IFDIR:  return NF3DIR;
-	case S_IFBLK:  return NF3BLK;
-	case S_IFCHR:  return NF3CHR;
-	case S_IFLNK:  return NF3LNK;
-	case S_IFSOCK: return NF3SOCK;
-	case S_IFIFO:  return NF3FIFO;
-	}
-	return NF3REG;
-}
-
-static void
-nfs3acl_stat_to_fattr3(struct svc_rqst *rqstp, struct fattr3 *fattr,
-		       const struct kstat *stat, const struct svc_fh *fhp)
-{
-	struct user_namespace *userns = nfsd_user_namespace(rqstp);
-	u64 fsid;
-
-	fattr->type = nfs3acl_mode_to_ftype3(stat->mode);
-	fattr->mode = stat->mode & S_IALLUGO;
-	fattr->nlink = stat->nlink;
-	fattr->uid = from_kuid_munged(userns, stat->uid);
-	fattr->gid = from_kgid_munged(userns, stat->gid);
-	if (S_ISLNK(stat->mode) && stat->size > NFS3_MAXPATHLEN)
-		fattr->size = NFS3_MAXPATHLEN;
-	else
-		fattr->size = stat->size;
-	fattr->used = (u64)stat->blocks << 9;
-	fattr->rdev.specdata1 = MAJOR(stat->rdev);
-	fattr->rdev.specdata2 = MINOR(stat->rdev);
-
-	switch (fsid_source(fhp)) {
-	case FSIDSOURCE_FSID:
-		fsid = (u64)fhp->fh_export->ex_fsid;
-		break;
-	case FSIDSOURCE_UUID:
-		fsid = ((u64 *)fhp->fh_export->ex_uuid)[0];
-		fsid ^= ((u64 *)fhp->fh_export->ex_uuid)[1];
-		break;
-	default:
-		fsid = (u64)huge_encode_dev(fhp->fh_dentry->d_sb->s_dev);
-	}
-	fattr->fsid = fsid;
-	fattr->fileid = stat->ino;
-
-	fattr->atime.seconds = stat->atime.tv_sec;
-	fattr->atime.nseconds = stat->atime.tv_nsec;
-	fattr->mtime.seconds = stat->mtime.tv_sec;
-	fattr->mtime.nseconds = stat->mtime.tv_nsec;
-	fattr->ctime.seconds = stat->ctime.tv_sec;
-	fattr->ctime.nseconds = stat->ctime.tv_nsec;
-}
-
-static void
-nfs3acl_encode_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
-			    struct kstat *stat, const struct svc_fh *fhp)
-{
-	attr->attributes_follow = true;
-	lease_get_mtime(d_inode(fhp->fh_dentry), &stat->mtime);
-	nfs3acl_stat_to_fattr3(rqstp, &attr->u.attributes, stat, fhp);
-}
-
 /*
  * A minimal (three-entry) ACL travels as four wire entries: the
  * POSIX entries plus a synthesized NA_CLASS_OBJ mask. The wire
@@ -284,9 +208,7 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst *rqstp)
 		goto out;
 	inode = d_inode(fhp->fh_dentry);
 
-	if (!fhp->fh_no_wcc && fh_getattr(fhp, &resp->stat) == acl3_ok)
-		nfs3acl_encode_post_op_attr(rqstp, &resp->xdrgen.u.resok.attr,
-					    &resp->stat, fhp);
+	nfsd3_fill_post_op_attr(rqstp, &resp->xdrgen.u.resok.attr, fhp);
 
 	if (argp->xdrgen.mask & ~NFS_ACL_MASK) {
 		resp->xdrgen.status = acl3err_inval;
@@ -411,10 +333,7 @@ static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 	 * resok and resfail both open with a post_op_attr, so filling
 	 * the resok arm serves either status.
 	 */
-	if (!fhp->fh_no_wcc && fhp->fh_dentry &&
-	    fh_getattr(fhp, &resp->stat) == acl3_ok)
-		nfs3acl_encode_post_op_attr(rqstp, &resp->xdrgen.u.resok.attr,
-					    &resp->stat, fhp);
+	nfsd3_fill_post_op_attr(rqstp, &resp->xdrgen.u.resok.attr, fhp);
 	/* argp->acl_{access,default} are released in nfs3svc_release_setacl. */
 	fh_put(fhp);
 	resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 39e5caa8e286..2f8da62ad6b0 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -15,6 +15,7 @@
 #include "cache.h"
 #include "xdr.h"
 #include "vfs.h"
+#include "fattr.h"
 #include "nfserr.h"
 #include "trace.h"
 
@@ -189,7 +190,7 @@ nfsd_mode_to_ftype(umode_t mode)
 	return NFNON;
 }
 
-static void
+void
 nfsd_stat_to_fattr(struct svc_rqst *rqstp, struct fattr *fattr,
 		   const struct kstat *stat, const struct svc_fh *fhp)
 {
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 90dadcacdf2b..ae8afec767ef 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -12,6 +12,7 @@
 #include <linux/sunrpc/xdrgen/nfs3.h>
 
 #include "vfs.h"
+#include "fattr.h"
 
 #define NF3NON		(0)
 #define NF3BAD		(8)
@@ -147,8 +148,6 @@ void nfs3svc_release_readdirplusres(struct svc_rqst *rqstp);
 
 void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 			    u64 cookie);
-void nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
-			     struct svc_fh *fhp);
 void nfsd3_fill_post_op_fh3(struct post_op_fh3 *post_op_fh,
 			    const struct svc_fh *fhp, u8 *data);
 
-- 
2.56.0

