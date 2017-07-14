Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36689 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdGNXvd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 19:51:33 -0400
Received: by mail-io0-f174.google.com with SMTP id z62so22013243ioi.3
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jul 2017 16:51:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170714212812.30297-1-danielmicay@gmail.com>
References: <20170714212812.30297-1-danielmicay@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 14 Jul 2017 16:51:31 -0700
Message-ID: <CAGXu5j+yRZWTouM9m1gKg3MtxT5tGgjoZOYWeAHZDz8MgjYdng@mail.gmail.com>
Subject: Re: [PATCH] replace incorrect strscpy use in FORTIFY_SOURCE
To: Daniel Micay <danielmicay@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 14, 2017 at 2:28 PM, Daniel Micay <danielmicay@gmail.com> wrote:
> Using strscpy was wrong because FORTIFY_SOURCE is passing the maximum
> possible size of the outermost object, but strscpy defines the count
> parameter as the exact buffer size, so this could copy past the end of
> the source. This would still be wrong with the planned usage of
> __builtin_object_size(p, 1) for intra-object overflow checks since it's
> the maximum possible size of the specified object with no guarantee of
> it being that large.
>
> Reuse of the fortified functions like this currently makes the runtime
> error reporting less precise but that can be improved later on.
>
> Signed-off-by: Daniel Micay <danielmicay@gmail.com>

Thanks for fixing this! Linus, do you want to take this directly or
have it go via -mm where fortify landed originally?

Acked-by: Kees Cook <keescook@chromium.org>

As far as testing goes, was the NFS tree not in -next, or was a test
not running against -next? I'm curious why it took until the NFS tree
landed in Linus's tree for this to get noticed. Fortify was in -next
for a while...

-Kees

-- 
Kees Cook
Pixel Security
