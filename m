Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34192 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdGNTFE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 15:05:04 -0400
MIME-Version: 1.0
In-Reply-To: <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com> <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 14 Jul 2017 12:05:02 -0700
Message-ID: <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
To: Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 14, 2017 at 7:25 AM, Dave Jones <davej@codemonkey.org.uk> wrote:
> On Thu, Jul 13, 2017 at 05:16:24PM -0400, Anna Schumaker wrote:
>  >
>  >   git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-1
>
> Since this landed, I'm seeing this during boot..
>
>  ==================================================================
>  BUG: KASAN: global-out-of-bounds in strscpy+0x4a/0x230
>  Read of size 8 at addr ffffffffb4eeaf20 by task nfsd/688

Is KASAN aware that strscpy() does the word-at-a-time optimistic reads
of the sources?

The problem may be that the source is initialized from the global
string "nfsd", and KASAN may be unhappy abotu the fact that we read 8
bytes from a 5-byte string (four plus NUL) as we do the word-at-a-time
strscpy..

That said, we do check the size first (because we also *write* 8 bytes
at a time), so maybe KASAN shouldn't even need to care.

Hmm. it really looks to me like this is actually a compiler bug (I'm
using current gcc in F26, which is gcc-7.1.1 - I'm assuming DaveJ is
the same).

This is the source code in __ip_map_lookup:

        struct ip_map ip;
     .....
        strcpy(ip.m_class, class);

and "m_class" is 8 bytes in size:

    struct ip_map {
    ...
            char                    m_class[8]; /* e.g. "nfsd" */
    ...

yet when I look at the generated code for __ip_map_lookup, I see

        movl    $32, %edx       #,
        movq    %r13, %rsi      # class,
        leaq    48(%rax), %rdi  #, tmp126
        call    strscpy #

what's the bug here? Look at that third argument - %rdx. It is
initialized to 32.

WTF?

The code to turn "strcpy()" into "strscpy()" should pick the *smaller*
of the two object sizes as the size argument. How the hell is that
size argument 32?

Am I missing something? DaveJ, do you see the same?

                       Linus
