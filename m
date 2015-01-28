Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:32959 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbbA1Ud0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2015 15:33:26 -0500
Received: by mail-lb0-f174.google.com with SMTP id f15so21214801lbj.5
        for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 12:33:25 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: [PATCH 2/2] string_helpers: Change semantics of string_escape_mem
Date: Wed, 28 Jan 2015 14:25:42 +0100
Message-Id: <1422451543-12401-3-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1422451543-12401-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1422451543-12401-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current semantics of string_escape_mem are inadequate for one of
its two current users, vsnprintf(). If that is to honour its contract,
it must know how much space would be needed for the entire escaped
buffer, and string_escape_mem provides no way of obtaining that (short
of allocating a large enough buffer (~4 times input string) to let it
play with, and that's definitely a big no-no inside vsnprintf).

So change the semantics for string_escape_mem to be more
snprintf-like: Return the size of the output that would be generated
if the destination buffer was big enough, but of course still only
write to the part of dst it is allowed to, and don't do
'\0'-termination. It is then up to the caller to detect whether output
was truncated and to append a '\0' if desired.

This also fixes a bug in the escaped_string() helper function, which
used to unconditionally pass a length of "end-buf" to
string_escape_mem(); since the latter doesn't check osz for being
insanely large, it would happily write to dst. For example,
kasprintf(GFP_KERNEL, "something and then %pE", ...); is an easy way
to trigger an oops.

The patch is somewhat larger than I'd like, but I couldn't find a way
of splitting it into smaller pieces. Implementation-wise, I changed
the various escape_* helpers to return true if they handled the
character, updating dst appropriately, false otherwise. Maybe there's
a more elegant way, but this seems to work.

In test-string_helpers.c, I removed the now meaningless -ENOMEM test,
and replaced it with testing for getting the expected return value
even if the buffer is too small. Also ensure that nothing is written
when osz==0.

In net/sunrpc/cache.c, I think qword_add still has the same
semantics. Someone should definitely double-check this.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/string_helpers.h |  10 +--
 lib/string_helpers.c           | 195 ++++++++++++++++-------------------------
 lib/test-string_helpers.c      |  37 ++++----
 lib/vsprintf.c                 |   2 +-
 net/sunrpc/cache.c             |   8 +-
 5 files changed, 101 insertions(+), 151 deletions(-)

diff --git a/include/linux/string_helpers.h b/include/linux/string_helpers.h
index 6eb567ac56bc..7a082aa183a8 100644
--- a/include/linux/string_helpers.h
+++ b/include/linux/string_helpers.h
@@ -47,22 +47,22 @@ static inline int string_unescape_any_inplace(char *buf)
 #define ESCAPE_ANY_NP		(ESCAPE_ANY | ESCAPE_NP)
 #define ESCAPE_HEX		0x20
 
-int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
+size_t string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
 		unsigned int flags, const char *esc);
 
-static inline int string_escape_mem_any_np(const char *src, size_t isz,
-		char **dst, size_t osz, const char *esc)
+static inline size_t string_escape_mem_any_np(const char *src, size_t isz,
+		char *dst, size_t osz, const char *esc)
 {
 	return string_escape_mem(src, isz, dst, osz, ESCAPE_ANY_NP, esc);
 }
 
