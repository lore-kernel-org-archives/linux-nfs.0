Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677234;
	b=4JqmW3/pjtdvAlHBxz6imMDQ5/VVoYgPN+IyHsxVMzHrVAzvJ3sjrIZzI1vWc7s0esGp
	 QRyP0KU8FUK/lASr9zMc2pByKGufUut5wnJWsNEug/cFNwteBzVTTphOmsd+/FOskq72B
	 4WxvKx4M0sdIQUM8RnWDEEl3ZBpGAurBYoOmu/7pOMMF8M22DAEMz+u4NqKqNA9/5audW
	 B2yZTcOSfXWY6D9izqlCNY/06yfmK7El50OM75r0+1zLdF253vEkqixvviBe1u2JsdueC
	 klN9p10D+9iSili4OcKdr1ADFqwXuEQdPLRelp+I+m4Sxh9lsPiEDigzr0XR+KU+SYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677234;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=xs/T/sA+xQfDI+sF4FLiV3JxoRmH5f6YWqva1tyfI0s=;
	b=R/axfgc/kQNMpUp3VvRJC4HxMqVkfNPPKSekXn8G5ESltp8hfa64cwXeHzbGZEv5yyjX
	 ajSrdYgnk5uDWPVKItTwI4UFvEYDgqaqryAVTAVOuS7WQ18HHjXBFyMHyrG8ekYYiHuf6
	 8utyn5hPLlxxjQAP18aFVjtKwKNXFj+JsZ2EuYk3h3sEDVm8hkssKaBE/HKwz7k93Oj5z
	 9Ycf6ztmRFc75QImIiLvKR2L/7vxiPWhV8QxLxALnAt1gHoDXmwazfTI6JWAbTjQzev1K
	 bLAqHaCZXqZIe5Hx/sGSzVFZYPkboFvxhpKNMIBcveW1XjWlnsCOgL+EEm2WBq3mX0A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="kU13cN/r";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 912BF60A261A
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kU13cN/r
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD5CE1F00ADB;
	Thu, 22 Oct 2026 13:53:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677233;
	bh=xs/T/sA+xQfDI+sF4FLiV3JxoRmH5f6YWqva1tyfI0s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kU13cN/rurewnHrUTvIK7DCpQYROg4MXVTtU9rBCfK+to9dGZjR7csdBUjwKU4AlW
	 XTZO1hWSwPZEzSP5Ials4mmZu1BR7nIOMi+tUGGNYD1y5wgdeUocEBg8zgl0RIP+fA
	 y2shh1wsJJeGPp3RDduRzZXj7hfKGAw7fjNZ+Hnqo3oAqvOupEEHPk0G//PIAq7EAH
	 cGi12q6VCQIoiAgdHrmgbJfGL27QASn2oMc8r/Vsh4+rdthxdI2O7zua2EueK6kmTV
	 bbcR7RGJlVVYtAAHDrm2lBnup2DdrRqgx/7yt/sfpt0T9Z7knHuRQ2saczgIP03DWO
	 tNQLdX9MCGoKw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 10/17] NFSD: Switch to using the NFS_ACLv2 status codes
Date: Thu, 22 Oct 2026 09:53:34 -0400
Message-ID: <20261022135341.14265-11-cel@kernel.org>
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

In preparation for converting the NFS_ACLv2 procedures to use
generated XDR decoding and encoding, swap in the generated headers,
replace the usage of the conventional nfserr codes with the
RPC protocol-specified ACL2ERR constants.

This conversion still depends on the numeric equivalence of the
NFSv2 and NFS_ACLv2 status codes. This is because, for now, the
fh_getattr(), fh_verify(), and nfsd_access() functions return an
nfserr value instead of an errno.

The ACCESS3 and NFS_ACL bit mask symbolic constants are replaced as
well so that this TU continues to compile with the header generated
from RPC spec.

