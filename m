Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0024.hostedemail.com ([216.40.44.24]:36666 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1728518AbeHVOhy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Aug 2018 10:37:54 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave03.hostedemail.com (Postfix) with ESMTP id 919FC180388D7
        for <linux-nfs@vger.kernel.org>; Wed, 22 Aug 2018 11:08:00 +0000 (UTC)
Message-ID: <e28ec4d435200be4d10dc76b17e6a4af0d71b77e.camel@perches.com>
Subject: Re: [PATCH 1/4] string: try to find const-laundering bugs
From: Joe Perches <joe@perches.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-nfs@vger.kernel.org
Date: Wed, 22 Aug 2018 04:07:56 -0700
In-Reply-To: <20180822110009.17583-1-linux@rasmusvillemoes.dk>
References: <20180822110009.17583-1-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-08-22 at 13:00 +0200, Rasmus Villemoes wrote:
> This wraps strchr and friends in macros that ensure the return value has
> type const char* if the passed-in string (which the return value points
> into) also has type const char*. The (s)+0 thing is to force a const
> char[] (e.g. a string literal) to decay to a const char* for the
> __same_type comparison.
[]
> diff --git a/include/linux/string.h b/include/linux/string.h
[]
> +#define strchr(s, c) (						  \
> +	__builtin_choose_expr(__same_type((s) + 0, const char *), \
> +			      (const char *)strchr(s, c),	  \
> +			      strchr(s, c)))
> +#endif
[]
> diff --git a/lib/string.c b/lib/string.c
[]
> @@ -367,7 +367,7 @@ EXPORT_SYMBOL(strncmp);
>   * @s: The string to be searched
>   * @c: The character to search for
>   */
> -char *strchr(const char *s, int c)
> +char *(strchr)(const char *s, int c)

I've tried to use this macro/function wrapping
a few times before, but it seems that it's fairly
unusual in the kernel.  I believe there may not
be any current uses of that style.

A comment explaining the form might be useful.
