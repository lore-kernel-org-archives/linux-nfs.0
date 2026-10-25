Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050580;
	b=DD/yHiXkBmRq2Z8tvkcSDqaTdOnOTVEQ29cEK8UW1N3WIR4KywKGy3URMZDMTEc4obxo
	 yJZvABrKwd1Z9XaIQe4VIZbo3GiTslVmdkXNwQCIR6L+uiWxFhWW8sBil3jpTpuA5AY0D
	 lhV09UB0cu5Hf4iBleDgDVXBAta6ienP3NXtTOiTfx0KbJAywq5K70u0hjk+zYz4sEJyk
	 BjC8yf+jo9MIGCTYVQYqjo4i/XDVLik8dkqUtBQ7Pe7zMaDn/TD04C+q8RMaN45lioNa+
	 Rn0pQAb0azBDTy8cB1HvLcG/8fFjZNtH3jFLQSo2qOi7W8to/qas1OhPnAEKJ/SPwTw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050580;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=BRdNHUvpsoavJEIdaTLUfyOs7zw5W75Lrm0GpMJGYXw=;
	b=F9Sl5YGoAE59EKS7dXSu84emxBDBzD4qgf7yZgX5VyuU8OMqr83oI3EIYkyQhS4d8Fz+
	 m87ZKHGFZQLbCML642ctb4xowvfGADixEoT//gX5UnIH9KRp/3nY/hcvhI33XNS/wgGxL
	 z3jNBmIdiJMau27kzJxNcwZSXlWrcf5foD0l0vwokZy240kBLECKmn1MpzminziaIsEP6
	 PnkVkeTGqASfHMtc5x/E3XO2HeJseWsug5fp7mWS3FyqM67Mp0BXuTOjNVk8yQQojrPGe
	 AVpzcEHelMc2Gp+HhXM+yXEQ0Fh42qcninfxrR/lKNX4JF/usr4wvDf93YgEsWXikIQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CBI6J7Kt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62963606A327
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CBI6J7Kt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8DDCC1F01828;
	Mon, 26 Oct 2026 21:36:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050579;
	bh=BRdNHUvpsoavJEIdaTLUfyOs7zw5W75Lrm0GpMJGYXw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=CBI6J7KtmFopH+r+kttjZjfEeNfHmJzrsSR4KzX7Hev2kIwBGyxlkxrc0XQjZOg9/
	 kdpap9DS2UT1F7Xa3LIx2iOKSx7BdFQtLaRNJSCxrID5W1pPte91QIkstG6aqH1VwE
	 m2DAR6Aiy6aJP2JVxJ8vNCpUTpR0i1n0WxSDvf7zhaJsOi6u54GRPD6NrOWDRIOJxD
	 ZmjOPNIwDwsxc47mqJKQzwbbslpqCcsYRJNrN7rDIP5quvmT6SVpQO2qQgIrBkMAXh
	 8XMGiwJUtIwbevsrd2VGcA9mnLMpMx3MHhOsVJxsrZ9xH0GIYiMF4+5F50tmdbXgQw
	 6XCRh2WWhdBlA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 02/13] NFSD: Add infrastructure for generating NFS_ACLv3 XDR encoders and decoders
Date: Sun, 25 Oct 2026 11:16:11 -0400
Message-ID: <20261025151622.141025-3-cel@kernel.org>
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

NFSD's NFS_ACLv3 XDR codecs are hand-maintained; they are being
converted to xdrgen-generated code one RPC procedure at a time.
The first step is to generate and commit the xdrgen C code based on
nfs_acl3.x. The generated code can be refreshed any time nfs_acl3.x
is modified by running "(cd fs/nfsd && make xdrgen)"

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs_acl3.x    |   2 +
 fs/nfsd/Makefile                       |  13 +-
 fs/nfsd/nfs_acl3xdr_gen.c              | 749 +++++++++++++++++++++++++
 fs/nfsd/nfs_acl3xdr_gen.h              |  24 +
 include/linux/sunrpc/xdrgen/nfs_acl3.h | 284 ++++++++++
 5 files changed, 1069 insertions(+), 3 deletions(-)
 create mode 100644 fs/nfsd/nfs_acl3xdr_gen.c
 create mode 100644 fs/nfsd/nfs_acl3xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs_acl3.h

