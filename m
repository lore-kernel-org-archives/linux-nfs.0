Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050581;
	b=urPT6URoKuXCVXrtg+uzo/vLx1di8DW207IuJNdhErW/QzXVt6nuBX0D9lLOtR2qpBIH
	 JnsRkHmPUTcBbBnFojDw8lNIR0T/CPo5WT0AZOCKfQR27pfZUW7+Y8F4Cm+y/STsvb884
	 EYuyioHI15Mv0Jy1WQozCjnlDyWvLP1aHwNOxwBUTbkReI3XCOQvm2PW8cszlDREA7x4b
	 AdBVpnmoI90IKkgf3OZkfRg4Q5ymvXmhzovLy0BHOhO6G6Ew9wZGa22VK9GAm6LotcXTP
	 rmXXWY7cFQZr8GvheZAmnKNmFaznVICmOQ9lynMJ6+Aci8Nfnm6NaWBCun2UmONSHEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050581;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=xBMmguM0/fe0Lnhsy78f+W+LnfN1Q+MsFGVZk0licC8=;
	b=mKwxMYw8GZH6JrYmKPNmMmgSRAVwduidzvk7AmLZ5kmBEGKjvl0qAGrSECYbnmrZZq7W
	 dKxrSh3Ujwbvo0+S6GUIPHjQEuFknhBuPnb7qGokNvw6+x3/JOVS3o2dB0Cmt0vFnLkG8
	 gc61bHmwWzITjIgNi5sdBDWtHDrIEuS6efZ/ChM1za78WnuypIku4qgL83xxB4p5KcZDn
	 rTfY5T9DWTE4wT83Bir/8v0MvXZ+G7M830pE/GQYz1ol69Pzu2i1uNG/ZdYyl6lFxCNn0
	 yVb0KwiarCBCkJIjEGVdSD896gt44Tqblb4PonJx0BbPohRw9w6d5g8T5zseA7kSa3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C0iOMz+U;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D594606A330
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C0iOMz+U
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 809571F031E4;
	Mon, 26 Oct 2026 21:36:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050581;
	bh=xBMmguM0/fe0Lnhsy78f+W+LnfN1Q+MsFGVZk0licC8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=C0iOMz+UD/OkltnUdCKz7y5PBJ1RAZvhuhqjznID9wS+5lrPjaGjuUOh1zpSZWDXQ
	 x8QuJ8CZTOybNfl1gQApb9jNNW/dov4G8/zWNUCXmL8Tbda+vn9uLZiIkbxeaH2sme
	 XqZtInPOoL3xO6adQ+hthX0RRprwjb8jtTuY4UW/2zfXvXnzxpJUwWHYAAlnY5Wp9B
	 WEJ8vV3kx8MKJkTlAUlRWF9tE21AokWGNYRsApO5+Q0R+XCpZ0Mi6p3DIpmi4DorFV
	 q8l/ucSLhqkDzn0Vu7uTH0KEYDyy7sfdsXwv0u2ZpmgGqSXy1brg8FfsTbnwrRSMKj
	 5L7QetxoFDutQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 04/13] NFSD: New NFS_ACLv3 status codes
Date: Sun, 25 Oct 2026 11:16:13 -0400
Message-ID: <20261025151622.141025-5-cel@kernel.org>
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

In preparation for converting the NFS_ACLv3 procedures to use
generated XDR decoding and encoding, swap in the generated headers,
replace the usage of the conventional nfserr codes with the RPC
protocol-specified ACL3ERR constants.

Note that this conversion still depends on the numeric equivalence
of the NFSv3 and NFS_ACLv3 status codes.

nfsd3_map_errno() keeps the errno choices nfserrno() makes for the
errors that aclstat3 can express, including the filesystem
corruption errnos that map to ACL3ERR_IO and the transient ones
that map to ACL3ERR_JUKEBOX. Every other errno becomes
ACL3ERR_SERVERFAULT.

The NFS_ACL bit mask symbolic constants are replaced as well so that
this TU continues to compile with the header generated from the RPC
spec.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs_acl3.x    |  1 +
 fs/nfsd/nfs3acl.c                      | 99 +++++++++++++++++++-------
 fs/nfsd/nfs_acl3xdr_gen.c              | 22 +++---
 fs/nfsd/nfs_acl3xdr_gen.h              |  2 +-
 include/linux/sunrpc/xdrgen/nfs_acl3.h |  4 +-
 5 files changed, 90 insertions(+), 38 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs_acl3.x b/Documentation/sunrpc/xdr/nfs_acl3.x
