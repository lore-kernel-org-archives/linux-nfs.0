Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677232;
	b=NC6KRnT6du2Tx61ZFP1UbLseTOqOnQ8IXCq69oNXjzblridjOSxQVakkX44R42D/GQXY
	 MnTl82iqoL6c5zVYR3PajzX9Ud/YRvvXYga31vQ5Yi+UjkEQAn+8y7/ASDNmTOgjZ4GRR
	 Taz15OiChere7gnKWDw7xIOoS3AsFdzK+MVnQdBpNFlqGiP0eQqox9ttCUu0PqXgVg75y
	 6B63p9NmsOsUKDsEt5SlMiFA2Ma68e2sgFicZX5pTPKCukl6ldsVmMIY3iMt9wcDXxLfQ
	 Cb0jyIsqWUOZ0nEmiVThtt1+caN91kT8uj5stx75mTyTYKRNUaF+N5bl7bnYRO/FOcg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677232;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=eVNLOvPxRZUh1DrN52v1OQuQd49J52h8u442WOMJ6Fs=;
	b=LRnvecD9e90Y7uxHqaOm8Vd8NtfYBjx9atKy58+7a6CCjfr3d8Ud49t2JQpDaazgAdIu
	 MN9LiFRcNcMqGdZ/mt/Sq8uNaMn+drLEka53FfM5BBVGeJ1t3RwA/BxAkUY3ShB2tvGGi
	 mnkUGKIH7qDYAx0L+6SZKqJF9hweIlqiq/C1fRy+V5Ydidq+IJfJAZFPTJk7KZcOitqST
	 8IBWrJufnt7D9zE0/Xv8VkQmxmClTXDyxTscaQl6PNJUmCZ57K/AhT/M41RepDnMfVyef
	 m7CprupfBtusyXTpmfNT0ImkeQwrjsHVw2b7cKMnkaAtTC/d23MzFcjoQf5akphdfnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Fl+O8WJg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 784ED606A32A
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Fl+O8WJg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 751AD1F000D2;
	Thu, 22 Oct 2026 13:53:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677231;
	bh=eVNLOvPxRZUh1DrN52v1OQuQd49J52h8u442WOMJ6Fs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Fl+O8WJgfuPCK0qtjDC4L2ScLUpljkKC/15DueW3n6TzvgSQTAIKAElGwQVVg29vK
	 6tkr3xIuncjYw+Y+xEkzWflNHGf24gBbZJHOIBCwl7ljBod4PErwCMgz1kqT4rquiy
	 y2p4Z5nDsm4nm2qAW4rs7Ny9DMtun22r9ksp1hVEk9Cd2/W2yvkktzg2IaJ58QxuVV
	 hBm7DM1lumK5Jf1Y40CvTpQWX67TlrYMOK2ADPhrkxzbfNxec0euu4dIZgb/kAQKhV
	 po+KNUy6pIv9sQTzjTC7//QNdfYv5Whccf96Jy3oNm9FAXaPa7TQV3XaQFbFlthJaY
	 xSfzj7fB19DvQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 07/17] NFSD: Add infrastructure for generating NFS_ACLv2 XDR encoders and decoders
Date: Thu, 22 Oct 2026 09:53:31 -0400
Message-ID: <20261022135341.14265-8-cel@kernel.org>
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

NFSD's NFS_ACLv2 XDR codecs are hand-maintained; they are being
converted to xdrgen-generated code one RPC procedure at a time.
The first step is to generate and commit the xdrgen C code based on
nfs_acl2.x. The generated code can be refreshed any time nfs_acl2.x
is modified by running "(cd fs/nfsd && make xdrgen)"

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs_acl2.x    |   2 +
 fs/nfsd/Makefile                       |  15 +-
 fs/nfsd/nfs_acl2xdr_gen.c              | 779 +++++++++++++++++++++++++
 fs/nfsd/nfs_acl2xdr_gen.h              |  28 +
 include/linux/sunrpc/xdrgen/nfs_acl2.h | 278 +++++++++
 5 files changed, 1099 insertions(+), 3 deletions(-)
 create mode 100644 fs/nfsd/nfs_acl2xdr_gen.c
 create mode 100644 fs/nfsd/nfs_acl2xdr_gen.h
 create mode 100644 include/linux/sunrpc/xdrgen/nfs_acl2.h