diff --git a/Documentation/sunrpc/xdr/nfs_acl3.x b/Documentation/sunrpc/xdr/nfs_acl3.x
index 913ecf3a369f..b0e1d2e1fd43 100644
--- a/Documentation/sunrpc/xdr/nfs_acl3.x
+++ b/Documentation/sunrpc/xdr/nfs_acl3.x
@@ -40,6 +40,8 @@
  *   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+pragma header nfs_acl3;
+
 const NFS_ACL_MAX_ENTRIES = 1024;
 
 typedef unsigned int uid;
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 7db3b248e15a..96af6d479731 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -16,7 +16,7 @@ nfsd-y 			+= nfssvc.o nfsctl.o nfsfh.o vfs.o \
 			   nfs3proc.o nfs3xdr.o nfs3xdr_gen.o
 nfsd-$(CONFIG_NFSD_V2) += nfsproc.o nfsxdr.o nfs2xdr_gen.o
 nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o nfs_acl2xdr_gen.o
-nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
+nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o nfs_acl3xdr_gen.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o nfs4xdr_gen.o
 nfsd-$(CONFIG_NFSD_PNFS) += nfs4layouts.o
@@ -40,11 +40,12 @@ nfsd-$(CONFIG_DEBUG_FS) += debugfs.o
 XDRGEN_DEFINITIONS	= ../../include/linux/sunrpc/xdrgen/nfs2.h \
 			  ../../include/linux/sunrpc/xdrgen/nfs_acl2.h \
 			  ../../include/linux/sunrpc/xdrgen/nfs3.h \
+			  ../../include/linux/sunrpc/xdrgen/nfs_acl3.h \
 			  ../../include/linux/sunrpc/xdrgen/nfs4_1.h
 XDRGEN_DECLARATIONS	= nfs2xdr_gen.h nfs_acl2xdr_gen.h \
-			  nfs3xdr_gen.h nfs4xdr_gen.h
+			  nfs3xdr_gen.h nfs_acl3xdr_gen.h nfs4xdr_gen.h
 XDRGEN_SOURCE		= nfs2xdr_gen.c nfs_acl2xdr_gen.c \
-			  nfs3xdr_gen.c nfs4xdr_gen.c
+			  nfs3xdr_gen.c nfs_acl3xdr_gen.c nfs4xdr_gen.c
 
 xdrgen: $(XDRGEN_DEFINITIONS) $(XDRGEN_DECLARATIONS) $(XDRGEN_SOURCE)
 
@@ -54,6 +55,8 @@ xdrgen: $(XDRGEN_DEFINITIONS) $(XDRGEN_DECLARATIONS) $(XDRGEN_SOURCE)
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 ../../include/linux/sunrpc/xdrgen/nfs3.h: ../../Documentation/sunrpc/xdr/nfs3.x
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
+../../include/linux/sunrpc/xdrgen/nfs_acl3.h: ../../Documentation/sunrpc/xdr/nfs_acl3.x
+	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 ../../include/linux/sunrpc/xdrgen/nfs4_1.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 
@@ -63,6 +66,8 @@ nfs_acl2xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs_acl2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 nfs3xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs3.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
+nfs_acl3xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs_acl3.x
+	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 nfs4xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 
@@ -72,5 +77,7 @@ nfs_acl2xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs_acl2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
 nfs3xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs3.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
+nfs_acl3xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs_acl3.x
+	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
 nfs4xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs4_1.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
