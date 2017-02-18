Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:32927 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753550AbdBRTMv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2017 14:12:51 -0500
Received: by mail-it0-f68.google.com with SMTP id e137so6808277itc.0
        for <linux-nfs@vger.kernel.org>; Sat, 18 Feb 2017 11:12:51 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/4] SUNRPC: Add generic helpers for xdr_stream encode/decode
Date: Sat, 18 Feb 2017 14:12:43 -0500
Message-Id: <20170218191246.32687-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170218191246.32687-1-trond.myklebust@primarydata.com>
References: <20170218191246.32687-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some generic helpers for encoding/decoding opaque structures and
basic u32/u64.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xdr.h | 173 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 173 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 56c48c884a24..37bf1be20b62 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -242,6 +242,179 @@ extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 
+/**
+ * xdr_align_size - Calculate padded size of an object
+ * @n: Size of an object being XDR encoded (in bytes)
+ *
+ * Return value:
+ *   Size (in bytes) of the object including xdr padding
+ */
+static inline size_t
+xdr_align_size(size_t n)
+{
+	const size_t mask = sizeof(__u32) - 1;
+
+	return (n + mask) & ~mask;
+}
+
+/**
+ * xdr_stream_encode_u32 - Encode a 32-bit integer
+ * @xdr: pointer to xdr_stream
+ * @n: integer to encode
+ *
+ * Return values:
+ *   On success, returns length in bytes of XDR buffer consumed
+ *   %-ENOBUFS on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_encode_u32(struct xdr_stream *xdr, __u32 n)
+{
+	const size_t len = sizeof(n);
+	__be32 *p = xdr_reserve_space(xdr, len);
+
+	if (unlikely(!p))
+		return -ENOBUFS;
+	*p = cpu_to_be32(n);
+	return len;
+}
+
+/**
+ * xdr_stream_encode_u64 - Encode a 64-bit integer
+ * @xdr: pointer to xdr_stream
+ * @n: 64-bit integer to encode
+ *
+ * Return values:
+ *   On success, returns length in bytes of XDR buffer consumed
+ *   %-ENOBUFS on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_encode_u64(struct xdr_stream *xdr, __u64 n)
+{
+	const size_t len = sizeof(n);
+	__be32 *p = xdr_reserve_space(xdr, len);
+
+	if (unlikely(!p))
+		return -ENOBUFS;
+	xdr_encode_hyper(p, n);
+	return len;
+}
+
+/**
+ * xdr_stream_encode_opaque_fixed - Encode fixed length opaque xdr data
+ * @xdr: pointer to xdr_stream
+ * @ptr: pointer to opaque data object
+ * @len: size of object pointed to by @ptr
+ *
+ * Return values:
+ *   On success, returns length in bytes of XDR buffer consumed
+ *   %-ENOBUFS on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_encode_opaque_fixed(struct xdr_stream *xdr, const void *ptr, size_t len)
+{
+	__be32 *p = xdr_reserve_space(xdr, len);
+
+	if (unlikely(!p))
+		return -ENOBUFS;
+	xdr_encode_opaque_fixed(p, ptr, len);
+	return xdr_align_size(len);
+}
+
+/**
+ * xdr_stream_encode_opaque - Encode variable length opaque xdr data
+ * @xdr: pointer to xdr_stream
+ * @ptr: pointer to opaque data object
+ * @len: size of object pointed to by @ptr
+ *
+ * Return values:
+ *   On success, returns length in bytes of XDR buffer consumed
+ *   %-ENOBUFS on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_encode_opaque(struct xdr_stream *xdr, const void *ptr, size_t len)
+{
+	size_t count = sizeof(__u32) + xdr_align_size(len);
+	__be32 *p = xdr_reserve_space(xdr, count);
+
+	if (unlikely(!p))
+		return -ENOBUFS;
+	xdr_encode_opaque(p, ptr, len);
+	return count;
+}
+
+/**
+ * xdr_stream_decode_u32 - Decode a 32-bit integer
+ * @xdr: pointer to xdr_stream
+ * @ptr: location to store integer
+ *
+ * Return values:
+ *   %0 on success
+ *   %-ENOBUFS on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_decode_u32(struct xdr_stream *xdr, __u32 *ptr)
+{
+	const size_t count = sizeof(*ptr);
+	__be32 *p = xdr_inline_decode(xdr, count);
+
+	if (unlikely(!p))
+		return -ENOBUFS;
+	*ptr = be32_to_cpup(p);
+	return 0;
+}
+
+/**
+ * xdr_stream_decode_opaque_fixed - Decode fixed length opaque xdr data
+ * @xdr: pointer to xdr_stream
+ * @ptr: location to store data
+ * @len: size of buffer pointed to by @ptr
+ *
+ * Return values:
+ *   On success, returns size of object stored in @ptr
+ *   %-ENOBUFS on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_decode_opaque_fixed(struct xdr_stream *xdr, void *ptr, size_t len)
+{
+	__be32 *p = xdr_inline_decode(xdr, len);
+
+	if (unlikely(!p))
+		return -ENOBUFS;
+	xdr_decode_opaque_fixed(p, ptr, len);
+	return len;
+}
+
+/**
+ * xdr_stream_decode_opaque_inline - Decode variable length opaque xdr data
+ * @xdr: pointer to xdr_stream
+ * @ptr: location to store pointer to opaque data
+ *
+ * Note: the pointer stored in @ptr cannot be assumed valid after the XDR
+ * buffer has been destroyed, or even after calling xdr_inline_decode()
+ * on @xdr. It is therefore expected that the object it points to should
+ * be processed immediately.
+ *
+ * Return values:
+ *   On success, returns size of object stored in *@ptr
+ *   %-ENOBUFS on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_decode_opaque_inline(struct xdr_stream *xdr, void **ptr)
+{
+	__be32 *p;
+	__u32 len;
+
+	if (unlikely(xdr_stream_decode_u32(xdr, &len) < 0))
+		return -ENOBUFS;
+	if (len != 0) {
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			return -ENOBUFS;
+		*ptr = p;
+	} else
+		*ptr = NULL;
+	return len;
+}
 #endif /* __KERNEL__ */
 
 #endif /* _SUNRPC_XDR_H_ */
-- 
2.9.3

