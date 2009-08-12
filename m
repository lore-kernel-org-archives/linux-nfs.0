From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 01/13] sunrpc: hton -> cpu_to_be*
Date: Wed, 12 Aug 2009 18:21:40 +0300
Message-ID: <1250090500-9540-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:11429
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752367AbZHLPVl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:21:41 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

htonl is already defined as cpu_to_be32.
cpu_to_be64 has architecture specific optimized implementations.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xdr.h |    5 ++---
 net/sunrpc/xdr.c           |    6 +++---
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index b99c625..f94bbdc 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -117,9 +117,8 @@ static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int le
 static inline __be32 *
 xdr_encode_hyper(__be32 *p, __u64 val)
 {
-	*p++ = htonl(val >> 32);
-	*p++ = htonl(val & 0xFFFFFFFF);
-	return p;
+	*(__be64 *)p = cpu_to_be64(val);
+	return p + 2;
 }
 
 static inline __be32 *
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 406e26d..0d05d25 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -24,7 +24,7 @@ xdr_encode_netobj(__be32 *p, const struct xdr_netobj *obj)
 	unsigned int	quadlen = XDR_QUADLEN(obj->len);
 
 	p[quadlen] = 0;		/* zero trailing bytes */
-	*p++ = htonl(obj->len);
+	*p++ = cpu_to_be32(obj->len);
 	memcpy(p, obj->data, obj->len);
 	return p + XDR_QUADLEN(obj->len);
 }
@@ -83,7 +83,7 @@ EXPORT_SYMBOL_GPL(xdr_encode_opaque_fixed);
  */
 __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
 {
-	*p++ = htonl(nbytes);
+	*p++ = cpu_to_be32(nbytes);
 	return xdr_encode_opaque_fixed(p, ptr, nbytes);
 }
 EXPORT_SYMBOL_GPL(xdr_encode_opaque);
@@ -779,7 +779,7 @@ EXPORT_SYMBOL_GPL(xdr_decode_word);
 int
 xdr_encode_word(struct xdr_buf *buf, unsigned int base, u32 obj)
 {
-	__be32	raw = htonl(obj);
+	__be32	raw = cpu_to_be32(obj);
 
 	return write_bytes_to_xdr_buf(buf, base, &raw, sizeof(obj));
 }
-- 
1.6.4

