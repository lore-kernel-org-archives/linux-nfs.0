Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C3F9545DB1
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576146; cv=none; b=cWrhPgh6J9hnochMvBhryUtH1NO/JcUNPGax/TqO2rmCRBPamICVM/WCBpMybiR+AOEKZyvXGcOH4PqglE8gU8t0mMv6dBKD3QfTSu+XhWCqhS/Xi77TsSouERdMeSKN2qvru0wosmr2BX4Tv073+F9BVvI+VyydFXic7QLuW6Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576146; c=relaxed/simple;
	bh=7gDAuE3UjiEZU+vyT+RfZmYesWUaVYJ83S008B/aRWE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iiAJ3aaeKFX5mEEnM/JKVj/qeIG/REJClwzJsb7gU0YDnpZYTedGclif7gH4AW4W/I2Xs6My2JBjboVru0lSzP9O14+71GAkn0t8pTW4DcBKU1V2MPY4Wlfkg+ZTh/VTfuoClywDVeFB0SMDeYbbuVWFGGQi6gUEoFxopniArZ4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=h+XIw7w5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="h+XIw7w5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 659FA1F0089A;
	Wed, 16 Sep 2026 16:29:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576143;
	bh=Wo+pLe0tk5jG5x2/8HyVeRQgJHuO2RRO+wdgT2kCeD4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=h+XIw7w5OBysmDf7mn7JqAvFtPMJ9V8vEB1Y9Ew7Wuf9C4l9Fm/VxMW1DiBjvdn9W
	 Enmjd5KMBzw3ESl2Ng/4oIsShabBPpC0xaLYxv4BWaoLBAq/qpPEbiEZM8y5l6CRg3
	 hxhOePX1jrC1Z7OdW4p/d6OH+QsfBoBoT0dotFxRxpK7U6FaGMFsYH1bo+H8yvw8s2
	 VN3hNrYTZfbvNF8NrBIFI7syR3UTFRviebxclwuraU8H9iAIbOH2WFUBKWy8Gj6sGN
	 WIrzwaib1UsB+gXCSt2U+qTBB/XsrExk0o/DECTEoe+Au1HkIEbLLYDGMnvmm49gYa
	 yfAnrpZ1sXycA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 02/27] NFSD: Add infrastructure for generating NFSv2 XDR encoders and decoders
Date: Wed, 16 Sep 2026 12:28:32 -0400
Message-ID: <20260916162859.2051-4-cel@kernel.org>
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

NFSD's NFSv2 XDR codecs are hand-maintained; they are being converted
to xdrgen-generated code one RPC procedure at a time. The first step
is to generate and commit the xdrgen C code based on nfs2.x. The
generated code can be refreshed any time nfs2.x is modified by
running "(cd fs/nfsd && make xdrgen)".

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x    |    2 +
 fs/nfsd/Makefile                   |   15 +-
 fs/nfsd/nfs2xdr_gen.c              | 1054 ++++++++++++++++++++++++++++
 fs/nfsd/nfs2xdr_gen.h              |   35 +
 include/linux/sunrpc/xdrgen/nfs2.h |  298 ++++++++
 5 files changed, 1402 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfsd/nfs2xdr_gen.c
 create mode 100644 fs/nfsd/nfs2xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs2.h

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
index 8a05975ad65a..5e6208d857f3 100644
--- a/Documentation/sunrpc/xdr/nfs2.x
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -10,6 +10,8 @@
  * or other IP ownership notice.
  */
 
+pragma header nfs2;
+
 const NFS_MAXDATA = 8192;
 const NFS_MAXPATHLEN = 1024;
 const NFS_MAXNAMLEN = 255;
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index f0da4d69dc74..05fb814f760b 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -14,7 +14,7 @@ nfsd-y 			+= nfssvc.o nfsctl.o nfsfh.o vfs.o \
 			   export.o auth.o lockd.o nfscache.o \
 			   stats.o filecache.o nfs3proc.o nfs3xdr.o \
 			   netlink.o
-nfsd-$(CONFIG_NFSD_V2) += nfsproc.o nfsxdr.o
+nfsd-$(CONFIG_NFSD_V2) += nfsproc.o nfsxdr.o nfs2xdr_gen.o
 nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
@@ -37,13 +37,24 @@ nfsd-$(CONFIG_DEBUG_FS) += debugfs.o
 #
 .PHONY: xdrgen
 