diff --git a/fs/nfsd/nfs_acl3xdr_gen.c b/fs/nfsd/nfs_acl3xdr_gen.c
new file mode 100644
index 000000000000..5bdeb29addfe
--- /dev/null
+++ b/fs/nfsd/nfs_acl3xdr_gen.c
@@ -0,0 +1,749 @@
+// SPDX-License-Identifier: GPL-2.0
+// Generated by xdrgen. Manual edits will be lost.
+// XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl3.x
+// XDR specification modification time: Fri Jul 10 20:10:15 2026
+
+#include <linux/sunrpc/svc.h>
+
+#include "nfs_acl3xdr_gen.h"
+
+static bool __maybe_unused
+xdrgen_decode_uid(struct xdr_stream *xdr, uid *ptr)
+{
+	return xdrgen_decode_unsigned_int(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_o_mode(struct xdr_stream *xdr, o_mode *ptr)
+{
+	return xdrgen_decode_unsigned_short(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_aclent(struct xdr_stream *xdr, struct aclent *ptr)
+{
+	if (!xdrgen_decode_int(xdr, &ptr->type))
+		return false;
+	if (!xdrgen_decode_uid(xdr, &ptr->id))
+		return false;
+	if (!xdrgen_decode_o_mode(xdr, &ptr->perm))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_secattr(struct xdr_stream *xdr, struct secattr *ptr)
+{
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->mask))
+		return false;
+	if (!xdrgen_decode_int(xdr, &ptr->aclcnt))
+		return false;
+	if (xdr_stream_decode_u32(xdr, &ptr->aclent.count) < 0)
+		return false;
+	if (ptr->aclent.count > NFS_ACL_MAX_ENTRIES)
+		return false;
+	for (u32 i = 0; i < ptr->aclent.count; i++)
+		if (!xdrgen_decode_aclent(xdr, &ptr->aclent.element[i]))
+			return false;
+	if (!xdrgen_decode_int(xdr, &ptr->dfaclcnt))
+		return false;
+	if (xdr_stream_decode_u32(xdr, &ptr->dfaclent.count) < 0)
+		return false;
+	if (ptr->dfaclent.count > NFS_ACL_MAX_ENTRIES)
+		return false;
+	for (u32 i = 0; i < ptr->dfaclent.count; i++)
+		if (!xdrgen_decode_aclent(xdr, &ptr->dfaclent.element[i]))
+			return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_uint64(struct xdr_stream *xdr, uint64 *ptr)
+{
+	return xdrgen_decode_unsigned_hyper(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_uint32(struct xdr_stream *xdr, uint32 *ptr)
+{
+	return xdrgen_decode_unsigned_long(xdr, ptr);
+}
+
+static bool __maybe_unused
+xdrgen_decode_fileid3(struct xdr_stream *xdr, fileid3 *ptr)
+{
+	return xdrgen_decode_uint64(xdr, ptr);
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
+xdrgen_decode_mode3(struct xdr_stream *xdr, mode3 *ptr)
+{
+	return xdrgen_decode_uint32(xdr, ptr);
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
+xdrgen_decode_aclstat3(struct xdr_stream *xdr, aclstat3 *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case ACL3_OK:
+	case ACL3ERR_PERM:
+	case ACL3ERR_NOENT:
+	case ACL3ERR_IO:
+	case ACL3ERR_ACCES:
+	case ACL3ERR_INVAL:
+	case ACL3ERR_NOSPC:
+	case ACL3ERR_ROFS:
+	case ACL3ERR_DQUOT:
+	case ACL3ERR_STALE:
+	case ACL3ERR_BADHANDLE:
+	case ACL3ERR_NOTSUPP:
+	case ACL3ERR_SERVERFAULT:
+	case ACL3ERR_JUKEBOX:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETACL3args(struct xdr_stream *xdr, struct GETACL3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->mask))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETACL3resok(struct xdr_stream *xdr, struct GETACL3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->attr))
+		return false;
+	if (!xdrgen_decode_secattr(xdr, &ptr->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETACL3resfail(struct xdr_stream *xdr, struct GETACL3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETACL3res(struct xdr_stream *xdr, struct GETACL3res *ptr)
+{
+	if (!xdrgen_decode_aclstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL3_OK:
+		if (!xdrgen_decode_GETACL3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_GETACL3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETACL3args(struct xdr_stream *xdr, struct SETACL3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_secattr(xdr, &ptr->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETACL3resok(struct xdr_stream *xdr, struct SETACL3resok *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETACL3resfail(struct xdr_stream *xdr, struct SETACL3resfail *ptr)
+{
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETACL3res(struct xdr_stream *xdr, struct SETACL3res *ptr)
+{
+	if (!xdrgen_decode_aclstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL3_OK:
+		if (!xdrgen_decode_SETACL3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_decode_SETACL3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETXATTRDIR3args(struct xdr_stream *xdr, struct GETXATTRDIR3args *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->create))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETXATTRDIR3resok(struct xdr_stream *xdr, struct GETXATTRDIR3resok *ptr)
+{
+	if (!xdrgen_decode_nfs_fh3(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_post_op_attr(xdr, &ptr->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETXATTRDIR3res(struct xdr_stream *xdr, struct GETXATTRDIR3res *ptr)
+{
+	if (!xdrgen_decode_aclstat3(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL3_OK:
+		if (!xdrgen_decode_GETXATTRDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+/**
+ * nfs_acl_svc_decode_GETACL3args - Decode a GETACL3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_GETACL3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETACL3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_GETACL3args(xdr, argp);
+}
+
+/**
+ * nfs_acl_svc_decode_SETACL3args - Decode a SETACL3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_SETACL3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SETACL3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_SETACL3args(xdr, argp);
+}
+
+/**
+ * nfs_acl_svc_decode_GETXATTRDIR3args - Decode a GETXATTRDIR3args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_GETXATTRDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETXATTRDIR3args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_GETXATTRDIR3args(xdr, argp);
+}
+
+static bool __maybe_unused
+xdrgen_encode_uid(struct xdr_stream *xdr, const uid value)
+{
+	return xdrgen_encode_unsigned_int(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_o_mode(struct xdr_stream *xdr, const o_mode value)
+{
+	return xdrgen_encode_unsigned_short(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_aclent(struct xdr_stream *xdr, const struct aclent *value)
+{
+	if (!xdrgen_encode_int(xdr, value->type))
+		return false;
+	if (!xdrgen_encode_uid(xdr, value->id))
+		return false;
+	if (!xdrgen_encode_o_mode(xdr, value->perm))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_secattr(struct xdr_stream *xdr, const struct secattr *value)
+{
+	if (!xdrgen_encode_unsigned_int(xdr, value->mask))
+		return false;
+	if (!xdrgen_encode_int(xdr, value->aclcnt))
+		return false;
+	if (value->aclent.count > NFS_ACL_MAX_ENTRIES)
+		return false;
+	if (xdr_stream_encode_u32(xdr, value->aclent.count) != XDR_UNIT)
+		return false;
+	for (u32 i = 0; i < value->aclent.count; i++)
+		if (!xdrgen_encode_aclent(xdr, &value->aclent.element[i]))
+			return false;
+	if (!xdrgen_encode_int(xdr, value->dfaclcnt))
+		return false;
+	if (value->dfaclent.count > NFS_ACL_MAX_ENTRIES)
+		return false;
+	if (xdr_stream_encode_u32(xdr, value->dfaclent.count) != XDR_UNIT)
+		return false;
+	for (u32 i = 0; i < value->dfaclent.count; i++)
+		if (!xdrgen_encode_aclent(xdr, &value->dfaclent.element[i]))
+			return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_uint64(struct xdr_stream *xdr, const uint64 value)
+{
+	return xdrgen_encode_unsigned_hyper(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_uint32(struct xdr_stream *xdr, const uint32 value)
+{
+	return xdrgen_encode_unsigned_long(xdr, value);
+}
+
+static bool __maybe_unused
+xdrgen_encode_fileid3(struct xdr_stream *xdr, const fileid3 value)
+{
+	return xdrgen_encode_uint64(xdr, value);
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
+xdrgen_encode_mode3(struct xdr_stream *xdr, const mode3 value)
+{
+	return xdrgen_encode_uint32(xdr, value);
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
+xdrgen_encode_aclstat3(struct xdr_stream *xdr, aclstat3 value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETACL3args(struct xdr_stream *xdr, const struct GETACL3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->fh))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->mask))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETACL3resok(struct xdr_stream *xdr, const struct GETACL3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->attr))
+		return false;
+	if (!xdrgen_encode_secattr(xdr, &value->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETACL3resfail(struct xdr_stream *xdr, const struct GETACL3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETACL3res(struct xdr_stream *xdr, const struct GETACL3res *ptr)
+{
+	if (!xdrgen_encode_aclstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL3_OK:
+		if (!xdrgen_encode_GETACL3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_GETACL3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETACL3args(struct xdr_stream *xdr, const struct SETACL3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->fh))
+		return false;
+	if (!xdrgen_encode_secattr(xdr, &value->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETACL3resok(struct xdr_stream *xdr, const struct SETACL3resok *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETACL3resfail(struct xdr_stream *xdr, const struct SETACL3resfail *value)
+{
+	if (!xdrgen_encode_post_op_attr(xdr, &value->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETACL3res(struct xdr_stream *xdr, const struct SETACL3res *ptr)
+{
+	if (!xdrgen_encode_aclstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL3_OK:
+		if (!xdrgen_encode_SETACL3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		if (!xdrgen_encode_SETACL3resfail(xdr, &ptr->u.resfail))
+			return false;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETXATTRDIR3args(struct xdr_stream *xdr, const struct GETXATTRDIR3args *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->fh))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->create))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETXATTRDIR3resok(struct xdr_stream *xdr, const struct GETXATTRDIR3resok *value)
+{
+	if (!xdrgen_encode_nfs_fh3(xdr, &value->fh))
+		return false;
+	if (!xdrgen_encode_post_op_attr(xdr, &value->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETXATTRDIR3res(struct xdr_stream *xdr, const struct GETXATTRDIR3res *ptr)
+{
+	if (!xdrgen_encode_aclstat3(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL3_OK:
+		if (!xdrgen_encode_GETXATTRDIR3resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+/**
+ * nfs_acl_svc_encode_GETACL3res - Encode a GETACL3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_GETACL3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETACL3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_GETACL3res(xdr, resp);
+}
+
+/**
+ * nfs_acl_svc_encode_SETACL3res - Encode a SETACL3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_SETACL3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SETACL3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_SETACL3res(xdr, resp);
+}
+
+/**
+ * nfs_acl_svc_encode_GETXATTRDIR3res - Encode a GETXATTRDIR3res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_GETXATTRDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETXATTRDIR3res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_GETXATTRDIR3res(xdr, resp);
+}
diff --git a/fs/nfsd/nfs_acl3xdr_gen.h b/fs/nfsd/nfs_acl3xdr_gen.h
new file mode 100644
index 000000000000..d778004ba26a
--- /dev/null
+++ b/fs/nfsd/nfs_acl3xdr_gen.h
@@ -0,0 +1,24 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl3.x */
+/* XDR specification modification time: Fri Jul 10 20:10:15 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS_ACL3_DECL_H
+#define _LINUX_XDRGEN_NFS_ACL3_DECL_H
+
+#include <linux/types.h>
+
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/xdrgen/_defs.h>
+#include <linux/sunrpc/xdrgen/_builtins.h>
+#include <linux/sunrpc/xdrgen/nfs_acl3.h>
+
+bool nfs_acl_svc_decode_GETACL3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_decode_SETACL3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_decode_GETXATTRDIR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+bool nfs_acl_svc_encode_GETACL3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_encode_SETACL3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_encode_GETXATTRDIR3res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+#endif /* _LINUX_XDRGEN_NFS_ACL3_DECL_H */
diff --git a/include/linux/sunrpc/xdrgen/nfs_acl3.h b/include/linux/sunrpc/xdrgen/nfs_acl3.h
new file mode 100644
index 000000000000..8758450dbca0
--- /dev/null
+++ b/include/linux/sunrpc/xdrgen/nfs_acl3.h
@@ -0,0 +1,284 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl3.x */
+/* XDR specification modification time: Fri Jul 10 20:10:15 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS_ACL3_DEF_H
+#define _LINUX_XDRGEN_NFS_ACL3_DEF_H
+
+#include <linux/types.h>
+#include <linux/sunrpc/xdrgen/_defs.h>
+
+enum { NFS_ACL_MAX_ENTRIES = 1024 };
+
+typedef u32 uid;
+
+typedef u16 o_mode;
+
+struct aclent {
+	s32 type;
+	uid id;
+	o_mode perm;
+};
+
+enum { NA_USER_OBJ = 0x1 };
+
+enum { NA_USER = 0x2 };
+
+enum { NA_GROUP_OBJ = 0x4 };
+
+enum { NA_GROUP = 0x8 };
+
+enum { NA_CLASS_OBJ = 0x10 };
+
+enum { NA_OTHER_OBJ = 0x20 };
+
+enum { NA_ACL_DEFAULT = 0x1000 };
+
+enum { NA_READ = 0x4 };
+
+enum { NA_WRITE = 0x2 };
+
+enum { NA_EXEC = 0x1 };
+
+struct secattr {
+	u32 mask;
+	s32 aclcnt;
+	struct {
+		u32 count;
+		struct aclent *element;
+	} aclent;
+	s32 dfaclcnt;
+	struct {
+		u32 count;
+		struct aclent *element;
+	} dfaclent;
+};
+
+enum { NA_ACL = 0x1 };
+
+enum { NA_ACLCNT = 0x2 };
+
+enum { NA_DFACL = 0x4 };
+
+enum { NA_DFACLCNT = 0x8 };
+
+enum { NFS_ACL_PORT = 2049 };
+
+enum { NFS_ACL_RDMA_PORT = 20049 };
+
+typedef u64 uint64;
+
+typedef u32 uint32;
+
+typedef uint64 fileid3;
+
+typedef uint32 uid3;
+
+typedef uint32 gid3;
+
+typedef uint64 size3;
+
+typedef uint32 mode3;
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
+enum { NFS3_FHSIZE = 64 };
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
+enum aclstat3 {
+	ACL3_OK = 0,
+	ACL3ERR_PERM = 1,
+	ACL3ERR_NOENT = 2,
+	ACL3ERR_IO = 5,
+	ACL3ERR_ACCES = 13,
+	ACL3ERR_INVAL = 22,
+	ACL3ERR_NOSPC = 28,
+	ACL3ERR_ROFS = 30,
+	ACL3ERR_DQUOT = 69,
+	ACL3ERR_STALE = 70,
+	ACL3ERR_BADHANDLE = 10001,
+	ACL3ERR_NOTSUPP = 10004,
+	ACL3ERR_SERVERFAULT = 10006,
+	ACL3ERR_JUKEBOX = 10008,
+};
+
+typedef enum aclstat3 aclstat3;
+
+struct GETACL3args {
+	struct nfs_fh3 fh;
+	u32 mask;
+};
+
+struct GETACL3resok {
+	struct post_op_attr attr;
+	struct secattr acl;
+};
+
+struct GETACL3resfail {
+	struct post_op_attr attr;
+};
+
+struct GETACL3res {
+	aclstat3 status;
+	union {
+		struct GETACL3resok resok;
+		struct GETACL3resfail resfail;
+	} u;
+};
+
+struct SETACL3args {
+	struct nfs_fh3 fh;
+	struct secattr acl;
+};
+
+struct SETACL3resok {
+	struct post_op_attr attr;
+};
+
+struct SETACL3resfail {
+	struct post_op_attr attr;
+};
+
+struct SETACL3res {
+	aclstat3 status;
+	union {
+		struct SETACL3resok resok;
+		struct SETACL3resfail resfail;
+	} u;
+};
+
+struct GETXATTRDIR3args {
+	struct nfs_fh3 fh;
+	bool create;
+};
+
+struct GETXATTRDIR3resok {
+	struct nfs_fh3 fh;
+	struct post_op_attr attr;
+};
+
+struct GETXATTRDIR3res {
+	aclstat3 status;
+	union {
+		struct GETXATTRDIR3resok resok;
+	} u;
+};
+
+enum {
+	ACLPROC3_NULL = 0,
+	ACLPROC3_GETACL = 1,
+	ACLPROC3_SETACL = 2,
+	ACLPROC3_GETXATTRDIR = 3,
+};
+
+#ifndef NFS_ACL_PROGRAM
+#define NFS_ACL_PROGRAM (100227)
+#endif
+
+#define NFS_ACL3_uid_sz                 \
+	(XDR_unsigned_int)
+#define NFS_ACL3_o_mode_sz              \
+	(XDR_unsigned_short)
+#define NFS_ACL3_aclent_sz              \
+	(XDR_int + NFS_ACL3_uid_sz + NFS_ACL3_o_mode_sz)
+#define NFS_ACL3_secattr_sz             \
+	(XDR_unsigned_int + XDR_int + XDR_unsigned_int + (NFS_ACL_MAX_ENTRIES * (NFS_ACL3_aclent_sz)) + XDR_int + XDR_unsigned_int + (NFS_ACL_MAX_ENTRIES * (NFS_ACL3_aclent_sz)))
+#define NFS_ACL3_uint64_sz              \
+	(XDR_unsigned_hyper)
+#define NFS_ACL3_uint32_sz              \
+	(XDR_unsigned_long)
+#define NFS_ACL3_fileid3_sz             \
+	(NFS_ACL3_uint64_sz)
+#define NFS_ACL3_uid3_sz                \
+	(NFS_ACL3_uint32_sz)
+#define NFS_ACL3_gid3_sz                \
+	(NFS_ACL3_uint32_sz)
+#define NFS_ACL3_size3_sz               \
+	(NFS_ACL3_uint64_sz)
+#define NFS_ACL3_mode3_sz               \
+	(NFS_ACL3_uint32_sz)
+#define NFS_ACL3_ftype3_sz              (XDR_int)
+#define NFS_ACL3_specdata3_sz           \
+	(NFS_ACL3_uint32_sz + NFS_ACL3_uint32_sz)
+#define NFS_ACL3_nfs_fh3_sz             \
+	(XDR_unsigned_int + XDR_QUADLEN(NFS3_FHSIZE))
+#define NFS_ACL3_nfstime3_sz            \
+	(NFS_ACL3_uint32_sz + NFS_ACL3_uint32_sz)
+#define NFS_ACL3_fattr3_sz              \
+	(NFS_ACL3_ftype3_sz + NFS_ACL3_mode3_sz + NFS_ACL3_uint32_sz + NFS_ACL3_uid3_sz + NFS_ACL3_gid3_sz + NFS_ACL3_size3_sz + NFS_ACL3_size3_sz + NFS_ACL3_specdata3_sz + NFS_ACL3_uint64_sz + NFS_ACL3_fileid3_sz + NFS_ACL3_nfstime3_sz + NFS_ACL3_nfstime3_sz + NFS_ACL3_nfstime3_sz)
+#define NFS_ACL3_post_op_attr_sz        \
+	(XDR_bool + NFS_ACL3_fattr3_sz)
+#define NFS_ACL3_aclstat3_sz            (XDR_int)
+#define NFS_ACL3_GETACL3args_sz         \
+	(NFS_ACL3_nfs_fh3_sz + XDR_unsigned_int)
+#define NFS_ACL3_GETACL3resok_sz        \
+	(NFS_ACL3_post_op_attr_sz + NFS_ACL3_secattr_sz)
+#define NFS_ACL3_GETACL3resfail_sz      \
+	(NFS_ACL3_post_op_attr_sz)
+#define NFS_ACL3_GETACL3res_sz          \
+	(NFS_ACL3_aclstat3_sz + NFS_ACL3_GETACL3resok_sz)
+#define NFS_ACL3_SETACL3args_sz         \
+	(NFS_ACL3_nfs_fh3_sz + NFS_ACL3_secattr_sz)
+#define NFS_ACL3_SETACL3resok_sz        \
+	(NFS_ACL3_post_op_attr_sz)
+#define NFS_ACL3_SETACL3resfail_sz      \
+	(NFS_ACL3_post_op_attr_sz)
+#define NFS_ACL3_SETACL3res_sz          \
+	(NFS_ACL3_aclstat3_sz + NFS_ACL3_SETACL3resok_sz)
+#define NFS_ACL3_GETXATTRDIR3args_sz    \
+	(NFS_ACL3_nfs_fh3_sz + XDR_bool)
+#define NFS_ACL3_GETXATTRDIR3resok_sz   \
+	(NFS_ACL3_nfs_fh3_sz + NFS_ACL3_post_op_attr_sz)
+#define NFS_ACL3_GETXATTRDIR3res_sz     \
+	(NFS_ACL3_aclstat3_sz + NFS_ACL3_GETXATTRDIR3resok_sz)
+#define NFS_ACL3_MAX_ARGS_SZ            \
+	(NFS_ACL3_SETACL3args_sz)
+
+#endif /* _LINUX_XDRGEN_NFS_ACL3_DEF_H */
-- 
2.56.0

