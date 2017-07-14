Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34491 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdGNX7E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 19:59:04 -0400
Message-ID: <1500076742.1208.2.camel@gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
From: Daniel Micay <danielmicay@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Kees Cook <keescook@chromium.org>
Cc: Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com
Date: Fri, 14 Jul 2017 19:59:02 -0400
In-Reply-To: <CA+55aFyH-bL6NhX_jvqS50L4G5Y1QBgYhdiX9d1OH8Ze25EU6w@mail.gmail.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
         <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
         <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
         <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com>
         <CA+55aFyH-bL6NhX_jvqS50L4G5Y1QBgYhdiX9d1OH8Ze25EU6w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I find "hardening" code that adds bugs to be particularly bad and
> ugly, the same way that I absolutely *hate* debugging code that turns
> out to make debugging impossible (we had that with the "better" stack
> tracing code that caused kernel panics to kill the machine entirely
> rather than show the backtrace, and I'm still bitter about it a decade
> after the fact).

Agree, it's very important for this code to be correct and the string
functions have some subtleties so it needs scrutiny. I messed up strcpy
between v1 and v2 trying to add a proper read overflow check. My fault
for not looking more closely at strscpy before adopting it based on my
misinterpretation of the API.

This is primarily a bug finding feature right now and it has gotten a
few fixed that actually matter (most were unimportant memcpy read past
end of string constant but not all). I don't think it has another bug
like this strscpy misuse itself, but there will need to be some more
fixes for minor read overflows, etc. elsewhere in the tree before it'll
actually make sense as a hardening feature because it can turn a benign
read overflow into a DoS via BUG(). I think it will be fine for 4.13,
but I definitely wouldn't propose 'default y' for a while, even if there
was no performance cost (and there is).

Fix for this issue is here in case anyone just looks only at this thread
(realized I should have passed send-email a reply id):

http://marc.info/?l=linux-fsdevel&m=150006772418003&w=2
