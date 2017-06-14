Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37529 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752112AbdFNPPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:15:48 -0400
Subject: [PATCH 01/27] Provide a function to create a NUL-terminated string
 from unterminated data [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:15:20 +0100
Message-ID: <149745332056.10897.12079641380366267582.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a function, kmemdup_nul(), that will create a NUL-terminated string
from an unterminated character array where the length is known in advance.

This is better than kstrndup() in situations where we already know the
string length as the strnlen() in kstrndup() is superfluous.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/string.h |    1 +
 mm/util.c              |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index 537918f8a98e..3dd944cfe171 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -131,6 +131,7 @@ extern char *kstrdup(const char *s, gfp_t gfp) __malloc;
 extern const char *kstrdup_const(const char *s, gfp_t gfp);
 extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
 extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
+extern char *kmemdup_nul(const char *s, size_t len, gfp_t gfp);
 
 extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
 extern void argv_free(char **argv);
diff --git a/mm/util.c b/mm/util.c
index 26be6407abd7..21ddf90f883d 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -83,6 +83,8 @@ EXPORT_SYMBOL(kstrdup_const);
  * @s: the string to duplicate
  * @max: read at most @max chars from @s
  * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ *
+ * Note: Use kmemdup_nul() instead if the size is known exactly.
  */
 char *kstrndup(const char *s, size_t max, gfp_t gfp)
 {
@@ -121,6 +123,28 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
 EXPORT_SYMBOL(kmemdup);
 
 /**
+ * kmemdup_nul - Create a NUL-terminated string from unterminated data
+ * @s: The data to stringify
+ * @len: The size of the data
+ * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ */
+char *kmemdup_nul(const char *s, size_t len, gfp_t gfp)
+{
+	char *buf;
+
+	if (!s)
+		return NULL;
+
+	buf = kmalloc_track_caller(len + 1, gfp);
+	if (buf) {
+		memcpy(buf, s, len);
+		buf[len] = '\0';
+	}
+	return buf;
+}
+EXPORT_SYMBOL(kmemdup_nul);
+
+/**
  * memdup_user - duplicate memory region from user space
  *
  * @src: source address in user space

