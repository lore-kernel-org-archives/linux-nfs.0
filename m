Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE95141D11F
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895765; cv=none; b=EEYZedRAIF2nKlUpNkidG2SAIWm6Zi5UQ+XKX0BjC0/rGaH6KnmUbnZUviGFGSohK9fCENM9yimKOHEkD3sIirrBNumuZoXRUH4zLSsys/vBaffN2QhBxkLQN1Mn6pPfGpM/O2LWt63/gMEKC/lktP0I1OArBLzDppI+saehjcU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895765; c=relaxed/simple;
	bh=PKInvvRD8bpLYbCOcnW8pk9l8F4f6HTSba8TNK6Ycog=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uOfrw89EeJIxurss8xg5aaT9Q18GvNbp7R27e9g3dOarUp4p0AAXsgilBsnLmiX5bnJ9f7eURot2w9kEaD6OhhnJmWXXZ7QdqUqxCjH+8AGbDZbLLOMsdNPqDcEJS+qFQoQ8btO1a5kzhjpX7GsxRpoyWuRt6XuiqmmjwyxQzmM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KarLQRnT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KarLQRnT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E541E1F00893;
	Tue, 13 Oct 2026 12:49:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895757;
	bh=xbH45t1FVETJiE6J4XZgreXR/uEzceC/iKPhK/C9A0g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KarLQRnTzhgUSuNG0TLhDB95SsSscMjkdOIR2mM/hfePQegPFjnzybv1Az3ui8BkY
	 5AgSI0Alc1SuCviIOh95+7pYmcuiy6sSPpcADaSEoGECuxz8+U8zjQs+1qVIb3sgYb
	 HsBU9ykfHIfTXdK8ZTbdt0snj0wBvArxDJPtwvAP7kNaLJrYwpQnDXmUJQw7HuogKN
	 ssC0e0iSlDIsLySGcpUOLABVicmEXtu+8AXBj0DiBIZcRJsIss6n3Fh/tRIsdE1+pQ
	 3yOZGrdZzL57cliiZ2tx9NyOWLw//su6FESNAeRqiQhcZHEIu3KcW88HTxyTW4KSYg
	 cf466252DAAig==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 03/34] NFSD: Add infrastructure for generating NFSv3 XDR encoders and decoders
Date: Tue, 13 Oct 2026 08:49:07 -0400
Message-ID: <20261013124913.316726-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124913.316726-1-cel@kernel.org>
References: <20261013124913.316726-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

NFSD's NFSv3 XDR codecs are hand-maintained; they are being converted
to xdrgen-generated code one RPC procedure at a time. The first step
is to generate and commit the xdrgen C code based on nfs3.x. The
generated code can be refreshed any time nfs3.x is modified by
running "(cd fs/nfsd && make xdrgen)".

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |    2 +
 fs/nfsd/Makefile                   |   15 +-
 fs/nfsd/nfs3xdr_gen.c              | 3768 ++++++++++++++++++++++++++++
 fs/nfsd/nfs3xdr_gen.h              |   60 +
 include/linux/sunrpc/xdrgen/nfs3.h | 1092 ++++++++
 5 files changed, 4933 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfsd/nfs3xdr_gen.c
 create mode 100644 fs/nfsd/nfs3xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs3.h

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index 7996775fb4ae..9feabfda94e7 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -39,6 +39,8 @@
  *   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+pragma header nfs3;
+
 const NFS3_FHSIZE		= 64;
 const NFS3_COOKIEVERFSIZE	= 8;
 const NFS3_CREATEVERFSIZE	= 8;
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 05fb814f760b..1dc449af28f4 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -12,8 +12,8 @@ nfsd-y			+= trace.o
 
 nfsd-y 			+= nfssvc.o nfsctl.o nfsfh.o vfs.o \
 			   export.o auth.o lockd.o nfscache.o \
-			   stats.o filecache.o nfs3proc.o nfs3xdr.o \
-			   netlink.o
+			   stats.o filecache.o netlink.o \
+			   nfs3proc.o nfs3xdr.o nfs3xdr_gen.o
 nfsd-$(CONFIG_NFSD_V2) += nfsproc.o nfsxdr.o nfs2xdr_gen.o
 nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
@@ -38,23 +38,30 @@ nfsd-$(CONFIG_DEBUG_FS) += debugfs.o
 .PHONY: xdrgen
 
 XDRGEN_DEFINITIONS	= ../../include/linux/sunrpc/xdrgen/nfs2.h \
+			  ../../include/linux/sunrpc/xdrgen/nfs3.h \
 			  ../../include/linux/sunrpc/xdrgen/nfs4_1.h
-XDRGEN_DECLARATIONS	= nfs2xdr_gen.h nfs4xdr_gen.h
-XDRGEN_SOURCE		= nfs2xdr_gen.c nfs4xdr_gen.c
+XDRGEN_DECLARATIONS	= nfs2xdr_gen.h nfs3xdr_gen.h nfs4xdr_gen.h
+XDRGEN_SOURCE		= nfs2xdr_gen.c nfs3xdr_gen.c nfs4xdr_gen.c
 
 xdrgen: $(XDRGEN_DEFINITIONS) $(XDRGEN_DECLARATIONS) $(XDRGEN_SOURCE)
 
 ../../include/linux/sunrpc/xdrgen/nfs2.h: ../../Documentation/sunrpc/xdr/nfs2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
+../../include/linux/sunrpc/xdrgen/nfs3.h: ../../Documentation/sunrpc/xdr/nfs3.x
+	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 ../../include/linux/sunrpc/xdrgen/nfs4_1.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 
 nfs2xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
+nfs3xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs3.x
+	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 nfs4xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 
 nfs2xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
+nfs3xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs3.x
+	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
 nfs4xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
