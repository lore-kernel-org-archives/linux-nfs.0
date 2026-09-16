Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2F0C55C1C5
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576150; cv=none; b=jlvXGG3GOmMycVmDPiaD98KKspao8hCrd7jmkB7Opw3oVK4BPZkjKIwkVo2K5LaAC34Cuq2+0roQJ3W5zbSzE05VD74KPoJMDjtmuYrlsz3eU6FTeiLBH9MvtmriMqYYRsvlz9H4Pjfcg9aK+BPqQDKcLPiu48GpdAsyRRAcLss=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576150; c=relaxed/simple;
	bh=9IRl8b9YY8xmJfc9JSenGT7iZt4AJ/tySbuBjIoF/LM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Rns2iDuWMuKEFAYpHEkJf77cAVaF09bTE1NQPzCz/vWuaHkYu27pYA6JNrv7mv+b3WzDRGZdQfLCp4AaBKVLy0wbgUtNyaT/1l/Fzuc7GkrUE7rKeI29ogJS5CD1NSNpQ0QQ6EcgZZhPoF0mlz1Iy648OFELw+GRscWaRKH9dT4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EXB57iDw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EXB57iDw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F073C1F00899;
	Wed, 16 Sep 2026 16:29:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576147;
	bh=tQ/MAD3baM6odTscJtT1xUEb74+yQlVFlFlG7+SIsoI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EXB57iDwaPzQPFhhZMegLGqdISj22zpf2LB9BrA8nm2JQp5qnA9eRqZhItHgXoL6n
	 ErAFzwCHlVIjZ5ywpmKku784oYV9BNRaimC9Y9fjDBJpXCDkCOWYktN1G1rzvaJ0Bl
	 rG9Y3PTK8rZ+5OtOqtilFzBKiyjy5TOrHocRfxy2prFEHwD7w7Z1YTHWAIRbOKxz8H
	 jFVwmNN177aOUYfGa14YD52tA78vJBzMMlLnZ/dh8jD4czPaLGyNSEWXFojhlsVF3x
	 Wem8DlrWyzpFn5F84G6QoSLsmQwl6kmyrqz+Dup8TYXFRQOF48fb1xiw68PaAAQX66
	 KQEHBP8sdfNog==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 07/27] NFSD: Use xdrgen XDR functions for NFSv2 GETATTR procedure
Date: Wed, 16 Sep 2026 12:28:38 -0400
Message-ID: <20260916162859.2051-10-cel@kernel.org>
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

Replace the NFSPROC_GETATTR entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_fhandle and nfs_svc_encode_attrstat. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh and kstat representations the NFSD VFS layer still uses. A
few helper functions are introduced which will be used here and
in subsequent patches.

The pc_argzero field is now set to zero for the NFSv2 GETATTR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

This refactor replaces the use of svcxdr_encode_fattr(), so the
reference to the file handle can be released directly by
nfsd_proc_getattr(). A separate ->pc_release callback is thus no
longer needed. This makes it straightforward to confirm that the
file handle is properly released during every error flow.

The new nfsd_mode_to_ftype() utility no longer maps socket and
FIFO devices to non-standard values: NFSOCK=6 which is outside
the ftype enum, and NFCHR for FIFOs which is semantically wrong.
The Linux NFS client implementation does not seem to use or
depend on these non-standard values. The new utility function
returns NFNON for both, which is the RFC-compliant behavior.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x    |   1 +
 fs/nfsd/nfs2xdr_gen.c              |  34 +++---
 fs/nfsd/nfs2xdr_gen.h              |   2 +-
 fs/nfsd/nfsproc.c                  | 170 ++++++++++++++++++++++++-----
 include/linux/sunrpc/xdrgen/nfs2.h |   4 +-
 5 files changed, 166 insertions(+), 45 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
index 5e6208d857f3..abec81cecbae 100644
--- a/Documentation/sunrpc/xdr/nfs2.x
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -44,6 +44,7 @@ enum nfsstat {
 	NFSERR_STALE		= 70,
 	NFSERR_WFLUSH		= 99
 };
