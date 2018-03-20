Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50697 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbeCTVDp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:45 -0400
Received: by mail-it0-f65.google.com with SMTP id d13-v6so4270116itf.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] NFSv4; Clean up XDR encoding of type bitmap4
Date: Tue, 20 Mar 2018 17:03:08 -0400
Message-Id: <20180320210313.94429-5-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-4-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
 <20180320210313.94429-3-trond.myklebust@primarydata.com>
 <20180320210313.94429-4-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c           | 166 ++++++++++++++++++++-------------------------
 include/linux/sunrpc/xdr.h |  63 +++++++++++++++++
 2 files changed, 135 insertions(+), 94 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6b08f6b1addf..80c5b519fd6a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -958,6 +958,35 @@ static void encode_uint64(struct xdr_stream *xdr, u64 n)
 	WARN_ON_ONCE(xdr_stream_encode_u64(xdr, n) < 0);
 }
 
+static ssize_t xdr_encode_bitmap4(struct xdr_stream *xdr,
+		const __u32 *bitmap, size_t len)
+{
+	ssize_t ret;
+
+	/* Trim empty words */
+	while (len > 0 && bitmap[len-1] == 0)
+		len--;
+	ret = xdr_stream_encode_uint32_array(xdr, bitmap, len);
+	if (WARN_ON_ONCE(ret < 0))
+		return ret;
+	return len;
+}
+
+static size_t mask_bitmap4(const __u32 *bitmap, const __u32 *mask,
+		__u32 *res, size_t len)
+{
+	size_t i;
+	__u32 tmp;
+
+	while (len > 0 && (bitmap[len-1] == 0 || mask[len-1] == 0))
+		len--;
+	for (i = len; i-- > 0;) {
+		tmp = bitmap[i] & mask[i];
+		res[i] = tmp;
+	}
+	return len;
+}
+
 static void encode_nfs4_seqid(struct xdr_stream *xdr,
 		const struct nfs_seqid *seqid)
 {
@@ -1200,85 +1229,45 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 			create->server, create->server->attr_bitmask);
 }
 
-static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
-{
-	__be32 *p;
-
-	encode_op_hdr(xdr, OP_GETATTR, decode_getattr_maxsz, hdr);
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(1);
-	*p = cpu_to_be32(bitmap);
-}
-
-static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1, struct compound_hdr *hdr)
-{
-	__be32 *p;
-
-	encode_op_hdr(xdr, OP_GETATTR, decode_getattr_maxsz, hdr);
-	p = reserve_space(xdr, 12);
-	*p++ = cpu_to_be32(2);
-	*p++ = cpu_to_be32(bm0);
-	*p = cpu_to_be32(bm1);
-}
-
-static void
-encode_getattr_three(struct xdr_stream *xdr,
-		     uint32_t bm0, uint32_t bm1, uint32_t bm2,
-		     struct compound_hdr *hdr)
+static void encode_getattr(struct xdr_stream *xdr,
+		const __u32 *bitmap, const __u32 *mask, size_t len,
+		struct compound_hdr *hdr)
 {
-	__be32 *p;
+	__u32 masked_bitmap[nfs4_fattr_bitmap_maxsz];
 
 	encode_op_hdr(xdr, OP_GETATTR, decode_getattr_maxsz, hdr);
-	if (bm2) {
-		p = reserve_space(xdr, 16);
-		*p++ = cpu_to_be32(3);
-		*p++ = cpu_to_be32(bm0);
-		*p++ = cpu_to_be32(bm1);
-		*p = cpu_to_be32(bm2);
-	} else if (bm1) {
-		p = reserve_space(xdr, 12);
-		*p++ = cpu_to_be32(2);
-		*p++ = cpu_to_be32(bm0);
-		*p = cpu_to_be32(bm1);
-	} else {
-		p = reserve_space(xdr, 8);
-		*p++ = cpu_to_be32(1);
-		*p = cpu_to_be32(bm0);
+	if (mask) {
+		if (WARN_ON_ONCE(len > ARRAY_SIZE(masked_bitmap)))
+			len = ARRAY_SIZE(masked_bitmap);
+		len = mask_bitmap4(bitmap, mask, masked_bitmap, len);
+		bitmap = masked_bitmap;
 	}
+	xdr_encode_bitmap4(xdr, bitmap, len);
 }
 
 static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	encode_getattr_three(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
-			   bitmask[1] & nfs4_fattr_bitmap[1],
-			   bitmask[2] & nfs4_fattr_bitmap[2],
-			   hdr);
+	encode_getattr(xdr, nfs4_fattr_bitmap, bitmask,
+			ARRAY_SIZE(nfs4_fattr_bitmap), hdr);
 }
 
 static void encode_getfattr_open(struct xdr_stream *xdr, const u32 *bitmask,
 				 const u32 *open_bitmap,
 				 struct compound_hdr *hdr)
 {
-	encode_getattr_three(xdr,
-			     bitmask[0] & open_bitmap[0],
-			     bitmask[1] & open_bitmap[1],
-			     bitmask[2] & open_bitmap[2],
-			     hdr);
+	encode_getattr(xdr, open_bitmap, bitmask, 3, hdr);
 }
 
 static void encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	encode_getattr_three(xdr,
-			     bitmask[0] & nfs4_fsinfo_bitmap[0],
-			     bitmask[1] & nfs4_fsinfo_bitmap[1],
-			     bitmask[2] & nfs4_fsinfo_bitmap[2],
-			     hdr);
+	encode_getattr(xdr, nfs4_fsinfo_bitmap, bitmask,
+			ARRAY_SIZE(nfs4_fsinfo_bitmap), hdr);
 }
 
 static void encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	encode_getattr_two(xdr, bitmask[0] & nfs4_fs_locations_bitmap[0],
-			   bitmask[1] & nfs4_fs_locations_bitmap[1], hdr);
+	encode_getattr(xdr, nfs4_fs_locations_bitmap, bitmask,
+			ARRAY_SIZE(nfs4_fs_locations_bitmap), hdr);
 }
 
 static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
