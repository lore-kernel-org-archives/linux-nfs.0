Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34906 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdGNVFS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 17:05:18 -0400
Message-ID: <1500066316.3755.7.camel@gmail.com>
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
Date: Fri, 14 Jul 2017 17:05:16 -0400
In-Reply-To: <1500066114.3755.5.camel@gmail.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
         <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
         <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
         <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com>
         <CA+55aFyH-bL6NhX_jvqS50L4G5Y1QBgYhdiX9d1OH8Ze25EU6w@mail.gmail.com>
         <1500064716.3755.1.camel@gmail.com>
         <CA+55aFxN4D4MJpNGYS+vbcMgb4KnHArnwsar58vvK_2gSoZQmQ@mail.gmail.com>
         <1500066114.3755.5.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The reason q_size isn't used is because it doesn't yet prevent read
> overflow. The commit message mentions that among the current
> limitations
> along with __builtin_object_size(ptr, 1).

Er rather, in strlcat, the q_size is unused after the fast path is
because strnlen obtains the constant again itself.
