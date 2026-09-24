Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA8474A2043
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269825; cv=none; b=hPTPXCL/vPp60xn4emF8QFgeu+yFfo9nPwKv4tbaiOSg3P5JoX0kaiQU8sFT6uHSh2vzpYPvyHRkKx0ScsLqugSEi0QggRvCqU1b4WG/Mmj6T3c+YhLJmKLu+u8KH6jHDOqM7g2Y1W3I+LcIlqddP6xP8FvV46f55SlCSh5JURQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269825; c=relaxed/simple;
	bh=igeju+7jE6//QU47GUpb9imAjCpcVOO8D0J7URhcWOY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YJO8fbYYQiYeJ3oehwZyi0chyT31p7GKrLw30LtU92Zs5PHf+826f6dT0IY+SzHY3Zy6gV0wTSOmkJE/v54MhezKOnvm8uqFqjCVbkkXg2946j0XCUJnUWnT3JFQxf+HWw23FdYSgqpmPUNPDpJcq9K5pijNKWuY6YzhsQPMul4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F4vhx0q8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F4vhx0q8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B3EC1F00899;
	Thu, 24 Sep 2026 17:10:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269821;
	bh=CeBjrdL/bCroblgw0czDQ8GUySwiw8XT8eihPHhb7tk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=F4vhx0q8DdBgdR7j4ohoQgKQh2cZMYxpeOrg50uev9sNXtiF0sPrZNy+/C9+C2pKC
	 s2mYwUZ6fBnmWUUidGXFIscbwFAQkAdnOz2jT0hb3CFTTPfKuHAj1A3SUd/06Dni8Q
	 5v/p8n5nvEHzzND9O+Cdp3gjF04ffHAOk1bjKnvkmi7v9T+guNTbOKhLNMrEy4WtJc
	 K2Oy3uTlStrBhm5QuCCyV2wJQQY8cy9jZXn5svEQreMv7w0XmCV/OGBmzO5cyPYrQ6
	 jrfwgvooA1zzYPnk8y6nzrc3HBKv71t9rlv/MmfMygHLAt+vxo0BWZaibTe2WGN7MW
	 tlw8eA2xa0vbQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 08/33] NFSD: Use xdrgen XDR functions for NFSv3 GETATTR procedure
Date: Thu, 24 Sep 2026 13:09:47 -0400
Message-ID: <20260924171012.3978-9-cel@kernel.org>
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

Replace the NFSPROC3_GETATTR entry in the nfsd_procedures3
array with an entry that dispatches the xdrgen-generated
nfs_svc_decode_GETATTR3args and nfs_svc_encode_GETATTR3res. Wrapper
structures bridge the generated xdrgen types and the legacy svc_fh
and kstat representations the NFSD VFS layer still uses. A few helper
functions are introduced which will be used here and in subsequent
patches.

The pc_argzero field is now set to zero for the NFSv3 GETATTR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive memset
unnecessary. The remaining argp fields are cleared as needed.

This refactor replaces the use of svcxdr_encode_fattr3(). Because
nfsd3_proc_getattr() now fills in the response attributes, the
fh_getattr() call is made in the proc function rather than in the XDR
result encoder, and the reference to the file handle can be released
directly by nfsd3_proc_getattr(). A separate ->pc_release callback is
thus no longer needed. This makes it straightforward to confirm that
the file handle is properly released during every error flow.