new file mode 100644
index 000000000000..48b382ccfc81
--- /dev/null
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -0,0 +1,3768 @@
+// SPDX-License-Identifier: GPL-2.0
+// Generated by xdrgen. Manual edits will be lost.
+// XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x
+// XDR specification modification time: Fri Jul 10 23:20:55 2026
+
+#include <linux/sunrpc/svc.h>
+
+#include "nfs3xdr_gen.h"
+
+static bool __maybe_unused
+xdrgen_decode_uint64(struct xdr_stream *xdr, uint64 *ptr)
+{
+	return xdrgen_decode_unsigned_hyper(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_int64(struct xdr_stream *xdr, int64 *ptr)
+{
+	return xdrgen_decode_hyper(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_uint32(struct xdr_stream *xdr, uint32 *ptr)
+{
+	return xdrgen_decode_unsigned_long(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_int32(struct xdr_stream *xdr, int32 *ptr)
+{
+	return xdrgen_decode_long(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_filename3(struct xdr_stream *xdr, filename3 *ptr)
+{
+	return xdrgen_decode_string(xdr, ptr, 0);
+}
+
+static bool __maybe_unused
+xdrgen_decode_nfspath3(struct xdr_stream *xdr, nfspath3 *ptr)
+{
+	return xdrgen_decode_string(xdr, ptr, 0);
+}
+
+static bool __maybe_unused
+xdrgen_decode_fileid3(struct xdr_stream *xdr, fileid3 *ptr)
+{
+	return xdrgen_decode_uint64(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_cookie3(struct xdr_stream *xdr, cookie3 *ptr)
+{
+	return xdrgen_decode_uint64(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_cookieverf3(struct xdr_stream *xdr, cookieverf3 *ptr)
+{
+	return xdr_stream_decode_opaque_fixed(xdr, ptr, NFS3_COOKIEVERFSIZE) == 0;
+}
+
+static bool __maybe_unused
+xdrgen_decode_createverf3(struct xdr_stream *xdr, createverf3 *ptr)
+{
+	return xdr_stream_decode_opaque_fixed(xdr, ptr, NFS3_CREATEVERFSIZE) == 0;
+}
+
+static bool __maybe_unused
+xdrgen_decode_writeverf3(struct xdr_stream *xdr, writeverf3 *ptr)
+{
+	return xdr_stream_decode_opaque_fixed(xdr, ptr, NFS3_WRITEVERFSIZE) == 0;
+}
+
+static bool __maybe_unused
+xdrgen_decode_uid3(struct xdr_stream *xdr, uid3 *ptr)
+{
+	return xdrgen_decode_uint32(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_gid3(struct xdr_stream *xdr, gid3 *ptr)
+{
+	return xdrgen_decode_uint32(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_size3(struct xdr_stream *xdr, size3 *ptr)
+{
+	return xdrgen_decode_uint64(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_offset3(struct xdr_stream *xdr, offset3 *ptr)
+{
+	return xdrgen_decode_uint64(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_mode3(struct xdr_stream *xdr, mode3 *ptr)
+{
+	return xdrgen_decode_uint32(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_count3(struct xdr_stream *xdr, count3 *ptr)
+{
+	return xdrgen_decode_uint32(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_nfsstat3(struct xdr_stream *xdr, nfsstat3 *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case NFS3_OK:
+	case NFS3ERR_PERM:
+	case NFS3ERR_NOENT:
+	case NFS3ERR_IO:
+	case NFS3ERR_NXIO:
+	case NFS3ERR_ACCES:
+	case NFS3ERR_EXIST:
+	case NFS3ERR_XDEV:
+	case NFS3ERR_NODEV:
+	case NFS3ERR_NOTDIR:
+	case NFS3ERR_ISDIR:
+	case NFS3ERR_INVAL:
+	case NFS3ERR_FBIG:
+	case NFS3ERR_NOSPC:
+	case NFS3ERR_ROFS:
+	case NFS3ERR_MLINK:
+	case NFS3ERR_NAMETOOLONG:
+	case NFS3ERR_NOTEMPTY:
+	case NFS3ERR_DQUOT:
+	case NFS3ERR_STALE:
+	case NFS3ERR_REMOTE:
+	case NFS3ERR_BADHANDLE:
+	case NFS3ERR_NOT_SYNC:
+	case NFS3ERR_BAD_COOKIE:
+	case NFS3ERR_NOTSUPP:
+	case NFS3ERR_TOOSMALL:
+	case NFS3ERR_SERVERFAULT:
+	case NFS3ERR_BADTYPE:
+	case NFS3ERR_JUKEBOX:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ftype3(struct xdr_stream *xdr, ftype3 *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case NF3REG:
+	case NF3DIR:
+	case NF3BLK:
+	case NF3CHR:
+	case NF3LNK:
+	case NF3SOCK:
+	case NF3FIFO:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_specdata3(struct xdr_stream *xdr, struct specdata3 *ptr)
+{
+	if (!xdrgen_decode_uint32(xdr, &ptr->specdata1))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->specdata2))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_nfs_fh3(struct xdr_stream *xdr, struct nfs_fh3 *ptr)
+{
+	if (!xdrgen_decode_opaque(xdr, &ptr->data, NFS3_FHSIZE))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_nfstime3(struct xdr_stream *xdr, struct nfstime3 *ptr)
+{
+	if (!xdrgen_decode_uint32(xdr, &ptr->seconds))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->nseconds))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_fattr3(struct xdr_stream *xdr, struct fattr3 *ptr)
+{
+	if (!xdrgen_decode_ftype3(xdr, &ptr->type))
+		return false;
+	if (!xdrgen_decode_mode3(xdr, &ptr->mode))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->nlink))
+		return false;
+	if (!xdrgen_decode_uid3(xdr, &ptr->uid))
+		return false;
+	if (!xdrgen_decode_gid3(xdr, &ptr->gid))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->size))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->used))
+		return false;
+	if (!xdrgen_decode_specdata3(xdr, &ptr->rdev))
+		return false;
+	if (!xdrgen_decode_uint64(xdr, &ptr->fsid))
+		return false;
+	if (!xdrgen_decode_fileid3(xdr, &ptr->fileid))
+		return false;
+	if (!xdrgen_decode_nfstime3(xdr, &ptr->atime))
+		return false;
+	if (!xdrgen_decode_nfstime3(xdr, &ptr->mtime))
+		return false;
+	if (!xdrgen_decode_nfstime3(xdr, &ptr->ctime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_post_op_attr(struct xdr_stream *xdr, struct post_op_attr *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->attributes_follow))
+		return false;
+	if (ptr->attributes_follow) {
+		if (!xdrgen_decode_fattr3(xdr, &ptr->u.attributes))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_wcc_attr(struct xdr_stream *xdr, struct wcc_attr *ptr)
+{
+	if (!xdrgen_decode_size3(xdr, &ptr->size))
+		return false;
+	if (!xdrgen_decode_nfstime3(xdr, &ptr->mtime))
+		return false;
+	if (!xdrgen_decode_nfstime3(xdr, &ptr->ctime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_pre_op_attr(struct xdr_stream *xdr, struct pre_op_attr *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->attributes_follow))
+		return false;
+	if (ptr->attributes_follow) {
+		if (!xdrgen_decode_wcc_attr(xdr, &ptr->u.attributes))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_wcc_data(struct xdr_stream *xdr, struct wcc_data *ptr)
+{
+	if (!xdrgen_decode_pre_op_attr(xdr, &ptr->before))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->after))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_post_op_fh3(struct xdr_stream *xdr, struct post_op_fh3 *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->handle_follows))
+		return false;
+	if (ptr->handle_follows) {
+		if (!xdrgen_decode_nfs_fh3(xdr, &ptr->u.handle))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_time_how(struct xdr_stream *xdr, time_how *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case DONT_CHANGE:
+	case SET_TO_SERVER_TIME:
+	case SET_TO_CLIENT_TIME:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_set_mode3(struct xdr_stream *xdr, struct set_mode3 *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_decode_mode3(xdr, &ptr->u.mode))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_set_uid3(struct xdr_stream *xdr, struct set_uid3 *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_decode_uid3(xdr, &ptr->u.uid))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_set_gid3(struct xdr_stream *xdr, struct set_gid3 *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_decode_gid3(xdr, &ptr->u.gid))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_set_size3(struct xdr_stream *xdr, struct set_size3 *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_decode_size3(xdr, &ptr->u.size))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_set_atime(struct xdr_stream *xdr, struct set_atime *ptr)
+{
+	if (!xdrgen_decode_time_how(xdr, &ptr->set_it))
+		return false;
+	switch (ptr->set_it) {
+	case SET_TO_CLIENT_TIME:
+		if (!xdrgen_decode_nfstime3(xdr, &ptr->u.atime))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_set_mtime(struct xdr_stream *xdr, struct set_mtime *ptr)
+{
+	if (!xdrgen_decode_time_how(xdr, &ptr->set_it))
+		return false;
+	switch (ptr->set_it) {
+	case SET_TO_CLIENT_TIME:
+		if (!xdrgen_decode_nfstime3(xdr, &ptr->u.mtime))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_sattr3(struct xdr_stream *xdr, struct sattr3 *ptr)
+{
+	if (!xdrgen_decode_set_mode3(xdr, &ptr->mode))
+		return false;
+	if (!xdrgen_decode_set_uid3(xdr, &ptr->uid))
+		return false;
+	if (!xdrgen_decode_set_gid3(xdr, &ptr->gid))
+		return false;
+	if (!xdrgen_decode_set_size3(xdr, &ptr->size))
+		return false;
+	if (!xdrgen_decode_set_atime(xdr, &ptr->atime))
+		return false;
+	if (!xdrgen_decode_set_mtime(xdr, &ptr->mtime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_diropargs3(struct xdr_stream *xdr, struct diropargs3 *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->dir))
+		return false;
+	if (!xdrgen_decode_filename3(xdr, &ptr->name))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETATTR3args(struct xdr_stream *xdr, struct GETATTR3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETATTR3resok(struct xdr_stream *xdr, struct GETATTR3resok *ptr)
+{
+	if (!xdrgen_decode_fattr3(xdr, &ptr->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETATTR3res(struct xdr_stream *xdr, struct GETATTR3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_GETATTR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_sattrguard3(struct xdr_stream *xdr, struct sattrguard3 *ptr)
+{
+	if (!xdrgen_decode_bool(xdr, &ptr->check))
+		return false;
+	if (ptr->check) {
+		if (!xdrgen_decode_nfstime3(xdr, &ptr->u.obj_ctime))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETATTR3args(struct xdr_stream *xdr, struct SETATTR3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->object))
+		return false;
+	if (!xdrgen_decode_sattr3(xdr, &ptr->new_attributes))
+		return false;
+	if (!xdrgen_decode_sattrguard3(xdr, &ptr->guard))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETATTR3resok(struct xdr_stream *xdr, struct SETATTR3resok *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->obj_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETATTR3resfail(struct xdr_stream *xdr, struct SETATTR3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->obj_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETATTR3res(struct xdr_stream *xdr, struct SETATTR3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_SETATTR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_SETATTR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LOOKUP3args(struct xdr_stream *xdr, struct LOOKUP3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->what))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LOOKUP3resok(struct xdr_stream *xdr, struct LOOKUP3resok *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->object))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LOOKUP3resfail(struct xdr_stream *xdr, struct LOOKUP3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LOOKUP3res(struct xdr_stream *xdr, struct LOOKUP3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_LOOKUP3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_LOOKUP3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ACCESS3args(struct xdr_stream *xdr, struct ACCESS3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->object))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ACCESS3resok(struct xdr_stream *xdr, struct ACCESS3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ACCESS3resfail(struct xdr_stream *xdr, struct ACCESS3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ACCESS3res(struct xdr_stream *xdr, struct ACCESS3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_ACCESS3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_ACCESS3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READLINK3args(struct xdr_stream *xdr, struct READLINK3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->symlink))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READLINK3resok(struct xdr_stream *xdr, struct READLINK3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->symlink_attributes))
+		return false;
+	if (!xdrgen_decode_nfspath3(xdr, &ptr->data))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READLINK3resfail(struct xdr_stream *xdr, struct READLINK3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->symlink_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READLINK3res(struct xdr_stream *xdr, struct READLINK3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_READLINK3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_READLINK3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READ3args(struct xdr_stream *xdr, struct READ3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_offset3(xdr, &ptr->offset))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READ3resok(struct xdr_stream *xdr, struct READ3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->file_attributes))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->count))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->eof))
+		return false;
+	if (!xdrgen_decode_opaque(xdr, &ptr->data, 0))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READ3resfail(struct xdr_stream *xdr, struct READ3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->file_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READ3res(struct xdr_stream *xdr, struct READ3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_READ3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_READ3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_stable_how(struct xdr_stream *xdr, stable_how *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case UNSTABLE:
+	case DATA_SYNC:
+	case FILE_SYNC:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_WRITE3args(struct xdr_stream *xdr, struct WRITE3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_offset3(xdr, &ptr->offset))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->count))
+		return false;
+	if (!xdrgen_decode_stable_how(xdr, &ptr->stable))
+		return false;
+	if (!xdrgen_decode_opaque(xdr, &ptr->data, 0))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_WRITE3resok(struct xdr_stream *xdr, struct WRITE3resok *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->file_wcc))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->count))
+		return false;
+	if (!xdrgen_decode_stable_how(xdr, &ptr->committed))
+		return false;
+	if (!xdrgen_decode_writeverf3(xdr, &ptr->verf))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_WRITE3resfail(struct xdr_stream *xdr, struct WRITE3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->file_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_WRITE3res(struct xdr_stream *xdr, struct WRITE3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_WRITE3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_WRITE3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_createmode3(struct xdr_stream *xdr, createmode3 *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case UNCHECKED:
+	case GUARDED:
+	case EXCLUSIVE:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_createhow3(struct xdr_stream *xdr, struct createhow3 *ptr)
+{
+	if (!xdrgen_decode_createmode3(xdr, &ptr->mode))
+		return false;
+	switch (ptr->mode) {
+	case UNCHECKED:
+	case GUARDED:
+		if (!xdrgen_decode_sattr3(xdr, &ptr->u.obj_attributes))
+			return false;
+		break;
+	case EXCLUSIVE:
+		if (!xdrgen_decode_createverf3(xdr, &ptr->u.verf))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_CREATE3args(struct xdr_stream *xdr, struct CREATE3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->where))
+		return false;
+	if (!xdrgen_decode_createhow3(xdr, &ptr->how))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_CREATE3resok(struct xdr_stream *xdr, struct CREATE3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_fh3(xdr, &ptr->obj))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_CREATE3resfail(struct xdr_stream *xdr, struct CREATE3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_CREATE3res(struct xdr_stream *xdr, struct CREATE3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_CREATE3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_CREATE3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKDIR3args(struct xdr_stream *xdr, struct MKDIR3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->where))
+		return false;
+	if (!xdrgen_decode_sattr3(xdr, &ptr->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKDIR3resok(struct xdr_stream *xdr, struct MKDIR3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_fh3(xdr, &ptr->obj))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKDIR3resfail(struct xdr_stream *xdr, struct MKDIR3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKDIR3res(struct xdr_stream *xdr, struct MKDIR3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_MKDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_MKDIR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_symlinkdata3(struct xdr_stream *xdr, struct symlinkdata3 *ptr)
+{
+	if (!xdrgen_decode_sattr3(xdr, &ptr->symlink_attributes))
+		return false;
+	if (!xdrgen_decode_nfspath3(xdr, &ptr->symlink_data))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SYMLINK3args(struct xdr_stream *xdr, struct SYMLINK3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->where))
+		return false;
+	if (!xdrgen_decode_symlinkdata3(xdr, &ptr->symlink))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SYMLINK3resok(struct xdr_stream *xdr, struct SYMLINK3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_fh3(xdr, &ptr->obj))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SYMLINK3resfail(struct xdr_stream *xdr, struct SYMLINK3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SYMLINK3res(struct xdr_stream *xdr, struct SYMLINK3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_SYMLINK3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_SYMLINK3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_devicedata3(struct xdr_stream *xdr, struct devicedata3 *ptr)
+{
+	if (!xdrgen_decode_sattr3(xdr, &ptr->dev_attributes))
+		return false;
+	if (!xdrgen_decode_specdata3(xdr, &ptr->spec))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_mknoddata3(struct xdr_stream *xdr, struct mknoddata3 *ptr)
+{
+	if (!xdrgen_decode_ftype3(xdr, &ptr->type))
+		return false;
+	switch (ptr->type) {
+	case NF3CHR:
+	case NF3BLK:
+		if (!xdrgen_decode_devicedata3(xdr, &ptr->u.device))
+			return false;
+		break;
+	case NF3SOCK:
+	case NF3FIFO:
+		if (!xdrgen_decode_sattr3(xdr, &ptr->u.pipe_attributes))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKNOD3args(struct xdr_stream *xdr, struct MKNOD3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->where))
+		return false;
+	if (!xdrgen_decode_mknoddata3(xdr, &ptr->what))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKNOD3resok(struct xdr_stream *xdr, struct MKNOD3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_fh3(xdr, &ptr->obj))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKNOD3resfail(struct xdr_stream *xdr, struct MKNOD3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_MKNOD3res(struct xdr_stream *xdr, struct MKNOD3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_MKNOD3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_MKNOD3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_REMOVE3args(struct xdr_stream *xdr, struct REMOVE3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_REMOVE3resok(struct xdr_stream *xdr, struct REMOVE3resok *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_REMOVE3resfail(struct xdr_stream *xdr, struct REMOVE3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_REMOVE3res(struct xdr_stream *xdr, struct REMOVE3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_REMOVE3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_REMOVE3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RMDIR3args(struct xdr_stream *xdr, struct RMDIR3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RMDIR3resok(struct xdr_stream *xdr, struct RMDIR3resok *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RMDIR3resfail(struct xdr_stream *xdr, struct RMDIR3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RMDIR3res(struct xdr_stream *xdr, struct RMDIR3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_RMDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_RMDIR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RENAME3args(struct xdr_stream *xdr, struct RENAME3args *ptr)
+{
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->from))
+		return false;
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->to))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RENAME3resok(struct xdr_stream *xdr, struct RENAME3resok *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->fromdir_wcc))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->todir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RENAME3resfail(struct xdr_stream *xdr, struct RENAME3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->fromdir_wcc))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->todir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_RENAME3res(struct xdr_stream *xdr, struct RENAME3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_RENAME3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_RENAME3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LINK3args(struct xdr_stream *xdr, struct LINK3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_diropargs3(xdr, &ptr->link))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LINK3resok(struct xdr_stream *xdr, struct LINK3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->file_attributes))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->linkdir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LINK3resfail(struct xdr_stream *xdr, struct LINK3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->file_attributes))
+		return false;
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->linkdir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_LINK3res(struct xdr_stream *xdr, struct LINK3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_LINK3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_LINK3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIR3args(struct xdr_stream *xdr, struct READDIR3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->dir))
+		return false;
+	if (!xdrgen_decode_cookie3(xdr, &ptr->cookie))
+		return false;
+	if (!xdrgen_decode_cookieverf3(xdr, &ptr->cookieverf))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_entry3(struct xdr_stream *xdr, struct entry3 *ptr)
+{
+	bool opted;
+
+	if (!xdrgen_decode_bool(xdr, &opted))
+		return false;
+	if (!opted)
+		return true;
+
+	if (!xdrgen_decode_fileid3(xdr, &ptr->fileid))
+		return false;
+	if (!xdrgen_decode_filename3(xdr, &ptr->name))
+		return false;
+	if (!xdrgen_decode_cookie3(xdr, &ptr->cookie))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_dirlist3(struct xdr_stream *xdr, struct dirlist3 *ptr)
+{
+	if (!xdrgen_decode_entry3(xdr, ptr->entries))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->eof))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIR3resok(struct xdr_stream *xdr, struct READDIR3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->dir_attributes))
+		return false;
+	if (!xdrgen_decode_cookieverf3(xdr, &ptr->cookieverf))
+		return false;
+	if (!xdrgen_decode_dirlist3(xdr, &ptr->reply))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIR3resfail(struct xdr_stream *xdr, struct READDIR3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIR3res(struct xdr_stream *xdr, struct READDIR3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_READDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_READDIR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIRPLUS3args(struct xdr_stream *xdr, struct READDIRPLUS3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->dir))
+		return false;
+	if (!xdrgen_decode_cookie3(xdr, &ptr->cookie))
+		return false;
+	if (!xdrgen_decode_cookieverf3(xdr, &ptr->cookieverf))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->dircount))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->maxcount))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_entryplus3(struct xdr_stream *xdr, struct entryplus3 *ptr)
+{
+	bool opted;
+
+	if (!xdrgen_decode_bool(xdr, &opted))
+		return false;
+	if (!opted)
+		return true;
+
+	if (!xdrgen_decode_fileid3(xdr, &ptr->fileid))
+		return false;
+	if (!xdrgen_decode_filename3(xdr, &ptr->name))
+		return false;
+	if (!xdrgen_decode_cookie3(xdr, &ptr->cookie))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->name_attributes))
+		return false;
+	if (!xdrgen_decode_post_op_fh3(xdr, &ptr->name_handle))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_dirlistplus3(struct xdr_stream *xdr, struct dirlistplus3 *ptr)
+{
+	if (!xdrgen_decode_entryplus3(xdr, ptr->entries))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->eof))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIRPLUS3resok(struct xdr_stream *xdr, struct READDIRPLUS3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->dir_attributes))
+		return false;
+	if (!xdrgen_decode_cookieverf3(xdr, &ptr->cookieverf))
+		return false;
+	if (!xdrgen_decode_dirlistplus3(xdr, &ptr->reply))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIRPLUS3resfail(struct xdr_stream *xdr, struct READDIRPLUS3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_READDIRPLUS3res(struct xdr_stream *xdr, struct READDIRPLUS3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_READDIRPLUS3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_READDIRPLUS3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSSTAT3args(struct xdr_stream *xdr, struct FSSTAT3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->fsroot))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSSTAT3resok(struct xdr_stream *xdr, struct FSSTAT3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->tbytes))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->fbytes))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->abytes))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->tfiles))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->ffiles))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->afiles))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->invarsec))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSSTAT3resfail(struct xdr_stream *xdr, struct FSSTAT3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSSTAT3res(struct xdr_stream *xdr, struct FSSTAT3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_FSSTAT3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_FSSTAT3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSINFO3args(struct xdr_stream *xdr, struct FSINFO3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->fsroot))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSINFO3resok(struct xdr_stream *xdr, struct FSINFO3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->rtmax))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->rtpref))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->rtmult))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->wtmax))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->wtpref))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->wtmult))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->dtpref))
+		return false;
+	if (!xdrgen_decode_size3(xdr, &ptr->maxfilesize))
+		return false;
+	if (!xdrgen_decode_nfstime3(xdr, &ptr->time_delta))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->properties))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSINFO3resfail(struct xdr_stream *xdr, struct FSINFO3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_FSINFO3res(struct xdr_stream *xdr, struct FSINFO3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_FSINFO3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_FSINFO3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_PATHCONF3args(struct xdr_stream *xdr, struct PATHCONF3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_PATHCONF3resok(struct xdr_stream *xdr, struct PATHCONF3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->linkmax))
+		return false;
+	if (!xdrgen_decode_uint32(xdr, &ptr->name_max))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->no_trunc))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->chown_restricted))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->case_insensitive))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->case_preserving))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_PATHCONF3resfail(struct xdr_stream *xdr, struct PATHCONF3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_PATHCONF3res(struct xdr_stream *xdr, struct PATHCONF3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_PATHCONF3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_PATHCONF3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_COMMIT3args(struct xdr_stream *xdr, struct COMMIT3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->file))
+		return false;
+	if (!xdrgen_decode_offset3(xdr, &ptr->offset))
+		return false;
+	if (!xdrgen_decode_count3(xdr, &ptr->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_COMMIT3resok(struct xdr_stream *xdr, struct COMMIT3resok *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->file_wcc))
+		return false;
+	if (!xdrgen_decode_writeverf3(xdr, &ptr->verf))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_COMMIT3resfail(struct xdr_stream *xdr, struct COMMIT3resfail *ptr)
+{
+	if (!xdrgen_decode_wcc_data(xdr, &ptr->file_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_COMMIT3res(struct xdr_stream *xdr, struct COMMIT3res *ptr)
+{
+	if (!xdrgen_decode_nfsstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_decode_COMMIT3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_COMMIT3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+/**
+ * nfs_svc_decode_GETATTR3args - Decode a GETATTR3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_GETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETATTR3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_GETATTR3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_SETATTR3args - Decode a SETATTR3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_SETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SETATTR3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_SETATTR3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_LOOKUP3args - Decode a LOOKUP3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_LOOKUP3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct LOOKUP3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_LOOKUP3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_ACCESS3args - Decode a ACCESS3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_ACCESS3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct ACCESS3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_ACCESS3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_READLINK3args - Decode a READLINK3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_READLINK3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READLINK3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_READLINK3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_READ3args - Decode a READ3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_READ3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READ3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_READ3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_WRITE3args - Decode a WRITE3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_WRITE3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct WRITE3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_WRITE3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_CREATE3args - Decode a CREATE3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_CREATE3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct CREATE3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_CREATE3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_MKDIR3args - Decode a MKDIR3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_MKDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct MKDIR3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_MKDIR3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_SYMLINK3args - Decode a SYMLINK3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_SYMLINK3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SYMLINK3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_SYMLINK3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_MKNOD3args - Decode a MKNOD3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_MKNOD3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct MKNOD3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_MKNOD3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_REMOVE3args - Decode a REMOVE3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_REMOVE3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct REMOVE3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_REMOVE3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_RMDIR3args - Decode a RMDIR3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_RMDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct RMDIR3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_RMDIR3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_RENAME3args - Decode a RENAME3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_RENAME3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct RENAME3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_RENAME3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_LINK3args - Decode a LINK3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_LINK3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct LINK3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_LINK3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_READDIR3args - Decode a READDIR3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_READDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READDIR3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_READDIR3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_READDIRPLUS3args - Decode a READDIRPLUS3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_READDIRPLUS3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READDIRPLUS3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_READDIRPLUS3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_FSSTAT3args - Decode a FSSTAT3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_FSSTAT3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct FSSTAT3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_FSSTAT3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_FSINFO3args - Decode a FSINFO3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_FSINFO3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct FSINFO3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_FSINFO3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_PATHCONF3args - Decode a PATHCONF3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_PATHCONF3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct PATHCONF3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_PATHCONF3args(xdr, argp);
+}
+
+/**
+ * nfs_svc_decode_COMMIT3args - Decode a COMMIT3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_svc_decode_COMMIT3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct COMMIT3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_COMMIT3args(xdr, argp);
+}
+
+static bool __maybe_unused
+xdrgen_encode_uint64(struct xdr_stream *xdr, const uint64 value)
+{
+	return xdrgen_encode_unsigned_hyper(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_int64(struct xdr_stream *xdr, const int64 value)
+{
+	return xdrgen_encode_hyper(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_uint32(struct xdr_stream *xdr, const uint32 value)
+{
+	return xdrgen_encode_unsigned_long(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_int32(struct xdr_stream *xdr, const int32 value)
+{
+	return xdrgen_encode_long(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_filename3(struct xdr_stream *xdr, const filename3 value)
+{
+	return xdr_stream_encode_opaque(xdr, value.data, value.len) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_nfspath3(struct xdr_stream *xdr, const nfspath3 value)
+{
+	return xdr_stream_encode_opaque(xdr, value.data, value.len) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_fileid3(struct xdr_stream *xdr, const fileid3 value)
+{
+	return xdrgen_encode_uint64(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_cookie3(struct xdr_stream *xdr, const cookie3 value)
+{
+	return xdrgen_encode_uint64(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_cookieverf3(struct xdr_stream *xdr, const cookieverf3 value)
+{
+	return xdr_stream_encode_opaque_fixed(xdr, value, NFS3_COOKIEVERFSIZE) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_createverf3(struct xdr_stream *xdr, const createverf3 value)
+{
+	return xdr_stream_encode_opaque_fixed(xdr, value, NFS3_CREATEVERFSIZE) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_writeverf3(struct xdr_stream *xdr, const writeverf3 value)
+{
+	return xdr_stream_encode_opaque_fixed(xdr, value, NFS3_WRITEVERFSIZE) >= 0;
+}
+
+static bool __maybe_unused
+xdrgen_encode_uid3(struct xdr_stream *xdr, const uid3 value)
+{
+	return xdrgen_encode_uint32(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_gid3(struct xdr_stream *xdr, const gid3 value)
+{
+	return xdrgen_encode_uint32(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_size3(struct xdr_stream *xdr, const size3 value)
+{
+	return xdrgen_encode_uint64(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_offset3(struct xdr_stream *xdr, const offset3 value)
+{
+	return xdrgen_encode_uint64(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_mode3(struct xdr_stream *xdr, const mode3 value)
+{
+	return xdrgen_encode_uint32(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_count3(struct xdr_stream *xdr, const count3 value)
+{
+	return xdrgen_encode_uint32(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_nfsstat3(struct xdr_stream *xdr, nfsstat3 value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ftype3(struct xdr_stream *xdr, ftype3 value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_specdata3(struct xdr_stream *xdr, const struct specdata3 *value)
+{
+	if (!xdrgen_encode_uint32(xdr, value->specdata1))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->specdata2))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh3 *value)
+{
+	if (value->data.len > NFS3_FHSIZE)
+		return false;
+	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_nfstime3(struct xdr_stream *xdr, const struct nfstime3 *value)
+{
+	if (!xdrgen_encode_uint32(xdr, value->seconds))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->nseconds))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_fattr3(struct xdr_stream *xdr, const struct fattr3 *value)
+{
+	if (!xdrgen_encode_ftype3(xdr, value->type))
+		return false;
+	if (!xdrgen_encode_mode3(xdr, value->mode))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->nlink))
+		return false;
+	if (!xdrgen_encode_uid3(xdr, value->uid))
+		return false;
+	if (!xdrgen_encode_gid3(xdr, value->gid))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->size))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->used))
+		return false;
+	if (!xdrgen_encode_specdata3(xdr, &value->rdev))
+		return false;
+	if (!xdrgen_encode_uint64(xdr, value->fsid))
+		return false;
+	if (!xdrgen_encode_fileid3(xdr, value->fileid))
+		return false;
+	if (!xdrgen_encode_nfstime3(xdr, &value->atime))
+		return false;
+	if (!xdrgen_encode_nfstime3(xdr, &value->mtime))
+		return false;
+	if (!xdrgen_encode_nfstime3(xdr, &value->ctime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_post_op_attr(struct xdr_stream *xdr, const struct post_op_attr *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->attributes_follow))
+		return false;
+	if (ptr->attributes_follow) {
+		if (!xdrgen_encode_fattr3(xdr, &ptr->u.attributes))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_wcc_attr(struct xdr_stream *xdr, const struct wcc_attr *value)
+{
+	if (!xdrgen_encode_size3(xdr, value->size))
+		return false;
+	if (!xdrgen_encode_nfstime3(xdr, &value->mtime))
+		return false;
+	if (!xdrgen_encode_nfstime3(xdr, &value->ctime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_pre_op_attr(struct xdr_stream *xdr, const struct pre_op_attr *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->attributes_follow))
+		return false;
+	if (ptr->attributes_follow) {
+		if (!xdrgen_encode_wcc_attr(xdr, &ptr->u.attributes))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_wcc_data(struct xdr_stream *xdr, const struct wcc_data *value)
+{
+	if (!xdrgen_encode_pre_op_attr(xdr, &value->before))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->after))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_post_op_fh3(struct xdr_stream *xdr, const struct post_op_fh3 *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->handle_follows))
+		return false;
+	if (ptr->handle_follows) {
+		if (!xdrgen_encode_nfs_fh3(xdr, &ptr->u.handle))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_time_how(struct xdr_stream *xdr, time_how value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_set_mode3(struct xdr_stream *xdr, const struct set_mode3 *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_encode_mode3(xdr, ptr->u.mode))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_set_uid3(struct xdr_stream *xdr, const struct set_uid3 *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_encode_uid3(xdr, ptr->u.uid))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_set_gid3(struct xdr_stream *xdr, const struct set_gid3 *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_encode_gid3(xdr, ptr->u.gid))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_set_size3(struct xdr_stream *xdr, const struct set_size3 *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->set_it))
+		return false;
+	if (ptr->set_it) {
+		if (!xdrgen_encode_size3(xdr, ptr->u.size))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_set_atime(struct xdr_stream *xdr, const struct set_atime *ptr)
+{
+	if (!xdrgen_encode_time_how(xdr, ptr->set_it))
+		return false;
+	switch (ptr->set_it) {
+	case SET_TO_CLIENT_TIME:
+		if (!xdrgen_encode_nfstime3(xdr, &ptr->u.atime))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_set_mtime(struct xdr_stream *xdr, const struct set_mtime *ptr)
+{
+	if (!xdrgen_encode_time_how(xdr, ptr->set_it))
+		return false;
+	switch (ptr->set_it) {
+	case SET_TO_CLIENT_TIME:
+		if (!xdrgen_encode_nfstime3(xdr, &ptr->u.mtime))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_sattr3(struct xdr_stream *xdr, const struct sattr3 *value)
+{
+	if (!xdrgen_encode_set_mode3(xdr, &value->mode))
+		return false;
+	if (!xdrgen_encode_set_uid3(xdr, &value->uid))
+		return false;
+	if (!xdrgen_encode_set_gid3(xdr, &value->gid))
+		return false;
+	if (!xdrgen_encode_set_size3(xdr, &value->size))
+		return false;
+	if (!xdrgen_encode_set_atime(xdr, &value->atime))
+		return false;
+	if (!xdrgen_encode_set_mtime(xdr, &value->mtime))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_diropargs3(struct xdr_stream *xdr, const struct diropargs3 *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->dir))
+		return false;
+	if (!xdrgen_encode_filename3(xdr, value->name))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETATTR3args(struct xdr_stream *xdr, const struct GETATTR3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETATTR3resok(struct xdr_stream *xdr, const struct GETATTR3resok *value)
+{
+	if (!xdrgen_encode_fattr3(xdr, &value->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETATTR3res(struct xdr_stream *xdr, const struct GETATTR3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_GETATTR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_sattrguard3(struct xdr_stream *xdr, const struct sattrguard3 *ptr)
+{
+	if (!xdrgen_encode_bool(xdr, ptr->check))
+		return false;
+	if (ptr->check) {
+		if (!xdrgen_encode_nfstime3(xdr, &ptr->u.obj_ctime))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETATTR3args(struct xdr_stream *xdr, const struct SETATTR3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->object))
+		return false;
+	if (!xdrgen_encode_sattr3(xdr, &value->new_attributes))
+		return false;
+	if (!xdrgen_encode_sattrguard3(xdr, &value->guard))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETATTR3resok(struct xdr_stream *xdr, const struct SETATTR3resok *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->obj_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETATTR3resfail(struct xdr_stream *xdr, const struct SETATTR3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->obj_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETATTR3res(struct xdr_stream *xdr, const struct SETATTR3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_SETATTR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_SETATTR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LOOKUP3args(struct xdr_stream *xdr, const struct LOOKUP3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->what))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LOOKUP3resok(struct xdr_stream *xdr, const struct LOOKUP3resok *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->object))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LOOKUP3resfail(struct xdr_stream *xdr, const struct LOOKUP3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LOOKUP3res(struct xdr_stream *xdr, const struct LOOKUP3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_LOOKUP3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_LOOKUP3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ACCESS3args(struct xdr_stream *xdr, const struct ACCESS3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->object))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ACCESS3resok(struct xdr_stream *xdr, const struct ACCESS3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ACCESS3resfail(struct xdr_stream *xdr, const struct ACCESS3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ACCESS3res(struct xdr_stream *xdr, const struct ACCESS3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_ACCESS3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_ACCESS3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READLINK3args(struct xdr_stream *xdr, const struct READLINK3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->symlink))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READLINK3resok(struct xdr_stream *xdr, const struct READLINK3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->symlink_attributes))
+		return false;
+	if (!xdrgen_encode_nfspath3(xdr, value->data))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READLINK3resfail(struct xdr_stream *xdr, const struct READLINK3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->symlink_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READLINK3res(struct xdr_stream *xdr, const struct READLINK3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_READLINK3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_READLINK3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READ3args(struct xdr_stream *xdr, const struct READ3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->file))
+		return false;
+	if (!xdrgen_encode_offset3(xdr, value->offset))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READ3resok(struct xdr_stream *xdr, const struct READ3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->file_attributes))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->count))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->eof))
+		return false;
+	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READ3resfail(struct xdr_stream *xdr, const struct READ3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->file_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READ3res(struct xdr_stream *xdr, const struct READ3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_READ3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_READ3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_stable_how(struct xdr_stream *xdr, stable_how value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_WRITE3args(struct xdr_stream *xdr, const struct WRITE3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->file))
+		return false;
+	if (!xdrgen_encode_offset3(xdr, value->offset))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->count))
+		return false;
+	if (!xdrgen_encode_stable_how(xdr, value->stable))
+		return false;
+	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_WRITE3resok(struct xdr_stream *xdr, const struct WRITE3resok *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->file_wcc))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->count))
+		return false;
+	if (!xdrgen_encode_stable_how(xdr, value->committed))
+		return false;
+	if (!xdrgen_encode_writeverf3(xdr, value->verf))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_WRITE3resfail(struct xdr_stream *xdr, const struct WRITE3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->file_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_WRITE3res(struct xdr_stream *xdr, const struct WRITE3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_WRITE3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_WRITE3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_createmode3(struct xdr_stream *xdr, createmode3 value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_createhow3(struct xdr_stream *xdr, const struct createhow3 *ptr)
+{
+	if (!xdrgen_encode_createmode3(xdr, ptr->mode))
+		return false;
+	switch (ptr->mode) {
+	case UNCHECKED:
+	case GUARDED:
+		if (!xdrgen_encode_sattr3(xdr, &ptr->u.obj_attributes))
+			return false;
+		break;
+	case EXCLUSIVE:
+		if (!xdrgen_encode_createverf3(xdr, ptr->u.verf))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_CREATE3args(struct xdr_stream *xdr, const struct CREATE3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->where))
+		return false;
+	if (!xdrgen_encode_createhow3(xdr, &value->how))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_CREATE3resok(struct xdr_stream *xdr, const struct CREATE3resok *value)
+{
+	if (!xdrgen_encode_post_op_fh3(xdr, &value->obj))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_CREATE3resfail(struct xdr_stream *xdr, const struct CREATE3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_CREATE3res(struct xdr_stream *xdr, const struct CREATE3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_CREATE3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_CREATE3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKDIR3args(struct xdr_stream *xdr, const struct MKDIR3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->where))
+		return false;
+	if (!xdrgen_encode_sattr3(xdr, &value->attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKDIR3resok(struct xdr_stream *xdr, const struct MKDIR3resok *value)
+{
+	if (!xdrgen_encode_post_op_fh3(xdr, &value->obj))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKDIR3resfail(struct xdr_stream *xdr, const struct MKDIR3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKDIR3res(struct xdr_stream *xdr, const struct MKDIR3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_MKDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_MKDIR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_symlinkdata3(struct xdr_stream *xdr, const struct symlinkdata3 *value)
+{
+	if (!xdrgen_encode_sattr3(xdr, &value->symlink_attributes))
+		return false;
+	if (!xdrgen_encode_nfspath3(xdr, value->symlink_data))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SYMLINK3args(struct xdr_stream *xdr, const struct SYMLINK3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->where))
+		return false;
+	if (!xdrgen_encode_symlinkdata3(xdr, &value->symlink))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SYMLINK3resok(struct xdr_stream *xdr, const struct SYMLINK3resok *value)
+{
+	if (!xdrgen_encode_post_op_fh3(xdr, &value->obj))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SYMLINK3resfail(struct xdr_stream *xdr, const struct SYMLINK3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SYMLINK3res(struct xdr_stream *xdr, const struct SYMLINK3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_SYMLINK3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_SYMLINK3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_devicedata3(struct xdr_stream *xdr, const struct devicedata3 *value)
+{
+	if (!xdrgen_encode_sattr3(xdr, &value->dev_attributes))
+		return false;
+	if (!xdrgen_encode_specdata3(xdr, &value->spec))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_mknoddata3(struct xdr_stream *xdr, const struct mknoddata3 *ptr)
+{
+	if (!xdrgen_encode_ftype3(xdr, ptr->type))
+		return false;
+	switch (ptr->type) {
+	case NF3CHR:
+	case NF3BLK:
+		if (!xdrgen_encode_devicedata3(xdr, &ptr->u.device))
+			return false;
+		break;
+	case NF3SOCK:
+	case NF3FIFO:
+		if (!xdrgen_encode_sattr3(xdr, &ptr->u.pipe_attributes))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKNOD3args(struct xdr_stream *xdr, const struct MKNOD3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->where))
+		return false;
+	if (!xdrgen_encode_mknoddata3(xdr, &value->what))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKNOD3resok(struct xdr_stream *xdr, const struct MKNOD3resok *value)
+{
+	if (!xdrgen_encode_post_op_fh3(xdr, &value->obj))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKNOD3resfail(struct xdr_stream *xdr, const struct MKNOD3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_MKNOD3res(struct xdr_stream *xdr, const struct MKNOD3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_MKNOD3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_MKNOD3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_REMOVE3args(struct xdr_stream *xdr, const struct REMOVE3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_REMOVE3resok(struct xdr_stream *xdr, const struct REMOVE3resok *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_REMOVE3resfail(struct xdr_stream *xdr, const struct REMOVE3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_REMOVE3res(struct xdr_stream *xdr, const struct REMOVE3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_REMOVE3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_REMOVE3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RMDIR3args(struct xdr_stream *xdr, const struct RMDIR3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RMDIR3resok(struct xdr_stream *xdr, const struct RMDIR3resok *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RMDIR3resfail(struct xdr_stream *xdr, const struct RMDIR3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->dir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RMDIR3res(struct xdr_stream *xdr, const struct RMDIR3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_RMDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_RMDIR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RENAME3args(struct xdr_stream *xdr, const struct RENAME3args *value)
+{
+	if (!xdrgen_encode_diropargs3(xdr, &value->from))
+		return false;
+	if (!xdrgen_encode_diropargs3(xdr, &value->to))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RENAME3resok(struct xdr_stream *xdr, const struct RENAME3resok *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->fromdir_wcc))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->todir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RENAME3resfail(struct xdr_stream *xdr, const struct RENAME3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->fromdir_wcc))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->todir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_RENAME3res(struct xdr_stream *xdr, const struct RENAME3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_RENAME3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_RENAME3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LINK3args(struct xdr_stream *xdr, const struct LINK3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->file))
+		return false;
+	if (!xdrgen_encode_diropargs3(xdr, &value->link))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LINK3resok(struct xdr_stream *xdr, const struct LINK3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->file_attributes))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->linkdir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LINK3resfail(struct xdr_stream *xdr, const struct LINK3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->file_attributes))
+		return false;
+	if (!xdrgen_encode_wcc_data(xdr, &value->linkdir_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_LINK3res(struct xdr_stream *xdr, const struct LINK3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_LINK3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_LINK3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIR3args(struct xdr_stream *xdr, const struct READDIR3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->dir))
+		return false;
+	if (!xdrgen_encode_cookie3(xdr, value->cookie))
+		return false;
+	if (!xdrgen_encode_cookieverf3(xdr, value->cookieverf))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_entry3(struct xdr_stream *xdr, const struct entry3 *value)
+{
+	if (!xdrgen_encode_bool(xdr, value != NULL))
+		return false;
+	if (!value)
+		return true;
+
+	if (!xdrgen_encode_fileid3(xdr, value->fileid))
+		return false;
+	if (!xdrgen_encode_filename3(xdr, value->name))
+		return false;
+	if (!xdrgen_encode_cookie3(xdr, value->cookie))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_dirlist3(struct xdr_stream *xdr, const struct dirlist3 *value)
+{
+	if (!xdrgen_encode_entry3(xdr, value->entries))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->eof))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIR3resok(struct xdr_stream *xdr, const struct READDIR3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->dir_attributes))
+		return false;
+	if (!xdrgen_encode_cookieverf3(xdr, value->cookieverf))
+		return false;
+	if (!xdrgen_encode_dirlist3(xdr, &value->reply))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIR3resfail(struct xdr_stream *xdr, const struct READDIR3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIR3res(struct xdr_stream *xdr, const struct READDIR3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_READDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_READDIR3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIRPLUS3args(struct xdr_stream *xdr, const struct READDIRPLUS3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->dir))
+		return false;
+	if (!xdrgen_encode_cookie3(xdr, value->cookie))
+		return false;
+	if (!xdrgen_encode_cookieverf3(xdr, value->cookieverf))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->dircount))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->maxcount))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_entryplus3(struct xdr_stream *xdr, const struct entryplus3 *value)
+{
+	if (!xdrgen_encode_bool(xdr, value != NULL))
+		return false;
+	if (!value)
+		return true;
+
+	if (!xdrgen_encode_fileid3(xdr, value->fileid))
+		return false;
+	if (!xdrgen_encode_filename3(xdr, value->name))
+		return false;
+	if (!xdrgen_encode_cookie3(xdr, value->cookie))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->name_attributes))
+		return false;
+	if (!xdrgen_encode_post_op_fh3(xdr, &value->name_handle))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_dirlistplus3(struct xdr_stream *xdr, const struct dirlistplus3 *value)
+{
+	if (!xdrgen_encode_entryplus3(xdr, value->entries))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->eof))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIRPLUS3resok(struct xdr_stream *xdr, const struct READDIRPLUS3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->dir_attributes))
+		return false;
+	if (!xdrgen_encode_cookieverf3(xdr, value->cookieverf))
+		return false;
+	if (!xdrgen_encode_dirlistplus3(xdr, &value->reply))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIRPLUS3resfail(struct xdr_stream *xdr, const struct READDIRPLUS3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->dir_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_READDIRPLUS3res(struct xdr_stream *xdr, const struct READDIRPLUS3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_READDIRPLUS3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_READDIRPLUS3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSSTAT3args(struct xdr_stream *xdr, const struct FSSTAT3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->fsroot))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSSTAT3resok(struct xdr_stream *xdr, const struct FSSTAT3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->tbytes))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->fbytes))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->abytes))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->tfiles))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->ffiles))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->afiles))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->invarsec))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSSTAT3resfail(struct xdr_stream *xdr, const struct FSSTAT3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSSTAT3res(struct xdr_stream *xdr, const struct FSSTAT3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_FSSTAT3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_FSSTAT3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSINFO3args(struct xdr_stream *xdr, const struct FSINFO3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->fsroot))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSINFO3resok(struct xdr_stream *xdr, const struct FSINFO3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->rtmax))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->rtpref))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->rtmult))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->wtmax))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->wtpref))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->wtmult))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->dtpref))
+		return false;
+	if (!xdrgen_encode_size3(xdr, value->maxfilesize))
+		return false;
+	if (!xdrgen_encode_nfstime3(xdr, &value->time_delta))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->properties))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSINFO3resfail(struct xdr_stream *xdr, const struct FSINFO3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_FSINFO3res(struct xdr_stream *xdr, const struct FSINFO3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_FSINFO3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_FSINFO3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_PATHCONF3args(struct xdr_stream *xdr, const struct PATHCONF3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->object))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_PATHCONF3resok(struct xdr_stream *xdr, const struct PATHCONF3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->linkmax))
+		return false;
+	if (!xdrgen_encode_uint32(xdr, value->name_max))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->no_trunc))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->chown_restricted))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->case_insensitive))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->case_preserving))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_PATHCONF3resfail(struct xdr_stream *xdr, const struct PATHCONF3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->obj_attributes))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_PATHCONF3res(struct xdr_stream *xdr, const struct PATHCONF3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_PATHCONF3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_PATHCONF3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_COMMIT3args(struct xdr_stream *xdr, const struct COMMIT3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->file))
+		return false;
+	if (!xdrgen_encode_offset3(xdr, value->offset))
+		return false;
+	if (!xdrgen_encode_count3(xdr, value->count))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_COMMIT3resok(struct xdr_stream *xdr, const struct COMMIT3resok *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->file_wcc))
+		return false;
+	if (!xdrgen_encode_writeverf3(xdr, value->verf))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_COMMIT3resfail(struct xdr_stream *xdr, const struct COMMIT3resfail *value)
+{
+	if (!xdrgen_encode_wcc_data(xdr, &value->file_wcc))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_COMMIT3res(struct xdr_stream *xdr, const struct COMMIT3res *ptr)
+{
+	if (!xdrgen_encode_nfsstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case NFS3_OK:
+		if (!xdrgen_encode_COMMIT3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_COMMIT3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+/**
+ * nfs_svc_encode_GETATTR3res - Encode a GETATTR3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_GETATTR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETATTR3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_GETATTR3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_SETATTR3res - Encode a SETATTR3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_SETATTR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SETATTR3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_SETATTR3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_LOOKUP3res - Encode a LOOKUP3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_LOOKUP3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct LOOKUP3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_LOOKUP3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_ACCESS3res - Encode a ACCESS3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_ACCESS3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct ACCESS3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_ACCESS3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_READLINK3res - Encode a READLINK3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_READLINK3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READLINK3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_READLINK3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_READ3res - Encode a READ3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_READ3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READ3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_READ3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_WRITE3res - Encode a WRITE3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_WRITE3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct WRITE3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_WRITE3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_CREATE3res - Encode a CREATE3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_CREATE3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct CREATE3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_CREATE3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_MKDIR3res - Encode a MKDIR3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_MKDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct MKDIR3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_MKDIR3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_SYMLINK3res - Encode a SYMLINK3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_SYMLINK3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SYMLINK3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_SYMLINK3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_MKNOD3res - Encode a MKNOD3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_MKNOD3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct MKNOD3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_MKNOD3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_REMOVE3res - Encode a REMOVE3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_REMOVE3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct REMOVE3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_REMOVE3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_RMDIR3res - Encode a RMDIR3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_RMDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct RMDIR3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_RMDIR3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_RENAME3res - Encode a RENAME3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_RENAME3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct RENAME3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_RENAME3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_LINK3res - Encode a LINK3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_LINK3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct LINK3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_LINK3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_READDIR3res - Encode a READDIR3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_READDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READDIR3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_READDIR3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_READDIRPLUS3res - Encode a READDIRPLUS3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_READDIRPLUS3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct READDIRPLUS3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_READDIRPLUS3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_FSSTAT3res - Encode a FSSTAT3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_FSSTAT3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct FSSTAT3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_FSSTAT3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_FSINFO3res - Encode a FSINFO3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_FSINFO3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct FSINFO3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_FSINFO3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_PATHCONF3res - Encode a PATHCONF3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_PATHCONF3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct PATHCONF3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_PATHCONF3res(xdr, resp);
+}
+
+/**
+ * nfs_svc_encode_COMMIT3res - Encode a COMMIT3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_svc_encode_COMMIT3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct COMMIT3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_COMMIT3res(xdr, resp);
+}
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
new file mode 100644
index 000000000000..e2fbb583da92
--- /dev/null
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -0,0 +1,60 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
+/* XDR specification modification time: Fri Jul 10 23:20:55 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS3_DECL_H
+#define _LINUX_XDRGEN_NFS3_DECL_H
+
+#include <linux/types.h>
+
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/xdrgen/_defs.h>
+#include <linux/sunrpc/xdrgen/_builtins.h>
+#include <linux/sunrpc/xdrgen/nfs3.h>
+
+bool nfs_svc_decode_GETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_SETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_LOOKUP3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_ACCESS3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_READLINK3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_READ3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_WRITE3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_CREATE3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_MKDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_SYMLINK3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_MKNOD3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_REMOVE3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_RMDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_RENAME3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_LINK3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_READDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_READDIRPLUS3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_FSSTAT3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_FSINFO3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_PATHCONF3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_decode_COMMIT3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+bool nfs_svc_encode_GETATTR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_SETATTR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_LOOKUP3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_ACCESS3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_READLINK3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_READ3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_WRITE3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_CREATE3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_MKDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_SYMLINK3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_MKNOD3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_REMOVE3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_RMDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_RENAME3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_LINK3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_READDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_READDIRPLUS3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_FSSTAT3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_FSINFO3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_PATHCONF3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_svc_encode_COMMIT3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+#endif /* _LINUX_XDRGEN_NFS3_DECL_H */
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
new file mode 100644
index 000000000000..3afc4ffb6daa
--- /dev/null
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -0,0 +1,1092 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
+/* XDR specification modification time: Fri Jul 10 23:20:55 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS3_DEF_H
+#define _LINUX_XDRGEN_NFS3_DEF_H
+
+#include <linux/types.h>
+#include <linux/sunrpc/xdrgen/_defs.h>
+
+enum { NFS3_FHSIZE = 64 };
+
+enum { NFS3_COOKIEVERFSIZE = 8 };
+
+enum { NFS3_CREATEVERFSIZE = 8 };
+
+enum { NFS3_WRITEVERFSIZE = 8 };
+
+typedef u64 uint64;
+
+typedef s64 int64;
+
+typedef u32 uint32;
+
+typedef s32 int32;
+
+typedef string filename3;
+
+typedef string nfspath3;
+
+typedef uint64 fileid3;
+
+typedef uint64 cookie3;
+
+typedef u8 cookieverf3[NFS3_COOKIEVERFSIZE];
+
+typedef u8 createverf3[NFS3_CREATEVERFSIZE];
+
+typedef u8 writeverf3[NFS3_WRITEVERFSIZE];
+
+typedef uint32 uid3;
+
+typedef uint32 gid3;
+
+typedef uint64 size3;
+
+typedef uint64 offset3;
+
+typedef uint32 mode3;
+
+typedef uint32 count3;
+
+enum nfsstat3 {
+	NFS3_OK = 0,
+	NFS3ERR_PERM = 1,
+	NFS3ERR_NOENT = 2,
+	NFS3ERR_IO = 5,
+	NFS3ERR_NXIO = 6,
+	NFS3ERR_ACCES = 13,
+	NFS3ERR_EXIST = 17,
+	NFS3ERR_XDEV = 18,
+	NFS3ERR_NODEV = 19,
+	NFS3ERR_NOTDIR = 20,
+	NFS3ERR_ISDIR = 21,
+	NFS3ERR_INVAL = 22,
+	NFS3ERR_FBIG = 27,
+	NFS3ERR_NOSPC = 28,
+	NFS3ERR_ROFS = 30,
+	NFS3ERR_MLINK = 31,
+	NFS3ERR_NAMETOOLONG = 63,
+	NFS3ERR_NOTEMPTY = 66,
+	NFS3ERR_DQUOT = 69,
+	NFS3ERR_STALE = 70,
+	NFS3ERR_REMOTE = 71,
+	NFS3ERR_BADHANDLE = 10001,
+	NFS3ERR_NOT_SYNC = 10002,
+	NFS3ERR_BAD_COOKIE = 10003,
+	NFS3ERR_NOTSUPP = 10004,
+	NFS3ERR_TOOSMALL = 10005,
+	NFS3ERR_SERVERFAULT = 10006,
+	NFS3ERR_BADTYPE = 10007,
+	NFS3ERR_JUKEBOX = 10008,
+};
+
+typedef enum nfsstat3 nfsstat3;
+
+enum ftype3 {
+	NF3REG = 1,
+	NF3DIR = 2,
+	NF3BLK = 3,
+	NF3CHR = 4,
+	NF3LNK = 5,
+	NF3SOCK = 6,
+	NF3FIFO = 7,
+};
+
+typedef enum ftype3 ftype3;
+
+struct specdata3 {
+	uint32 specdata1;
+	uint32 specdata2;
+};
+
+struct nfs_fh3 {
+	opaque data;
+};
+
+struct nfstime3 {
+	uint32 seconds;
+	uint32 nseconds;
+};
+
+struct fattr3 {
+	ftype3 type;
+	mode3 mode;
+	uint32 nlink;
+	uid3 uid;
+	gid3 gid;
+	size3 size;
+	size3 used;
+	struct specdata3 rdev;
+	uint64 fsid;
+	fileid3 fileid;
+	struct nfstime3 atime;
+	struct nfstime3 mtime;
+	struct nfstime3 ctime;
+};
+
+struct post_op_attr {
+	bool attributes_follow;
+	union {
+		struct fattr3 attributes;
+	} u;
+};
+
+struct wcc_attr {
+	size3 size;
+	struct nfstime3 mtime;
+	struct nfstime3 ctime;
+};
+
+struct pre_op_attr {
+	bool attributes_follow;
+	union {
+		struct wcc_attr attributes;
+	} u;
+};
+
+struct wcc_data {
+	struct pre_op_attr before;
+	struct post_op_attr after;
+};
+
+struct post_op_fh3 {
+	bool handle_follows;
+	union {
+		struct nfs_fh3 handle;
+	} u;
+};
+
+enum time_how {
+	DONT_CHANGE = 0,
+	SET_TO_SERVER_TIME = 1,
+	SET_TO_CLIENT_TIME = 2,
+};
+
+typedef enum time_how time_how;
+
+struct set_mode3 {
+	bool set_it;
+	union {
+		mode3 mode;
+	} u;
+};
+
+struct set_uid3 {
+	bool set_it;
+	union {
+		uid3 uid;
+	} u;
+};
+
+struct set_gid3 {
+	bool set_it;
+	union {
+		gid3 gid;
+	} u;
+};
+
+struct set_size3 {
+	bool set_it;
+	union {
+		size3 size;
+	} u;
+};
+
+struct set_atime {
+	time_how set_it;
+	union {
+		struct nfstime3 atime;
+	} u;
+};
+
+struct set_mtime {
+	time_how set_it;
+	union {
+		struct nfstime3 mtime;
+	} u;
+};
+
+struct sattr3 {
+	struct set_mode3 mode;
+	struct set_uid3 uid;
+	struct set_gid3 gid;
+	struct set_size3 size;
+	struct set_atime atime;
+	struct set_mtime mtime;
+};
+
+struct diropargs3 {
+	struct nfs_fh3 dir;
+	filename3 name;
+};
+
+struct GETATTR3args {
+	struct nfs_fh3 object;
+};
+
+struct GETATTR3resok {
+	struct fattr3 obj_attributes;
+};
+
+struct GETATTR3res {
+	nfsstat3 status;
+	union {
+		struct GETATTR3resok resok;
+	} u;
+};
+
+struct sattrguard3 {
+	bool check;
+	union {
+		struct nfstime3 obj_ctime;
+	} u;
+};
+
+struct SETATTR3args {
+	struct nfs_fh3 object;
+	struct sattr3 new_attributes;
+	struct sattrguard3 guard;
+};
+
+struct SETATTR3resok {
+	struct wcc_data obj_wcc;
+};
+
+struct SETATTR3resfail {
+	struct wcc_data obj_wcc;
+};
+
+struct SETATTR3res {
+	nfsstat3 status;
+	union {
+		struct SETATTR3resok resok;
+		struct SETATTR3resfail resfail;
+	} u;
+};
+
+struct LOOKUP3args {
+	struct diropargs3 what;
+};
+
+struct LOOKUP3resok {
+	struct nfs_fh3 object;
+	struct post_op_attr obj_attributes;
+	struct post_op_attr dir_attributes;
+};
+
+struct LOOKUP3resfail {
+	struct post_op_attr dir_attributes;
+};
+
+struct LOOKUP3res {
+	nfsstat3 status;
+	union {
+		struct LOOKUP3resok resok;
+		struct LOOKUP3resfail resfail;
+	} u;
+};
+
+enum { ACCESS3_READ = 0x0001 };
+
+enum { ACCESS3_LOOKUP = 0x0002 };
+
+enum { ACCESS3_MODIFY = 0x0004 };
+
+enum { ACCESS3_EXTEND = 0x0008 };
+
+enum { ACCESS3_DELETE = 0x0010 };
+
+enum { ACCESS3_EXECUTE = 0x0020 };
+
+struct ACCESS3args {
+	struct nfs_fh3 object;
+	uint32 access;
+};
+
+struct ACCESS3resok {
+	struct post_op_attr obj_attributes;
+	uint32 access;
+};
+
+struct ACCESS3resfail {
+	struct post_op_attr obj_attributes;
+};
+
+struct ACCESS3res {
+	nfsstat3 status;
+	union {
+		struct ACCESS3resok resok;
+		struct ACCESS3resfail resfail;
+	} u;
+};
+
+struct READLINK3args {
+	struct nfs_fh3 symlink;
+};
+
+struct READLINK3resok {
+	struct post_op_attr symlink_attributes;
+	nfspath3 data;
+};
+
+struct READLINK3resfail {
+	struct post_op_attr symlink_attributes;
+};
+
+struct READLINK3res {
+	nfsstat3 status;
+	union {
+		struct READLINK3resok resok;
+		struct READLINK3resfail resfail;
+	} u;
+};
+
+struct READ3args {
+	struct nfs_fh3 file;
+	offset3 offset;
+	count3 count;
+};
+
+struct READ3resok {
+	struct post_op_attr file_attributes;
+	count3 count;
+	bool eof;
+	opaque data;
+};
+
+struct READ3resfail {
+	struct post_op_attr file_attributes;
+};
+
+struct READ3res {
+	nfsstat3 status;
+	union {
+		struct READ3resok resok;
+		struct READ3resfail resfail;
+	} u;
+};
+
+enum stable_how {
+	UNSTABLE = 0,
+	DATA_SYNC = 1,
+	FILE_SYNC = 2,
+};
+
+typedef enum stable_how stable_how;
+
+struct WRITE3args {
+	struct nfs_fh3 file;
+	offset3 offset;
+	count3 count;
+	stable_how stable;
+	opaque data;
+};
+
+struct WRITE3resok {
+	struct wcc_data file_wcc;
+	count3 count;
+	stable_how committed;
+	writeverf3 verf;
+};
+
+struct WRITE3resfail {
+	struct wcc_data file_wcc;
+};
+
+struct WRITE3res {
+	nfsstat3 status;
+	union {
+		struct WRITE3resok resok;
+		struct WRITE3resfail resfail;
+	} u;
+};
+
+enum createmode3 {
+	UNCHECKED = 0,
+	GUARDED = 1,
+	EXCLUSIVE = 2,
+};
+
+typedef enum createmode3 createmode3;
+
+struct createhow3 {
+	createmode3 mode;
+	union {
+		struct sattr3 obj_attributes;
+		createverf3 verf;
+	} u;
+};
+
+struct CREATE3args {
+	struct diropargs3 where;
+	struct createhow3 how;
+};
+
+struct CREATE3resok {
+	struct post_op_fh3 obj;
+	struct post_op_attr obj_attributes;
+	struct wcc_data dir_wcc;
+};
+
+struct CREATE3resfail {
+	struct wcc_data dir_wcc;
+};
+
+struct CREATE3res {
+	nfsstat3 status;
+	union {
+		struct CREATE3resok resok;
+		struct CREATE3resfail resfail;
+	} u;
+};
+
+struct MKDIR3args {
+	struct diropargs3 where;
+	struct sattr3 attributes;
+};
+
+struct MKDIR3resok {
+	struct post_op_fh3 obj;
+	struct post_op_attr obj_attributes;
+	struct wcc_data dir_wcc;
+};
+
+struct MKDIR3resfail {
+	struct wcc_data dir_wcc;
+};
+
+struct MKDIR3res {
+	nfsstat3 status;
+	union {
+		struct MKDIR3resok resok;
+		struct MKDIR3resfail resfail;
+	} u;
+};
+
+struct symlinkdata3 {
+	struct sattr3 symlink_attributes;
+	nfspath3 symlink_data;
+};
+
+struct SYMLINK3args {
+	struct diropargs3 where;
+	struct symlinkdata3 symlink;
+};
+
+struct SYMLINK3resok {
+	struct post_op_fh3 obj;
+	struct post_op_attr obj_attributes;
+	struct wcc_data dir_wcc;
+};
+
+struct SYMLINK3resfail {
+	struct wcc_data dir_wcc;
+};
+
+struct SYMLINK3res {
+	nfsstat3 status;
+	union {
+		struct SYMLINK3resok resok;
+		struct SYMLINK3resfail resfail;
+	} u;
+};
+
+struct devicedata3 {
+	struct sattr3 dev_attributes;
+	struct specdata3 spec;
+};
+
+struct mknoddata3 {
+	ftype3 type;
+	union {
+		struct devicedata3 device;
+		struct sattr3 pipe_attributes;
+	} u;
+};
+
+struct MKNOD3args {
+	struct diropargs3 where;
+	struct mknoddata3 what;
+};
+
+struct MKNOD3resok {
+	struct post_op_fh3 obj;
+	struct post_op_attr obj_attributes;
+	struct wcc_data dir_wcc;
+};
+
+struct MKNOD3resfail {
+	struct wcc_data dir_wcc;
+};
+
+struct MKNOD3res {
+	nfsstat3 status;
+	union {
+		struct MKNOD3resok resok;
+		struct MKNOD3resfail resfail;
+	} u;
+};
+
+struct REMOVE3args {
+	struct diropargs3 object;
+};
+
+struct REMOVE3resok {
+	struct wcc_data dir_wcc;
+};
+
+struct REMOVE3resfail {
+	struct wcc_data dir_wcc;
+};
+
+struct REMOVE3res {
+	nfsstat3 status;
+	union {
+		struct REMOVE3resok resok;
+		struct REMOVE3resfail resfail;
+	} u;
+};
+
+struct RMDIR3args {
+	struct diropargs3 object;
+};
+
+struct RMDIR3resok {
+	struct wcc_data dir_wcc;
+};
+
+struct RMDIR3resfail {
+	struct wcc_data dir_wcc;
+};
+
+struct RMDIR3res {
+	nfsstat3 status;
+	union {
+		struct RMDIR3resok resok;
+		struct RMDIR3resfail resfail;
+	} u;
+};
+
+struct RENAME3args {
+	struct diropargs3 from;
+	struct diropargs3 to;
+};
+
+struct RENAME3resok {
+	struct wcc_data fromdir_wcc;
+	struct wcc_data todir_wcc;
+};
+
+struct RENAME3resfail {
+	struct wcc_data fromdir_wcc;
+	struct wcc_data todir_wcc;
+};
+
+struct RENAME3res {
+	nfsstat3 status;
+	union {
+		struct RENAME3resok resok;
+		struct RENAME3resfail resfail;
+	} u;
+};
+
+struct LINK3args {
+	struct nfs_fh3 file;
+	struct diropargs3 link;
+};
+
+struct LINK3resok {
+	struct post_op_attr file_attributes;
+	struct wcc_data linkdir_wcc;
+};
+
+struct LINK3resfail {
+	struct post_op_attr file_attributes;
+	struct wcc_data linkdir_wcc;
+};
+
+struct LINK3res {
+	nfsstat3 status;
+	union {
+		struct LINK3resok resok;
+		struct LINK3resfail resfail;
+	} u;
+};
+
+struct READDIR3args {
+	struct nfs_fh3 dir;
+	cookie3 cookie;
+	cookieverf3 cookieverf;
+	count3 count;
+};
+
+struct entry3 {
+	fileid3 fileid;
+	filename3 name;
+	cookie3 cookie;
+};
+
+struct dirlist3 {
+	struct entry3 *entries;
+	bool eof;
+};
+
+struct READDIR3resok {
+	struct post_op_attr dir_attributes;
+	cookieverf3 cookieverf;
+	struct dirlist3 reply;
+};
+
+struct READDIR3resfail {
+	struct post_op_attr dir_attributes;
+};
+
+struct READDIR3res {
+	nfsstat3 status;
+	union {
+		struct READDIR3resok resok;
+		struct READDIR3resfail resfail;
+	} u;
+};
+
+struct READDIRPLUS3args {
+	struct nfs_fh3 dir;
+	cookie3 cookie;
+	cookieverf3 cookieverf;
+	count3 dircount;
+	count3 maxcount;
+};
+
+struct entryplus3 {
+	fileid3 fileid;
+	filename3 name;
+	cookie3 cookie;
+	struct post_op_attr name_attributes;
+	struct post_op_fh3 name_handle;
+};
+
+struct dirlistplus3 {
+	struct entryplus3 *entries;
+	bool eof;
+};
+
+struct READDIRPLUS3resok {
+	struct post_op_attr dir_attributes;
+	cookieverf3 cookieverf;
+	struct dirlistplus3 reply;
+};
+
+struct READDIRPLUS3resfail {
+	struct post_op_attr dir_attributes;
+};
+
+struct READDIRPLUS3res {
+	nfsstat3 status;
+	union {
+		struct READDIRPLUS3resok resok;
+		struct READDIRPLUS3resfail resfail;
+	} u;
+};
+
+struct FSSTAT3args {
+	struct nfs_fh3 fsroot;
+};
+
+struct FSSTAT3resok {
+	struct post_op_attr obj_attributes;
+	size3 tbytes;
+	size3 fbytes;
+	size3 abytes;
+	size3 tfiles;
+	size3 ffiles;
+	size3 afiles;
+	uint32 invarsec;
+};
+
+struct FSSTAT3resfail {
+	struct post_op_attr obj_attributes;
+};
+
+struct FSSTAT3res {
+	nfsstat3 status;
+	union {
+		struct FSSTAT3resok resok;
+		struct FSSTAT3resfail resfail;
+	} u;
+};
+
+enum { FSF3_LINK = 0x0001 };
+
+enum { FSF3_SYMLINK = 0x0002 };
+
+enum { FSF3_HOMOGENEOUS = 0x0008 };
+
+enum { FSF3_CANSETTIME = 0x0010 };
+
+struct FSINFO3args {
+	struct nfs_fh3 fsroot;
+};
+
+struct FSINFO3resok {
+	struct post_op_attr obj_attributes;
+	uint32 rtmax;
+	uint32 rtpref;
+	uint32 rtmult;
+	uint32 wtmax;
+	uint32 wtpref;
+	uint32 wtmult;
+	uint32 dtpref;
+	size3 maxfilesize;
+	struct nfstime3 time_delta;
+	uint32 properties;
+};
+
+struct FSINFO3resfail {
+	struct post_op_attr obj_attributes;
+};
+
+struct FSINFO3res {
+	nfsstat3 status;
+	union {
+		struct FSINFO3resok resok;
+		struct FSINFO3resfail resfail;
+	} u;
+};
+
+struct PATHCONF3args {
+	struct nfs_fh3 object;
+};
+
+struct PATHCONF3resok {
+	struct post_op_attr obj_attributes;
+	uint32 linkmax;
+	uint32 name_max;
+	bool no_trunc;
+	bool chown_restricted;
+	bool case_insensitive;
+	bool case_preserving;
+};
+
+struct PATHCONF3resfail {
+	struct post_op_attr obj_attributes;
+};
+
+struct PATHCONF3res {
+	nfsstat3 status;
+	union {
+		struct PATHCONF3resok resok;
+		struct PATHCONF3resfail resfail;
+	} u;
+};
+
+struct COMMIT3args {
+	struct nfs_fh3 file;
+	offset3 offset;
+	count3 count;
+};
+
+struct COMMIT3resok {
+	struct wcc_data file_wcc;
+	writeverf3 verf;
+};
+
+struct COMMIT3resfail {
+	struct wcc_data file_wcc;
+};
+
+struct COMMIT3res {
+	nfsstat3 status;
+	union {
+		struct COMMIT3resok resok;
+		struct COMMIT3resfail resfail;
+	} u;
+};
+
+enum {
+	NFSPROC3_NULL = 0,
+	NFSPROC3_GETATTR = 1,
+	NFSPROC3_SETATTR = 2,
+	NFSPROC3_LOOKUP = 3,
+	NFSPROC3_ACCESS = 4,
+	NFSPROC3_READLINK = 5,
+	NFSPROC3_READ = 6,
+	NFSPROC3_WRITE = 7,
+	NFSPROC3_CREATE = 8,
+	NFSPROC3_MKDIR = 9,
+	NFSPROC3_SYMLINK = 10,
+	NFSPROC3_MKNOD = 11,
+	NFSPROC3_REMOVE = 12,
+	NFSPROC3_RMDIR = 13,
+	NFSPROC3_RENAME = 14,
+	NFSPROC3_LINK = 15,
+	NFSPROC3_READDIR = 16,
+	NFSPROC3_READDIRPLUS = 17,
+	NFSPROC3_FSSTAT = 18,
+	NFSPROC3_FSINFO = 19,
+	NFSPROC3_PATHCONF = 20,
+	NFSPROC3_COMMIT = 21,
+};
+
+#ifndef NFS_PROGRAM
+#define NFS_PROGRAM (100003)
+#endif
+
+#define NFS3_uint64_sz                  \
+	(XDR_unsigned_hyper)
+#define NFS3_int64_sz                   \
+	(XDR_hyper)
+#define NFS3_uint32_sz                  \
+	(XDR_unsigned_long)
+#define NFS3_int32_sz                   \
+	(XDR_long)
+#define NFS3_filename3_sz               (XDR_unsigned_int)
+#define NFS3_nfspath3_sz                (XDR_unsigned_int)
+#define NFS3_fileid3_sz                 \
+	(NFS3_uint64_sz)
+#define NFS3_cookie3_sz                 \
+	(NFS3_uint64_sz)
+#define NFS3_cookieverf3_sz             (XDR_QUADLEN(NFS3_COOKIEVERFSIZE))
+#define NFS3_createverf3_sz             (XDR_QUADLEN(NFS3_CREATEVERFSIZE))
+#define NFS3_writeverf3_sz              (XDR_QUADLEN(NFS3_WRITEVERFSIZE))
+#define NFS3_uid3_sz                    \
+	(NFS3_uint32_sz)
+#define NFS3_gid3_sz                    \
+	(NFS3_uint32_sz)
+#define NFS3_size3_sz                   \
+	(NFS3_uint64_sz)
+#define NFS3_offset3_sz                 \
+	(NFS3_uint64_sz)
+#define NFS3_mode3_sz                   \
+	(NFS3_uint32_sz)
+#define NFS3_count3_sz                  \
+	(NFS3_uint32_sz)
+#define NFS3_nfsstat3_sz                (XDR_int)
+#define NFS3_ftype3_sz                  (XDR_int)
+#define NFS3_specdata3_sz               \
+	(NFS3_uint32_sz + NFS3_uint32_sz)
+#define NFS3_nfs_fh3_sz                 \
+	(XDR_unsigned_int + XDR_QUADLEN(NFS3_FHSIZE))
+#define NFS3_nfstime3_sz                \
+	(NFS3_uint32_sz + NFS3_uint32_sz)
+#define NFS3_fattr3_sz                  \
+	(NFS3_ftype3_sz + NFS3_mode3_sz + NFS3_uint32_sz + NFS3_uid3_sz + NFS3_gid3_sz + NFS3_size3_sz + NFS3_size3_sz + NFS3_specdata3_sz + NFS3_uint64_sz + NFS3_fileid3_sz + NFS3_nfstime3_sz + NFS3_nfstime3_sz + NFS3_nfstime3_sz)
+#define NFS3_post_op_attr_sz            \
+	(XDR_bool + NFS3_fattr3_sz)
+#define NFS3_wcc_attr_sz                \
+	(NFS3_size3_sz + NFS3_nfstime3_sz + NFS3_nfstime3_sz)
+#define NFS3_pre_op_attr_sz             \
+	(XDR_bool + NFS3_wcc_attr_sz)
+#define NFS3_wcc_data_sz                \
+	(NFS3_pre_op_attr_sz + NFS3_post_op_attr_sz)
+#define NFS3_post_op_fh3_sz             \
+	(XDR_bool + NFS3_nfs_fh3_sz)
+#define NFS3_time_how_sz                (XDR_int)
+#define NFS3_set_mode3_sz               \
+	(NFS3_time_how_sz + NFS3_mode3_sz)
+#define NFS3_set_uid3_sz                \
+	(NFS3_time_how_sz + NFS3_uid3_sz)
+#define NFS3_set_gid3_sz                \
+	(NFS3_time_how_sz + NFS3_gid3_sz)
+#define NFS3_set_size3_sz               \
+	(NFS3_time_how_sz + NFS3_size3_sz)
+#define NFS3_set_atime_sz               \
+	(NFS3_time_how_sz + NFS3_nfstime3_sz)
+#define NFS3_set_mtime_sz               \
+	(NFS3_time_how_sz + NFS3_nfstime3_sz)
+#define NFS3_sattr3_sz                  \
+	(NFS3_set_mode3_sz + NFS3_set_uid3_sz + NFS3_set_gid3_sz + NFS3_set_size3_sz + NFS3_set_atime_sz + NFS3_set_mtime_sz)
+#define NFS3_diropargs3_sz              \
+	(NFS3_nfs_fh3_sz + NFS3_filename3_sz)
+#define NFS3_GETATTR3args_sz            \
+	(NFS3_nfs_fh3_sz)
+#define NFS3_GETATTR3resok_sz           \
+	(NFS3_fattr3_sz)
+#define NFS3_GETATTR3res_sz             \
+	(NFS3_nfsstat3_sz + NFS3_GETATTR3resok_sz)
+#define NFS3_sattrguard3_sz             \
+	(XDR_bool + NFS3_nfstime3_sz)
+#define NFS3_SETATTR3args_sz            \
+	(NFS3_nfs_fh3_sz + NFS3_sattr3_sz + NFS3_sattrguard3_sz)
+#define NFS3_SETATTR3resok_sz           \
+	(NFS3_wcc_data_sz)
+#define NFS3_SETATTR3resfail_sz         \
+	(NFS3_wcc_data_sz)
+#define NFS3_SETATTR3res_sz             \
+	(NFS3_nfsstat3_sz + NFS3_SETATTR3resok_sz)
+#define NFS3_LOOKUP3args_sz             \
+	(NFS3_diropargs3_sz)
+#define NFS3_LOOKUP3resok_sz            \
+	(NFS3_nfs_fh3_sz + NFS3_post_op_attr_sz + NFS3_post_op_attr_sz)
+#define NFS3_LOOKUP3resfail_sz          \
+	(NFS3_post_op_attr_sz)
+#define NFS3_LOOKUP3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_LOOKUP3resok_sz)
+#define NFS3_ACCESS3args_sz             \
+	(NFS3_nfs_fh3_sz + NFS3_uint32_sz)
+#define NFS3_ACCESS3resok_sz            \
+	(NFS3_post_op_attr_sz + NFS3_uint32_sz)
+#define NFS3_ACCESS3resfail_sz          \
+	(NFS3_post_op_attr_sz)
+#define NFS3_ACCESS3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_ACCESS3resok_sz)
+#define NFS3_READLINK3args_sz           \
+	(NFS3_nfs_fh3_sz)
+#define NFS3_READLINK3resok_sz          \
+	(NFS3_post_op_attr_sz + NFS3_nfspath3_sz)
+#define NFS3_READLINK3resfail_sz        \
+	(NFS3_post_op_attr_sz)
+#define NFS3_READLINK3res_sz            \
+	(NFS3_nfsstat3_sz + NFS3_READLINK3resok_sz)
+#define NFS3_READ3args_sz               \
+	(NFS3_nfs_fh3_sz + NFS3_offset3_sz + NFS3_count3_sz)
+#define NFS3_READ3resok_sz              \
+	(NFS3_post_op_attr_sz + NFS3_count3_sz + XDR_bool + XDR_unsigned_int)
+#define NFS3_READ3resfail_sz            \
+	(NFS3_post_op_attr_sz)
+#define NFS3_READ3res_sz                \
+	(NFS3_nfsstat3_sz + NFS3_READ3resok_sz)
+#define NFS3_stable_how_sz              (XDR_int)
+#define NFS3_WRITE3args_sz              \
+	(NFS3_nfs_fh3_sz + NFS3_offset3_sz + NFS3_count3_sz + NFS3_stable_how_sz + XDR_unsigned_int)
+#define NFS3_WRITE3resok_sz             \
+	(NFS3_wcc_data_sz + NFS3_count3_sz + NFS3_stable_how_sz + NFS3_writeverf3_sz)
+#define NFS3_WRITE3resfail_sz           \
+	(NFS3_wcc_data_sz)
+#define NFS3_WRITE3res_sz               \
+	(NFS3_nfsstat3_sz + NFS3_WRITE3resok_sz)
+#define NFS3_createmode3_sz             (XDR_int)
+#define NFS3_createhow3_sz              \
+	(NFS3_createmode3_sz + NFS3_sattr3_sz)
+#define NFS3_CREATE3args_sz             \
+	(NFS3_diropargs3_sz + NFS3_createhow3_sz)
+#define NFS3_CREATE3resok_sz            \
+	(NFS3_post_op_fh3_sz + NFS3_post_op_attr_sz + NFS3_wcc_data_sz)
+#define NFS3_CREATE3resfail_sz          \
+	(NFS3_wcc_data_sz)
+#define NFS3_CREATE3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_CREATE3resok_sz)
+#define NFS3_MKDIR3args_sz              \
+	(NFS3_diropargs3_sz + NFS3_sattr3_sz)
+#define NFS3_MKDIR3resok_sz             \
+	(NFS3_post_op_fh3_sz + NFS3_post_op_attr_sz + NFS3_wcc_data_sz)
+#define NFS3_MKDIR3resfail_sz           \
+	(NFS3_wcc_data_sz)
+#define NFS3_MKDIR3res_sz               \
+	(NFS3_nfsstat3_sz + NFS3_MKDIR3resok_sz)
+#define NFS3_symlinkdata3_sz            \
+	(NFS3_sattr3_sz + NFS3_nfspath3_sz)
+#define NFS3_SYMLINK3args_sz            \
+	(NFS3_diropargs3_sz + NFS3_symlinkdata3_sz)
+#define NFS3_SYMLINK3resok_sz           \
+	(NFS3_post_op_fh3_sz + NFS3_post_op_attr_sz + NFS3_wcc_data_sz)
+#define NFS3_SYMLINK3resfail_sz         \
+	(NFS3_wcc_data_sz)
+#define NFS3_SYMLINK3res_sz             \
+	(NFS3_nfsstat3_sz + NFS3_SYMLINK3resok_sz)
+#define NFS3_devicedata3_sz             \
+	(NFS3_sattr3_sz + NFS3_specdata3_sz)
+#define NFS3_mknoddata3_sz              \
+	(NFS3_ftype3_sz + NFS3_devicedata3_sz)
+#define NFS3_MKNOD3args_sz              \
+	(NFS3_diropargs3_sz + NFS3_mknoddata3_sz)
+#define NFS3_MKNOD3resok_sz             \
+	(NFS3_post_op_fh3_sz + NFS3_post_op_attr_sz + NFS3_wcc_data_sz)
+#define NFS3_MKNOD3resfail_sz           \
+	(NFS3_wcc_data_sz)
+#define NFS3_MKNOD3res_sz               \
+	(NFS3_nfsstat3_sz + NFS3_MKNOD3resok_sz)
+#define NFS3_REMOVE3args_sz             \
+	(NFS3_diropargs3_sz)
+#define NFS3_REMOVE3resok_sz            \
+	(NFS3_wcc_data_sz)
+#define NFS3_REMOVE3resfail_sz          \
+	(NFS3_wcc_data_sz)
+#define NFS3_REMOVE3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_REMOVE3resok_sz)
+#define NFS3_RMDIR3args_sz              \
+	(NFS3_diropargs3_sz)
+#define NFS3_RMDIR3resok_sz             \
+	(NFS3_wcc_data_sz)
+#define NFS3_RMDIR3resfail_sz           \
+	(NFS3_wcc_data_sz)
+#define NFS3_RMDIR3res_sz               \
+	(NFS3_nfsstat3_sz + NFS3_RMDIR3resok_sz)
+#define NFS3_RENAME3args_sz             \
+	(NFS3_diropargs3_sz + NFS3_diropargs3_sz)
+#define NFS3_RENAME3resok_sz            \
+	(NFS3_wcc_data_sz + NFS3_wcc_data_sz)
+#define NFS3_RENAME3resfail_sz          \
+	(NFS3_wcc_data_sz + NFS3_wcc_data_sz)
+#define NFS3_RENAME3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_RENAME3resok_sz)
+#define NFS3_LINK3args_sz               \
+	(NFS3_nfs_fh3_sz + NFS3_diropargs3_sz)
+#define NFS3_LINK3resok_sz              \
+	(NFS3_post_op_attr_sz + NFS3_wcc_data_sz)
+#define NFS3_LINK3resfail_sz            \
+	(NFS3_post_op_attr_sz + NFS3_wcc_data_sz)
+#define NFS3_LINK3res_sz                \
+	(NFS3_nfsstat3_sz + NFS3_LINK3resok_sz)
+#define NFS3_READDIR3args_sz            \
+	(NFS3_nfs_fh3_sz + NFS3_cookie3_sz + NFS3_cookieverf3_sz + NFS3_count3_sz)
+#define NFS3_entry3_sz                  \
+	(XDR_bool + NFS3_fileid3_sz + NFS3_filename3_sz + NFS3_cookie3_sz)
+#define NFS3_dirlist3_sz                \
+	(XDR_bool + XDR_bool)
+#define NFS3_READDIR3resok_sz           \
+	(NFS3_post_op_attr_sz + NFS3_cookieverf3_sz + NFS3_dirlist3_sz)
+#define NFS3_READDIR3resfail_sz         \
+	(NFS3_post_op_attr_sz)
+#define NFS3_READDIR3res_sz             \
+	(NFS3_nfsstat3_sz + NFS3_READDIR3resok_sz)
+#define NFS3_READDIRPLUS3args_sz        \
+	(NFS3_nfs_fh3_sz + NFS3_cookie3_sz + NFS3_cookieverf3_sz + NFS3_count3_sz + NFS3_count3_sz)
+#define NFS3_entryplus3_sz              \
+	(XDR_bool + NFS3_fileid3_sz + NFS3_filename3_sz + NFS3_cookie3_sz + NFS3_post_op_attr_sz + NFS3_post_op_fh3_sz)
+#define NFS3_dirlistplus3_sz            \
+	(XDR_bool + XDR_bool)
+#define NFS3_READDIRPLUS3resok_sz       \
+	(NFS3_post_op_attr_sz + NFS3_cookieverf3_sz + NFS3_dirlistplus3_sz)
+#define NFS3_READDIRPLUS3resfail_sz     \
+	(NFS3_post_op_attr_sz)
+#define NFS3_READDIRPLUS3res_sz         \
+	(NFS3_nfsstat3_sz + NFS3_READDIRPLUS3resok_sz)
+#define NFS3_FSSTAT3args_sz             \
+	(NFS3_nfs_fh3_sz)
+#define NFS3_FSSTAT3resok_sz            \
+	(NFS3_post_op_attr_sz + NFS3_size3_sz + NFS3_size3_sz + NFS3_size3_sz + NFS3_size3_sz + NFS3_size3_sz + NFS3_size3_sz + NFS3_uint32_sz)
+#define NFS3_FSSTAT3resfail_sz          \
+	(NFS3_post_op_attr_sz)
+#define NFS3_FSSTAT3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_FSSTAT3resok_sz)
+#define NFS3_FSINFO3args_sz             \
+	(NFS3_nfs_fh3_sz)
+#define NFS3_FSINFO3resok_sz            \
+	(NFS3_post_op_attr_sz + NFS3_uint32_sz + NFS3_uint32_sz + NFS3_uint32_sz + NFS3_uint32_sz + NFS3_uint32_sz + NFS3_uint32_sz + NFS3_uint32_sz + NFS3_size3_sz + NFS3_nfstime3_sz + NFS3_uint32_sz)
+#define NFS3_FSINFO3resfail_sz          \
+	(NFS3_post_op_attr_sz)
+#define NFS3_FSINFO3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_FSINFO3resok_sz)
+#define NFS3_PATHCONF3args_sz           \
+	(NFS3_nfs_fh3_sz)
+#define NFS3_PATHCONF3resok_sz          \
+	(NFS3_post_op_attr_sz + NFS3_uint32_sz + NFS3_uint32_sz + XDR_bool + XDR_bool + XDR_bool + XDR_bool)
+#define NFS3_PATHCONF3resfail_sz        \
+	(NFS3_post_op_attr_sz)
+#define NFS3_PATHCONF3res_sz            \
+	(NFS3_nfsstat3_sz + NFS3_PATHCONF3resok_sz)
+#define NFS3_COMMIT3args_sz             \
+	(NFS3_nfs_fh3_sz + NFS3_offset3_sz + NFS3_count3_sz)
+#define NFS3_COMMIT3resok_sz            \
+	(NFS3_wcc_data_sz + NFS3_writeverf3_sz)
+#define NFS3_COMMIT3resfail_sz          \
+	(NFS3_wcc_data_sz)
+#define NFS3_COMMIT3res_sz              \
+	(NFS3_nfsstat3_sz + NFS3_COMMIT3resok_sz)
+#define NFS3_MAX_ARGS_SZ                \
+	(NFS3_MKNOD3args_sz)
+
+#endif /* _LINUX_XDRGEN_NFS3_DEF_H */
-- 
2.55.0

