Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:32927 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdGNUuH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 16:50:07 -0400
MIME-Version: 1.0
In-Reply-To: <1500064716.3755.1.camel@gmail.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk> <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
 <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com> <CA+55aFyH-bL6NhX_jvqS50L4G5Y1QBgYhdiX9d1OH8Ze25EU6w@mail.gmail.com>
 <1500064716.3755.1.camel@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 14 Jul 2017 13:50:06 -0700
Message-ID: <CA+55aFxN4D4MJpNGYS+vbcMgb4KnHArnwsar58vvK_2gSoZQmQ@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
To: Daniel Micay <danielmicay@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Kees Cook <keescook@chromium.org>,
        Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 14, 2017 at 1:38 PM, Daniel Micay <danielmicay@gmail.com> wrote:
>
> If strscpy treats the count parameter as a *guarantee* of the dest size
> rather than a limit,

No, it's a *limit*.

And by a *limit*, I mean that we know that we can access both source
and destination within that limit.

> My initial patch used strlcpy there, because I wasn't aware of strscpy
> before it was suggested:

Since I'm looking at this, I note that the "strlcpy()" code is
complete garbage too, and has that same

     p_size == (size_t)-1 && q_size == (size_t)-1

check which is wrong.  Of course, in strlcpy, q_size is never actually
*used*, so the whole check seems bogus.

But no, strlcpy() is complete garbage, and should never be used. It is
truly a shit interface, and anybody who uses it is by definition
buggy.

Why? Because the return value of "strlcpy()" is defined to be ignoring
the limit, so you FUNDAMENTALLY must not use that thing on untrusted
source strings.

But since the whole *point* of people using it is for untrusted
sources, it by definition is garbage.

Ergo: don't use strlcpy(). It's unbelievable crap. It's wrong. There's
a reason we defined "strscpy()" as the way to do safe copies
(strncpy(), of course, is broken for both lack of NUL termination
_and_ for excessive NUL termination when a NUL did exist).

So quite frankly, this hardening code needs to be looked at again. And
no, if it uses "strlcpy()", then it's not hardering, it's just a pile
of crap.

Yes, I'm annoyed. I really get very very annoyed by "hardening" code
that does nothing of the kind.

                   Linus