Following the precedent of commit 40ee5dc6af35 ("knfsd: 64 bit ino
support for NFS server"), lease_get_mtime() determines the file's
mtime for GETATTR (and later when filling in post-op attributes),
but is not used for WCC data. This seems odd to me; NFSv4 does not use
lease_get_mtime() at all, and not using it for WCC data seems like an
NFSv3 file's reported mtime values might vary depending on how the file
metadata is queried.

nfs3svc_encode_getattrres() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |   1 +
 fs/nfsd/nfs3proc.c                 | 161 ++++++++++++++++++++++++-----
 fs/nfsd/nfs3xdr.c                  |  19 ----
 fs/nfsd/nfs3xdr_gen.c              |  94 ++++++++---------
 fs/nfsd/nfs3xdr_gen.h              |   2 +-
 fs/nfsd/xdr3.h                     |   1 -
 include/linux/sunrpc/xdrgen/nfs3.h |   4 +-
 7 files changed, 187 insertions(+), 95 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index 9feabfda94e7..1ef99ec54103 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -95,6 +95,7 @@ enum nfsstat3 {
 	NFS3ERR_BADTYPE		= 10007,
 	NFS3ERR_JUKEBOX		= 10008
 };
+pragma big_endian nfsstat3;
 
 enum ftype3 {
 	NF3REG		= 1,
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 0c4109bde2bb..1facaccf408b 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -9,7 +9,10 @@
 #include <linux/ext2_fs.h>
 #include <linux/magic.h>
 #include <linux/namei.h>
+#include <linux/sunrpc/svc.h>
 
+#include "auth.h"
+#include "nfsd.h"
 #include "cache.h"
 #include "xdr3.h"
 #include "vfs.h"
@@ -24,6 +27,26 @@
 #define NFS3_FSF_DEFAULT		0x001b
 #define NFS3_FSF_BILLYBOY		0x0018
 
+/*
+ * Wrapper structures combine xdrgen types with legacy structures.
+ * The xdrgen field must be first so the structure can be cast
+ * to its XDR type for the RPC dispatch layer.
+ */
+
+struct GETATTR3args_wrapper {
+	struct GETATTR3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct GETATTR3args_wrapper, xdrgen) == 0);
+
+struct GETATTR3res_wrapper {
+	struct GETATTR3res	xdrgen;
+	struct kstat		stat;
+};
+
+static_assert(offsetof(struct GETATTR3res_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -129,6 +152,77 @@ static __be32 nfsd3_map_status(__be32 status)
 	return status;
 }
 
+/* XDR decoding has already checked that the FH length is valid */
+static __always_inline void
+nfsd3_fh3_to_svc_fh(struct svc_fh *fhp, const struct nfs_fh3 *fh3)
+{
+	fh_init(fhp, NFS3_FHSIZE);
+	fhp->fh_handle.fh_size = fh3->data.len;
+	memcpy(&fhp->fh_handle.fh_raw, fh3->data.data, fh3->data.len);
+}
+
+static __always_inline void
+nfsd3_timespec64_to_nfstime3(struct nfstime3 *dst,
+			     const struct timespec64 *src)
+{
+	dst->seconds = src->tv_sec;
+	dst->nseconds = src->tv_nsec;
+}
+
+static u32
+nfsd3_mode_to_ftype3(umode_t mode)
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
+
+	pr_warn_once("NFSD: unexpected file type: mode=0%o\n", mode);
+	return NF3REG;
+}
+
+static void
+nfsd3_stat_to_fattr3(struct svc_rqst *rqstp, struct fattr3 *fattr,
+		     const struct kstat *stat, const struct svc_fh *fhp)
+{
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
+
+	fattr->type = nfsd3_mode_to_ftype3(stat->mode);
+	fattr->mode = stat->mode & S_IALLUGO;
+	fattr->nlink = stat->nlink;
+	fattr->uid = from_kuid_munged(userns, stat->uid);
+	fattr->gid = from_kgid_munged(userns, stat->gid);
+	if (S_ISLNK(stat->mode) && stat->size > NFS3_MAXPATHLEN)
+		fattr->size = NFS3_MAXPATHLEN;
+	else
+		fattr->size = stat->size;
+	fattr->used = stat->blocks << 9;
+	fattr->rdev.specdata1 = MAJOR(stat->rdev);
+	fattr->rdev.specdata2 = MINOR(stat->rdev);
+
+	switch (fsid_source(fhp)) {
+	case FSIDSOURCE_FSID:
+		fattr->fsid = (u64)fhp->fh_export->ex_fsid;
+		break;
+	case FSIDSOURCE_UUID:
+		fattr->fsid = ((u64 *)fhp->fh_export->ex_uuid)[0];
+		fattr->fsid ^= ((u64 *)fhp->fh_export->ex_uuid)[1];
+		break;
+	default:
+		fattr->fsid = (u64)huge_encode_dev(fhp->fh_dentry->d_sb->s_dev);
+	}
+	fattr->fileid = stat->ino;
+
+	nfsd3_timespec64_to_nfstime3(&fattr->atime, &stat->atime);
+	nfsd3_timespec64_to_nfstime3(&fattr->mtime, &stat->mtime);
+	nfsd3_timespec64_to_nfstime3(&fattr->ctime, &stat->ctime);
+}
+
 /*
  * A full specification of each of the following NFSv3 procedures is
  * available in RFC 1813 Section 3.3.
@@ -149,26 +243,42 @@ static __be32 nfsd3_proc_null(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get a file's attributes
+/**
+ * nfsd3_proc_getattr - GETATTR: Get file attributes
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   GETATTR3res NFSPROC3_GETATTR(GETATTR3args) = 1;
  */
-static __be32
-nfsd3_proc_getattr(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_getattr(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+	struct GETATTR3args_wrapper *argp = rqstp->rq_argp;
+	struct GETATTR3res_wrapper *resp = rqstp->rq_resp;
+	struct kstat *statp = &resp->stat;
+	struct svc_fh *fhp = &argp->fh;
 
-	trace_nfsd_vfs_getattr(rqstp, &argp->fh);
-
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = fh_verify(rqstp, &resp->fh, 0,
-				 NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
-	if (resp->status != nfs_ok)
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.object);
+	trace_nfsd_vfs_getattr(rqstp, fhp);
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP |
+					NFSD_MAY_BYPASS_GSS_ON_ROOT);
+	if (resp->xdrgen.status != nfs_ok)
 		goto out;
 
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
+	resp->xdrgen.status = fh_getattr(fhp, statp);
+
 out:
-	resp->status = nfsd3_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok) {
+		lease_get_mtime(d_inode(fhp->fh_dentry), &statp->mtime);
+		nfsd3_stat_to_fattr3(rqstp, &resp->xdrgen.u.resok.obj_attributes,
+				     statp, fhp);
+	} else {
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -920,12 +1030,10 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
  * NFSv3 Server procedures.
  * Only the results of non-idempotent operations are cached.
  */
-#define nfs3svc_encode_attrstatres	nfs3svc_encode_attrstat
 #define nfs3svc_encode_wccstatres	nfs3svc_encode_wccstat
 #define nfsd3_mkdirargs			nfsd3_createargs
 #define nfsd3_readdirplusargs		nfsd3_readdirargs
 #define nfsd3_fhandleargs		nfsd_fhandle
-#define nfsd3_attrstatres		nfsd3_attrstat
 #define nfsd3_wccstatres		nfsd3_attrstat
 
 #define ST 1		/* status*/
@@ -947,16 +1055,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "NULL",
 	},
 	[NFSPROC3_GETATTR] = {
-		.pc_func = nfsd3_proc_getattr,
-		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = nfs3svc_encode_getattrres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd_fhandle),
-		.pc_argzero = sizeof(struct nfsd_fhandle),
-		.pc_ressize = sizeof(struct nfsd3_attrstatres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+AT,
-		.pc_name = "GETATTR",
+		.pc_func	= nfsd3_proc_getattr,
+		.pc_decode	= nfs_svc_decode_GETATTR3args,
+		.pc_encode	= nfs_svc_encode_GETATTR3res,
+		.pc_argsize	= sizeof(struct GETATTR3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct GETATTR3res_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_GETATTR3res_sz,
+		.pc_name	= "GETATTR",
 	},
 	[NFSPROC3_SETATTR] = {
 		.pc_func = nfsd3_proc_setattr,
@@ -1199,6 +1306,8 @@ static const struct svc_procedure nfsd_procedures3[22] = {
  * Storage requirements for XDR arguments and results.
  */
 union nfsd3_xdrstore {
+	struct GETATTR3args_wrapper	getattrargs;
+	struct GETATTR3res_wrapper	getattrres;
 	struct nfsd3_sattrargs		sattrargs;
 	struct nfsd3_diropargs		diropargs;
 	struct nfsd3_readargs		readargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index d163b51684d5..5802208f96b7 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -738,25 +738,6 @@ nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  * XDR encode functions
  */
 
-/* GETATTR */
-bool
-nfs3svc_encode_getattrres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		lease_get_mtime(d_inode(resp->fh.fh_dentry), &resp->stat.mtime);
-		if (!svcxdr_encode_fattr3(rqstp, xdr, &resp->fh, &resp->stat))
-			return false;
-		break;
-	}
-
-	return true;
-}
-
 /* SETATTR, REMOVE, RMDIR */
 bool
 nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
index 48b382ccfc81..e21ee0053129 100644
--- a/fs/nfsd/nfs3xdr_gen.c
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x
-// XDR specification modification time: Fri Jul 10 23:20:55 2026
+// XDR specification modification time: Fri Jul 10 23:21:45 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -112,10 +112,12 @@ xdrgen_decode_count3(struct xdr_stream *xdr, count3 *ptr)
 static bool __maybe_unused
 xdrgen_decode_nfsstat3(struct xdr_stream *xdr, nfsstat3 *ptr)
 {
+	__be32 raw;
 	u32 val;
 
-	if (xdr_stream_decode_u32(xdr, &val) < 0)
+	if (xdr_stream_decode_be32(xdr, &raw) < 0)
 		return false;
+	val = be32_to_cpu(raw);
 	/* Compiler may optimize to a range check for dense enums */
 	switch (val) {
 	case NFS3_OK:
@@ -151,7 +153,7 @@ xdrgen_decode_nfsstat3(struct xdr_stream *xdr, nfsstat3 *ptr)
 	default:
 		return false;
 	}
-	*ptr = val;
+	*ptr = raw;
 	return true;
 }
 
@@ -447,7 +449,7 @@ xdrgen_decode_GETATTR3res(struct xdr_stream *xdr, struct GETATTR3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_GETATTR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -503,7 +505,7 @@ xdrgen_decode_SETATTR3res(struct xdr_stream *xdr, struct SETATTR3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_SETATTR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -548,7 +550,7 @@ xdrgen_decode_LOOKUP3res(struct xdr_stream *xdr, struct LOOKUP3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_LOOKUP3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -593,7 +595,7 @@ xdrgen_decode_ACCESS3res(struct xdr_stream *xdr, struct ACCESS3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_ACCESS3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -636,7 +638,7 @@ xdrgen_decode_READLINK3res(struct xdr_stream *xdr, struct READLINK3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_READLINK3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -687,7 +689,7 @@ xdrgen_decode_READ3res(struct xdr_stream *xdr, struct READ3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_READ3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -762,7 +764,7 @@ xdrgen_decode_WRITE3res(struct xdr_stream *xdr, struct WRITE3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_WRITE3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -850,7 +852,7 @@ xdrgen_decode_CREATE3res(struct xdr_stream *xdr, struct CREATE3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_CREATE3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -897,7 +899,7 @@ xdrgen_decode_MKDIR3res(struct xdr_stream *xdr, struct MKDIR3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_MKDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -954,7 +956,7 @@ xdrgen_decode_SYMLINK3res(struct xdr_stream *xdr, struct SYMLINK3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_SYMLINK3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1033,7 +1035,7 @@ xdrgen_decode_MKNOD3res(struct xdr_stream *xdr, struct MKNOD3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_MKNOD3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1074,7 +1076,7 @@ xdrgen_decode_REMOVE3res(struct xdr_stream *xdr, struct REMOVE3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_REMOVE3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1115,7 +1117,7 @@ xdrgen_decode_RMDIR3res(struct xdr_stream *xdr, struct RMDIR3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_RMDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1162,7 +1164,7 @@ xdrgen_decode_RENAME3res(struct xdr_stream *xdr, struct RENAME3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_RENAME3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1209,7 +1211,7 @@ xdrgen_decode_LINK3res(struct xdr_stream *xdr, struct LINK3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_LINK3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1289,7 +1291,7 @@ xdrgen_decode_READDIR3res(struct xdr_stream *xdr, struct READDIR3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_READDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1375,7 +1377,7 @@ xdrgen_decode_READDIRPLUS3res(struct xdr_stream *xdr, struct READDIRPLUS3res *pt
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_READDIRPLUS3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1430,7 +1432,7 @@ xdrgen_decode_FSSTAT3res(struct xdr_stream *xdr, struct FSSTAT3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_FSSTAT3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1491,7 +1493,7 @@ xdrgen_decode_FSINFO3res(struct xdr_stream *xdr, struct FSINFO3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_FSINFO3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1544,7 +1546,7 @@ xdrgen_decode_PATHCONF3res(struct xdr_stream *xdr, struct PATHCONF3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_PATHCONF3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -1591,7 +1593,7 @@ xdrgen_decode_COMMIT3res(struct xdr_stream *xdr, struct COMMIT3res *ptr)
 	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_decode_COMMIT3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2043,7 +2045,7 @@ xdrgen_encode_count3(struct xdr_stream *xdr, const count3 value)
 static bool __maybe_unused
 xdrgen_encode_nfsstat3(struct xdr_stream *xdr, nfsstat3 value)
 {
-	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+	return xdr_stream_encode_be32(xdr, value) == XDR_UNIT;
 }
 
 static bool __maybe_unused
@@ -2308,7 +2310,7 @@ xdrgen_encode_GETATTR3res(struct xdr_stream *xdr, const struct GETATTR3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_GETATTR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2364,7 +2366,7 @@ xdrgen_encode_SETATTR3res(struct xdr_stream *xdr, const struct SETATTR3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_SETATTR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2409,7 +2411,7 @@ xdrgen_encode_LOOKUP3res(struct xdr_stream *xdr, const struct LOOKUP3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_LOOKUP3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2454,7 +2456,7 @@ xdrgen_encode_ACCESS3res(struct xdr_stream *xdr, const struct ACCESS3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_ACCESS3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2497,7 +2499,7 @@ xdrgen_encode_READLINK3res(struct xdr_stream *xdr, const struct READLINK3res *pt
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_READLINK3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2548,7 +2550,7 @@ xdrgen_encode_READ3res(struct xdr_stream *xdr, const struct READ3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_READ3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2609,7 +2611,7 @@ xdrgen_encode_WRITE3res(struct xdr_stream *xdr, const struct WRITE3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_WRITE3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2683,7 +2685,7 @@ xdrgen_encode_CREATE3res(struct xdr_stream *xdr, const struct CREATE3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_CREATE3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2730,7 +2732,7 @@ xdrgen_encode_MKDIR3res(struct xdr_stream *xdr, const struct MKDIR3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_MKDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2787,7 +2789,7 @@ xdrgen_encode_SYMLINK3res(struct xdr_stream *xdr, const struct SYMLINK3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_SYMLINK3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2866,7 +2868,7 @@ xdrgen_encode_MKNOD3res(struct xdr_stream *xdr, const struct MKNOD3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_MKNOD3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2907,7 +2909,7 @@ xdrgen_encode_REMOVE3res(struct xdr_stream *xdr, const struct REMOVE3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_REMOVE3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2948,7 +2950,7 @@ xdrgen_encode_RMDIR3res(struct xdr_stream *xdr, const struct RMDIR3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_RMDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -2995,7 +2997,7 @@ xdrgen_encode_RENAME3res(struct xdr_stream *xdr, const struct RENAME3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_RENAME3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -3042,7 +3044,7 @@ xdrgen_encode_LINK3res(struct xdr_stream *xdr, const struct LINK3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_LINK3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -3120,7 +3122,7 @@ xdrgen_encode_READDIR3res(struct xdr_stream *xdr, const struct READDIR3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_READDIR3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -3204,7 +3206,7 @@ xdrgen_encode_READDIRPLUS3res(struct xdr_stream *xdr, const struct READDIRPLUS3r
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_READDIRPLUS3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -3259,7 +3261,7 @@ xdrgen_encode_FSSTAT3res(struct xdr_stream *xdr, const struct FSSTAT3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_FSSTAT3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -3320,7 +3322,7 @@ xdrgen_encode_FSINFO3res(struct xdr_stream *xdr, const struct FSINFO3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_FSINFO3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -3373,7 +3375,7 @@ xdrgen_encode_PATHCONF3res(struct xdr_stream *xdr, const struct PATHCONF3res *pt
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_PATHCONF3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
@@ -3420,7 +3422,7 @@ xdrgen_encode_COMMIT3res(struct xdr_stream *xdr, const struct COMMIT3res *ptr)
 	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS3_OK:
+	case __constant_cpu_to_be32(NFS3_OK):
 		if (!xdrgen_encode_COMMIT3resok(xdr, &ptr->u.resok))
 			return false;
 		break;
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
index e2fbb583da92..58499ca28c43 100644
--- a/fs/nfsd/nfs3xdr_gen.h
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Fri Jul 10 23:20:55 2026 */
+/* XDR specification modification time: Fri Jul 10 23:21:45 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DECL_H
 #define _LINUX_XDRGEN_NFS3_DECL_H
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 35fb715e7c3f..2dcd36160ced 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -259,7 +259,6 @@ bool nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
-bool nfs3svc_encode_getattrres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_lookupres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 3afc4ffb6daa..785ebff351ce 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Fri Jul 10 23:20:55 2026 */
+/* XDR specification modification time: Fri Jul 10 23:21:45 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DEF_H
 #define _LINUX_XDRGEN_NFS3_DEF_H
@@ -83,7 +83,7 @@ enum nfsstat3 {
 	NFS3ERR_JUKEBOX = 10008,
 };
 
-typedef enum nfsstat3 nfsstat3;
+typedef __be32 nfsstat3;
 
 enum ftype3 {
 	NF3REG = 1,
-- 
2.55.0