+pragma big_endian nfsstat;
 
 enum ftype {
 	NFNON		= 0,
diff --git a/fs/nfsd/nfs2xdr_gen.c b/fs/nfsd/nfs2xdr_gen.c
index ae81d1731ac6..59bee2746650 100644
--- a/fs/nfsd/nfs2xdr_gen.c
+++ b/fs/nfsd/nfs2xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x
-// XDR specification modification time: Tue Sep  8 11:23:43 2026
+// XDR specification modification time: Tue Sep  8 11:24:48 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -10,10 +10,12 @@
 static bool __maybe_unused
 xdrgen_decode_nfsstat(struct xdr_stream *xdr, nfsstat *ptr)
 {
+	__be32 raw;
 	u32 val;
 
-	if (xdr_stream_decode_u32(xdr, &val) < 0)
+	if (xdr_stream_decode_be32(xdr, &raw) < 0)
 		return false;
+	val = be32_to_cpu(raw);
 	/* Compiler may optimize to a range check for dense enums */
 	switch (val) {
 	case NFS_OK:
@@ -38,7 +40,7 @@ xdrgen_decode_nfsstat(struct xdr_stream *xdr, nfsstat *ptr)
 	default:
 		return false;
 	}
-	*ptr = val;
+	*ptr = raw;
 	return true;
 }
 
@@ -157,7 +159,7 @@ xdrgen_decode_attrstat(struct xdr_stream *xdr, struct attrstat *ptr)
 	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_decode_fattr(xdr, &ptr->u.attributes))
 			return false;
 		break;
@@ -193,7 +195,7 @@ xdrgen_decode_diropres(struct xdr_stream *xdr, struct diropres *ptr)
 	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_decode_diropok(xdr, &ptr->u.diropok))
 			return false;
 		break;
@@ -219,7 +221,7 @@ xdrgen_decode_readlinkres(struct xdr_stream *xdr, struct readlinkres *ptr)
 	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_decode_path(xdr, &ptr->u.data))
 			return false;
 		break;
@@ -259,7 +261,7 @@ xdrgen_decode_readres(struct xdr_stream *xdr, struct readres *ptr)
 	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_decode_readresok(xdr, &ptr->u.readresok))
 			return false;
 		break;
@@ -374,7 +376,7 @@ xdrgen_decode_readdirres(struct xdr_stream *xdr, struct readdirres *ptr)
 	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_decode_readdirok(xdr, &ptr->u.readdirok))
 			return false;
 		break;
@@ -406,7 +408,7 @@ xdrgen_decode_statfsres(struct xdr_stream *xdr, struct statfsres *ptr)
 	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_decode_info(xdr, &ptr->u.info))
 			return false;
 		break;
@@ -579,7 +581,7 @@ bool nfs_svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 static bool __maybe_unused
 xdrgen_encode_nfsstat(struct xdr_stream *xdr, nfsstat value)
 {
-	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+	return xdr_stream_encode_be32(xdr, value) == XDR_UNIT;
 }
 
 static bool __maybe_unused
@@ -680,7 +682,7 @@ xdrgen_encode_attrstat(struct xdr_stream *xdr, const struct attrstat *ptr)
 	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_encode_fattr(xdr, &ptr->u.attributes))
 			return false;
 		break;
@@ -716,7 +718,7 @@ xdrgen_encode_diropres(struct xdr_stream *xdr, const struct diropres *ptr)
 	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_encode_diropok(xdr, &ptr->u.diropok))
 			return false;
 		break;
@@ -742,7 +744,7 @@ xdrgen_encode_readlinkres(struct xdr_stream *xdr, const struct readlinkres *ptr)
 	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_encode_path(xdr, ptr->u.data))
 			return false;
 		break;
