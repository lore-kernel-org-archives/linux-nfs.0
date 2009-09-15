From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] sunrpc: xdr_xcode_hyper helpers cannot presume 64-bit alignment
Date: Tue, 15 Sep 2009 19:05:24 +0300
Message-ID: <1253030724-22196-1-git-send-email-bhalevy@panasas.com>
References: <20090912140001.GD5858@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:11985 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751502AbZIOQEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2009 12:04:09 -0400
In-Reply-To: <20090912140001.GD5858@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xdr.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 7da466b..f5cc089 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -11,6 +11,7 @@
 
 #include <linux/uio.h>
 #include <asm/byteorder.h>
+#include <asm/unaligned.h>
 #include <linux/scatterlist.h>
 
 /*
@@ -117,14 +118,14 @@ static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int le
 static inline __be32 *
 xdr_encode_hyper(__be32 *p, __u64 val)
 {
-	*(__be64 *)p = cpu_to_be64(val);
+	put_unaligned_be64(val, p);
 	return p + 2;
 }
 
 static inline __be32 *
 xdr_decode_hyper(__be32 *p, __u64 *valp)
 {
-	*valp = be64_to_cpup((__be64 *)p);
+	*valp = get_unaligned_be64(p);
 	return p + 2;
 }
 
-- 
1.6.4