index b0e1d2e1fd43..b355705bf970 100644
--- a/Documentation/sunrpc/xdr/nfs_acl3.x
+++ b/Documentation/sunrpc/xdr/nfs_acl3.x
@@ -189,6 +189,7 @@ enum aclstat3 {
     ACL3ERR_SERVERFAULT = 10006,
     ACL3ERR_JUKEBOX = 10008
 };
+pragma big_endian aclstat3;
 
 /*
  * NFS_ACL version 3 procedure arguments and results
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 98de13b44a80..536593ba59bc 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -5,16 +5,19 @@
  * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
  */
 
-#include "nfsd.h"
-#include "nfserr.h"
-
-#include <linux/nfsacl.h>
-#include <uapi/linux/nfsacl.h>
 #include <linux/gfp.h>
+#include <linux/fs.h>
+#include <linux/nfsacl.h>
+#include <linux/nfs4.h>
+
+#include "nfs_acl3xdr_gen.h"
 
 #include "cache.h"
+#include "nfsd.h"
 #include "vfs.h"
 
+#define NFS_ACL_MASK		(NA_ACL | NA_ACLCNT | NA_DFACL | NA_DFACLCNT)
+
 struct nfsd3_getaclargs {
 	struct svc_fh		fh;
 	__u32			mask;
@@ -48,14 +51,60 @@ bool svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status);
 bool svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 				const struct svc_fh *fhp);
 
+enum {
+	acl3_ok = __constant_cpu_to_be32(ACL3_OK),
+	acl3err_perm = __constant_cpu_to_be32(ACL3ERR_PERM),
+	acl3err_noent = __constant_cpu_to_be32(ACL3ERR_NOENT),
+	acl3err_io = __constant_cpu_to_be32(ACL3ERR_IO),
+	acl3err_acces = __constant_cpu_to_be32(ACL3ERR_ACCES),
+	acl3err_inval = __constant_cpu_to_be32(ACL3ERR_INVAL),
+	acl3err_nospc = __constant_cpu_to_be32(ACL3ERR_NOSPC),
+	acl3err_rofs = __constant_cpu_to_be32(ACL3ERR_ROFS),
+	acl3err_dquot = __constant_cpu_to_be32(ACL3ERR_DQUOT),
+	acl3err_stale = __constant_cpu_to_be32(ACL3ERR_STALE),
+	acl3err_badhandle = __constant_cpu_to_be32(ACL3ERR_BADHANDLE),
+	acl3err_notsupp = __constant_cpu_to_be32(ACL3ERR_NOTSUPP),
+	acl3err_serverfault = __constant_cpu_to_be32(ACL3ERR_SERVERFAULT),
+	acl3err_jukebox = __constant_cpu_to_be32(ACL3ERR_JUKEBOX),
+};
+
+/* Ensure errno values do not leak onto the wire. */
+static __be32 nfsd3_map_errno(int errno)
+{
+	switch (errno) {
+	case 0:			return acl3_ok;
+	case -EPERM:
+	case -ENOKEY:		return acl3err_perm;
+	case -ENOENT:		return acl3err_noent;
+	case -EIO:
+	case -EREMOTEIO:
+	case -ETXTBSY:
+	case -EUCLEAN:
+	case -EBADMSG:		return acl3err_io;
+	case -EACCES:		return acl3err_acces;
+	case -EINVAL:		return acl3err_inval;
+	case -ENOSPC:		return acl3err_nospc;
+	case -EROFS:		return acl3err_rofs;
+	case -EDQUOT:		return acl3err_dquot;
+	case -EBADF:
+	case -ESTALE:		return acl3err_stale;
+	case -EOPNOTSUPP:	return acl3err_notsupp;
+	case -ENOMEM:
+	case -EAGAIN:
+	case -ERESTARTSYS:
+	case -ETIMEDOUT:	return acl3err_jukebox;
+	default:		return acl3err_serverfault;
+	}
+}
+
 static __be32 nfsd3_map_status(__be32 status)
 {
 	switch (status) {
-	case nfserr_nofilehandle:
-		status = nfserr_badhandle;
+	case cpu_to_be32(NFS4ERR_NOFILEHANDLE):
+		status = acl3err_badhandle;
 		break;
-	case nfserr_wrongsec:
-		status = nfserr_acces;
+	case cpu_to_be32(NFS4ERR_WRONGSEC):
+		status = acl3err_acces;
 		break;
 	}
 	return status;
@@ -83,35 +132,35 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst *rqstp)
 
 	fh = fh_copy(&resp->fh, &argp->fh);
 	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
-	if (resp->status != nfs_ok)
+	if (resp->status != acl3_ok)
 		goto out;
 
 	inode = d_inode(fh->fh_dentry);
 
 	if (argp->mask & ~NFS_ACL_MASK) {
-		resp->status = nfserr_inval;
+		resp->status = acl3err_inval;
 		goto out;
 	}
 	resp->mask = argp->mask;
 
