Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.horizon.com ([71.41.210.147]:62250 "HELO ns.horizon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753044AbcEBK06 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 06:26:58 -0400
Date: 2 May 2016 06:20:16 -0400
Message-ID: <20160502102016.17936.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de,
        torvalds@linux-foundation.org
Subject: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32 bits
Cc: bfields@fieldses.org, eric.dumazet@gmail.com, jlayton@poochiereds.net,
        linux@horizon.com, linux-nfs@vger.kernel.org, riel@redhat.com
In-Reply-To: <alpine.DEB.2.11.1605020908080.3692@nanos>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This also affects hash_str() and hash_mem() in <linux/sunrpc/svcauth.h>.

After a careful scan through the kernel code, no caller asks any of
those four for  more than 32 bits of hash result, except that the
latter two need 64 bits from hash_long() if BITS_PER_LONG == 64.

This is in preparation for the following patch, which will create
a new implementation of hash_64 for the BITS_PER_LONG == 32 case
which is optimized for 32-bit machines.

Signed-off-by: George Spelvin <linux@horizon.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
---
Cc: to NFS folks because it touches the sunrpc directory.

Is that "TODO" comment too presumptuous of me?

 include/linux/hash.h           | 22 ++++++++++++++++------
 include/linux/sunrpc/svcauth.h | 15 +++++++--------
 2 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/include/linux/hash.h b/include/linux/hash.h
index 1afde47e..05003fdc 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -24,15 +24,17 @@
 
 #if BITS_PER_LONG == 32
 #define GOLDEN_RATIO_PRIME GOLDEN_RATIO_PRIME_32
+#define __hash_long(val) __hash_32(val)
 #define hash_long(val, bits) hash_32(val, bits)
 #elif BITS_PER_LONG == 64
+#define __hash_long(val) __hash_64(val)
 #define hash_long(val, bits) hash_64(val, bits)
 #define GOLDEN_RATIO_PRIME GOLDEN_RATIO_PRIME_64
 #else
 #error Wordsize not 32 or 64
 #endif
 
-static __always_inline u64 hash_64(u64 val, unsigned int bits)
+static __always_inline u64 __hash_64(u64 val)
 {
 	u64 hash = val;
 
@@ -55,20 +57,28 @@ static __always_inline u64 hash_64(u64 val, unsigned int bits)
 	hash += n;
 #endif
 
+	return hash;
+}
+
+static __always_inline u64 hash_64(u64 val, unsigned bits)
+{
 	/* High bits are more random, so use them. */
-	return hash >> (64 - bits);
+	return __hash_64(val) >> (64 - bits);
 }
 
-static inline u32 hash_32(u32 val, unsigned int bits)
+static inline u32 __hash_32(u32 val)
 {
 	/* On some cpus multiply is faster, on others gcc will do shifts */
-	u32 hash = val * GOLDEN_RATIO_PRIME_32;
+	return val * GOLDEN_RATIO_PRIME_32;
+}
 
+static inline u32 hash_32(u32 val, unsigned bits)
+{
 	/* High bits are more random, so use them. */
-	return hash >> (32 - bits);
+	return __hash_32(val) >> (32 - bits);
 }
 
-static inline unsigned long hash_ptr(const void *ptr, unsigned int bits)
+static inline u32 hash_ptr(const void *ptr, unsigned bits)
 {
 	return hash_long((unsigned long)ptr, bits);
 }
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index c00f53a4..eb1241b3 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -165,7 +165,8 @@ extern int svcauth_unix_set_client(struct svc_rqst *rqstp);
 extern int unix_gid_cache_create(struct net *net);
 extern void unix_gid_cache_destroy(struct net *net);
 
-static inline unsigned long hash_str(char *name, int bits)
+/* TODO: Update to <asm/word-at-a-time.h> when CONFIG_DCACHE_WORD_ACCESS */
+static inline u32 hash_str(const char *name, int bits)
 {
 	unsigned long hash = 0;
 	unsigned long l = 0;
@@ -176,14 +177,13 @@ static inline unsigned long hash_str(char *name, int bits)
 			c = (char)len; len = -1;
 		}
 		l = (l << 8) | c;
-		len++;
-		if ((len & (BITS_PER_LONG/8-1))==0)
-			hash = hash_long(hash^l, BITS_PER_LONG);
+		if (++len % sizeof(hash) == 0)
+			hash = __hash_long(hash^l);
 	} while (len);
 	return hash >> (BITS_PER_LONG - bits);
 }
 
-static inline unsigned long hash_mem(char *buf, int length, int bits)
+static inline u32 hash_mem(const char *buf, int length, int bits)
 {
 	unsigned long hash = 0;
 	unsigned long l = 0;
@@ -195,9 +195,8 @@ static inline unsigned long hash_mem(char *buf, int length, int bits)
 		} else
 			c = *buf++;
 		l = (l << 8) | c;
-		len++;
-		if ((len & (BITS_PER_LONG/8-1))==0)
-			hash = hash_long(hash^l, BITS_PER_LONG);
+		if (++len % sizeof(hash) == 0)
+			hash = __hash_long(hash^l);
 	} while (len);
 	return hash >> (BITS_PER_LONG - bits);
 }
-- 
2.8.1