Include ACL2ERR_INVAL in the be32 status-code set and map -EINVAL
to it. The NFS_ACL protocol reports an invalid SETACL argument with
ACL2ERR_INVAL rather than ACL2ERR_IO (draft-ietf-nfsv4-nfs-acl
Section 3.5.4.2); the decode and SETACL conversion patches that
follow use this code to put that status on the wire.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs_acl2.x    |   1 +
 fs/nfsd/nfs2acl.c                      | 126 ++++++++++++++++---------
 fs/nfsd/nfs_acl2xdr_gen.c              |  30 +++---
 fs/nfsd/nfs_acl2xdr_gen.h              |   2 +-
 include/linux/sunrpc/xdrgen/nfs_acl2.h |   4 +-
 5 files changed, 103 insertions(+), 60 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs_acl2.x b/Documentation/sunrpc/xdr/nfs_acl2.x
index 165f50a898c0..8ec8bffbe77b 100644
--- a/Documentation/sunrpc/xdr/nfs_acl2.x
+++ b/Documentation/sunrpc/xdr/nfs_acl2.x
@@ -163,6 +163,7 @@ enum aclstat2 {
     ACL2ERR_DQUOT = 69,
     ACL2ERR_STALE = 70
 };
+pragma big_endian aclstat2;
 
 /*
  * NFS_ACL version 2 procedure arguments and results
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 777d754f016a..c0bc77467e79 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -5,16 +5,23 @@
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
+#include <linux/nfs3.h>
+#include <linux/nfs4.h>
+
+#include <uapi/linux/nfsd/debug.h>
+
+#include "nfs_acl2xdr_gen.h"
+
 #include "cache.h"
+#include "nfsd.h"
 #include "vfs.h"
 
-#define NFSDDBG_FACILITY		NFSDDBG_PROC
+#define NFSDDBG_FACILITY	NFSDDBG_PROC
+
+#define NFS_ACL_MASK		(NA_ACL | NA_ACLCNT | NA_DFACL | NA_DFACLCNT)
 
 struct posix_acl;
 
@@ -72,19 +79,19 @@ bool svcxdr_encode_fattr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
  * the behavior of the two versions to diverge if needed.
  */
 static const struct nfsd_access_map nfsd2_regaccess[] = {
-	{ ACCESS3_READ,		NFSD_MAY_READ				},
-	{ ACCESS3_EXECUTE,	NFSD_MAY_EXEC				},
-	{ ACCESS3_MODIFY,	NFSD_MAY_WRITE | NFSD_MAY_TRUNC		},
-	{ ACCESS3_EXTEND,	NFSD_MAY_WRITE				},
+	{ ACCESS2_READ,		NFSD_MAY_READ				},
+	{ ACCESS2_EXECUTE,	NFSD_MAY_EXEC				},
+	{ ACCESS2_MODIFY,	NFSD_MAY_WRITE | NFSD_MAY_TRUNC		},
+	{ ACCESS2_EXTEND,	NFSD_MAY_WRITE				},
 	{ 0,			0					}
 };
 
 static const struct nfsd_access_map nfsd2_diraccess[] = {
-	{ ACCESS3_READ,		NFSD_MAY_READ				},
-	{ ACCESS3_LOOKUP,	NFSD_MAY_EXEC				},
-	{ ACCESS3_MODIFY,	NFSD_MAY_EXEC | NFSD_MAY_WRITE | NFSD_MAY_TRUNC },
-	{ ACCESS3_EXTEND,	NFSD_MAY_EXEC | NFSD_MAY_WRITE		},
-	{ ACCESS3_DELETE,	NFSD_MAY_REMOVE				},
+	{ ACCESS2_READ,		NFSD_MAY_READ				},
+	{ ACCESS2_LOOKUP,	NFSD_MAY_EXEC				},
+	{ ACCESS2_MODIFY,	NFSD_MAY_EXEC | NFSD_MAY_WRITE | NFSD_MAY_TRUNC },
+	{ ACCESS2_EXTEND,	NFSD_MAY_EXEC | NFSD_MAY_WRITE		},
+	{ ACCESS2_DELETE,	NFSD_MAY_REMOVE				},
 	{ 0,			0					}
 };
 