@@ -784,7 +786,7 @@ xdrgen_encode_readres(struct xdr_stream *xdr, const struct readres *ptr)
 	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_encode_readresok(xdr, &ptr->u.readresok))
 			return false;
 		break;
@@ -899,7 +901,7 @@ xdrgen_encode_readdirres(struct xdr_stream *xdr, const struct readdirres *ptr)
 	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_encode_readdirok(xdr, &ptr->u.readdirok))
 			return false;
 		break;
@@ -931,7 +933,7 @@ xdrgen_encode_statfsres(struct xdr_stream *xdr, const struct statfsres *ptr)
 	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
 		return false;
 	switch (ptr->status) {
-	case NFS_OK:
+	case __constant_cpu_to_be32(NFS_OK):
 		if (!xdrgen_encode_info(xdr, &ptr->u.info))
 			return false;
 		break;
diff --git a/fs/nfsd/nfs2xdr_gen.h b/fs/nfsd/nfs2xdr_gen.h
index df800e42b80e..150f4215dbe3 100644
--- a/fs/nfsd/nfs2xdr_gen.h
+++ b/fs/nfsd/nfs2xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:23:43 2026 */
+/* XDR specification modification time: Tue Sep  8 11:24:48 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DECL_H
 #define _LINUX_XDRGEN_NFS2_DECL_H
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0a1c184217e0..0196a554de5e 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -9,6 +9,9 @@
 #include <linux/sunrpc/svc.h>
 
 #include "nfs2xdr_gen.h"
+
+#include "auth.h"
+#include "nfsd.h"
 #include "cache.h"
 #include "xdr.h"
 #include "vfs.h"
@@ -17,6 +20,26 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
+/*
+ * Wrapper structures combine xdrgen types with legacy structures.
+ * The xdrgen field must be first so the structure can be cast
+ * to its XDR type for the RPC dispatch layer.
+ */
+
+struct fhandle_wrapper {
+	fhandle			xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct fhandle_wrapper, xdrgen) == 0);
+
+struct attrstat_wrapper {
+	struct attrstat		xdrgen;
+	struct kstat		stat;
+};
+
+static_assert(offsetof(struct attrstat_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -42,6 +65,88 @@ static __be32 nfsd_map_status(__be32 status)
 	return status;
 }
 
+static __always_inline void
+nfsd_fhandle_to_svc_fh(struct svc_fh *fhp, const fhandle *fhandle)
+{
+	fh_init(fhp, NFS_FHSIZE);
+	fhp->fh_handle.fh_size = NFS_FHSIZE;
+	memcpy(&fhp->fh_handle.fh_raw, fhandle, NFS_FHSIZE);
+}
+
+static __always_inline void
+nfsd_timespec64_to_timeval(struct timeval *dst,
+			   const struct timespec64 *src)
+{
+	dst->seconds = src->tv_sec;
+	dst->useconds = src->tv_nsec / NSEC_PER_USEC;
+}
+
+static u32
+nfsd_mode_to_ftype(umode_t mode)
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
+nfsd_stat_to_fattr(struct svc_rqst *rqstp, struct fattr *fattr,
+		   const struct kstat *stat, const struct svc_fh *fhp)
+{
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
+	struct timespec64 time;
+	u32 fsid;
+
+	fattr->type = nfsd_mode_to_ftype(stat->mode);
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
+	}
+	fattr->fsid = fsid;
+	fattr->fileid = stat->ino;
+
+	nfsd_timespec64_to_timeval(&fattr->atime, &stat->atime);
+	time = stat->mtime;
+	lease_get_mtime(d_inode(fhp->fh_dentry), &time);
+	nfsd_timespec64_to_timeval(&fattr->mtime, &time);
+	nfsd_timespec64_to_timeval(&fattr->ctime, &stat->ctime);
+}
+
 /*
  * Because NFSv2 does not have an NFSERR_SYMLINK, Solaris returns
  * NFSERR_ISDIR when the target of a READ or WRITE is any object
@@ -77,26 +182,39 @@ static __be32 nfsd_proc_null(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Get a file's attributes
- * N.B. After this call resp->fh needs an fh_put
+/**
+ * nfsd_proc_getattr - GETATTR: Get file attributes
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   attrstat NFSPROC_GETATTR(fhandle) = 1;
  */
