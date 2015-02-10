Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:39772 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbbBJMcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2015 07:32:36 -0500
Message-ID: <1423571552.31903.468.camel@linux.intel.com>
Subject: Re: [PATCH v3 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Tue, 10 Feb 2015 14:32:32 +0200
In-Reply-To: <1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-02-10 at 00:44 +0100, Rasmus Villemoes wrote:
> The current semantics of string_escape_mem are inadequate for one of
> its current users, vsnprintf(). If that is to honour its contract, it
> must know how much space would be needed for the entire escaped
> buffer, and string_escape_mem provides no way of obtaining that (short
> of allocating a large enough buffer (~4 times input string) to let it
> play with, and that's definitely a big no-no inside vsnprintf).
> 
> So change the semantics for string_escape_mem to be more
> snprintf-like: Return the size of the output that would be generated
> if the destination buffer was big enough, but of course still only
> write to the part of dst it is allowed to, and don't do
> '\0'-termination. It is then up to the caller to detect whether output
> was truncated and to append a '\0' if desired. Also, we must output
> partial escape sequences, otherwise a call such as snprintf(buf, 3,
> "%1pE", "\123") would cause printf to write a \0 to buf[2] but leaving
> buf[0] and buf[1] with whatever they previously contained.
> 
> This also fixes a bug in the escaped_string() helper function, which
> used to unconditionally pass a length of "end-buf" to
> string_escape_mem(); since the latter doesn't check osz for being
> insanely large, it would happily write to dst. For example,
> kasprintf(GFP_KERNEL, "something and then %pE", ...); is an easy way
> to trigger an oops.
> 
> In test-string_helpers.c, I removed the now meaningless -ENOMEM test,
> and replaced it with testing for getting the expected return value
> even if the buffer is too small. Also ensure that nothing is written
> when osz == 0.
> 
> In net/sunrpc/cache.c, I think qword_add still has the same
> semantics. Someone should definitely double-check this.

Thanks for an update. My comments below.
After addressing 'em, wrt changes to patch 2/3, take my 
Acked-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

for all parts except net/sunrpc/cache.c.

> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  include/linux/string_helpers.h |  8 ++++----
>  lib/string_helpers.c           | 39 +++++++--------------------------------
>  lib/test-string_helpers.c      | 35 +++++++++++++++--------------------
>  lib/vsprintf.c                 |  8 ++++++--
>  net/sunrpc/cache.c             |  8 +++++---
>  5 files changed, 37 insertions(+), 61 deletions(-)
> 
> diff --git a/include/linux/string_helpers.h b/include/linux/string_helpers.h
> index 6eb567ac56bc..38a2a6f1fc76 100644
> --- a/include/linux/string_helpers.h
> +++ b/include/linux/string_helpers.h
> @@ -47,22 +47,22 @@ static inline int string_unescape_any_inplace(char *buf)
>  #define ESCAPE_ANY_NP		(ESCAPE_ANY | ESCAPE_NP)
>  #define ESCAPE_HEX		0x20
>  
> -int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
> +int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
>  		unsigned int flags, const char *esc);
>  
>  static inline int string_escape_mem_any_np(const char *src, size_t isz,
> -		char **dst, size_t osz, const char *esc)
> +		char *dst, size_t osz, const char *esc)
>  {
>  	return string_escape_mem(src, isz, dst, osz, ESCAPE_ANY_NP, esc);
>  }
>  
> -static inline int string_escape_str(const char *src, char **dst, size_t sz,
> +static inline int string_escape_str(const char *src, char *dst, size_t sz,
>  		unsigned int flags, const char *esc)
>  {
>  	return string_escape_mem(src, strlen(src), dst, sz, flags, esc);
>  }
>  
> -static inline int string_escape_str_any_np(const char *src, char **dst,
> +static inline int string_escape_str_any_np(const char *src, char *dst,
>  		size_t sz, const char *esc)
>  {
>  	return string_escape_str(src, dst, sz, ESCAPE_ANY_NP, esc);
> diff --git a/lib/string_helpers.c b/lib/string_helpers.c
> index 7e2fef1eb40e..df7fda90b333 100644
> --- a/lib/string_helpers.c
> +++ b/lib/string_helpers.c
> @@ -278,14 +278,11 @@ static bool escape_space(unsigned char c, char **dst, char *end)
>  		return false;
>  	}
>  
> -	if (out + 1 >= end)
> -		goto skip;
>  	if (out + 0 < end)
>  		out[0] = '\\';
>  	if (out + 1 < end)
>  		out[1] = to;
>  
> -skip:
>  	*dst = out + 2;
>  	return true;
>  }
> @@ -309,14 +306,11 @@ static bool escape_special(unsigned char c, char **dst, char *end)
>  		return false;
>  	}
>  
> -	if (out + 1 >= end)
> -		goto skip;
>  	if (out + 0 < end)
>  		out[0] = '\\';
>  	if (out + 1 < end)
>  		out[1] = to;
>  
> -skip:
>  	*dst = out + 2;
>  	return true;
>  }
> @@ -328,14 +322,11 @@ static bool escape_null(unsigned char c, char **dst, char *end)
>  	if (c)
>  		return false;
>  
> -	if (out + 1 >= end)
> -		goto skip;
>  	if (out + 0 < end)
>  		out[0] = '\\';
>  	if (out + 1 < end)
>  		out[1] = '0';
>  
> -skip:
>  	*dst = out + 2;
>  	return true;
>  }
> @@ -344,8 +335,6 @@ static bool escape_octal(unsigned char c, char **dst, char *end)
>  {
>  	char *out = *dst;
>  
> -	if (out + 3 >= end)
> -		goto skip;
>  	if (out + 0 < end)
>  		out[0] = '\\';
>  	if (out + 1 < end)
> @@ -355,7 +344,6 @@ static bool escape_octal(unsigned char c, char **dst, char *end)
>  	if (out + 3 < end)
>  		out[3] = ((c >> 0) & 0x07) + '0';
>  
> -skip:
>  	*dst = out + 4;
>  	return true;
>  }
> @@ -364,8 +352,6 @@ static bool escape_hex(unsigned char c, char **dst, char *end)
>  {
>  	char *out = *dst;
>  
> -	if (out + 3 >= end)
> -		goto skip;
>  	if (out + 0 < end)
>  		out[0] = '\\';
>  	if (out + 1 < end)
> @@ -375,7 +361,6 @@ static bool escape_hex(unsigned char c, char **dst, char *end)
>  	if (out + 3 < end)
>  		out[3] = hex_asc_lo(c);
>  
> -skip:
>  	*dst = out + 4;
>  	return true;
>  }
> @@ -429,20 +414,17 @@ skip:
>   * it if needs.
>   *
>   * Return:
> - * The amount of the characters processed to the destination buffer, or
> - * %-ENOMEM if the size of buffer is not enough to put an escaped character is
> - * returned.
> - *
> - * Even in the case of error @dst pointer will be updated to point to the byte
> - * after the last processed character.
> + * The total size of the escaped output that would be generated for
> + * the given input and flags. To check whether the output was
> + * truncated, compare the return value to osz. There is room left in
> + * dst for a '\0' terminator if and only if ret < osz.
>   */
> -int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
> +int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
>  		      unsigned int flags, const char *esc)
>  {
> -	char *p = *dst;
> +	char *p = dst;
>  	char *end = p + osz;
>  	bool is_dict = esc && *esc;
> -	int ret;
>  
>  	while (isz--) {
>  		unsigned char c = *src++;
> @@ -482,13 +464,6 @@ int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
>  		escape_passthrough(c, &p, end);
>  	}
>  
> -	if (p > end) {
> -		*dst = end;
> -		return -ENOMEM;
> -	}
> -
> -	ret = p - *dst;
> -	*dst = p;
> -	return ret;
> +	return p - dst;
>  }
>  EXPORT_SYMBOL(string_escape_mem);
> diff --git a/lib/test-string_helpers.c b/lib/test-string_helpers.c
> index ab0d30e1e18f..5f759c3c2f60 100644
> --- a/lib/test-string_helpers.c
> +++ b/lib/test-string_helpers.c
> @@ -264,12 +264,12 @@ static __init void test_string_escape(const char *name,
>  				      const struct test_string_2 *s2,
>  				      unsigned int flags, const char *esc)
>  {
> -	int q_real = 512;
> -	char *out_test = kmalloc(q_real, GFP_KERNEL);
> -	char *out_real = kmalloc(q_real, GFP_KERNEL);
> +	size_t out_size = 512;
> +	char *out_test = kmalloc(out_size, GFP_KERNEL);
> +	char *out_real = kmalloc(out_size, GFP_KERNEL);
>  	char *in = kmalloc(256, GFP_KERNEL);
> -	char *buf = out_real;
>  	int p = 0, q_test = 0;
> +	int q_real;
>  
>  	if (!out_test || !out_real || !in)
>  		goto out;
> @@ -301,29 +301,26 @@ static __init void test_string_escape(const char *name,
>  		q_test += len;
>  	}
>  
> -	q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
> +	q_real = string_escape_mem(in, p, out_real, out_size, flags, esc);
>  
>  	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test,
>  			      q_test);
> +
> +	memset(out_real, 'Z', out_size);
> +	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
> +	if (q_real != q_test)
> +		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
> +			name, flags, q_test, q_real);
> +	if (memchr_inv(out_real, 'Z', out_size))
> +		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
> +			name);
> +