-static inline int string_escape_str(const char *src, char **dst, size_t sz,
+static inline size_t string_escape_str(const char *src, char *dst, size_t sz,
 		unsigned int flags, const char *esc)
 {
 	return string_escape_mem(src, strlen(src), dst, sz, flags, esc);
 }
 
-static inline int string_escape_str_any_np(const char *src, char **dst,
+static inline size_t string_escape_str_any_np(const char *src, char *dst,
 		size_t sz, const char *esc)
 {
 	return string_escape_str(src, dst, sz, ESCAPE_ANY_NP, esc);
diff --git a/lib/string_helpers.c b/lib/string_helpers.c
index 58b78ba57439..288bacca74aa 100644
--- a/lib/string_helpers.c
+++ b/lib/string_helpers.c
@@ -243,28 +243,20 @@ int string_unescape(char *src, char *dst, size_t size, unsigned int flags)
 }
 EXPORT_SYMBOL(string_unescape);
 
-static int escape_passthrough(unsigned char c, char **dst, size_t *osz)
+static bool escape_passthrough(unsigned char c, char **dst, char *end)
 {
 	char *out = *dst;
 
-	if (*osz < 1)
-		return -ENOMEM;
-
-	*out++ = c;
-
-	*dst = out;
-	*osz -= 1;
-
-	return 1;
+	if (out < end)
+		*out = c;
+	*dst = out + 1;
+	return true;
 }
 
-static int escape_space(unsigned char c, char **dst, size_t *osz)
+static bool escape_space(unsigned char c, char **dst, char *end)
 {
-	char *out = *dst;
 	unsigned char to;
-
-	if (*osz < 2)
-		return -ENOMEM;
+	char *out = *dst;
 
 	switch (c) {
 	case '\n':
@@ -283,25 +275,22 @@ static int escape_space(unsigned char c, char **dst, size_t *osz)
 		to = 'f';
 		break;
 	default:
-		return 0;
+		return false;
 	}
 
-	*out++ = '\\';
-	*out++ = to;
-
-	*dst = out;
-	*osz -= 2;
+	if (out + 0 < end)
+		out[0] = '\\';
+	if (out + 1 < end)
+		out[1] = to;
 
-	return 1;
+	*dst = out + 2;
+	return true;
 }
 
-static int escape_special(unsigned char c, char **dst, size_t *osz)
+static bool escape_special(unsigned char c, char **dst, char *end)
 {
-	char *out = *dst;
 	unsigned char to;
-
-	if (*osz < 2)
-		return -ENOMEM;
+	char *out = *dst;
 
 	switch (c) {
 	case '\\':
@@ -314,71 +303,66 @@ static int escape_special(unsigned char c, char **dst, size_t *osz)
 		to = 'e';
 		break;
 	default:
-		return 0;
+		return false;
 	}
 
-	*out++ = '\\';
-	*out++ = to;
+	if (out + 0 < end)
+		out[0] = '\\';
+	if (out + 1 < end)
+		out[1] = to;
 
-	*dst = out;
-	*osz -= 2;
-
-	return 1;
+	*dst = out + 2;
+	return true;
 }
 
-static int escape_null(unsigned char c, char **dst, size_t *osz)
+static bool escape_null(unsigned char c, char **dst, char *end)
 {
 	char *out = *dst;
 
-	if (*osz < 2)
-		return -ENOMEM;
-
 	if (c)
-		return 0;
-
-	*out++ = '\\';
-	*out++ = '0';
+		return false;
 
-	*dst = out;
-	*osz -= 2;
+	if (out + 0 < end)
+		out[0] = '\\';
+	if (out + 1 < end)
+		out[1] = '0';
 
-	return 1;
+	*dst = out + 2;
+	return true;
 }
 
-static int escape_octal(unsigned char c, char **dst, size_t *osz)
+static bool escape_octal(unsigned char c, char **dst, char *end)
 {
 	char *out = *dst;
 
-	if (*osz < 4)
-		return -ENOMEM;
-
-	*out++ = '\\';
-	*out++ = ((c >> 6) & 0x07) + '0';
-	*out++ = ((c >> 3) & 0x07) + '0';
-	*out++ = ((c >> 0) & 0x07) + '0';
+	if (out + 0 < end)
+		out[0] = '\\';
+	if (out + 1 < end)
+		out[1] = ((c >> 6) & 0x07) + '0';
+	if (out + 2 < end)
+		out[2] = ((c >> 3) & 0x07) + '0';
+	if (out + 3 < end)
+		out[3] = ((c >> 0) & 0x07) + '0';
 
-	*dst = out;
-	*osz -= 4;
-
-	return 1;
+	*dst = out + 4;
+	return true;
 }
 
-static int escape_hex(unsigned char c, char **dst, size_t *osz)
+static bool escape_hex(unsigned char c, char **dst, char *end)
 {
 	char *out = *dst;
 
-	if (*osz < 4)
-		return -ENOMEM;
+	if (out + 0 < end)
+		out[0] = '\\';
+	if (out + 1 < end)
+		out[1] = 'x';
+	if (out + 2 < end)
+		out[2] = hex_asc_hi(c);
+	if (out + 3 < end)
+		out[3] = hex_asc_lo(c);
 
-	*out++ = '\\';
-	*out++ = 'x';
-	*out++ = hex_asc_hi(c);
-	*out++ = hex_asc_lo(c);
-
-	*dst = out;
-	*osz -= 4;
-
-	return 1;
+	*dst = out + 4;
+	return true;
 }
 
 /**
@@ -430,19 +414,17 @@ static int escape_hex(unsigned char c, char **dst, size_t *osz)
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
-		      unsigned int flags, const char *esc)
+size_t string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
+			 unsigned int flags, const char *esc)
 {
-	char *out = *dst, *p = out;
+	char *p = dst;
+	char *end = dst + osz;
 	bool is_dict = esc && *esc;
-	int ret = 0;
 
 	while (isz--) {
 		unsigned char c = *src++;
@@ -462,55 +444,26 @@ int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
 		    (is_dict && !strchr(esc, c))) {
 			/* do nothing */
 		} else {
-			if (flags & ESCAPE_SPACE) {
-				ret = escape_space(c, &p, &osz);
-				if (ret < 0)
-					break;
-				if (ret > 0)
-					continue;
-			}
-
-			if (flags & ESCAPE_SPECIAL) {
-				ret = escape_special(c, &p, &osz);
-				if (ret < 0)
-					break;
-				if (ret > 0)
-					continue;
-			}
-
-			if (flags & ESCAPE_NULL) {
-				ret = escape_null(c, &p, &osz);
-				if (ret < 0)
-					break;
-				if (ret > 0)
-					continue;
-			}
+			if (flags & ESCAPE_SPACE && escape_space(c, &p, end))
+				continue;
+
+			if (flags & ESCAPE_SPECIAL && escape_special(c, &p, end))
+				continue;
+
+			if (flags & ESCAPE_NULL && escape_null(c, &p, end))
+				continue;
 
 			/* ESCAPE_OCTAL and ESCAPE_HEX always go last */
-			if (flags & ESCAPE_OCTAL) {
-				ret = escape_octal(c, &p, &osz);
-				if (ret < 0)
-					break;
+			if (flags & ESCAPE_OCTAL && escape_octal(c, &p, end))
 				continue;
-			}
-			if (flags & ESCAPE_HEX) {
-				ret = escape_hex(c, &p, &osz);
-				if (ret < 0)
-					break;
+
+			if (flags & ESCAPE_HEX && escape_hex(c, &p, end))
 				continue;
-			}
 		}
 
-		ret = escape_passthrough(c, &p, &osz);
-		if (ret < 0)
-			break;
+		escape_passthrough(c, &p, end);
 	}
 
