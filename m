Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f176.google.com ([209.85.217.176]:40441 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757355AbbCCXVC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 18:21:02 -0500
Received: by lbiw7 with SMTP id w7so1329566lbi.7
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 15:21:00 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andrew Morton <akpm@linux-foundation.org>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: [PATCH v4 3/3] lib/string_helpers.c: Change semantics of string_escape_mem
Date: Wed,  4 Mar 2015 00:20:35 +0100
Message-Id: <1425424836-17947-4-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1425424836-17947-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
 <1425424836-17947-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current semantics of string_escape_mem are inadequate for one of
its current users, vsnprintf(). If that is to honour its contract, it
must know how much space would be needed for the entire escaped
buffer, and string_escape_mem provides no way of obtaining that (short
of allocating a large enough buffer (~4 times input string) to let it
play with, and that's definitely a big no-no inside vsnprintf).

So change the semantics for string_escape_mem to be more
snprintf-like: Return the size of the output that would be generated
if the destination buffer was big enough, but of course still only
write to the part of dst it is allowed to, and (contrary to snprintf)
don't do '\0'-termination. It is then up to the caller to detect
whether output was truncated and to append a '\0' if desired. Also, we
must output partial escape sequences, otherwise a call such as
snprintf(buf, 3, "%1pE", "\123") would cause printf to write a \0 to
buf[2] but leaving buf[0] and buf[1] with whatever they previously
contained.

This also fixes a bug in the escaped_string() helper function, which
used to unconditionally pass a length of "end-buf" to
string_escape_mem(); since the latter doesn't check osz for being
insanely large, it would happily write to dst. For example,
kasprintf(GFP_KERNEL, "something and then %pE", ...); is an easy way
to trigger an oops.

In test-string_helpers.c, the -ENOMEM test is replaced with testing
for getting the expected return value even if the buffer is too
small. We also ensure that nothing is written (by relying on a NULL
pointer deref) if the output size is 0 by passing NULL - this has to
work for kasprintf("%pE") to work.

In net/sunrpc/cache.c, I think qword_add still has the same
semantics. Someone should definitely double-check this.

In fs/proc/array.c, I made the minimum possible change, but
longer-term it should stop poking around in seq_file internals.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 fs/proc/array.c                |  4 ++--
 include/linux/string_helpers.h |  8 +++----
 lib/string_helpers.c           | 49 ++++++------------------------------------
 lib/test-string_helpers.c      | 40 +++++++++++++++++-----------------
 lib/vsprintf.c                 |  8 +++++--
 net/sunrpc/cache.c             |  8 ++++---
 6 files changed, 44 insertions(+), 73 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 1295a00ca316..b5405889a780 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -99,8 +99,8 @@ static inline void task_name(struct seq_file *m, struct task_struct *p)
 	buf = m->buf + m->count;
 
 	/* Ignore error for now */
-	string_escape_str(tcomm, &buf, m->size - m->count,
-			  ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
+	buf += string_escape_str(tcomm, buf, m->size - m->count,
+				 ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
 
 	m->count = buf - m->buf;
 	seq_putc(m, '\n');
diff --git a/include/linux/string_helpers.h b/include/linux/string_helpers.h
index 657571817260..0991913f4953 100644
--- a/include/linux/string_helpers.h
+++ b/include/linux/string_helpers.h
@@ -47,22 +47,22 @@ static inline int string_unescape_any_inplace(char *buf)
 #define ESCAPE_ANY_NP		(ESCAPE_ANY | ESCAPE_NP)
 #define ESCAPE_HEX		0x20
 
-int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
+int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
 		unsigned int flags, const char *esc);
 
 static inline int string_escape_mem_any_np(const char *src, size_t isz,
-		char **dst, size_t osz, const char *esc)
+		char *dst, size_t osz, const char *esc)
 {
 	return string_escape_mem(src, isz, dst, osz, ESCAPE_ANY_NP, esc);
 }
 
-static inline int string_escape_str(const char *src, char **dst, size_t sz,
+static inline int string_escape_str(const char *src, char *dst, size_t sz,
 		unsigned int flags, const char *esc)
 {
 	return string_escape_mem(src, strlen(src), dst, sz, flags, esc);
 }
 
-static inline int string_escape_str_any_np(const char *src, char **dst,
+static inline int string_escape_str_any_np(const char *src, char *dst,
 		size_t sz, const char *esc)
 {
 	return string_escape_str(src, dst, sz, ESCAPE_ANY_NP, esc);
diff --git a/lib/string_helpers.c b/lib/string_helpers.c
index 9c48ddad0f0d..1826c7407258 100644
--- a/lib/string_helpers.c
+++ b/lib/string_helpers.c
@@ -274,11 +274,6 @@ static bool escape_space(unsigned char c, char **dst, char *end)
 		return false;
 	}
 
-	if (out + 2 > end) {
-		*dst = out + 2;
-		return true;
-	}
-
 	if (out < end)
 		*out = '\\';
 	++out;
@@ -309,11 +304,6 @@ static bool escape_special(unsigned char c, char **dst, char *end)
 		return false;
 	}
 
-	if (out + 2 > end) {
-		*dst = out + 2;
-		return true;
-	}
-
 	if (out < end)
 		*out = '\\';
 	++out;
@@ -332,11 +322,6 @@ static bool escape_null(unsigned char c, char **dst, char *end)
 	if (c)
 		return false;
 
-	if (out + 2 > end) {
-		*dst = out + 2;
-		return true;
-	}
-
 	if (out < end)
 		*out = '\\';
 	++out;
@@ -352,11 +337,6 @@ static bool escape_octal(unsigned char c, char **dst, char *end)
 {
 	char *out = *dst;
 
-	if (out + 4 > end) {
-		*dst = out + 4;
-		return true;
-	}
-
 	if (out < end)
 		*out = '\\';
 	++out;
@@ -378,11 +358,6 @@ static bool escape_hex(unsigned char c, char **dst, char *end)
 {
 	char *out = *dst;
 
-	if (out + 4 > end) {
-		*dst = out + 4;
-		return true;
-	}
-
 	if (out < end)
 		*out = '\\';
 	++out;
@@ -449,20 +424,17 @@ static bool escape_hex(unsigned char c, char **dst, char *end)
  * it if needs.
  *
  * Return:
- * The amount of the characters processed to the destination buffer, or
- * %-ENOMEM if the size of buffer is not enough to put an escaped character is
- * returned.
- *
- * Even in the case of error @dst pointer will be updated to point to the byte
- * after the last processed character.
+ * The total size of the escaped output that would be generated for
+ * the given input and flags. To check whether the output was
+ * truncated, compare the return value to osz. There is room left in
+ * dst for a '\0' terminator if and only if ret < osz.
  */
-int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
+int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
 		      unsigned int flags, const char *esc)
 {
-	char *p = *dst;
+	char *p = dst;
 	char *end = p + osz;
 	bool is_dict = esc && *esc;
-	int ret;
 
 	while (isz--) {
 		unsigned char c = *src++;
@@ -502,13 +474,6 @@ int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
 		escape_passthrough(c, &p, end);
 	}
 
-	if (p > end) {
-		*dst = end;
-		return -ENOMEM;
-	}
-
-	ret = p - *dst;
-	*dst = p;
-	return ret;
+	return p - dst;
 }
 EXPORT_SYMBOL(string_escape_mem);
diff --git a/lib/test-string_helpers.c b/lib/test-string_helpers.c
index ab0d30e1e18f..8e376efd88a4 100644
--- a/lib/test-string_helpers.c
+++ b/lib/test-string_helpers.c
@@ -260,16 +260,28 @@ static __init const char *test_string_find_match(const struct test_string_2 *s2,
 	return NULL;
 }
 
+static __init void
+test_string_escape_overflow(const char *in, int p, unsigned int flags, const char *esc,
+			    int q_test, const char *name)
+{
+	int q_real;
+
+	q_real = string_escape_mem(in, p, NULL, 0, flags, esc);
+	if (q_real != q_test)
+		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
+			name, flags, q_test, q_real);
+}
+
 static __init void test_string_escape(const char *name,
 				      const struct test_string_2 *s2,
 				      unsigned int flags, const char *esc)
 {
-	int q_real = 512;
-	char *out_test = kmalloc(q_real, GFP_KERNEL);
-	char *out_real = kmalloc(q_real, GFP_KERNEL);
+	size_t out_size = 512;
+	char *out_test = kmalloc(out_size, GFP_KERNEL);
+	char *out_real = kmalloc(out_size, GFP_KERNEL);
 	char *in = kmalloc(256, GFP_KERNEL);
-	char *buf = out_real;
 	int p = 0, q_test = 0;
+	int q_real;
 
 	if (!out_test || !out_real || !in)
 		goto out;
@@ -301,29 +313,19 @@ static __init void test_string_escape(const char *name,
 		q_test += len;
 	}
 
-	q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
+	q_real = string_escape_mem(in, p, out_real, out_size, flags, esc);
 
 	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test,
 			      q_test);
+
+	test_string_escape_overflow(in, p, flags, esc, q_test, name);
+
 out:
 	kfree(in);
 	kfree(out_real);
 	kfree(out_test);
 }
 
-static __init void test_string_escape_nomem(void)
-{
-	char *in = "\eb \\C\007\"\x90\r]";
-	char out[64], *buf = out;
-	int rc = -ENOMEM, ret;
-
-	ret = string_escape_str_any_np(in, &buf, strlen(in), NULL);
-	if (ret == rc)
-		return;
-
-	pr_err("Test 'escape nomem' failed: got %d instead of %d\n", ret, rc);
-}
-
 static int __init test_string_helpers_init(void)
 {
 	unsigned int i;
@@ -342,8 +344,6 @@ static int __init test_string_helpers_init(void)
 	for (i = 0; i < (ESCAPE_ANY_NP | ESCAPE_HEX) + 1; i++)
 		test_string_escape("escape 1", escape1, i, TEST_STRING_2_DICT_1);
 
-	test_string_escape_nomem();
-
 	return -EINVAL;
 }
 module_init(test_string_helpers_init);
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index a1b6487c6710..9651686f3b42 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1241,8 +1241,12 @@ char *escaped_string(char *buf, char *end, u8 *addr, struct printf_spec spec,
 
 	len = spec.field_width < 0 ? 1 : spec.field_width;
 
-	/* Ignore the error. We print as many characters as we can */
-	string_escape_mem(addr, len, &buf, end - buf, flags, NULL);
+	/*
+	 * string_escape_mem() writes as many characters as it can to
+	 * the given buffer, and returns the total size of the output
+	 * had the buffer been big enough.
+	 */
+	buf += string_escape_mem(addr, len, buf, buf < end ? end - buf : 0, flags, NULL);
 
 	return buf;
 }
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 33fb105d4352..22c4418057f4 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1068,12 +1068,14 @@ void qword_add(char **bpp, int *lp, char *str)
 {
 	char *bp = *bpp;
 	int len = *lp;
-	int ret;
+	int ret, written;
 
 	if (len < 0) return;
 
-	ret = string_escape_str(str, &bp, len, ESCAPE_OCTAL, "\\ \n\t");
-	if (ret < 0 || ret == len)
+	ret = string_escape_str(str, bp, len, ESCAPE_OCTAL, "\\ \n\t");
+	written = min(ret, len);
+	bp += written;
+	if (ret >= len)
 		len = -1;
 	else {
 		len -= ret;
-- 
2.1.3

