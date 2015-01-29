Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga14.intel.com ([192.55.52.115]:3905 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbbA2N3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jan 2015 08:29:39 -0500
Message-ID: <1422538178.31903.325.camel@linux.intel.com>
Subject: Re: [PATCH v2 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Thu, 29 Jan 2015 15:29:38 +0200
In-Reply-To: <1422525801-26560-4-git-send-email-linux@rasmusvillemoes.dk>
References: <1422451543-12401-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1422525801-26560-4-git-send-email-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2015-01-29 at 11:03 +0100, Rasmus Villemoes wrote:

Thanks for an update.
Few comments below.

> The current semantics of string_escape_mem are inadequate for one of
> its two current users, vsnprintf(). If that is to honour its contract,
> it must know how much space would be needed for the entire escaped
> buffer, and string_escape_mem provides no way of obtaining that (short
> of allocating a large enough buffer (~4 times input string) to let it
> play with, and that's definitely a big no-no inside vsnprintf).
> 
> So change the semantics for string_escape_mem to be more
> snprintf-like: Return the size of the output that would be generated
> if the destination buffer was big enough, but of course still only
> write to the part of dst it is allowed to, and don't do
> '\0'-termination. It is then up to the caller to detect whether output
> was truncated and to append a '\0' if desired.
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
> when osz==0.

'osz == 0'

> 
> In net/sunrpc/cache.c, I think qword_add still has the same
> semantics. Someone should definitely double-check this.


> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  include/linux/string_helpers.h | 10 +++++-----
>  lib/string_helpers.c           | 25 ++++++++-----------------
>  lib/test-string_helpers.c      | 37 ++++++++++++++++---------------------
>  lib/vsprintf.c                 |  2 +-
>  net/sunrpc/cache.c             |  8 +++++---
>  5 files changed, 35 insertions(+), 47 deletions(-)
> 
> diff --git a/include/linux/string_helpers.h b/include/linux/string_helpers.h
> index 6eb567ac56bc..7a082aa183a8 100644
> --- a/include/linux/string_helpers.h
> +++ b/include/linux/string_helpers.h
> @@ -47,22 +47,22 @@ static inline int string_unescape_any_inplace(char *buf)
>  #define ESCAPE_ANY_NP		(ESCAPE_ANY | ESCAPE_NP)
>  #define ESCAPE_HEX		0x20
>  
> -int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
> +size_t string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
>  		unsigned int flags, const char *esc);
>  
> -static inline int string_escape_mem_any_np(const char *src, size_t isz,
> -		char **dst, size_t osz, const char *esc)
> +static inline size_t string_escape_mem_any_np(const char *src, size_t isz,
> +		char *dst, size_t osz, const char *esc)
>  {
>  	return string_escape_mem(src, isz, dst, osz, ESCAPE_ANY_NP, esc);
>  }
>  
> -static inline int string_escape_str(const char *src, char **dst, size_t sz,
> +static inline size_t string_escape_str(const char *src, char *dst, size_t sz,
>  		unsigned int flags, const char *esc)
>  {
>  	return string_escape_mem(src, strlen(src), dst, sz, flags, esc);
>  }
>  
> -static inline int string_escape_str_any_np(const char *src, char **dst,
> +static inline size_t string_escape_str_any_np(const char *src, char *dst,
>  		size_t sz, const char *esc)
>  {
>  	return string_escape_str(src, dst, sz, ESCAPE_ANY_NP, esc);
> diff --git a/lib/string_helpers.c b/lib/string_helpers.c
> index e14dd8555760..05d4a583d20e 100644
> --- a/lib/string_helpers.c
> +++ b/lib/string_helpers.c
> @@ -414,20 +414,17 @@ static bool escape_hex(unsigned char c, char **dst, char *end)
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
> -		      unsigned int flags, const char *esc)
> +size_t string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
> +			 unsigned int flags, const char *esc)

I prefer to leave the prototype the same. int for return is okay. dst
should be updated accordingly.

>  {
> -	char *p = *dst;
> +	char *p = dst;
>  	char *end = p + osz;
>  	bool is_dict = esc && *esc;
> -	int ret;
>  
>  	while (isz--) {
>  		unsigned char c = *src++;
> @@ -466,13 +463,7 @@ int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
>  
>  		escape_passthrough(c, &p, end);
>  	}
> -	if (p > end) {
> -		*dst = end;
> -		return -ENOMEM;
> -	}
>  
> -	ret = p - *dst;
> -	*dst = p;
> -	return ret;
> +	return p - dst;
>  }
>  EXPORT_SYMBOL(string_escape_mem);
> diff --git a/lib/test-string_helpers.c b/lib/test-string_helpers.c
> index ab0d30e1e18f..5f95114a2f86 100644
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
> -	int p = 0, q_test = 0;
> +	size_t p = 0, q_test = 0;
> +	size_t q_real;
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
> +		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %zu, got %zu\n",
> +			name, flags, q_test, q_real);
> +	if (memchr_inv(out_real, 'Z', out_size))
> +		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
> +			name);

Could it be a part of nomem test still?

> +
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
> index 3568e3906777..d02c394b5b58 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -1160,7 +1160,7 @@ char *escaped_string(char *buf, char *end, u8 *addr, struct printf_spec spec,
>  	len = spec.field_width < 0 ? 1 : spec.field_width;
>  
>  	/* Ignore the error. We print as many characters as we can */
> -	string_escape_mem(addr, len, &buf, end - buf, flags, NULL);
> +	buf += string_escape_mem(addr, len, buf, buf < end ? end - buf : 0, flags, NULL);

So, the problem is when we have end < buf, right?
How about to move this check out of the call parameters?

[Keep in might the original prototype]

if (buf < end)
 string_escape_mem(addr, len, &buf, end - buf, flags, NULL);
else
 string_escape_mem(addr, len, &buf, 0, flags, NULL);

I don't know if it's a good idea to check this inside
string_escape_mem(). Possible not.

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

For this part the comment from J. Bruce is needed.

There is one more user, i.e. fs/proc/array.c::task_name().

In all of them we have to amend a prepend commentary. Like changing
'Ignore the error' to 'Ignore the overflow'.

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

