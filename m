Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:37909 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751634AbcEYH0c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 03:26:32 -0400
Date: 25 May 2016 03:26:30 -0400
Message-ID: <20160525072630.5343.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        torvalds@linux-foundation.org
Subject: [PATCH 03/10] <linux/sunrpc/svcauth.h>: Define hash_str() in terms of hash_string()
Cc: linux@sciencehorizons.net, tglx@linutronix.de
In-Reply-To: <CA+55aFxPSW+84KfQ1N_WmND-wtvgj2zQm8nFPkRcc+gyU=uing@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Finally, the first use of previous two patches: Eliminate the
separate ad-hoc string hash functions in the sunrpc code.

This also eliminates the only caller of hash_long which asks for
more than 32 bits of output.

sunrpc guys: Is it okay if I send this to Linus directly?

Signed-off-by: George Spelvin <linux@sciencehorizons.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
---
 include/linux/sunrpc/svcauth.h | 36 +++++-------------------------------
 1 file changed, 5 insertions(+), 31 deletions(-)

diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index c00f53a4..ef2b2552 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/hash.h>
+#include <linux/stringhash.h>
 #include <linux/cred.h>
 
 struct svc_cred {
@@ -165,41 +166,14 @@ extern int svcauth_unix_set_client(struct svc_rqst *rqstp);
 extern int unix_gid_cache_create(struct net *net);
 extern void unix_gid_cache_destroy(struct net *net);
 
-static inline unsigned long hash_str(char *name, int bits)
+static inline unsigned long hash_str(char const *name, int bits)
 {
-	unsigned long hash = 0;
-	unsigned long l = 0;
-	int len = 0;
-	unsigned char c;
-	do {
-		if (unlikely(!(c = *name++))) {
-			c = (char)len; len = -1;
-		}
-		l = (l << 8) | c;
-		len++;
-		if ((len & (BITS_PER_LONG/8-1))==0)
-			hash = hash_long(hash^l, BITS_PER_LONG);
-	} while (len);
-	return hash >> (BITS_PER_LONG - bits);
+	return hash_32(hashlen_hash(hash_string(name)), bits);
 }
 
-static inline unsigned long hash_mem(char *buf, int length, int bits)
+static inline unsigned long hash_mem(char const *buf, int length, int bits)
 {
-	unsigned long hash = 0;
-	unsigned long l = 0;
-	int len = 0;
-	unsigned char c;
-	do {
-		if (len == length) {
-			c = (char)len; len = -1;
-		} else
-			c = *buf++;
-		l = (l << 8) | c;
-		len++;
-		if ((len & (BITS_PER_LONG/8-1))==0)
-			hash = hash_long(hash^l, BITS_PER_LONG);
-	} while (len);
-	return hash >> (BITS_PER_LONG - bits);
+	return hash_32(full_name_hash(buf, length), bits);
 }
 
 #endif /* __KERNEL__ */
-- 
2.8.1

