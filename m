Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f49.google.com ([209.85.215.49]:42831 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933297AbbBJNCW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2015 08:02:22 -0500
Received: by labhs14 with SMTP id hs14so20048120lab.9
        for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 05:02:21 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH v3 3/3] lib/string_helpers.c: Change semantics of string_escape_mem
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	<1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	<1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
	<1423571552.31903.468.camel@linux.intel.com>
Date: Tue, 10 Feb 2015 14:02:19 +0100
In-Reply-To: <1423571552.31903.468.camel@linux.intel.com> (Andy Shevchenko's
	message of "Tue, 10 Feb 2015 14:32:32 +0200")
Message-ID: <87386dj4x0.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10 2015, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:

> On Tue, 2015-02-10 at 00:44 +0100, Rasmus Villemoes wrote:
>> The current semantics of string_escape_mem are inadequate for one of
>> its current users, vsnprintf(). If that is to honour its contract, it
>> must know how much space would be needed for the entire escaped
>> buffer, and string_escape_mem provides no way of obtaining that (short
>> of allocating a large enough buffer (~4 times input string) to let it
>> play with, and that's definitely a big no-no inside vsnprintf).
>> 
>> So change the semantics for string_escape_mem to be more
>> snprintf-like: Return the size of the output that would be generated
>> if the destination buffer was big enough, but of course still only
>> write to the part of dst it is allowed to, and don't do
>> '\0'-termination. It is then up to the caller to detect whether output
>> was truncated and to append a '\0' if desired. Also, we must output
>> partial escape sequences, otherwise a call such as snprintf(buf, 3,
>> "%1pE", "\123") would cause printf to write a \0 to buf[2] but leaving
>> buf[0] and buf[1] with whatever they previously contained.
>> 
>> This also fixes a bug in the escaped_string() helper function, which
>> used to unconditionally pass a length of "end-buf" to
>> string_escape_mem(); since the latter doesn't check osz for being
>> insanely large, it would happily write to dst. For example,
>> kasprintf(GFP_KERNEL, "something and then %pE", ...); is an easy way
>> to trigger an oops.
>> 
>> In test-string_helpers.c, I removed the now meaningless -ENOMEM test,
>> and replaced it with testing for getting the expected return value
>> even if the buffer is too small. Also ensure that nothing is written
>> when osz == 0.
>> 
>> In net/sunrpc/cache.c, I think qword_add still has the same
>> semantics. Someone should definitely double-check this.
>
> Thanks for an update. My comments below.
> After addressing 'em, wrt changes to patch 2/3, take my 
> Acked-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
>
> for all parts except net/sunrpc/cache.c.
>
>> 
>> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>> ---
>> index ab0d30e1e18f..5f759c3c2f60 100644
>> --- a/lib/test-string_helpers.c
>> +++ b/lib/test-string_helpers.c
>> @@ -264,12 +264,12 @@ static __init void test_string_escape(const char *name,
>>  				      const struct test_string_2 *s2,
>>  				      unsigned int flags, const char *esc)
>>  {
>> -	int q_real = 512;
>> -	char *out_test = kmalloc(q_real, GFP_KERNEL);
>> -	char *out_real = kmalloc(q_real, GFP_KERNEL);
>> +	size_t out_size = 512;
>> +	char *out_test = kmalloc(out_size, GFP_KERNEL);
>> +	char *out_real = kmalloc(out_size, GFP_KERNEL);
>>  	char *in = kmalloc(256, GFP_KERNEL);
>> -	char *buf = out_real;
>>  	int p = 0, q_test = 0;
>> +	int q_real;
>>  
>>  	if (!out_test || !out_real || !in)
>>  		goto out;
>> @@ -301,29 +301,26 @@ static __init void test_string_escape(const char *name,
>>  		q_test += len;
>>  	}
>>  
>> -	q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
>> +	q_real = string_escape_mem(in, p, out_real, out_size, flags, esc);
>>  
>>  	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test,
>>  			      q_test);
>> +
>> +	memset(out_real, 'Z', out_size);
>> +	q_real = string_escape_mem(in, p, out_real, 0, flags, esc);
>> +	if (q_real != q_test)
>> +		pr_warn("Test '%s' failed: flags = %u, osz = 0, expected %d, got %d\n",
>> +			name, flags, q_test, q_real);
>> +	if (memchr_inv(out_real, 'Z', out_size))
>> +		pr_warn("Test '%s' failed: osz = 0 but string_escape_mem wrote to the buffer\n",
>> +			name);
>> +
>
> So, why couldn't we split this to separate test case? It seems I already
> pointed this out.
>

This actually provides better coverage since we do this for all the
"positive" test cases, instead of just the single ad hoc case done previously. Of
course the added lines could be factored into a separate helper, but
there's quite a lot of state to pass, so I thought this would actually
be simpler - note how the two string_escape_mem calls are easily seen to
be identical except for the outsize argument.

It may already be too late for the merge window, but I didn't want to
spend too much time on these mostly cosmetic details (that also goes for
the 3- versus 2-line issue).

Rasmus

