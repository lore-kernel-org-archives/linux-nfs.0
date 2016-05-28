Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:24355 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751429AbcE1T6C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 May 2016 15:58:02 -0400
From: George Spelvin <linux@sciencehorizons.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        lkml <linux-kernel@vger.kernel.org>
Cc: "J . Bruce Fields" <bfields@redhat.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: [PATCH v3 03/10] <linux/sunrpc/svcauth.h>: Define hash_str() in terms of hashlen_string()
Date: Sat, 28 May 2016 15:57:16 -0400
Message-Id: <1464465443-25305-4-git-send-email-linux@sciencehorizons.net>
In-Reply-To: <1464465443-25305-1-git-send-email-linux@sciencehorizons.net>
References: <CAADWXX_F0jOjui1iHti1eC6tsD+cwMzZ0T_16e9nCzAK6raFxA@mail.gmail.com>
 <1464465443-25305-1-git-send-email-linux@sciencehorizons.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Finally, the first use of previous two patches: eliminate the
separate ad-hoc string hash functions in the sunrpc code.

Now hash_str() is a wrapper around hash_string(), and hash_mem() is
likewise a wrapper around full_name_hash().

Note that sunrpc code *does* call hash_mem() with a zero length, which
is why the previous patch needed to handle that in full_name_hash().
(Thanks, Bruce, for finding that!)

This also eliminates the only caller of hash_long which asks for
more than 32 bits of output.

The comment about the quality of hashlen_string() and full_name_hash()
is jumping the gun by a few patches; they aren't very impressive now,
but will be improved greatly later in the series.

Signed-off-by: George Spelvin <linux@sciencehorizons.net>
Tested-by: J. Bruce Fields <bfields@redhat.com>
Acked-by: J. Bruce Fields <bfields@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
---
 include/linux/sunrpc/svcauth.h | 40 +++++++++-------------------------------
 1 file changed, 9 insertions(+), 31 deletions(-)

diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index c00f53a4..91d5a5d6 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/hash.h>
+#include <linux/stringhash.h>
 #include <linux/cred.h>
 
 struct svc_cred {
@@ -165,41 +166,18 @@ extern int svcauth_unix_set_client(struct svc_rqst *rqstp);
 extern int unix_gid_cache_create(struct net *net);
 extern void unix_gid_cache_destroy(struct net *net);
 
-static inline unsigned long hash_str(char *name, int bits)
+/*
+ * The <stringhash.h> functions are good enough that we don't need to
+ * use hash_32() on them; just extracting the high bits is enough.
+ */
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
+	return hashlen_hash(hashlen_string(name)) >> (32 - bits);
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
+	return full_name_hash(buf, length) >> (32 - bits);
 }
 
 #endif /* __KERNEL__ */
-- 
2.8.1

