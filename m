Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33921 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752302AbdBRAwi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2017 19:52:38 -0500
Received: by mail-it0-f67.google.com with SMTP id r141so5175506ita.1
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2017 16:52:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] SUNRPC: Add generic helpers for xdr_stream encode/decode
Date: Fri, 17 Feb 2017 19:52:32 -0500
Message-Id: <20170218005235.65198-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some generic helpers for encoding/decoding opaque structures and
basic u32/u64.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xdr.h | 93 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 93 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 56c48c884a24..dc69299dca72 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -242,6 +242,99 @@ extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 
+static inline size_t
+xdr_align_size(size_t n)
+{
+	const size_t mask = sizeof(__u32) - 1;
+
+	return (n + mask) & ~mask;
+}
+
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
+static inline ssize_t
+xdr_stream_encode_opaque(struct xdr_stream *xdr, const void *ptr, size_t len)
+{
+	__be32 *p = xdr_reserve_space(xdr, len);
+
+	if (unlikely(!p))
+		return -ENOBUFS;
+	xdr_encode_opaque(p, ptr, len);
+	return xdr_align_size(len);
+}
+
+static inline ssize_t
+xdr_stream_decode_u32(struct xdr_stream *xdr, __u32 *n)
+{
+	const size_t len = sizeof(*n);
+	__be32 *p = xdr_inline_decode(xdr, len);
+	if (unlikely(!p))
+		return -ENOBUFS;
+	*n = be32_to_cpup(p);
+	return len;
+}
+
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

