Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:51217 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab3IZSki (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:38 -0400
Received: by mail-qe0-f53.google.com with SMTP id jy17so1105241qeb.26
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:37 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 11/49] NFSD: introduce exp_xdr.h
Date: Thu, 26 Sep 2013 14:40:35 -0400
Message-Id: <1380220835-13182-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Containing xdr encoding helpers to be used by the layout type library functions
or by the file system to encode/decode layout-type specific device and layout
information.

Cc: J. Bruce Fields <bfields@citi.umich.edu>
[nfsd: fix exp_xdr_encode_u64 parameter type]
Reported-by: J. Bruce Fields <bfields@citi.umich.edu>
[exportfs: exp_xdr.h: Use #include <linux/string.h> instead of <asm/string.h>]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 include/linux/exp_xdr.h | 141 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 141 insertions(+)
 create mode 100644 include/linux/exp_xdr.h

diff --git a/include/linux/exp_xdr.h b/include/linux/exp_xdr.h
new file mode 100644
index 0000000..b69c309
--- /dev/null
+++ b/include/linux/exp_xdr.h
@@ -0,0 +1,141 @@
+#ifndef _LINUX_EXP_XDR_H
+#define _LINUX_EXP_XDR_H
+
+#include <asm/byteorder.h>
+#include <asm/unaligned.h>
+#include <linux/string.h>
+
+struct exp_xdr_stream {
+	__be32 *p;
+	__be32 *end;
+};
+
+/**
+ * exp_xdr_qwords - Calculate the number of quad-words holding nbytes
+ * @nbytes: number of bytes to encode
+ */
+static inline size_t
+exp_xdr_qwords(__u32 nbytes)
+{
+	return DIV_ROUND_UP(nbytes, 4);
+}
+
+/**
+ * exp_xdr_qbytes - Calculate the number of bytes holding qwords
+ * @qwords: number of quad-words to encode
+ */
+static inline size_t
+exp_xdr_qbytes(size_t qwords)
+{
+	return qwords << 2;
+}
+
+/**
+ * exp_xdr_reserve_space - Reserve buffer space for sending
+ * @xdr: pointer to exp_xdr_stream
+ * @nbytes: number of bytes to reserve
+ *
+ * Checks that we have enough buffer space to encode 'nbytes' more
+ * bytes of data. If so, update the xdr stream.
+ */
+static inline __be32 *
+exp_xdr_reserve_space(struct exp_xdr_stream *xdr, size_t nbytes)
+{
+	__be32 *p = xdr->p;
+	__be32 *q;
+
+	/* align nbytes on the next 32-bit boundary */
+	q = p + exp_xdr_qwords(nbytes);
+	if (unlikely(q > xdr->end || q < p))
+		return NULL;
+	xdr->p = q;
+	return p;
+}
+
+/**
+ * exp_xdr_reserve_qwords - Reserve buffer space for sending
+ * @xdr: pointer to exp_xdr_stream
+ * @nwords: number of quad words (u32's) to reserve
+ */
+static inline __be32 *
+exp_xdr_reserve_qwords(struct exp_xdr_stream *xdr, size_t qwords)
+{
+	return exp_xdr_reserve_space(xdr, exp_xdr_qbytes(qwords));
+}
+
+/**
+ * exp_xdr_encode_u32 - Encode an unsigned 32-bit value onto a xdr stream
+ * @p: pointer to encoding destination
+ * @val: value to encode
+ */
+static inline __be32 *
+exp_xdr_encode_u32(__be32 *p, __u32 val)
+{
+	*p = cpu_to_be32(val);
+	return p + 1;
+}
+
+/**
+ * exp_xdr_encode_u64 - Encode an unsigned 64-bit value onto a xdr stream
+ * @p: pointer to encoding destination
+ * @val: value to encode
+ */
+static inline __be32 *
+exp_xdr_encode_u64(__be32 *p, __u64 val)
+{
+	put_unaligned_be64(val, p);
+	return p + 2;
+}
+
+/**
+ * exp_xdr_encode_bytes - Encode an array of bytes onto a xdr stream
+ * @p: pointer to encoding destination
+ * @ptr: pointer to the array of bytes
+ * @nbytes: number of bytes to encode
+ */
+static inline __be32 *
+exp_xdr_encode_bytes(__be32 *p, const void *ptr, __u32 nbytes)
+{
+	if (likely(nbytes != 0)) {
+		unsigned int qwords = exp_xdr_qwords(nbytes);
+		unsigned int padding = exp_xdr_qbytes(qwords) - nbytes;
+
+		memcpy(p, ptr, nbytes);
+		if (padding != 0)
+			memset((char *)p + nbytes, 0, padding);
+		p += qwords;
+	}
+	return p;
+}
+
+/**
+ * exp_xdr_encode_opaque - Encode an opaque type onto a xdr stream
+ * @p: pointer to encoding destination
+ * @ptr: pointer to the opaque array
+ * @nbytes: number of bytes to encode
+ *
+ * Encodes the 32-bit opaque size in bytes followed by the opaque value.
+ */
+static inline __be32 *
+exp_xdr_encode_opaque(__be32 *p, const void *ptr, __u32 nbytes)
+{
+	p = exp_xdr_encode_u32(p, nbytes);
+	return exp_xdr_encode_bytes(p, ptr, nbytes);
+}
+
+/**
+ * exp_xdr_encode_opaque_qlen - Encode the opaque length onto a xdr stream
+ * @lenp: pointer to the opaque length destination
+ * @endp: pointer to the end of the opaque array
+ *
+ * Encodes the 32-bit opaque size in bytes given the start and end pointers
+ */
+static inline __be32 *
+exp_xdr_encode_opaque_len(__be32 *lenp, const void *endp)
+{
+	size_t nbytes = (char *)endp - (char *)(lenp + 1);
+
+	exp_xdr_encode_u32(lenp, nbytes);
+	return lenp + 1 + exp_xdr_qwords(nbytes);
+}
+#endif /* _LINUX_EXP_XDR_H */
-- 
1.8.3.1