-static __be32
-nfsd_proc_getattr(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_getattr(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
-	struct nfsd_attrstat *resp = rqstp->rq_resp;
+	struct fhandle_wrapper *argp = rqstp->rq_argp;
+	struct attrstat_wrapper *resp = rqstp->rq_resp;
+	struct kstat *statp = &resp->stat;
+	struct svc_fh *fhp = &argp->fh;
 
-	trace_nfsd_vfs_getattr(rqstp, &argp->fh);
-
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = fh_verify(rqstp, &resp->fh, 0,
-				 NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
-	if (resp->status != nfs_ok)
+	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen);
+	trace_nfsd_vfs_getattr(rqstp, fhp);
+	resp->xdrgen.status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP |
+					NFSD_MAY_BYPASS_GSS_ON_ROOT);
+	if (resp->xdrgen.status != nfs_ok)
 		goto out;
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
+
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
 
@@ -698,16 +816,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "NULL",
 	},
 	[NFSPROC_GETATTR] = {
-		.pc_func = nfsd_proc_getattr,
-		.pc_decode = nfssvc_decode_fhandleargs,
-		.pc_encode = nfssvc_encode_attrstatres,
-		.pc_release = nfssvc_release_attrstat,
-		.pc_argsize = sizeof(struct nfsd_fhandle),
-		.pc_argzero = sizeof(struct nfsd_fhandle),
-		.pc_ressize = sizeof(struct nfsd_attrstat),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+AT,
-		.pc_name = "GETATTR",
+		.pc_func	= nfsd_proc_getattr,
+		.pc_decode	= nfs_svc_decode_fhandle,
+		.pc_encode	= nfs_svc_encode_attrstat,
+		.pc_argsize	= sizeof(struct fhandle_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct attrstat_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS2_attrstat_sz,
+		.pc_name	= "GETATTR",
 	},
 	[NFSPROC_SETATTR] = {
 		.pc_func = nfsd_proc_setattr,
@@ -896,6 +1013,7 @@ static const struct svc_procedure nfsd_procedures2[18] = {
  * Storage requirements for XDR arguments and results.
  */
 union nfsd_xdrstore {
+	struct fhandle_wrapper		fhandle;
 	struct nfsd_sattrargs	sattr;
 	struct nfsd_diropargs	dirop;
 	struct nfsd_readargs	read;
@@ -905,7 +1023,7 @@ union nfsd_xdrstore {
 	struct nfsd_linkargs	link;
 	struct nfsd_symlinkargs	symlink;
 	struct nfsd_readdirargs	readdir;
-	struct nfsd_attrstat	attrstat;
+	struct attrstat_wrapper		attrstat;
 	struct nfsd_diropres	diropres;
 	struct nfsd_readlinkres	readlinkres;
 	struct nfsd_readres	readres;
diff --git a/include/linux/sunrpc/xdrgen/nfs2.h b/include/linux/sunrpc/xdrgen/nfs2.h
index 4a022b670b0c..7e3af2ad90a7 100644
--- a/include/linux/sunrpc/xdrgen/nfs2.h
+++ b/include/linux/sunrpc/xdrgen/nfs2.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:23:43 2026 */
+/* XDR specification modification time: Tue Sep  8 11:24:48 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DEF_H
 #define _LINUX_XDRGEN_NFS2_DEF_H
@@ -40,7 +40,7 @@ enum nfsstat {
 	NFSERR_WFLUSH = 99,
 };
 
-typedef enum nfsstat nfsstat;
+typedef __be32 nfsstat;
 
 enum ftype {
 	NFNON = 0,
-- 
2.55.0

