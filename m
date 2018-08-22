Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf1-f67.google.com ([209.85.167.67]:46275 "EHLO
        mail-lf1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728660AbeHVPFZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Aug 2018 11:05:25 -0400
Received: by mail-lf1-f67.google.com with SMTP id e23-v6so1131020lfc.13
        for <linux-nfs@vger.kernel.org>; Wed, 22 Aug 2018 04:40:51 -0700 (PDT)
Subject: Re: [PATCH 1/4] string: try to find const-laundering bugs
To: Joe Perches <joe@perches.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-nfs@vger.kernel.org
References: <20180822110009.17583-1-linux@rasmusvillemoes.dk>
 <e28ec4d435200be4d10dc76b17e6a4af0d71b77e.camel@perches.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <9c463cc2-8385-6e1b-334b-367218b4440e@rasmusvillemoes.dk>
Date: Wed, 22 Aug 2018 13:40:48 +0200
MIME-Version: 1.0
In-Reply-To: <e28ec4d435200be4d10dc76b17e6a4af0d71b77e.camel@perches.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2018-08-22 13:07, Joe Perches wrote:
> On Wed, 2018-08-22 at 13:00 +0200, Rasmus Villemoes wrote:
>> This wraps strchr and friends in macros that ensure the return value has
>> type const char* if the passed-in string (which the return value points
>> into) also has type const char*. The (s)+0 thing is to force a const
>> char[] (e.g. a string literal) to decay to a const char* for the
>> __same_type comparison.
> []
>> diff --git a/include/linux/string.h b/include/linux/string.h
> []
>> +#define strchr(s, c) (						  \
>> +	__builtin_choose_expr(__same_type((s) + 0, const char *), \
>> +			      (const char *)strchr(s, c),	  \
>> +			      strchr(s, c)))
>> +#endif
> []
>> diff --git a/lib/string.c b/lib/string.c
> []
>> @@ -367,7 +367,7 @@ EXPORT_SYMBOL(strncmp);
>>   * @s: The string to be searched
>>   * @c: The character to search for
>>   */
>> -char *strchr(const char *s, int c)
>> +char *(strchr)(const char *s, int c)
> 
> I've tried to use this macro/function wrapping
> a few times before, but it seems that it's fairly
> unusual in the kernel.  I believe there may not
> be any current uses of that style.
> 
> A comment explaining the form might be useful.
> 

True. I dislike the more conventional #undef strchr approach, because
that would mean any other function in string.c that calls strchr and
happens to be defined after strchr() would not be 'instrumented'. It's
more a principle than a practical thing because, well, none of the
instrumented functions happen to be used by other functions in string.c.

Rasmus
