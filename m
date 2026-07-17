Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B467389DE0
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 18:41:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784313676; cv=none; b=O+wOR6YRQe2PB1tO493sIO1Q3C1Dev2ni72pO1bkLL6+U1JGdTzuLJWixaJIzY342x539EfIUqUksntSoMg+GycTOEDKEGUfuaqHI8muFlQ0hh3vbSeLoxXqAMom0N3T0qDEy4hfDPwhEHNkmHIRf8L3Yblvtf5xe6xP6rOiRPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784313676; c=relaxed/simple;
	bh=4H1bmYWPAr+e03DNx7g6SNU53TtRbIavzrujgvDw7JY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gQeJ4cZ+XC80P1W3QBSz0Om65v5S9IcCO821bBfZTp+H03V5G6PGp4d71+jQxvm6uIqGRbD2uWfPZ0BOukmrBIJmXcjUvs6gpYCiOnzdwoNaNlqp/gxCAjCxVitSkOewn/+09r+Z/EEfliPSNA3YM5hHhKNt/MIEKfe53HO4xuM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TSTOFD06; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TSTOFD06"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E9CC1F00A3A;
	Fri, 17 Jul 2026 18:41:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784313675;
	bh=p1sTOcjUJpRZe5BwvP/dqZw/7yCO7iJxO3ddBq6fvh8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TSTOFD06liQzZijDKCRbtX4A2WXniQAldRCsFfjDjT0iorBZS+1QeGkPYHPbdr6z7
	 pX8YpkO7YukgAuauVcsCWV8BUuqsNABL94G12LUrzvuj4AKCvR0vVefQYCQfx8k0sE
	 k/ULpb0JqbI/0j5WWP6azR0AE8EBrlTG/XoVGIpWDCFL4Dg0yIqHm8oGLbCtdyLvSO
	 HCHTMnDpH/n7f/avcZSP4q6mxIja+2G93KvHljdbzmLe/0K29jlkxuhTl1dOUkX2Rq
	 Ow3W22izZv31A10hZhQYXbkFVzEBG+JOMHa0Y7MODnBsxPGAeEK5Vru5kfuviX0vXn
	 cbjOkesVro3LQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/6] NFSD: Move XDR encoding helpers out of xdr4.h
Date: Fri, 17 Jul 2026 14:41:07 -0400
Message-ID: <20260717184112.507548-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717184112.507548-1-cel@kernel.org>
References: <20260717184112.507548-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

These static inline helpers use the nfserr_resource macro, which
pulls in the whole rack of NFS status codes. Move those helpers
into the only file that uses them, to get rid of the nfserr macro
dependency globally.

These helper were originally placed in xdr4.h because I thought
they would be utilized in the rest of the NFSv4 XDR code, but
XDR translation is eventually to be subsumed by xdrgen instead.
I'm not converting them now because that is much more churn than
this patch is.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/blocklayoutxdr.c |  10 +++
 fs/nfsd/nfs4xdr.c        |  92 ++++++++++++++++++++++++++
 fs/nfsd/xdr4.h           | 139 ---------------------------------------
 3 files changed, 102 insertions(+), 139 deletions(-)

diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index f80dbc41fd5f..51cc2a07d7b3 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -13,6 +13,16 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_PNFS
 