-	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
+	if (resp->mask & (NA_ACL | NA_ACLCNT)) {
 		acl = get_inode_acl(inode, ACL_TYPE_ACCESS);
 		if (acl == NULL) {
 			/* Solaris returns the inode's minimum ACL. */
 			acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		}
 		if (IS_ERR(acl)) {
-			resp->status = nfserrno(PTR_ERR(acl));
+			resp->status = nfsd3_map_errno(PTR_ERR(acl));
 			goto fail;
 		}
 		resp->acl_access = acl;
 	}
-	if (resp->mask & (NFS_DFACL|NFS_DFACLCNT)) {
+	if (resp->mask & (NA_DFACL | NA_DFACLCNT)) {
 		/* Check how Solaris handles requests for the Default ACL
 		   of a non-directory! */
 		acl = get_inode_acl(inode, ACL_TYPE_DEFAULT);
 		if (IS_ERR(acl)) {
-			resp->status = nfserrno(PTR_ERR(acl));
+			resp->status = nfsd3_map_errno(PTR_ERR(acl));
 			goto fail;
 		}
 		resp->acl_default = acl;
@@ -143,7 +192,7 @@ static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 
 	fh = fh_copy(&resp->fh, &argp->fh);
 	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_SATTR);
-	if (resp->status != nfs_ok)
+	if (resp->status != acl3_ok)
 		goto out;
 
 	inode = d_inode(fh->fh_dentry);
@@ -155,13 +204,13 @@ static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 	inode_lock(inode);
 
 	error = 0;
-	if (argp->mask & NFS_ACL) {
+	if (argp->mask & NA_ACL) {
 		error = set_posix_acl(&nop_mnt_idmap, fh->fh_dentry,
 				      ACL_TYPE_ACCESS, argp->acl_access);
 		if (error)
 			goto out_drop_lock;
 	}
-	if (argp->mask & NFS_DFACL) {
+	if (argp->mask & NA_DFACL) {
 		error = set_posix_acl(&nop_mnt_idmap, fh->fh_dentry,
 				      ACL_TYPE_DEFAULT, argp->acl_default);
 	}
@@ -170,7 +219,7 @@ static __be32 nfsd3_proc_setacl(struct svc_rqst *rqstp)
 	inode_unlock(inode);
 	fh_drop_write(fh);
 out_errno:
-	resp->status = nfserrno(error);
+	resp->status = nfsd3_map_errno(error);
 out:
 	/* argp->acl_{access,default} are released in nfs3svc_release_setacl. */
 	resp->status = nfsd3_map_status(resp->status);
@@ -205,10 +254,10 @@ nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		return false;
 	if (argp->mask & ~NFS_ACL_MASK)
 		return false;
-	if (!nfs_stream_decode_acl(xdr, NULL, (argp->mask & NFS_ACL) ?
+	if (!nfs_stream_decode_acl(xdr, NULL, (argp->mask & NA_ACL) ?
 				   &argp->acl_access : NULL))
 		return false;
-	if (!nfs_stream_decode_acl(xdr, NULL, (argp->mask & NFS_DFACL) ?
+	if (!nfs_stream_decode_acl(xdr, NULL, (argp->mask & NA_DFACL) ?
 				   &argp->acl_default : NULL))
 		return false;
 
@@ -230,7 +279,7 @@ nfs3svc_encode_getaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
 		return false;
 	switch (resp->status) {
-	case nfs_ok:
+	case acl3_ok:
 		inode = d_inode(dentry);
 		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
 			return false;
@@ -238,11 +287,11 @@ nfs3svc_encode_getaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 			return false;
 
 		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_access,
-					   resp->mask & NFS_ACL, 0))
+					   resp->mask & NA_ACL, 0))
 			return false;
 		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_default,
-					   resp->mask & NFS_DFACL,
-					   NFS_ACL_DEFAULT))
+					   resp->mask & NA_DFACL,
+					   NA_ACL_DEFAULT))
 			return false;
 		break;
 	default:
diff --git a/fs/nfsd/nfs_acl3xdr_gen.c b/fs/nfsd/nfs_acl3xdr_gen.c
index 5bdeb29addfe..05e35653a0fc 100644
--- a/fs/nfsd/nfs_acl3xdr_gen.c
+++ b/fs/nfsd/nfs_acl3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl3.x
-// XDR specification modification time: Fri Jul 10 20:10:15 2026
+// XDR specification modification time: Fri Jul 10 20:12:08 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -198,10 +198,12 @@ xdrgen_decode_post_op_attr(struct xdr_stream *xdr, struct post_op_attr *ptr)
 static bool __maybe_unused
 xdrgen_decode_aclstat3(struct xdr_stream *xdr, aclstat3 *ptr)
 {
+	__be32 raw;
 	u32 val;
 
-	if (xdr_stream_decode_u32(xdr, &val) < 0)
+	if (xdr_stream_decode_be32(xdr, &raw) < 0)
 		return false;
+	val = be32_to_cpu(raw);
 	/* Compiler may optimize to a range check for dense enums */
 	switch (val) {
 	case ACL3_OK:
@@ -222,7 +224,7 @@ xdrgen_decode_aclstat3(struct xdr_stream *xdr, aclstat3 *ptr)
 	default:
 		return false;
 	}
-	*ptr = val;
+	*ptr = raw;
 	return true;
 }
 
@@ -260,7 +262,7 @@ xdrgen_decode_GETACL3res(struct xdr_stream *xdr, struct GETACL3res *ptr)
 	if (!xdrgen_decode_aclstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL3_OK:
+	case __constant_cpu_to_be32(ACL3_OK):
 		if (!xdrgen_decode_GETACL3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -303,7 +305,7 @@ xdrgen_decode_SETACL3res(struct xdr_stream *xdr, struct SETACL3res *ptr)
 	if (!xdrgen_decode_aclstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL3_OK:
+	case __constant_cpu_to_be32(ACL3_OK):
 		if (!xdrgen_decode_SETACL3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -340,7 +342,7 @@ xdrgen_decode_GETXATTRDIR3res(struct xdr_stream *xdr, struct GETXATTRDIR3res *pt
 	if (!xdrgen_decode_aclstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL3_OK:
+	case __constant_cpu_to_be32(ACL3_OK):
 		if (!xdrgen_decode_GETXATTRDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -573,7 +575,7 @@ xdrgen_encode_post_op_attr(struct xdr_stream *xdr, const struct post_op_attr *pt
 static bool __maybe_unused
 xdrgen_encode_aclstat3(struct xdr_stream *xdr, aclstat3 value)
 {
-	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+	return xdr_stream_encode_be32(xdr, value) == XDR_UNIT;
 }
 
 static bool __maybe_unused
@@ -610,7 +612,7 @@ xdrgen_encode_GETACL3res(struct xdr_stream *xdr, const struct GETACL3res *ptr)
 	if (!xdrgen_encode_aclstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL3_OK:
+	case __constant_cpu_to_be32(ACL3_OK):
 		if (!xdrgen_encode_GETACL3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -653,7 +655,7 @@ xdrgen_encode_SETACL3res(struct xdr_stream *xdr, const struct SETACL3res *ptr)
 	if (!xdrgen_encode_aclstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL3_OK:
+	case __constant_cpu_to_be32(ACL3_OK):
 		if (!xdrgen_encode_SETACL3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -690,7 +692,7 @@ xdrgen_encode_GETXATTRDIR3res(struct xdr_stream *xdr, const struct GETXATTRDIR3r
 	if (!xdrgen_encode_aclstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL3_OK:
+	case __constant_cpu_to_be32(ACL3_OK):
 		if (!xdrgen_encode_GETXATTRDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
diff --git a/fs/nfsd/nfs_acl3xdr_gen.h b/fs/nfsd/nfs_acl3xdr_gen.h
index d778004ba26a..8d960c0506db 100644
--- a/fs/nfsd/nfs_acl3xdr_gen.h
+++ b/fs/nfsd/nfs_acl3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl3.x */
-/* XDR specification modification time: Fri Jul 10 20:10:15 2026 */
+/* XDR specification modification time: Fri Jul 10 20:12:08 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS_ACL3_DECL_H
 #define _LINUX_XDRGEN_NFS_ACL3_DECL_H
diff --git a/include/linux/sunrpc/xdrgen/nfs_acl3.h b/include/linux/sunrpc/xdrgen/nfs_acl3.h
index 8758450dbca0..4d71e4907261 100644
--- a/include/linux/sunrpc/xdrgen/nfs_acl3.h
+++ b/include/linux/sunrpc/xdrgen/nfs_acl3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl3.x */
-/* XDR specification modification time: Fri Jul 10 20:10:15 2026 */
+/* XDR specification modification time: Fri Jul 10 20:12:08 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS_ACL3_DEF_H
 #define _LINUX_XDRGEN_NFS_ACL3_DEF_H
@@ -149,7 +149,7 @@ enum aclstat3 {
 	ACL3ERR_JUKEBOX = 10008,
 };
 
-typedef enum aclstat3 aclstat3;
+typedef __be32 aclstat3;
 
 struct GETACL3args {
 	struct nfs_fh3 fh;
-- 
2.56.0