-xdrgen: ../../include/linux/sunrpc/xdrgen/nfs4_1.h nfs4xdr_gen.h nfs4xdr_gen.c
+XDRGEN_DEFINITIONS	= ../../include/linux/sunrpc/xdrgen/nfs2.h \
+			  ../../include/linux/sunrpc/xdrgen/nfs4_1.h
+XDRGEN_DECLARATIONS	= nfs2xdr_gen.h nfs4xdr_gen.h
+XDRGEN_SOURCE		= nfs2xdr_gen.c nfs4xdr_gen.c
 
+xdrgen: $(XDRGEN_DEFINITIONS) $(XDRGEN_DECLARATIONS) $(XDRGEN_SOURCE)
+
+../../include/linux/sunrpc/xdrgen/nfs2.h: ../../Documentation/sunrpc/xdr/nfs2.x
+	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 ../../include/linux/sunrpc/xdrgen/nfs4_1.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 
+nfs2xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs2.x
+	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 nfs4xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 
+nfs2xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs2.x
+	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
 nfs4xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
diff --git a/fs/nfsd/nfs2xdr_gen.c b/fs/nfsd/nfs2xdr_gen.c
new file mode 100644
index 000000000000..ae81d1731ac6
--- /dev/null
+++ b/fs/nfsd/nfs2xdr_gen.c
@@ -0,0 +1,1054 @@
+// SPDX-License-Identifier: GPL-2.0
+// Generated by xdrgen. Manual edits will be lost.
+// XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x
+// XDR specification modification time: Tue Sep  8 11:23:43 2026
+
+#include <linux/sunrpc/svc.h>
+
+#include "nfs2xdr_gen.h"
+
+static bool __maybe_unused
+xdrgen_decode_nfsstat(struct xdr_stream *xdr, nfsstat *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case NFS_OK:
+	case NFSERR_PERM:
+	case NFSERR_NOENT:
+	case NFSERR_IO:
+	case NFSERR_NXIO:
+	case NFSERR_ACCES:
+	case NFSERR_EXIST:
+	case NFSERR_NODEV:
+	case NFSERR_NOTDIR:
+	case NFSERR_ISDIR:
+	case NFSERR_FBIG:
+	case NFSERR_NOSPC:
+	case NFSERR_ROFS:
+	case NFSERR_NAMETOOLONG:
+	case NFSERR_NOTEMPTY:
+	case NFSERR_DQUOT:
+	case NFSERR_STALE:
+	case NFSERR_WFLUSH:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ftype(struct xdr_stream *xdr, ftype *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case NFNON:
+	case NFREG:
+	case NFDIR:
+	case NFBLK:
+	case NFCHR:
+	case NFLNK:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_fhandle(struct xdr_stream *xdr, fhandle *ptr)
+{
+	return xdr_stream_decode_opaque_fixed(xdr, ptr, NFS_FHSIZE) == 0;
+}
+
+static bool __maybe_unused
+xdrgen_decode_nfscookie(struct xdr_stream *xdr, nfscookie *ptr)
+{
+	return xdr_stream_decode_opaque_fixed(xdr, ptr, NFS_COOKIESIZE) == 0;
+}
+
+static bool __maybe_unused
+xdrgen_decode_timeval(struct xdr_stream *xdr, struct timeval *ptr)
+{
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->seconds))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->useconds))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_fattr(struct xdr_stream *xdr, struct fattr *ptr)
+{
+	if (!xdrgen_decode_ftype(xdr, &ptr->type))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->mode))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->nlink))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->uid))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->gid))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->size))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->blocksize))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->rdev))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->blocks))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->fsid))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->fileid))
+		return false;
+	if (!xdrgen_decode_timeval(xdr, &ptr->atime))
+		return false;
+	if (!xdrgen_decode_timeval(xdr, &ptr->mtime))
+		return false;
+	if (!xdrgen_decode_timeval(xdr, &ptr->ctime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_sattr(struct xdr_stream *xdr, struct sattr *ptr)
+{
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->mode))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->uid))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->gid))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->size))
+		return false;
+	if (!xdrgen_decode_timeval(xdr, &ptr->atime))
+		return false;
+	if (!xdrgen_decode_timeval(xdr, &ptr->mtime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_filename(struct xdr_stream *xdr, filename *ptr)
+{
+	return xdrgen_decode_string(xdr, ptr, NFS_MAXNAMLEN);
+}
+
+static bool __maybe_unused
+xdrgen_decode_path(struct xdr_stream *xdr, path *ptr)
+{
+	return xdrgen_decode_string(xdr, ptr, NFS_MAXPATHLEN);
+}
+
+static bool __maybe_unused
+xdrgen_decode_attrstat(struct xdr_stream *xdr, struct attrstat *ptr)
+{
+	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_decode_fattr(xdr, &ptr->u.attributes))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_diropargs(struct xdr_stream *xdr, struct diropargs *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->dir))
+		return false;
+	if (!xdrgen_decode_filename(xdr, &ptr->name))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_diropok(struct xdr_stream *xdr, struct diropok *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_fattr(xdr, &ptr->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_diropres(struct xdr_stream *xdr, struct diropres *ptr)
+{
+	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_decode_diropok(xdr, &ptr->u.diropok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_sattrargs(struct xdr_stream *xdr, struct sattrargs *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_sattr(xdr, &ptr->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_readlinkres(struct xdr_stream *xdr, struct readlinkres *ptr)
+{
+	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_decode_path(xdr, &ptr->u.data))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_readargs(struct xdr_stream *xdr, struct readargs *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->offset))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->count))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->totalcount))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_readresok(struct xdr_stream *xdr, struct readresok *ptr)
+{
+	if (!xdrgen_decode_fattr(xdr, &ptr->attributes))
+		return false;
+	if (!xdrgen_decode_opaque(xdr, &ptr->data, NFS_MAXDATA))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_readres(struct xdr_stream *xdr, struct readres *ptr)
+{
+	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_decode_readresok(xdr, &ptr->u.readresok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_writeargs(struct xdr_stream *xdr, struct writeargs *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->beginoffset))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->offset))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->totalcount))
+		return false;
+	if (!xdrgen_decode_opaque(xdr, &ptr->data, NFS_MAXDATA))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_createargs(struct xdr_stream *xdr, struct createargs *ptr)
+{
+	if (!xdrgen_decode_diropargs(xdr, &ptr->where))
+		return false;
+	if (!xdrgen_decode_sattr(xdr, &ptr->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_renameargs(struct xdr_stream *xdr, struct renameargs *ptr)
+{
+	if (!xdrgen_decode_diropargs(xdr, &ptr->from))
+		return false;
+	if (!xdrgen_decode_diropargs(xdr, &ptr->to))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_linkargs(struct xdr_stream *xdr, struct linkargs *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->from))
+		return false;
+	if (!xdrgen_decode_diropargs(xdr, &ptr->to))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_symlinkargs(struct xdr_stream *xdr, struct symlinkargs *ptr)
+{
+	if (!xdrgen_decode_diropargs(xdr, &ptr->from))
+		return false;
+	if (!xdrgen_decode_path(xdr, &ptr->to))
+		return false;
+	if (!xdrgen_decode_sattr(xdr, &ptr->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_readdirargs(struct xdr_stream *xdr, struct readdirargs *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->dir))
+		return false;
+	if (!xdrgen_decode_nfscookie(xdr, &ptr->cookie))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_entry(struct xdr_stream *xdr, struct entry *ptr)
+{
+	bool opted;
+
+	if (!xdrgen_decode_bool(xdr, &opted))
+		return false;
+	if (!opted)
+		return true;
+
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->fileid))
+		return false;
+	if (!xdrgen_decode_filename(xdr, &ptr->name))
+		return false;
+	if (!xdrgen_decode_nfscookie(xdr, &ptr->cookie))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_readdirok(struct xdr_stream *xdr, struct readdirok *ptr)
+{
+	if (!xdrgen_decode_entry(xdr, ptr->entries))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->eof))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_readdirres(struct xdr_stream *xdr, struct readdirres *ptr)
+{
+	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_decode_readdirok(xdr, &ptr->u.readdirok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_info(struct xdr_stream *xdr, struct info *ptr)
+{
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->tsize))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->bsize))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->blocks))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->bfree))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->bavail))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_statfsres(struct xdr_stream *xdr, struct statfsres *ptr)
+{
+	if (!xdrgen_decode_nfsstat(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_decode_info(xdr, &ptr->u.info))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+/**
+ * nfs_svc_decode_fhandle - Decode a fhandle argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_fhandle(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	fhandle *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_fhandle(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_sattrargs - Decode a sattrargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct sattrargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_sattrargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_diropargs - Decode a diropargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct diropargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_diropargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_readargs - Decode a readargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct readargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_readargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_writeargs - Decode a writeargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct writeargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_writeargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_createargs - Decode a createargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct createargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_createargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_renameargs - Decode a renameargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct renameargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_renameargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_linkargs - Decode a linkargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct linkargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_linkargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_symlinkargs - Decode a symlinkargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct symlinkargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_symlinkargs(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_readdirargs - Decode a readdirargs argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct readdirargs *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_readdirargs(xdr, argp);
+}
+
+static bool __maybe_unused
+xdrgen_encode_nfsstat(struct xdr_stream *xdr, nfsstat value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ftype(struct xdr_stream *xdr, ftype value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_fhandle(struct xdr_stream *xdr, const fhandle value)
+{
+	return xdr_stream_encode_opaque_fixed(xdr, value, NFS_FHSIZE) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_nfscookie(struct xdr_stream *xdr, const nfscookie value)
+{
+	return xdr_stream_encode_opaque_fixed(xdr, value, NFS_COOKIESIZE) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_timeval(struct xdr_stream *xdr, const struct timeval *value)
+{
+	if (!xdrgen_encode_unsigned_int(xdr, value->seconds))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->useconds))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_fattr(struct xdr_stream *xdr, const struct fattr *value)
+{
+	if (!xdrgen_encode_ftype(xdr, value->type))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->mode))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->nlink))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->uid))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->gid))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->size))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->blocksize))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->rdev))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->blocks))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->fsid))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->fileid))
+		return false;
+	if (!xdrgen_encode_timeval(xdr, &value->atime))
+		return false;
+	if (!xdrgen_encode_timeval(xdr, &value->mtime))
+		return false;
+	if (!xdrgen_encode_timeval(xdr, &value->ctime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_sattr(struct xdr_stream *xdr, const struct sattr *value)
+{
+	if (!xdrgen_encode_unsigned_int(xdr, value->mode))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->uid))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->gid))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->size))
+		return false;
+	if (!xdrgen_encode_timeval(xdr, &value->atime))
+		return false;
+	if (!xdrgen_encode_timeval(xdr, &value->mtime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_filename(struct xdr_stream *xdr, const filename value)
+{
+	return xdr_stream_encode_opaque(xdr, value.data, value.len) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_path(struct xdr_stream *xdr, const path value)
+{
+	return xdr_stream_encode_opaque(xdr, value.data, value.len) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_attrstat(struct xdr_stream *xdr, const struct attrstat *ptr)
+{
+	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_encode_fattr(xdr, &ptr->u.attributes))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_diropargs(struct xdr_stream *xdr, const struct diropargs *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->dir))
+		return false;
+	if (!xdrgen_encode_filename(xdr, value->name))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_diropok(struct xdr_stream *xdr, const struct diropok *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->file))
+		return false;
+	if (!xdrgen_encode_fattr(xdr, &value->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_diropres(struct xdr_stream *xdr, const struct diropres *ptr)
+{
+	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_encode_diropok(xdr, &ptr->u.diropok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_sattrargs(struct xdr_stream *xdr, const struct sattrargs *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->file))
+		return false;
+	if (!xdrgen_encode_sattr(xdr, &value->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_readlinkres(struct xdr_stream *xdr, const struct readlinkres *ptr)
+{
+	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_encode_path(xdr, ptr->u.data))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_readargs(struct xdr_stream *xdr, const struct readargs *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->file))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->offset))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->count))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->totalcount))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_readresok(struct xdr_stream *xdr, const struct readresok *value)
+{
+	if (!xdrgen_encode_fattr(xdr, &value->attributes))
+		return false;
+	if (value->data.len > NFS_MAXDATA)
+		return false;
+	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_readres(struct xdr_stream *xdr, const struct readres *ptr)
+{
+	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_encode_readresok(xdr, &ptr->u.readresok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_writeargs(struct xdr_stream *xdr, const struct writeargs *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->file))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->beginoffset))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->offset))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->totalcount))
+		return false;
+	if (value->data.len > NFS_MAXDATA)
+		return false;
+	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_createargs(struct xdr_stream *xdr, const struct createargs *value)
+{
+	if (!xdrgen_encode_diropargs(xdr, &value->where))
+		return false;
+	if (!xdrgen_encode_sattr(xdr, &value->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_renameargs(struct xdr_stream *xdr, const struct renameargs *value)
+{
+	if (!xdrgen_encode_diropargs(xdr, &value->from))
+		return false;
+	if (!xdrgen_encode_diropargs(xdr, &value->to))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_linkargs(struct xdr_stream *xdr, const struct linkargs *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->from))
+		return false;
+	if (!xdrgen_encode_diropargs(xdr, &value->to))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_symlinkargs(struct xdr_stream *xdr, const struct symlinkargs *value)
+{
+	if (!xdrgen_encode_diropargs(xdr, &value->from))
+		return false;
+	if (!xdrgen_encode_path(xdr, value->to))
+		return false;
+	if (!xdrgen_encode_sattr(xdr, &value->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_readdirargs(struct xdr_stream *xdr, const struct readdirargs *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->dir))
+		return false;
+	if (!xdrgen_encode_nfscookie(xdr, value->cookie))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_entry(struct xdr_stream *xdr, const struct entry *value)
+{
+	if (!xdrgen_encode_bool(xdr, value != NULL))
+		return false;
+	if (!value)
+		return true;
+
+	if (!xdrgen_encode_unsigned_int(xdr, value->fileid))
+		return false;
+	if (!xdrgen_encode_filename(xdr, value->name))
+		return false;
+	if (!xdrgen_encode_nfscookie(xdr, value->cookie))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_readdirok(struct xdr_stream *xdr, const struct readdirok *value)
+{
+	if (!xdrgen_encode_entry(xdr, value->entries))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->eof))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_readdirres(struct xdr_stream *xdr, const struct readdirres *ptr)
+{
+	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_encode_readdirok(xdr, &ptr->u.readdirok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_info(struct xdr_stream *xdr, const struct info *value)
+{
+	if (!xdrgen_encode_unsigned_int(xdr, value->tsize))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->bsize))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->blocks))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->bfree))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->bavail))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_statfsres(struct xdr_stream *xdr, const struct statfsres *ptr)
+{
+	if (!xdrgen_encode_nfsstat(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS_OK:
+		if (!xdrgen_encode_info(xdr, &ptr->u.info))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+/**
+ * nfs_svc_encode_attrstat - Encode a attrstat result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_attrstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct attrstat *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_attrstat(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_diropres - Encode a diropres result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct diropres *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_diropres(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_readlinkres - Encode a readlinkres result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct readlinkres *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_readlinkres(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_readres - Encode a readres result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct readres *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_readres(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_nfsstat - Encode a nfsstat result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_nfsstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	nfsstat *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_nfsstat(xdr, *resp);
+}
+
+/**
+ * nfs_svc_encode_readdirres - Encode a readdirres result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct readdirres *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_readdirres(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_statfsres - Encode a statfsres result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct statfsres *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_statfsres(xdr, resp);
+}
diff --git a/fs/nfsd/nfs2xdr_gen.h b/fs/nfsd/nfs2xdr_gen.h
new file mode 100644
index 000000000000..df800e42b80e
--- /dev/null
+++ b/fs/nfsd/nfs2xdr_gen.h
@@ -0,0 +1,35 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
+/* XDR specification modification time: Tue Sep  8 11:23:43 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS2_DECL_H
+#define _LINUX_XDRGEN_NFS2_DECL_H
+
+#include <linux/types.h>
+
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/xdrgen/_defs.h>
+#include <linux/sunrpc/xdrgen/_builtins.h>
+#include <linux/sunrpc/xdrgen/nfs2.h>
+
+bool nfs_svc_decode_fhandle(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_sattrargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+bool nfs_svc_encode_attrstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_nfsstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+#endif /* _LINUX_XDRGEN_NFS2_DECL_H */
diff --git a/include/linux/sunrpc/xdrgen/nfs2.h b/include/linux/sunrpc/xdrgen/nfs2.h
new file mode 100644
index 000000000000..4a022b670b0c
--- /dev/null
+++ b/include/linux/sunrpc/xdrgen/nfs2.h
@@ -0,0 +1,298 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
+/* XDR specification modification time: Tue Sep  8 11:23:43 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS2_DEF_H
+#define _LINUX_XDRGEN_NFS2_DEF_H
+
+#include <linux/types.h>
+#include <linux/sunrpc/xdrgen/_defs.h>
+
+enum { NFS_MAXDATA = 8192 };
+
+enum { NFS_MAXPATHLEN = 1024 };
+
+enum { NFS_MAXNAMLEN = 255 };
+
+enum { NFS_COOKIESIZE = 4 };
+
+enum { NFS_FHSIZE = 32 };
+
+enum nfsstat {
+	NFS_OK = 0,
+	NFSERR_PERM = 1,
+	NFSERR_NOENT = 2,
+	NFSERR_IO = 5,
+	NFSERR_NXIO = 6,
+	NFSERR_ACCES = 13,
+	NFSERR_EXIST = 17,
+	NFSERR_NODEV = 19,
+	NFSERR_NOTDIR = 20,
+	NFSERR_ISDIR = 21,
+	NFSERR_FBIG = 27,
+	NFSERR_NOSPC = 28,
+	NFSERR_ROFS = 30,
+	NFSERR_NAMETOOLONG = 63,
+	NFSERR_NOTEMPTY = 66,
+	NFSERR_DQUOT = 69,
+	NFSERR_STALE = 70,
+	NFSERR_WFLUSH = 99,
+};
+
+typedef enum nfsstat nfsstat;
+
+enum ftype {
+	NFNON = 0,
+	NFREG = 1,
+	NFDIR = 2,
+	NFBLK = 3,
+	NFCHR = 4,
+	NFLNK = 5,
+};
+
+typedef enum ftype ftype;
+
+typedef u8 fhandle[NFS_FHSIZE];
+
+typedef u8 nfscookie[NFS_COOKIESIZE];
+
+struct timeval {
+	u32 seconds;
+	u32 useconds;
+};
+
+struct fattr {
+	ftype type;
+	u32 mode;
+	u32 nlink;
+	u32 uid;
+	u32 gid;
+	u32 size;
+	u32 blocksize;
+	u32 rdev;
+	u32 blocks;
+	u32 fsid;
+	u32 fileid;
+	struct timeval atime;
+	struct timeval mtime;
+	struct timeval ctime;
+};
+
+struct sattr {
+	u32 mode;
+	u32 uid;
+	u32 gid;
+	u32 size;
+	struct timeval atime;
+	struct timeval mtime;
+};
+
+typedef string filename;
+
+typedef string path;
+
+struct attrstat {
+	nfsstat status;
+	union {
+		struct fattr attributes;
+	} u;
+};
+
+struct diropargs {
+	fhandle dir;
+	filename name;
+};
+
+struct diropok {
+	fhandle file;
+	struct fattr attributes;
+};
+
+struct diropres {
+	nfsstat status;
+	union {
+		struct diropok diropok;
+	} u;
+};
+
+struct sattrargs {
+	fhandle file;
+	struct sattr attributes;
+};
+
+struct readlinkres {
+	nfsstat status;
+	union {
+		path data;
+	} u;
+};
+
+struct readargs {
+	fhandle file;
+	u32 offset;
+	u32 count;
+	u32 totalcount;
+};
+
+struct readresok {
+	struct fattr attributes;
+	opaque data;
+};
+
+struct readres {
+	nfsstat status;
+	union {
+		struct readresok readresok;
+	} u;
+};
+
+struct writeargs {
+	fhandle file;
+	u32 beginoffset;
+	u32 offset;
+	u32 totalcount;
+	opaque data;
+};
+
+struct createargs {
+	struct diropargs where;
+	struct sattr attributes;
+};
+
+struct renameargs {
+	struct diropargs from;
+	struct diropargs to;
+};
+
+struct linkargs {
+	fhandle from;
+	struct diropargs to;
+};
+
+struct symlinkargs {
+	struct diropargs from;
+	path to;
+	struct sattr attributes;
+};
+
+struct readdirargs {
+	fhandle dir;
+	nfscookie cookie;
+	u32 count;
+};
+
+struct entry {
+	u32 fileid;
+	filename name;
+	nfscookie cookie;
+};
+
+struct readdirok {
+	struct entry *entries;
+	bool eof;
+};
+
+struct readdirres {
+	nfsstat status;
+	union {
+		struct readdirok readdirok;
+	} u;
+};
+
+struct info {
+	u32 tsize;
+	u32 bsize;
+	u32 blocks;
+	u32 bfree;
+	u32 bavail;
+};
+
+struct statfsres {
+	nfsstat status;
+	union {
+		struct info info;
+	} u;
+};
+
+enum {
+	NFSPROC_NULL = 0,
+	NFSPROC_GETATTR = 1,
+	NFSPROC_SETATTR = 2,
+	NFSPROC_ROOT = 3,
+	NFSPROC_LOOKUP = 4,
+	NFSPROC_READLINK = 5,
+	NFSPROC_READ = 6,
+	NFSPROC_WRITECACHE = 7,
+	NFSPROC_WRITE = 8,
+	NFSPROC_CREATE = 9,
+	NFSPROC_REMOVE = 10,
+	NFSPROC_RENAME = 11,
+	NFSPROC_LINK = 12,
+	NFSPROC_SYMLINK = 13,
+	NFSPROC_MKDIR = 14,
+	NFSPROC_RMDIR = 15,
+	NFSPROC_READDIR = 16,
+	NFSPROC_STATFS = 17,
+};
+
+#ifndef NFS_PROGRAM
+#define NFS_PROGRAM (100003)
+#endif
+
+#define NFS2_nfsstat_sz                 (XDR_int)
+#define NFS2_ftype_sz                   (XDR_int)
+#define NFS2_fhandle_sz                 (XDR_QUADLEN(NFS_FHSIZE))
+#define NFS2_nfscookie_sz               (XDR_QUADLEN(NFS_COOKIESIZE))
+#define NFS2_timeval_sz                 \
+	(XDR_unsigned_int + XDR_unsigned_int)
+#define NFS2_fattr_sz                   \
+	(NFS2_ftype_sz + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + NFS2_timeval_sz + NFS2_timeval_sz + NFS2_timeval_sz)
+#define NFS2_sattr_sz                   \
+	(XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + NFS2_timeval_sz + NFS2_timeval_sz)
+#define NFS2_filename_sz                (XDR_unsigned_int + XDR_QUADLEN(NFS_MAXNAMLEN))
+#define NFS2_path_sz                    (XDR_unsigned_int + XDR_QUADLEN(NFS_MAXPATHLEN))
+#define NFS2_attrstat_sz                \
+	(NFS2_nfsstat_sz + NFS2_fattr_sz)
+#define NFS2_diropargs_sz               \
+	(NFS2_fhandle_sz + NFS2_filename_sz)
+#define NFS2_diropok_sz                 \
+	(NFS2_fhandle_sz + NFS2_fattr_sz)
+#define NFS2_diropres_sz                \
+	(NFS2_nfsstat_sz + NFS2_diropok_sz)
+#define NFS2_sattrargs_sz               \
+	(NFS2_fhandle_sz + NFS2_sattr_sz)
+#define NFS2_readlinkres_sz             \
+	(NFS2_nfsstat_sz + NFS2_path_sz)
+#define NFS2_readargs_sz                \
+	(NFS2_fhandle_sz + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int)
+#define NFS2_readresok_sz               \
+	(NFS2_fattr_sz + XDR_unsigned_int + XDR_QUADLEN(NFS_MAXDATA))
+#define NFS2_readres_sz                 \
+	(NFS2_nfsstat_sz + NFS2_readresok_sz)
+#define NFS2_writeargs_sz               \
+	(NFS2_fhandle_sz + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_QUADLEN(NFS_MAXDATA))
+#define NFS2_createargs_sz              \
+	(NFS2_diropargs_sz + NFS2_sattr_sz)
+#define NFS2_renameargs_sz              \
+	(NFS2_diropargs_sz + NFS2_diropargs_sz)
+#define NFS2_linkargs_sz                \
+	(NFS2_fhandle_sz + NFS2_diropargs_sz)
+#define NFS2_symlinkargs_sz             \
+	(NFS2_diropargs_sz + NFS2_path_sz + NFS2_sattr_sz)
+#define NFS2_readdirargs_sz             \
+	(NFS2_fhandle_sz + NFS2_nfscookie_sz + XDR_unsigned_int)
+#define NFS2_entry_sz                   \
+	(XDR_bool + XDR_unsigned_int + NFS2_filename_sz + NFS2_nfscookie_sz)
+#define NFS2_readdirok_sz               \
+	(XDR_bool + XDR_bool)
+#define NFS2_readdirres_sz              \
+	(NFS2_nfsstat_sz + NFS2_readdirok_sz)
+#define NFS2_info_sz                    \
+	(XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int)
+#define NFS2_statfsres_sz               \
+	(NFS2_nfsstat_sz + NFS2_info_sz)
+#define NFS2_MAX_ARGS_SZ                \
+	(NFS2_writeargs_sz)
+
+#endif /* _LINUX_XDRGEN_NFS2_DEF_H */
-- 
2.55.0