So, why couldn't we split this to separate test case? It seems I already
pointed this out.

>  out:
>  	kfree(in);
>  	kfree(out_real);
>  	kfree(out_test);
>  }
>  
> -static __init void test_string_escape_nomem(void)
> -{
> -	char *in = "\eb \\C\007\"\x90\r]";
> -	char out[64], *buf = out;
> -	int rc = -ENOMEM, ret;
> -
> -	ret = string_escape_str_any_np(in, &buf, strlen(in), NULL);
> -	if (ret == rc)
> -		return;
> -
> -	pr_err("Test 'escape nomem' failed: got %d instead of %d\n", ret, rc);
> -}
> -
>  static int __init test_string_helpers_init(void)
>  {
>  	unsigned int i;
> @@ -342,8 +339,6 @@ static int __init test_string_helpers_init(void)
>  	for (i = 0; i < (ESCAPE_ANY_NP | ESCAPE_HEX) + 1; i++)
>  		test_string_escape("escape 1", escape1, i, TEST_STRING_2_DICT_1);
>  
> -	test_string_escape_nomem();
> -
>  	return -EINVAL;
>  }
>  module_init(test_string_helpers_init);
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 3568e3906777..58e1193eaa4b 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -1159,8 +1159,12 @@ char *escaped_string(char *buf, char *end, u8 *addr, struct printf_spec spec,
>  
>  	len = spec.field_width < 0 ? 1 : spec.field_width;
>  
> -	/* Ignore the error. We print as many characters as we can */
> -	string_escape_mem(addr, len, &buf, end - buf, flags, NULL);
> +	/*
> +	 * string_escape_mem writes as many characters as it can to

'string_escape_mem() writes…'

> +	 * the given buffer, and returns the total size of the output
> +	 * had the buffer been big enough.
> +	 */
> +	buf += string_escape_mem(addr, len, buf, buf < end ? end - buf : 0, flags, NULL);
>  
>  	return buf;
>  }
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 33fb105d4352..22c4418057f4 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1068,12 +1068,14 @@ void qword_add(char **bpp, int *lp, char *str)
>  {
>  	char *bp = *bpp;
>  	int len = *lp;
> -	int ret;
> +	int ret, written;
>  
>  	if (len < 0) return;
>  
> -	ret = string_escape_str(str, &bp, len, ESCAPE_OCTAL, "\\ \n\t");
> -	if (ret < 0 || ret == len)
> +	ret = string_escape_str(str, bp, len, ESCAPE_OCTAL, "\\ \n\t");
> +	written = min(ret, len);
> +	bp += written;
> +	if (ret >= len)
>  		len = -1;
>  	else {
>  		len -= ret;


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