diff --git a/Documentation/sunrpc/xdr/nfs_acl2.x b/Documentation/sunrpc/xdr/nfs_acl2.x
index 7ed89679e395..165f50a898c0 100644
--- a/Documentation/sunrpc/xdr/nfs_acl2.x
+++ b/Documentation/sunrpc/xdr/nfs_acl2.x
@@ -40,6 +40,8 @@
  *   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+pragma header nfs_acl2;
+
 const NFS_ACL_MAX_ENTRIES = 1024;
 
 typedef unsigned int uid;
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 1dc449af28f4..7db3b248e15a 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -15,7 +15,7 @@ nfsd-y 			+= nfssvc.o nfsctl.o nfsfh.o vfs.o \
 			   stats.o filecache.o netlink.o \
 			   nfs3proc.o nfs3xdr.o nfs3xdr_gen.o
 nfsd-$(CONFIG_NFSD_V2) += nfsproc.o nfsxdr.o nfs2xdr_gen.o
-nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
+nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o nfs_acl2xdr_gen.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o nfs4xdr_gen.o
@@ -38,15 +38,20 @@ nfsd-$(CONFIG_DEBUG_FS) += debugfs.o
 .PHONY: xdrgen
 
 XDRGEN_DEFINITIONS	= ../../include/linux/sunrpc/xdrgen/nfs2.h \
+			  ../../include/linux/sunrpc/xdrgen/nfs_acl2.h \
 			  ../../include/linux/sunrpc/xdrgen/nfs3.h \
 			  ../../include/linux/sunrpc/xdrgen/nfs4_1.h
-XDRGEN_DECLARATIONS	= nfs2xdr_gen.h nfs3xdr_gen.h nfs4xdr_gen.h
-XDRGEN_SOURCE		= nfs2xdr_gen.c nfs3xdr_gen.c nfs4xdr_gen.c
+XDRGEN_DECLARATIONS	= nfs2xdr_gen.h nfs_acl2xdr_gen.h \
+			  nfs3xdr_gen.h nfs4xdr_gen.h
+XDRGEN_SOURCE		= nfs2xdr_gen.c nfs_acl2xdr_gen.c \
+			  nfs3xdr_gen.c nfs4xdr_gen.c
 
 xdrgen: $(XDRGEN_DEFINITIONS) $(XDRGEN_DECLARATIONS) $(XDRGEN_SOURCE)
 
 ../../include/linux/sunrpc/xdrgen/nfs2.h: ../../Documentation/sunrpc/xdr/nfs2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
+../../include/linux/sunrpc/xdrgen/nfs_acl2.h: ../../Documentation/sunrpc/xdr/nfs_acl2.x
+	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 ../../include/linux/sunrpc/xdrgen/nfs3.h: ../../Documentation/sunrpc/xdr/nfs3.x
 	../../tools/net/sunrpc/xdrgen/xdrgen definitions $< > $@
 ../../include/linux/sunrpc/xdrgen/nfs4_1.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
@@ -54,6 +59,8 @@ xdrgen: $(XDRGEN_DEFINITIONS) $(XDRGEN_DECLARATIONS) $(XDRGEN_SOURCE)
 
 nfs2xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
+nfs_acl2xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs_acl2.x
+	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 nfs3xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs3.x
 	../../tools/net/sunrpc/xdrgen/xdrgen declarations $< > $@
 nfs4xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
