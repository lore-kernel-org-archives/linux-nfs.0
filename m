Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34753 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdGNUuc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 16:50:32 -0400
Message-ID: <1500065429.3755.3.camel@gmail.com>
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
Date: Fri, 14 Jul 2017 16:50:29 -0400
In-Reply-To: <1500064716.3755.1.camel@gmail.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
         <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
         <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
         <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com>
         <CA+55aFyH-bL6NhX_jvqS50L4G5Y1QBgYhdiX9d1OH8Ze25EU6w@mail.gmail.com>
         <1500064716.3755.1.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> My initial patch used strlcpy there, because I wasn't aware of strscpy
> before it was suggested:
> 
> http://www.openwall.com/lists/kernel-hardening/2017/05/04/11
> 
> I was wrong to move it to strscpy. It could be switched back to
> strlcpy
> again unless the kernel considers the count parameter to be a
> guarantee
> that could be leveraged in the future. Using the fortified strlen +
> memcpy would provide the improvement that strscpy was meant to provide
> there over strlcpy.

Similarly, the FORTIFY_SOURCE strcat uses strlcat with the assumption
that the count parameter is a limit, not a guarantee for a optimization.
There's only a C implementation and it currently doesn't, but if it's
meant to be a guarantee then the strcat needs to be changed too.

I'll make a fix moving away both from the existing functions.