@@ -96,10 +103,10 @@ static const struct nfsd_access_map nfsd2_diraccess[] = {
  * filesystem checks.
  */
 static const struct nfsd_access_map nfsd2_otheraccess[] = {
-	{ ACCESS3_READ,		NFSD_MAY_READ				},
-	{ ACCESS3_EXECUTE,	NFSD_MAY_EXEC				},
-	{ ACCESS3_MODIFY,	NFSD_MAY_WRITE | NFSD_MAY_LOCAL_ACCESS	},
-	{ ACCESS3_EXTEND,	NFSD_MAY_WRITE | NFSD_MAY_LOCAL_ACCESS	},
+	{ ACCESS2_READ,		NFSD_MAY_READ				},
+	{ ACCESS2_EXECUTE,	NFSD_MAY_EXEC				},
+	{ ACCESS2_MODIFY,	NFSD_MAY_WRITE | NFSD_MAY_LOCAL_ACCESS	},
+	{ ACCESS2_EXTEND,	NFSD_MAY_WRITE | NFSD_MAY_LOCAL_ACCESS	},
 	{ 0,			0					}
 };
 
@@ -109,15 +116,48 @@ static const struct nfsd_access_maps nfsd2_access_maps = {
 	.other		= nfsd2_otheraccess,
 };
 
+enum {
+	acl2_ok = __constant_cpu_to_be32(ACL2_OK),
+	acl2err_perm = __constant_cpu_to_be32(ACL2ERR_PERM),
+	acl2err_noent = __constant_cpu_to_be32(ACL2ERR_NOENT),
+	acl2err_io = __constant_cpu_to_be32(ACL2ERR_IO),
+	acl2err_acces = __constant_cpu_to_be32(ACL2ERR_ACCES),
+	acl2err_inval = __constant_cpu_to_be32(ACL2ERR_INVAL),
+	acl2err_nospc = __constant_cpu_to_be32(ACL2ERR_NOSPC),
+	acl2err_rofs = __constant_cpu_to_be32(ACL2ERR_ROFS),
+	acl2err_notsupp = __constant_cpu_to_be32(ACL2ERR_NOTSUPP),
+	acl2err_dquot = __constant_cpu_to_be32(ACL2ERR_DQUOT),
+	acl2err_stale = __constant_cpu_to_be32(ACL2ERR_STALE),
+};
+
+/* Ensure errno values do not leak onto the wire. */
+static __be32 nfsacld_map_errno(int errno)
+{
+	switch (errno) {
+	case 0:			return acl2_ok;
+	case -EPERM:		return acl2err_perm;
+	case -ENOENT:		return acl2err_noent;
+	case -EACCES:		return acl2err_acces;
+	case -EINVAL:		return acl2err_inval;
+	case -ENOSPC:		return acl2err_nospc;
+	case -EROFS:		return acl2err_rofs;
+	case -EOPNOTSUPP:	return acl2err_notsupp;
+	case -EDQUOT:		return acl2err_dquot;
+	case -EBADF:
+	case -ESTALE:		return acl2err_stale;
+	default:		return acl2err_io;
+	}
+}
+
 static __be32 nfsacld_map_status(__be32 status)
 {
 	switch (status) {
-	case nfserr_nofilehandle:
-	case nfserr_badhandle:
-		status = nfserr_stale;
+	case cpu_to_be32(NFS4ERR_NOFILEHANDLE):
+	case cpu_to_be32(NFS3ERR_BADHANDLE):
+		status = acl2err_stale;
 		break;
-	case nfserr_wrongsec:
-		status = nfserr_acces;
+	case cpu_to_be32(NFS4ERR_WRONGSEC):
+		status = acl2err_acces;
 		break;
 	}
 	return status;
@@ -147,39 +187,39 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst *rqstp)
 
 	fh = fh_copy(&resp->fh, &argp->fh);
 	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
-	if (resp->status != nfs_ok)
+	if (resp->status != acl2_ok)
 		goto out;
 
 	inode = d_inode(fh->fh_dentry);
 
 	if (argp->mask & ~NFS_ACL_MASK) {
-		resp->status = nfserr_io;
+		resp->status = acl2err_io;
 		goto out;
 	}
 	resp->mask = argp->mask;
 
 	resp->status = fh_getattr(fh, &resp->stat);
-	if (resp->status != nfs_ok)
+	if (resp->status != acl2_ok)
 		goto out;
 
-	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
+	if (resp->mask & (NA_ACL | NA_ACLCNT)) {
 		acl = get_inode_acl(inode, ACL_TYPE_ACCESS);
 		if (acl == NULL) {
 			/* Solaris returns the inode's minimum ACL. */
 			acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		}
 		if (IS_ERR(acl)) {
-			resp->status = nfserrno(PTR_ERR(acl));
+			resp->status = nfsacld_map_errno(PTR_ERR(acl));
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
+			resp->status = nfsacld_map_errno(PTR_ERR(acl));
 			goto fail;
 		}
 		resp->acl_default = acl;
@@ -213,7 +253,7 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 
 	fh = fh_copy(&resp->fh, &argp->fh);
 	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_SATTR);
-	if (resp->status != nfs_ok)
+	if (resp->status != acl2_ok)
 		goto out;
 
 	inode = d_inode(fh->fh_dentry);
@@ -225,13 +265,13 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
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
 		if (error)
@@ -253,7 +293,7 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 	inode_unlock(inode);
 	fh_drop_write(fh);
 out_errno:
-	resp->status = nfserrno(error);
+	resp->status = nfsacld_map_errno(error);
 	goto out;
 }
 
