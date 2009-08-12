From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 02/13] sunrpc: ntoh -> be*_to_cpu
Date: Wed, 12 Aug 2009 18:21:48 +0300
Message-ID: <1250090508-9572-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:10960
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752367AbZHLPVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:21:48 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ntohl is already defined as be32_to_cpu.
be64_to_cpu has architecture specific optimized implementations.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xdr.h |    5 ++---
 net/sunrpc/xdr.c           |    6 +++---
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index f94bbdc..7da466b 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -124,9 +124,8 @@ xdr_encode_hyper(__be32 *p, __u64 val)
 static inline __be32 *
 xdr_decode_hyper(__be32 *p, __u64 *valp)
 {
-	*valp  = ((__u64) ntohl(*p++)) << 32;
-	*valp |= ntohl(*p++);
-	return p;
+	*valp = be64_to_cpup((__be64 *)p);
+	return p + 2;
 }
 
 /*
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 0d05d25..8bd690c 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -35,7 +35,7 @@ xdr_decode_netobj(__be32 *p, struct xdr_netobj *obj)
 {
 	unsigned int	len;
 
-	if ((len = ntohl(*p++)) > XDR_MAX_NETOBJ)
+	if ((len = be32_to_cpu(*p++)) > XDR_MAX_NETOBJ)
 		return NULL;
 	obj->len  = len;
 	obj->data = (u8 *) p;
@@ -101,7 +101,7 @@ xdr_decode_string_inplace(__be32 *p, char **sp,
 {
 	u32 len;
 
-	len = ntohl(*p++);
+	len = be32_to_cpu(*p++);
 	if (len > maxlen)
 		return NULL;
 	*lenp = len;
@@ -771,7 +771,7 @@ xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)
 	status = read_bytes_from_xdr_buf(buf, base, &raw, sizeof(*obj));
 	if (status)
 		return status;
-	*obj = ntohl(raw);
+	*obj = be32_to_cpu(raw);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xdr_decode_word);
-- 
1.6.4

