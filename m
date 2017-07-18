Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44394 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751413AbdGROyD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Jul 2017 10:54:03 -0400
Date: Tue, 18 Jul 2017 10:54:03 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Kees Cook <keescook@chromium.org>
Cc: Daniel Micay <danielmicay@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        kasan-dev <kasan-dev@googlegroups.com>
Subject: Re: [PATCH] replace incorrect strscpy use in FORTIFY_SOURCE
Message-ID: <20170718145403.GC19030@fieldses.org>
References: <20170714212812.30297-1-danielmicay@gmail.com>
 <CAGXu5j+yRZWTouM9m1gKg3MtxT5tGgjoZOYWeAHZDz8MgjYdng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGXu5j+yRZWTouM9m1gKg3MtxT5tGgjoZOYWeAHZDz8MgjYdng@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 14, 2017 at 04:51:31PM -0700, Kees Cook wrote:
> On Fri, Jul 14, 2017 at 2:28 PM, Daniel Micay <danielmicay@gmail.com> wrote:
> > Using strscpy was wrong because FORTIFY_SOURCE is passing the maximum
> > possible size of the outermost object, but strscpy defines the count
> > parameter as the exact buffer size, so this could copy past the end of
> > the source. This would still be wrong with the planned usage of
> > __builtin_object_size(p, 1) for intra-object overflow checks since it's
> > the maximum possible size of the specified object with no guarantee of
> > it being that large.
> >
> > Reuse of the fortified functions like this currently makes the runtime
> > error reporting less precise but that can be improved later on.
> >
> > Signed-off-by: Daniel Micay <danielmicay@gmail.com>
> 
> Thanks for fixing this! Linus, do you want to take this directly or
> have it go via -mm where fortify landed originally?
> 
> Acked-by: Kees Cook <keescook@chromium.org>
> 
> As far as testing goes, was the NFS tree not in -next, or was a test
> not running against -next? I'm curious why it took until the NFS tree
> landed in Linus's tree for this to get noticed. Fortify was in -next
> for a while...

There was a last-minute rebase of that tree.  I don't see anything
relevant there.  The code in question has been the same for ages.  But I
most be overlooking something....  I guess it could be interesting to
bisect to figure out when the warning started.

--b.
