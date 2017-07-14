Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33725 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdGNVB5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 17:01:57 -0400
Message-ID: <1500066114.3755.5.camel@gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
From: Daniel Micay <danielmicay@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
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
Date: Fri, 14 Jul 2017 17:01:54 -0400
In-Reply-To: <CA+55aFxN4D4MJpNGYS+vbcMgb4KnHArnwsar58vvK_2gSoZQmQ@mail.gmail.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
         <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
         <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
         <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com>
         <CA+55aFyH-bL6NhX_jvqS50L4G5Y1QBgYhdiX9d1OH8Ze25EU6w@mail.gmail.com>
         <1500064716.3755.1.camel@gmail.com>
         <CA+55aFxN4D4MJpNGYS+vbcMgb4KnHArnwsar58vvK_2gSoZQmQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-07-14 at 13:50 -0700, Linus Torvalds wrote:
> On Fri, Jul 14, 2017 at 1:38 PM, Daniel Micay <danielmicay@gmail.com>
> wrote:
> > 
> > If strscpy treats the count parameter as a *guarantee* of the dest
> > size
> > rather than a limit,
> 
> No, it's a *limit*.
> 
> And by a *limit*, I mean that we know that we can access both source
> and destination within that limit.

FORTIFY_SOURCE needs to be able to pass a limit without implying that
there's a minimum. That's the distinction I was trying to make. It's
wrong to use anything where it's interpreted as a minimum here. Using
__builtin_object_size(ptr, 0) vs. __builtin_object_size(ptr, 1) doesn't
avoid the problem. __builtin_object_size(ptr, 1) returns a maximum among
the possible buffer sizes just like 0. It's just stricter, i.e. catches
intra-object overflow, which isn't desirable for the first take since it
will cause compatibility issues. There's code using memcpy,
copy_to_user, etc. to read / write multiple fields with a pointer to the
first one passed as the source / destination.

> > My initial patch used strlcpy there, because I wasn't aware of
> > strscpy
> > before it was suggested:
> 
> Since I'm looking at this, I note that the "strlcpy()" code is
> complete garbage too, and has that same
> 
>      p_size == (size_t)-1 && q_size == (size_t)-1
> 
> check which is wrong.  Of course, in strlcpy, q_size is never actually
> *used*, so the whole check seems bogus.

That check is only an optimization. __builtin_object_size always returns
a constant, and it's (size_t)-1 when no limit could be found.

The reason q_size isn't used is because it doesn't yet prevent read
overflow. The commit message mentions that among the current limitations
along with __builtin_object_size(ptr, 1).

> But no, strlcpy() is complete garbage, and should never be used. It is
> truly a shit interface, and anybody who uses it is by definition
> buggy.
> 
> Why? Because the return value of "strlcpy()" is defined to be ignoring
> the limit, so you FUNDAMENTALLY must not use that thing on untrusted
> source strings.
> 
> But since the whole *point* of people using it is for untrusted
> sources, it by definition is garbage.
> 
> Ergo: don't use strlcpy(). It's unbelievable crap. It's wrong. There's
> a reason we defined "strscpy()" as the way to do safe copies
> (strncpy(), of course, is broken for both lack of NUL termination
> _and_ for excessive NUL termination when a NUL did exist).

Sure, it doesn't prevent read overflow (but it's not worse than strcpy,
which is the purpose) which is why I said this:

"The fortified string functions should place a limit on reads from the
source. For strcat/strcpy, these could just be a variant of strlcat /
strlcpy using the size limit as a bound on both the source and
destination, with the return value only reporting whether truncation
occurred rather than providing the source length. It would be an easier
API for developers to use too and not that it really matters but it
would be more efficient for the case where truncation is intended."

That's why strscpy was suggested and I switched to that + updated the
commit message to only mention strcat, but it's wrong to use it here
because __builtin_object_size(p, 0) / __builtin_object_size(p, 1) are
only a guaranteed maximum length with no minimum guarantee.
