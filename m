From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 03/13] sunrpc: introduce 32-bit Xcoding helpers
Date: Wed, 12 Aug 2009 18:21:51 +0300
Message-ID: <1250090511-9605-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:11183
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752555AbZHLPVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:21:52 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To be used instead of WRITE32/READ32.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xdr.h |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 7da466b..466ea12 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -112,6 +112,23 @@ static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int le
 }
 
 /*
+ * Xcode 32bit quantities
+ */
+static inline __be32 *
+xdr_encode_int(__be32 *p, __u32 val)
+{
+	*p = cpu_to_be32(val);
+	return p + 1;
+}
+
+static inline __be32 *
+xdr_decode_int(__be32 *p, __u32 *valp)
+{
+	*valp = be32_to_cpu(*p);
+	return p + 1;
+}
+
+/*
  * Decode 64bit quantities (NFSv3 support)
  */
 static inline __be32 *
-- 
1.6.4

