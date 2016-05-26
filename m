Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:35473 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1750914AbcE0Q0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2016 12:26:21 -0400
Date: 26 May 2016 14:39:39 -0400
Message-ID: <20160526183939.30389.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@horizon.com>
To: bfields@fieldses.org, jlayton@poochiereds.net, linux-nfs@vger.kernel.org
Subject: [PATCH RESEND 03/10] <linux/sunrpc/svcauth.h>: Define hash_str() in terms of hash_string()
Cc: linux@sciencehorizons.net
Reply-To: linux@sciencehorizons.net
In-Reply-To: <20160525072630.5343.qmail@ns.sciencehorizons.net>
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
I have't heard anything from the linix-NFS crowd, so this is a re-ping.

I've been having some e-mail troubles leading to increased spam scores
due to a recent domain name change, so this is a resend from a different
address in case the previous copy got binned.

I'll happily send along the entire patch series, but the tl;dr is this
is part of a patch series that improves the <linux/hash.h> and fs/namei.c
hash functions, implementing Linus's suggestion:

On Mon, 02 May 2016 at 09:24:21, Linus Torvalds wrote:
> That said, I actually think hash_str() should be killed entirely.
> Better just use what we use for pathnames: full_name_hash() (which
> gets a pointer and length) and hash_name (which gets the string).
> 
> Those functions do the "word-at-a-time" optimization, and they should
> do a good enough job. If they aren't, we should fix them, because they
> are a hell of a lot more important than anything that the svcauth code
> does.

He had a typically fulminating comment about the hard-to-predict if()
branch in the inner loop.

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


