Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34295 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdGOAYB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 20:24:01 -0400
Message-ID: <1500078238.1208.4.camel@gmail.com>
Subject: Re: [PATCH] replace incorrect strscpy use in FORTIFY_SOURCE
From: Daniel Micay <danielmicay@gmail.com>
To: Kees Cook <keescook@chromium.org>,
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
Date: Fri, 14 Jul 2017 20:23:58 -0400
In-Reply-To: <CAGXu5j+yRZWTouM9m1gKg3MtxT5tGgjoZOYWeAHZDz8MgjYdng@mail.gmail.com>
References: <20170714212812.30297-1-danielmicay@gmail.com>
         <CAGXu5j+yRZWTouM9m1gKg3MtxT5tGgjoZOYWeAHZDz8MgjYdng@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-07-14 at 16:51 -0700, Kees Cook wrote:
> On Fri, Jul 14, 2017 at 2:28 PM, Daniel Micay <danielmicay@gmail.com>
> wrote:
> > Using strscpy was wrong because FORTIFY_SOURCE is passing the
> > maximum
> > possible size of the outermost object, but strscpy defines the count
> > parameter as the exact buffer size, so this could copy past the end
> > of
> > the source. This would still be wrong with the planned usage of
> > __builtin_object_size(p, 1) for intra-object overflow checks since
> > it's
> > the maximum possible size of the specified object with no guarantee
> > of
> > it being that large.
> > 
> > Reuse of the fortified functions like this currently makes the
> > runtime
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
> 
> -Kees

Not sure but one issue is that v1 wasn't broken and that's what I most
heavily tested myself. I then switched to testing with intra-object size
checks on top of it, and there would have needed to be a case like this
to break with those stricter checks:

char a[2];
char b[3];
char *p = cond ? a : b;
strcpy(a, c);

__builtin_object_size(p, 0) / __builtin_object_size(p, 1) will both
return 3 there, which is wrong with that incorrect strscpy usage.

I wouldn't have found it via NFS since I've been testing with the string
(but not memory) functions switched to the stricter type 1.

I started on some test cases for FORTIFY_SOURCE but I was testing to
make sure it catches all the bugs it's supposed to catch, it's probably
a good idea to write some more generic string edge case tests too.

One of the somewhat subtle cases (which is handled properly already):

struct foo {
	char a[2];
	char b;
}

struct foo x;
x.a[0] = '1';
x.a[1] = '2';
x.b = '\0';

strlen(x.a); // BUG with stricter intra-object overflow checks on
strnlen(x.a, 3); // BUG with stricter intra-object overflow checks on
strnlen(x.a, 2); // no overflow

Anyway, it'd be really good if other people looked closely at these. I
wasn't sure what to do with test cases that I've made though. It seems
ones that are *supposed* to BUG should go in lkdtm, and should the other
tests just be together with those? Some should also pass w/o the intra
object overflow checks, but BUG with them enabled.