@@ -2559,13 +2548,17 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
+	const __u32 nfs4_acl_bitmap[1] = {
+		[0] = FATTR4_WORD0_ACL,
+	};
 	uint32_t replen;
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	replen = hdr.replen + op_decode_hdr_maxsz;
-	encode_getattr_two(xdr, FATTR4_WORD0_ACL, 0, &hdr);
+	encode_getattr(xdr, nfs4_acl_bitmap, NULL,
+			ARRAY_SIZE(nfs4_acl_bitmap), &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
 		args->acl_pages, 0, args->acl_len);
@@ -2644,8 +2637,8 @@ static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
-	encode_getattr_one(xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
-			   &hdr);
+	encode_getattr(xdr, nfs4_pathconf_bitmap, args->bitmask,
+			ARRAY_SIZE(nfs4_pathconf_bitmap), &hdr);
 	encode_nops(&hdr);
 }
 
@@ -2663,8 +2656,8 @@ static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
-	encode_getattr_two(xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
-			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
+	encode_getattr(xdr, nfs4_statfs_bitmap, args->bitmask,
+			ARRAY_SIZE(nfs4_statfs_bitmap), &hdr);
 	encode_nops(&hdr);
 }
 
@@ -2684,7 +2677,7 @@ static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fhandle, &hdr);
-	encode_getattr_three(xdr, bitmask[0], bitmask[1], bitmask[2], &hdr);
+	encode_getattr(xdr, bitmask, NULL, 3, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -3218,34 +3211,27 @@ static int decode_ace(struct xdr_stream *xdr, void *ace)
 	return -EIO;
 }
 