-	*dst = p;
-
-	if (ret < 0)
-		return ret;
-
-	return p - out;
+	return p - dst;
 }
 EXPORT_SYMBOL(string_escape_mem);
diff --git a/lib/test-string_helpers.c b/lib/test-string_helpers.c
index ab0d30e1e18f..5f95114a2f86 100644
--- a/lib/test-string_helpers.c
+++ b/lib/test-string_helpers.c
@@ -264,12 +264,12 @@ static __init void test_string_escape(const char *name,
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
-	int p = 0, q_test = 0;
+	size_t p = 0, q_test = 0;
+	size_t q_real;
 
 	if (!out_test || !out_real || !in)
 		goto out;
@@ -301,29 +301,26 @@ static __init void test_string_escape(const char *name,
 		q_test += len;
 	}
 
-	q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
+	q_real = string_escape_mem(in, p, out_real, out_size, flags, esc);
 
 	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test,
 			      q_test);
+
+	memset(out_real, 'Z', out_size);
+	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
+	if (q_real != q_test)
+		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %zu, got %zu\n",
+			name, flags, q_test, q_real);
+	if (memchr_inv(out_real, 'Z', out_size))
+		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
+			name);
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
@@ -342,8 +339,6 @@ static int __init test_string_helpers_init(void)
 	for (i = 0; i < (ESCAPE_ANY_NP | ESCAPE_HEX) + 1; i++)
 		test_string_escape("escape 1", escape1, i, TEST_STRING_2_DICT_1);
 
-	test_string_escape_nomem();
-
 	return -EINVAL;
 }
 module_init(test_string_helpers_init);
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 0d57be58448f..a3e474f9957f 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1165,7 +1165,7 @@ char *escaped_string(char *buf, char *end, u8 *addr, struct printf_spec spec,
 	len = spec.field_width < 0 ? 1 : spec.field_width;
 
 	/* Ignore the error. We print as many characters as we can */
-	string_escape_mem(addr, len, &buf, end - buf, flags, NULL);
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