@@ -269,7 +309,7 @@ static __be32 nfsacld_proc_getattr(struct svc_rqst *rqstp)
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->status = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
-	if (resp->status != nfs_ok)
+	if (resp->status != acl2_ok)
 		goto out;
 	resp->status = fh_getattr(&resp->fh, &resp->stat);
 out:
@@ -294,7 +334,7 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 
 	resp->status = nfsd_access(rqstp, &resp->fh, &nfsd2_access_maps,
 				   &resp->access, NULL);
-	if (resp->status != nfs_ok)
+	if (resp->status != acl2_ok)
 		goto out;
 	resp->status = fh_getattr(&resp->fh, &resp->stat);
 out:
@@ -330,10 +370,10 @@ nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
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
 
@@ -368,17 +408,17 @@ nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	if (!svcxdr_encode_stat(xdr, resp->status))
 		return false;
 	switch (resp->status) {
-	case nfs_ok:
+	case acl2_ok:
 		inode = d_inode(dentry);
 		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
 			return false;
 		if (xdr_stream_encode_u32(xdr, resp->mask) < 0)
 			return false;
 		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_access,
-					   resp->mask & NFS_ACL, 0))
+					   resp->mask & NA_ACL, 0))
 			return false;
 		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_default,
-					   resp->mask & NFS_DFACL, NFS_ACL_DEFAULT))
+					   resp->mask & NA_DFACL, NA_ACL_DEFAULT))
 			return false;
 		break;
 	}