-static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
+static ssize_t
+decode_bitmap4(struct xdr_stream *xdr, uint32_t *bitmap, size_t sz)
 {
-	uint32_t bmlen;
-	__be32 *p;
-
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	bmlen = be32_to_cpup(p);
+	ssize_t ret;
 
-	bitmap[0] = bitmap[1] = bitmap[2] = 0;
-	p = xdr_inline_decode(xdr, (bmlen << 2));
-	if (unlikely(!p))
-		goto out_overflow;
-	if (bmlen > 0) {
-		bitmap[0] = be32_to_cpup(p++);
-		if (bmlen > 1) {
-			bitmap[1] = be32_to_cpup(p++);
-			if (bmlen > 2)
-				bitmap[2] = be32_to_cpup(p);
-		}
-	}
-	return 0;
-out_overflow:
+	ret = xdr_stream_decode_uint32_array(xdr, bitmap, sz);
+	if (likely(ret >= 0))
+		return ret;
+	if (ret == -EMSGSIZE)
+		return sz;
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
+static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
+{
+	ssize_t ret;
+	ret = decode_bitmap4(xdr, bitmap, 3);
+	return ret < 0 ? ret : 0;
+}
+
 static int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen, unsigned int *savep)
 {
 	__be32 *p;
@@ -5471,21 +5457,13 @@ decode_savefh(struct xdr_stream *xdr)
 
 static int decode_setattr(struct xdr_stream *xdr)
 {
-	__be32 *p;
-	uint32_t bmlen;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_SETATTR);
 	if (status)
 		return status;
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	bmlen = be32_to_cpup(p);
-	p = xdr_inline_decode(xdr, bmlen << 2);
-	if (likely(p))
+	if (decode_bitmap4(xdr, NULL, 0) >= 0)
 		return 0;
-out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index a43c3b6455b6..2bd68177a442 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -386,6 +386,31 @@ xdr_stream_encode_opaque(struct xdr_stream *xdr, const void *ptr, size_t len)
 	return count;
 }
 
+/**
+ * xdr_stream_encode_uint32_array - Encode variable length array of integers
+ * @xdr: pointer to xdr_stream
+ * @array: array of integers
+ * @array_size: number of elements in @array
+ *
+ * Return values:
+ *   On success, returns length in bytes of XDR buffer consumed
+ *   %-EMSGSIZE on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_encode_uint32_array(struct xdr_stream *xdr,
+		const __u32 *array, size_t array_size)
+{
+	ssize_t ret = (array_size+1) * sizeof(__u32);
+	__be32 *p = xdr_reserve_space(xdr, ret);
+
+	if (unlikely(!p))
+		return -EMSGSIZE;
+	*p++ = cpu_to_be32(array_size);
+	for (; array_size > 0; p++, array++, array_size--)
+		*p = cpu_to_be32p(array);
+	return ret;
+}
+
 /**
  * xdr_stream_decode_u32 - Decode a 32-bit integer
  * @xdr: pointer to xdr_stream
@@ -463,6 +488,44 @@ xdr_stream_decode_opaque_inline(struct xdr_stream *xdr, void **ptr, size_t maxle
 	}
 	return len;
 }
+
+/**
+ * xdr_stream_decode_uint32_array - Decode variable length array of integers
+ * @xdr: pointer to xdr_stream
+ * @array: location to store the integer array or NULL
+ * @array_size: number of elements to store
+ *
+ * Return values:
+ *   On success, returns number of elements stored in @array
+ *   %-EBADMSG on XDR buffer overflow
+ *   %-EMSGSIZE if the size of the array exceeds @array_size
+ */
+static inline ssize_t
+xdr_stream_decode_uint32_array(struct xdr_stream *xdr,
+		__u32 *array, size_t array_size)
+{
+	__be32 *p;
+	__u32 len;
+	ssize_t retval;
+
+	if (unlikely(xdr_stream_decode_u32(xdr, &len) < 0))
+		return -EBADMSG;
+	p = xdr_inline_decode(xdr, len * sizeof(*p));
+	if (unlikely(!p))
+		return -EBADMSG;
+	if (array == NULL)
+		return len;
+	if (len <= array_size) {
+		if (len < array_size)
+			memset(array+len, 0, (array_size-len)*sizeof(*array));
+		array_size = len;
+		retval = len;
+	} else
+		retval = -EMSGSIZE;
+	for (; array_size > 0; p++, array++, array_size--)
+		*array = be32_to_cpup(p);
+	return retval;
+}
 #endif /* __KERNEL__ */
 
 #endif /* _SUNRPC_XDR_H_ */
-- 
2.14.3