+static __be32
+nfsd4_decode_deviceid4(struct xdr_stream *xdr, struct nfsd4_deviceid *devid)
+{
+	__be32 *p = xdr_inline_decode(xdr, NFS4_DEVICEID4_SIZE);
+
+	if (unlikely(!p))
+		return nfserr_bad_xdr;
+	svcxdr_decode_deviceid4(p, devid);
+	return nfs_ok;
+}
 
 /**
  * nfsd4_block_encode_layoutget - encode block/scsi layout extent array
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 04755c41d871..05d64733094b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1919,6 +1919,17 @@ nfsd4_decode_get_dir_delegation(struct nfsd4_compoundargs *argp,
 }
 
 #ifdef CONFIG_NFSD_PNFS
+static __be32
+nfsd4_decode_deviceid4(struct xdr_stream *xdr, struct nfsd4_deviceid *devid)
+{
+	__be32 *p = xdr_inline_decode(xdr, NFS4_DEVICEID4_SIZE);
+
+	if (unlikely(!p))
+		return nfserr_bad_xdr;
+	svcxdr_decode_deviceid4(p, devid);
+	return nfs_ok;
+}
+
 static __be32
 nfsd4_decode_getdeviceinfo(struct nfsd4_compoundargs *argp,
 		union nfsd4_op_u *u)
@@ -2733,6 +2744,87 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	return true;
 }
 
+static __always_inline __be32
+nfsd4_encode_bool(struct xdr_stream *xdr, bool val)
+{
+	__be32 *p = xdr_reserve_space(xdr, XDR_UNIT);
+
+	if (unlikely(p == NULL))
+		return nfserr_resource;
+	*p = val ? xdr_one : xdr_zero;
+	return nfs_ok;
+}
+
+static __always_inline __be32
+nfsd4_encode_uint32_t(struct xdr_stream *xdr, u32 val)
+{
+	__be32 *p = xdr_reserve_space(xdr, XDR_UNIT);
+
+	if (unlikely(p == NULL))
+		return nfserr_resource;
+	*p = cpu_to_be32(val);
+	return nfs_ok;
+}
+
+#define nfsd4_encode_aceflag4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_acemask4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_acetype4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_count4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_mode4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_nfs_lease4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_qop4(x, v)		nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_sequenceid4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_slotid4(x, v)	nfsd4_encode_uint32_t(x, v)
+
+static __always_inline __be32
+nfsd4_encode_uint64_t(struct xdr_stream *xdr, u64 val)
+{
+	__be32 *p = xdr_reserve_space(xdr, XDR_UNIT * 2);
+
+	if (unlikely(p == NULL))
+		return nfserr_resource;
+	put_unaligned_be64(val, p);
+	return nfs_ok;
+}
+
+#define nfsd4_encode_changeid4(x, v)	nfsd4_encode_uint64_t(x, v)
+#define nfsd4_encode_nfs_cookie4(x, v)	nfsd4_encode_uint64_t(x, v)
+#define nfsd4_encode_length4(x, v)	nfsd4_encode_uint64_t(x, v)
+#define nfsd4_encode_offset4(x, v)	nfsd4_encode_uint64_t(x, v)
+
+static __always_inline __be32
+nfsd4_encode_opaque_fixed(struct xdr_stream *xdr, const void *data,
+			  size_t size)
+{
+	__be32 *p = xdr_reserve_space(xdr, xdr_align_size(size));
+	size_t pad = xdr_pad_size(size);
+
+	if (unlikely(p == NULL))
+		return nfserr_resource;
+	memcpy(p, data, size);
+	if (pad)
+		memset((char *)p + size, 0, pad);
+	return nfs_ok;
+}
+
+static __always_inline __be32
+nfsd4_encode_opaque(struct xdr_stream *xdr, const void *data, size_t size)
+{
+	size_t pad = xdr_pad_size(size);
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, XDR_UNIT + xdr_align_size(size));
+	if (unlikely(p == NULL))
+		return nfserr_resource;
+	*p++ = cpu_to_be32(size);
+	memcpy(p, data, size);
+	if (pad)
+		memset((char *)p + size, 0, pad);
+	return nfs_ok;
+}
+
+#define nfsd4_encode_component4(x, d, s)	nfsd4_encode_opaque(x, d, s)
+
 static __be32 nfsd4_encode_nfs_fh4(struct xdr_stream *xdr,
 				   const struct knfsd_fh *fh_handle)
 {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index c7eda5bc833b..e833407859c8 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -50,134 +50,6 @@
 #define HAS_CSTATE_FLAG(c, f) ((c)->sid_flags & (f))
 #define CLEAR_CSTATE_FLAG(c, f) ((c)->sid_flags &= ~(f))
 
-/**
- * nfsd4_encode_bool - Encode an XDR bool type result
- * @xdr: target XDR stream
- * @val: boolean value to encode
- *
- * Return values:
- *    %nfs_ok: @val encoded; @xdr advanced to next position
- *    %nfserr_resource: stream buffer space exhausted
- */
-static __always_inline __be32
-nfsd4_encode_bool(struct xdr_stream *xdr, bool val)
-{
-	__be32 *p = xdr_reserve_space(xdr, XDR_UNIT);
-
-	if (unlikely(p == NULL))
-		return nfserr_resource;
-	*p = val ? xdr_one : xdr_zero;
-	return nfs_ok;
-}
-
-/**
- * nfsd4_encode_uint32_t - Encode an XDR uint32_t type result
- * @xdr: target XDR stream
- * @val: integer value to encode
- *
- * Return values:
- *    %nfs_ok: @val encoded; @xdr advanced to next position
- *    %nfserr_resource: stream buffer space exhausted
- */
-static __always_inline __be32
-nfsd4_encode_uint32_t(struct xdr_stream *xdr, u32 val)
-{
-	__be32 *p = xdr_reserve_space(xdr, XDR_UNIT);
-
-	if (unlikely(p == NULL))
-		return nfserr_resource;
-	*p = cpu_to_be32(val);
-	return nfs_ok;
-}
-
-#define nfsd4_encode_aceflag4(x, v)	nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_acemask4(x, v)	nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_acetype4(x, v)	nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_count4(x, v)	nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_mode4(x, v)	nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_nfs_lease4(x, v)	nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_qop4(x, v)		nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_sequenceid4(x, v)	nfsd4_encode_uint32_t(x, v)
-#define nfsd4_encode_slotid4(x, v)	nfsd4_encode_uint32_t(x, v)
-
-/**
- * nfsd4_encode_uint64_t - Encode an XDR uint64_t type result
- * @xdr: target XDR stream
- * @val: integer value to encode
- *
- * Return values:
- *    %nfs_ok: @val encoded; @xdr advanced to next position
- *    %nfserr_resource: stream buffer space exhausted
- */
-static __always_inline __be32
-nfsd4_encode_uint64_t(struct xdr_stream *xdr, u64 val)
-{
-	__be32 *p = xdr_reserve_space(xdr, XDR_UNIT * 2);
-
-	if (unlikely(p == NULL))
-		return nfserr_resource;
-	put_unaligned_be64(val, p);
-	return nfs_ok;
-}
-
-#define nfsd4_encode_changeid4(x, v)	nfsd4_encode_uint64_t(x, v)
-#define nfsd4_encode_nfs_cookie4(x, v)	nfsd4_encode_uint64_t(x, v)
-#define nfsd4_encode_length4(x, v)	nfsd4_encode_uint64_t(x, v)
-#define nfsd4_encode_offset4(x, v)	nfsd4_encode_uint64_t(x, v)
-
-/**
- * nfsd4_encode_opaque_fixed - Encode a fixed-length XDR opaque type result
- * @xdr: target XDR stream
- * @data: pointer to data
- * @size: length of data in bytes
- *
- * Return values:
- *    %nfs_ok: @data encoded; @xdr advanced to next position
- *    %nfserr_resource: stream buffer space exhausted
- */
-static __always_inline __be32
-nfsd4_encode_opaque_fixed(struct xdr_stream *xdr, const void *data,
-			  size_t size)
-{
-	__be32 *p = xdr_reserve_space(xdr, xdr_align_size(size));
-	size_t pad = xdr_pad_size(size);
-
-	if (unlikely(p == NULL))
-		return nfserr_resource;
-	memcpy(p, data, size);
-	if (pad)
-		memset((char *)p + size, 0, pad);
-	return nfs_ok;
-}
-
-/**
- * nfsd4_encode_opaque - Encode a variable-length XDR opaque type result
- * @xdr: target XDR stream
- * @data: pointer to data
- * @size: length of data in bytes
- *
- * Return values:
- *    %nfs_ok: @data encoded; @xdr advanced to next position
- *    %nfserr_resource: stream buffer space exhausted
- */
-static __always_inline __be32
-nfsd4_encode_opaque(struct xdr_stream *xdr, const void *data, size_t size)
-{
-	size_t pad = xdr_pad_size(size);
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, XDR_UNIT + xdr_align_size(size));
-	if (unlikely(p == NULL))
-		return nfserr_resource;
-	*p++ = cpu_to_be32(size);
-	memcpy(p, data, size);
-	if (pad)
-		memset((char *)p + size, 0, pad);
-	return nfs_ok;
-}
-
-#define nfsd4_encode_component4(x, d, s)	nfsd4_encode_opaque(x, d, s)
-
 struct nfsd4_compound_state {
 	struct svc_fh		current_fh;
 	struct svc_fh		save_fh;
@@ -642,17 +514,6 @@ svcxdr_decode_deviceid4(__be32 *p, struct nfsd4_deviceid *devid)
 	return p;
 }
 
-static inline __be32
-nfsd4_decode_deviceid4(struct xdr_stream *xdr, struct nfsd4_deviceid *devid)
-{
-	__be32 *p = xdr_inline_decode(xdr, NFS4_DEVICEID4_SIZE);
-
-	if (unlikely(!p))
-		return nfserr_bad_xdr;
-	svcxdr_decode_deviceid4(p, devid);
-	return nfs_ok;
-}
-
 struct nfsd4_layout_seg {
 	u32			iomode;
 	u64			offset;
-- 
2.54.0