@@ -61,6 +68,8 @@ nfs4xdr_gen.h: ../../Documentation/sunrpc/xdr/nfs4_1.x
 
 nfs2xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs2.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
+nfs_acl2xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs_acl2.x
+	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
 nfs3xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs3.x
 	../../tools/net/sunrpc/xdrgen/xdrgen source $< > $@
 nfs4xdr_gen.c: ../../Documentation/sunrpc/xdr/nfs4_1.x
diff --git a/fs/nfsd/nfs_acl2xdr_gen.c b/fs/nfsd/nfs_acl2xdr_gen.c
new file mode 100644
index 000000000000..2c1b6a4e2ebc
--- /dev/null
+++ b/fs/nfsd/nfs_acl2xdr_gen.c
@@ -0,0 +1,779 @@
+// SPDX-License-Identifier: GPL-2.0
+// Generated by xdrgen. Manual edits will be lost.
+// XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl2.x
+// XDR specification modification time: Wed Jul 15 19:22:39 2026
+
+#include <linux/sunrpc/svc.h>
+
+#include "nfs_acl2xdr_gen.h"
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
+	return xdr_stream_decode_opaque_fixed(xdr, ptr, FHSIZE) == 0;
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
+xdrgen_decode_aclstat2(struct xdr_stream *xdr, aclstat2 *ptr)
+{
+	u32 val;
+
+	if (xdr_stream_decode_u32(xdr, &val) < 0)
+		return false;
+	/* Compiler may optimize to a range check for dense enums */
+	switch (val) {
+	case ACL2_OK:
+	case ACL2ERR_PERM:
+	case ACL2ERR_NOENT:
+	case ACL2ERR_IO:
+	case ACL2ERR_ACCES:
+	case ACL2ERR_INVAL:
+	case ACL2ERR_NOSPC:
+	case ACL2ERR_ROFS:
+	case ACL2ERR_NOTSUPP:
+	case ACL2ERR_DQUOT:
+	case ACL2ERR_STALE:
+		break;
+	default:
+		return false;
+	}
+	*ptr = val;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETACL2args(struct xdr_stream *xdr, struct GETACL2args *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->mask))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETACL2resok(struct xdr_stream *xdr, struct GETACL2resok *ptr)
+{
+	if (!xdrgen_decode_fattr(xdr, &ptr->attr))
+		return false;
+	if (!xdrgen_decode_secattr(xdr, &ptr->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETACL2res(struct xdr_stream *xdr, struct GETACL2res *ptr)
+{
+	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_decode_GETACL2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETACL2args(struct xdr_stream *xdr, struct SETACL2args *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_secattr(xdr, &ptr->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETACL2resok(struct xdr_stream *xdr, struct SETACL2resok *ptr)
+{
+	if (!xdrgen_decode_fattr(xdr, &ptr->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_SETACL2res(struct xdr_stream *xdr, struct SETACL2res *ptr)
+{
+	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_decode_SETACL2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETATTR2args(struct xdr_stream *xdr, struct GETATTR2args *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->fh))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETATTR2resok(struct xdr_stream *xdr, struct GETATTR2resok *ptr)
+{
+	if (!xdrgen_decode_fattr(xdr, &ptr->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETATTR2res(struct xdr_stream *xdr, struct GETATTR2res *ptr)
+{
+	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_decode_GETATTR2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ACCESS2args(struct xdr_stream *xdr, struct ACCESS2args *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ACCESS2resok(struct xdr_stream *xdr, struct ACCESS2resok *ptr)
+{
+	if (!xdrgen_decode_fattr(xdr, &ptr->attr))
+		return false;
+	if (!xdrgen_decode_unsigned_int(xdr, &ptr->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_ACCESS2res(struct xdr_stream *xdr, struct ACCESS2res *ptr)
+{
+	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_decode_ACCESS2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETXATTRDIR2args(struct xdr_stream *xdr, struct GETXATTRDIR2args *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_bool(xdr, &ptr->create))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETXATTRDIR2resok(struct xdr_stream *xdr, struct GETXATTRDIR2resok *ptr)
+{
+	if (!xdrgen_decode_fhandle(xdr, &ptr->fh))
+		return false;
+	if (!xdrgen_decode_fattr(xdr, &ptr->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_decode_GETXATTRDIR2res(struct xdr_stream *xdr, struct GETXATTRDIR2res *ptr)
+{
+	if (!xdrgen_decode_aclstat2(xdr, &ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_decode_GETXATTRDIR2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+/**
+ * nfs_acl_svc_decode_GETACL2args - Decode a GETACL2args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_GETACL2args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETACL2args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_GETACL2args(xdr, argp);
+}
+
+/**
+ * nfs_acl_svc_decode_SETACL2args - Decode a SETACL2args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_SETACL2args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SETACL2args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_SETACL2args(xdr, argp);
+}
+
+/**
+ * nfs_acl_svc_decode_GETATTR2args - Decode a GETATTR2args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_GETATTR2args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETATTR2args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_GETATTR2args(xdr, argp);
+}
+
+/**
+ * nfs_acl_svc_decode_ACCESS2args - Decode a ACCESS2args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_ACCESS2args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct ACCESS2args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_ACCESS2args(xdr, argp);
+}
+
+/**
+ * nfs_acl_svc_decode_GETXATTRDIR2args - Decode a GETXATTRDIR2args argument
+ * @rqstp: RPC transaction context
+ * @xdr: source XDR data stream
+ *
+ * Return values:
+ *   %true: procedure arguments decoded successfully
+ *   %false: decode failed
+ */
+bool nfs_acl_svc_decode_GETXATTRDIR2args(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETXATTRDIR2args *argp = rqstp->rq_argp;
+
+	return xdrgen_decode_GETXATTRDIR2args(xdr, argp);
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
+xdrgen_encode_ftype(struct xdr_stream *xdr, ftype value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_fhandle(struct xdr_stream *xdr, const fhandle value)
+{
+	return xdr_stream_encode_opaque_fixed(xdr, value, FHSIZE) >= 0;
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
+xdrgen_encode_aclstat2(struct xdr_stream *xdr, aclstat2 value)
+{
+	return xdr_stream_encode_u32(xdr, value) == XDR_UNIT;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETACL2args(struct xdr_stream *xdr, const struct GETACL2args *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->fh))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->mask))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETACL2resok(struct xdr_stream *xdr, const struct GETACL2resok *value)
+{
+	if (!xdrgen_encode_fattr(xdr, &value->attr))
+		return false;
+	if (!xdrgen_encode_secattr(xdr, &value->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETACL2res(struct xdr_stream *xdr, const struct GETACL2res *ptr)
+{
+	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_encode_GETACL2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETACL2args(struct xdr_stream *xdr, const struct SETACL2args *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->fh))
+		return false;
+	if (!xdrgen_encode_secattr(xdr, &value->acl))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETACL2resok(struct xdr_stream *xdr, const struct SETACL2resok *value)
+{
+	if (!xdrgen_encode_fattr(xdr, &value->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_SETACL2res(struct xdr_stream *xdr, const struct SETACL2res *ptr)
+{
+	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_encode_SETACL2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETATTR2args(struct xdr_stream *xdr, const struct GETATTR2args *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->fh))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETATTR2resok(struct xdr_stream *xdr, const struct GETATTR2resok *value)
+{
+	if (!xdrgen_encode_fattr(xdr, &value->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETATTR2res(struct xdr_stream *xdr, const struct GETATTR2res *ptr)
+{
+	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_encode_GETATTR2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ACCESS2args(struct xdr_stream *xdr, const struct ACCESS2args *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->fh))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ACCESS2resok(struct xdr_stream *xdr, const struct ACCESS2resok *value)
+{
+	if (!xdrgen_encode_fattr(xdr, &value->attr))
+		return false;
+	if (!xdrgen_encode_unsigned_int(xdr, value->access))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_ACCESS2res(struct xdr_stream *xdr, const struct ACCESS2res *ptr)
+{
+	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_encode_ACCESS2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETXATTRDIR2args(struct xdr_stream *xdr, const struct GETXATTRDIR2args *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->fh))
+		return false;
+	if (!xdrgen_encode_bool(xdr, value->create))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETXATTRDIR2resok(struct xdr_stream *xdr, const struct GETXATTRDIR2resok *value)
+{
+	if (!xdrgen_encode_fhandle(xdr, value->fh))
+		return false;
+	if (!xdrgen_encode_fattr(xdr, &value->attr))
+		return false;
+	return true;
+}
+
+static bool __maybe_unused
+xdrgen_encode_GETXATTRDIR2res(struct xdr_stream *xdr, const struct GETXATTRDIR2res *ptr)
+{
+	if (!xdrgen_encode_aclstat2(xdr, ptr->status))
+		return false;
+	switch (ptr->status) {
+	case ACL2_OK:
+		if (!xdrgen_encode_GETXATTRDIR2resok(xdr, &ptr->u.resok))
+			return false;
+		break;
+	default:
+		break;
+	}
+	return true;
+}
+
+/**
+ * nfs_acl_svc_encode_GETACL2res - Encode a GETACL2res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_GETACL2res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETACL2res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_GETACL2res(xdr, resp);
+}
+
+/**
+ * nfs_acl_svc_encode_SETACL2res - Encode a SETACL2res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_SETACL2res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct SETACL2res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_SETACL2res(xdr, resp);
+}
+
+/**
+ * nfs_acl_svc_encode_GETATTR2res - Encode a GETATTR2res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_GETATTR2res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETATTR2res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_GETATTR2res(xdr, resp);
+}
+
+/**
+ * nfs_acl_svc_encode_ACCESS2res - Encode a ACCESS2res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_ACCESS2res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct ACCESS2res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_ACCESS2res(xdr, resp);
+}
+
+/**
+ * nfs_acl_svc_encode_GETXATTRDIR2res - Encode a GETXATTRDIR2res result
+ * @rqstp: RPC transaction context
+ * @xdr: target XDR data stream
+ *
+ * Return values:
+ *   %true: procedure results encoded successfully
+ *   %false: encode failed
+ */
+bool nfs_acl_svc_encode_GETXATTRDIR2res(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct GETXATTRDIR2res *resp = rqstp->rq_resp;
+
+	return xdrgen_encode_GETXATTRDIR2res(xdr, resp);
+}
diff --git a/fs/nfsd/nfs_acl2xdr_gen.h b/fs/nfsd/nfs_acl2xdr_gen.h
new file mode 100644
index 000000000000..0152aa0b6695
--- /dev/null
+++ b/fs/nfsd/nfs_acl2xdr_gen.h
@@ -0,0 +1,28 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl2.x */
+/* XDR specification modification time: Wed Jul 15 19:22:39 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS_ACL2_DECL_H
+#define _LINUX_XDRGEN_NFS_ACL2_DECL_H
+
+#include <linux/types.h>
+
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/xdrgen/_defs.h>
+#include <linux/sunrpc/xdrgen/_builtins.h>
+#include <linux/sunrpc/xdrgen/nfs_acl2.h>
+
+bool nfs_acl_svc_decode_GETACL2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_decode_SETACL2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_decode_GETATTR2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_decode_ACCESS2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_decode_GETXATTRDIR2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+bool nfs_acl_svc_encode_GETACL2res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_encode_SETACL2res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_encode_GETATTR2res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_encode_ACCESS2res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs_acl_svc_encode_GETXATTRDIR2res(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+#endif /* _LINUX_XDRGEN_NFS_ACL2_DECL_H */
diff --git a/include/linux/sunrpc/xdrgen/nfs_acl2.h b/include/linux/sunrpc/xdrgen/nfs_acl2.h
new file mode 100644
index 000000000000..2069015d0c14
--- /dev/null
+++ b/include/linux/sunrpc/xdrgen/nfs_acl2.h
@@ -0,0 +1,278 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Generated by xdrgen. Manual edits will be lost. */
+/* XDR specification file: ../../Documentation/sunrpc/xdr/nfs_acl2.x */
+/* XDR specification modification time: Wed Jul 15 19:22:39 2026 */
+
+#ifndef _LINUX_XDRGEN_NFS_ACL2_DEF_H
+#define _LINUX_XDRGEN_NFS_ACL2_DEF_H
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
+enum { FHSIZE = 32 };
+
+typedef u8 fhandle[FHSIZE];
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
+enum aclstat2 {
+	ACL2_OK = 0,
+	ACL2ERR_PERM = 1,
+	ACL2ERR_NOENT = 2,
+	ACL2ERR_IO = 5,
+	ACL2ERR_ACCES = 13,
+	ACL2ERR_INVAL = 22,
+	ACL2ERR_NOSPC = 28,
+	ACL2ERR_ROFS = 30,
+	ACL2ERR_NOTSUPP = 45,
+	ACL2ERR_DQUOT = 69,
+	ACL2ERR_STALE = 70,
+};
+
+typedef enum aclstat2 aclstat2;
+
+struct GETACL2args {
+	fhandle fh;
+	u32 mask;
+};
+
+struct GETACL2resok {
+	struct fattr attr;
+	struct secattr acl;
+};
+
+struct GETACL2res {
+	aclstat2 status;
+	union {
+		struct GETACL2resok resok;
+	} u;
+};
+
+struct SETACL2args {
+	fhandle fh;
+	struct secattr acl;
+};
+
+struct SETACL2resok {
+	struct fattr attr;
+};
+
+struct SETACL2res {
+	aclstat2 status;
+	union {
+		struct SETACL2resok resok;
+	} u;
+};
+
+struct GETATTR2args {
+	fhandle fh;
+};
+
+struct GETATTR2resok {
+	struct fattr attr;
+};
+
+struct GETATTR2res {
+	aclstat2 status;
+	union {
+		struct GETATTR2resok resok;
+	} u;
+};
+
+struct ACCESS2args {
+	fhandle fh;
+	u32 access;
+};
+
+enum { ACCESS2_READ = 0x1 };
+
+enum { ACCESS2_LOOKUP = 0x2 };
+
+enum { ACCESS2_MODIFY = 0x4 };
+
+enum { ACCESS2_EXTEND = 0x8 };
+
+enum { ACCESS2_DELETE = 0x10 };
+
+enum { ACCESS2_EXECUTE = 0x20 };
+
+struct ACCESS2resok {
+	struct fattr attr;
+	u32 access;
+};
+
+struct ACCESS2res {
+	aclstat2 status;
+	union {
+		struct ACCESS2resok resok;
+	} u;
+};
+
+struct GETXATTRDIR2args {
+	fhandle fh;
+	bool create;
+};
+
+struct GETXATTRDIR2resok {
+	fhandle fh;
+	struct fattr attr;
+};
+
+struct GETXATTRDIR2res {
+	aclstat2 status;
+	union {
+		struct GETXATTRDIR2resok resok;
+	} u;
+};
+
+enum {
+	ACLPROC2_NULL = 0,
+	ACLPROC2_GETACL = 1,
+	ACLPROC2_SETACL = 2,
+	ACLPROC2_GETATTR = 3,
+	ACLPROC2_ACCESS = 4,
+	ACLPROC2_GETXATTRDIR = 5,
+};
+
+#ifndef NFS_ACL_PROGRAM
+#define NFS_ACL_PROGRAM (100227)
+#endif
+
+#define NFS_ACL2_uid_sz                 \
+	(XDR_unsigned_int)
+#define NFS_ACL2_o_mode_sz              \
+	(XDR_unsigned_short)
+#define NFS_ACL2_aclent_sz              \
+	(XDR_int + XDR_unsigned_int + NFS_ACL2_o_mode_sz)
+#define NFS_ACL2_secattr_sz             \
+	(XDR_unsigned_int + XDR_int + XDR_unsigned_int + (NFS_ACL_MAX_ENTRIES * (NFS_ACL2_aclent_sz)) + XDR_int + XDR_unsigned_int + (NFS_ACL_MAX_ENTRIES * (NFS_ACL2_aclent_sz)))
+#define NFS_ACL2_ftype_sz               (XDR_int)
+#define NFS_ACL2_fhandle_sz             (XDR_QUADLEN(FHSIZE))
+#define NFS_ACL2_timeval_sz             \
+	(XDR_unsigned_int + XDR_unsigned_int)
+#define NFS_ACL2_fattr_sz               \
+	(NFS_ACL2_ftype_sz + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + XDR_unsigned_int + NFS_ACL2_timeval_sz + NFS_ACL2_timeval_sz + NFS_ACL2_timeval_sz)
+#define NFS_ACL2_aclstat2_sz            (XDR_int)
+#define NFS_ACL2_GETACL2args_sz         \
+	(NFS_ACL2_fhandle_sz + XDR_unsigned_int)
+#define NFS_ACL2_GETACL2resok_sz        \
+	(NFS_ACL2_fattr_sz + NFS_ACL2_secattr_sz)
+#define NFS_ACL2_GETACL2res_sz          \
+	(NFS_ACL2_aclstat2_sz + NFS_ACL2_GETACL2resok_sz)
+#define NFS_ACL2_SETACL2args_sz         \
+	(NFS_ACL2_fhandle_sz + NFS_ACL2_secattr_sz)
+#define NFS_ACL2_SETACL2resok_sz        \
+	(NFS_ACL2_fattr_sz)
+#define NFS_ACL2_SETACL2res_sz          \
+	(NFS_ACL2_aclstat2_sz + NFS_ACL2_SETACL2resok_sz)
+#define NFS_ACL2_GETATTR2args_sz        \
+	(NFS_ACL2_fhandle_sz)
+#define NFS_ACL2_GETATTR2resok_sz       \
+	(NFS_ACL2_fattr_sz)
+#define NFS_ACL2_GETATTR2res_sz         \
+	(NFS_ACL2_aclstat2_sz + NFS_ACL2_GETATTR2resok_sz)
+#define NFS_ACL2_ACCESS2args_sz         \
+	(NFS_ACL2_fhandle_sz + XDR_unsigned_int)
+#define NFS_ACL2_ACCESS2resok_sz        \
+	(NFS_ACL2_fattr_sz + XDR_unsigned_int)
+#define NFS_ACL2_ACCESS2res_sz          \
+	(NFS_ACL2_aclstat2_sz + NFS_ACL2_ACCESS2resok_sz)
+#define NFS_ACL2_GETXATTRDIR2args_sz    \
+	(NFS_ACL2_fhandle_sz + XDR_bool)
+#define NFS_ACL2_GETXATTRDIR2resok_sz   \
+	(NFS_ACL2_fhandle_sz + NFS_ACL2_fattr_sz)
+#define NFS_ACL2_GETXATTRDIR2res_sz     \
+	(NFS_ACL2_aclstat2_sz + NFS_ACL2_GETXATTRDIR2resok_sz)
+#define NFS_ACL2_MAX_ARGS_SZ            \
+	(NFS_ACL2_SETACL2args_sz)
+
+#endif /* _LINUX_XDRGEN_NFS_ACL2_DEF_H */
-- 
2.56.0

