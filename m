Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36155 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751142AbdGNV2X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 17:28:23 -0400
From: Daniel Micay <danielmicay@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com,
        Daniel Micay <danielmicay@gmail.com>
Subject: [PATCH] replace incorrect strscpy use in FORTIFY_SOURCE
Date: Fri, 14 Jul 2017 17:28:12 -0400
Message-Id: <20170714212812.30297-1-danielmicay@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using strscpy was wrong because FORTIFY_SOURCE is passing the maximum
possible size of the outermost object, but strscpy defines the count
parameter as the exact buffer size, so this could copy past the end of
the source. This would still be wrong with the planned usage of
__builtin_object_size(p, 1) for intra-object overflow checks since it's
the maximum possible size of the specified object with no guarantee of
it being that large.

Reuse of the fortified functions like this currently makes the runtime
error reporting less precise but that can be improved later on.

Signed-off-by: Daniel Micay <danielmicay@gmail.com>
---
 include/linux/string.h | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/string.h b/include/linux/string.h
index 96f5a5fd0377..049866760e8b 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -202,17 +202,6 @@ void __read_overflow2(void) __compiletime_error("detected read beyond size of ob
 void __write_overflow(void) __compiletime_error("detected write beyond size of object passed as 1st parameter");
 
 #if !defined(__NO_FORTIFY) && defined(__OPTIMIZE__) && defined(CONFIG_FORTIFY_SOURCE)
-__FORTIFY_INLINE char *strcpy(char *p, const char *q)
-{
-	size_t p_size = __builtin_object_size(p, 0);
-	size_t q_size = __builtin_object_size(q, 0);
-	if (p_size == (size_t)-1 && q_size == (size_t)-1)
-		return __builtin_strcpy(p, q);
-	if (strscpy(p, q, p_size < q_size ? p_size : q_size) < 0)
-		fortify_panic(__func__);
-	return p;
-}
-
 __FORTIFY_INLINE char *strncpy(char *p, const char *q, __kernel_size_t size)
 {
 	size_t p_size = __builtin_object_size(p, 0);
@@ -391,6 +380,18 @@ __FORTIFY_INLINE void *kmemdup(const void *p, size_t size, gfp_t gfp)
 		fortify_panic(__func__);
 	return __real_kmemdup(p, size, gfp);
 }
+
+/* defined after fortified strlen and memcpy to reuse them */
+__FORTIFY_INLINE char *strcpy(char *p, const char *q)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	size_t q_size = __builtin_object_size(q, 0);
+	if (p_size == (size_t)-1 && q_size == (size_t)-1)
+		return __builtin_strcpy(p, q);
+	memcpy(p, q, strlen(q) + 1);
+	return p;
+}
+
 #endif
 
 #endif /* _LINUX_STRING_H_ */
-- 
2.13.3