@@ -395,7 +435,7 @@ nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	if (!svcxdr_encode_stat(xdr, resp->status))
 		return false;
 	switch (resp->status) {
-	case nfs_ok:
+	case acl2_ok:
 		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
 			return false;
 		if (xdr_stream_encode_u32(xdr, resp->access) < 0)
diff --git a/fs/nfsd/nfs_acl2xdr_gen.c b/fs/nfsd/nfs_acl2xdr_gen.c
index 2c1b6a4e2ebc..59765733bd49 100644
--- a/fs/nfsd/nfs_acl2xdr_gen.c
+++ b/fs/nfsd/nfs_acl2xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl2.x
-// XDR specification modification time: Wed Jul 15 19:22:39 2026
+// XDR specification modification time: Wed Jul 15 19:23:04 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -133,10 +133,12 @@ xdrgen_decode_fattr(struct xdr_stream *xdr, struct fattr *ptr)
 static bool __maybe_unused
 xdrgen_decode_aclstat2(struct xdr_stream *xdr, aclstat2 *ptr)
 {
+	__be32 raw;
 	u32 val;
 
-	if (xdr_stream_decode_u32(xdr, &val) < 0)
+	if (xdr_stream_decode_be32(xdr, &raw) < 0)
 		return false;
+	val = be32_to_cpu(raw);
 	/* Compiler may optimize to a range check for dense enums */
 	switch (val) {
 	case ACL2_OK:
@@ -154,7 +156,7 @@ xdrgen_decode_aclstat2(struct xdr_stream *xdr, aclstat2 *ptr)
 	default:
 		return false;
 	}
-	*ptr = val;
+	*ptr = raw;
 	return true;
 }
 
@@ -184,7 +186,7 @@ xdrgen_decode_GETACL2res(struct xdr_stream *xdr, struct GETACL2res *ptr)
 	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_decode_GETACL2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -218,7 +220,7 @@ xdrgen_decode_SETACL2res(struct xdr_stream *xdr, struct SETACL2res *ptr)
 	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_decode_SETACL2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -250,7 +252,7 @@ xdrgen_decode_GETATTR2res(struct xdr_stream *xdr, struct GETATTR2res *ptr)
 	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_decode_GETATTR2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -286,7 +288,7 @@ xdrgen_decode_ACCESS2res(struct xdr_stream *xdr, struct ACCESS2res *ptr)
 	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_decode_ACCESS2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -322,7 +324,7 @@ xdrgen_decode_GETXATTRDIR2res(struct xdr_stream *xdr, struct GETXATTRDIR2res *pt
 	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_decode_GETXATTRDIR2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -521,7 +523,7 @@ xdrgen_encode_fattr(struct xdr_stream *xdr, const struct fattr *value)
 static bool __maybe_unused
 xdrgen_encode_aclstat2(struct xdr_stream *xdr, aclstat2 value)
 {
-	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+	return xdr_stream_encode_be32(xdr, value) == XDR_UNIT;
 }
 
 static bool __maybe_unused
@@ -550,7 +552,7 @@ xdrgen_encode_GETACL2res(struct xdr_stream *xdr, const struct GETACL2res *ptr)
 	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_encode_GETACL2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -584,7 +586,7 @@ xdrgen_encode_SETACL2res(struct xdr_stream *xdr, const struct SETACL2res *ptr)
 	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_encode_SETACL2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -616,7 +618,7 @@ xdrgen_encode_GETATTR2res(struct xdr_stream *xdr, const struct GETATTR2res *ptr)
 	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_encode_GETATTR2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -652,7 +654,7 @@ xdrgen_encode_ACCESS2res(struct xdr_stream *xdr, const struct ACCESS2res *ptr)
 	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_encode_ACCESS2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -688,7 +690,7 @@ xdrgen_encode_GETXATTRDIR2res(struct xdr_stream *xdr, const struct GETXATTRDIR2r
 	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case ACL2_OK:
+	case __constant_cpu_to_be32(ACL2_OK):
 		if (!xdrgen_encode_GETXATTRDIR2resok(xdr, &ptr->u.resok))
 			return false;
 		break;
diff --git a/fs/nfsd/nfs_acl2xdr_gen.h b/fs/nfsd/nfs_acl2xdr_gen.h
index 0152aa0b6695..a650fb7a3c83 100644
--- a/fs/nfsd/nfs_acl2xdr_gen.h
+++ b/fs/nfsd/nfs_acl2xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl2.x */
-/* XDR specification modification time: Wed Jul 15 19:22:39 2026 */
+/* XDR specification modification time: Wed Jul 15 19:23:04 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS_ACL2_DECL_H
 #define _LINUX_XDRGEN_NFS_ACL2_DECL_H
diff --git a/include/linux/sunrpc/xdrgen/nfs_acl2.h b/include/linux/sunrpc/xdrgen/nfs_acl2.h
index 2069015d0c14..cc0b0db4c738 100644
--- a/include/linux/sunrpc/xdrgen/nfs_acl2.h
+++ b/include/linux/sunrpc/xdrgen/nfs_acl2.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl2.x */
-/* XDR specification modification time: Wed Jul 15 19:22:39 2026 */
+/* XDR specification modification time: Wed Jul 15 19:23:04 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS_ACL2_DEF_H
 #define _LINUX_XDRGEN_NFS_ACL2_DEF_H
@@ -118,7 +118,7 @@ enum aclstat2 {
 	ACL2ERR_STALE = 70,
 };
 
-typedef enum aclstat2 aclstat2;
+typedef __be32 aclstat2;
 
 struct GETACL2args {
 	fhandle fh;
-- 
2.56.0

