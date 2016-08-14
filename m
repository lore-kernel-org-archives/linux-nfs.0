Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36209 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbcHNWN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Aug 2016 18:13:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so8182488wmf.3
        for <linux-nfs@vger.kernel.org>; Sun, 14 Aug 2016 15:13:55 -0700 (PDT)
Date: Mon, 15 Aug 2016 00:13:52 +0200
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH rpcbind] src: include cdefs.h for the __P() macro
Message-ID: <20160814221352.GI30771@free.fr>
References: <1471097125-13193-1-git-send-email-yann.morin.1998@free.fr>
 <7736F23D-7AA5-4ABD-9693-99C9DCE03B91@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <7736F23D-7AA5-4ABD-9693-99C9DCE03B91@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck, All,

On 2016-08-14 14:30 -0400, Chuck Lever spake thusly:
> > On Aug 13, 2016, at 10:05 AM, Yann E. MORIN <yann.morin.1998@free.fr> wrote:
> > 
> > The __P() macro is defined in cdefs.h, so we must include it explicitly
> > rather than relying on it being included by another header.
> > 
> > cdefs.h is a glibc-ism; glibc includes it almost everywhere from its own
> > headers. So it automatically gets included for glibc.
> > 
> > However, cdefs.h is not present in musl, so its headers do not include
> > it. We must thus include it when we need __P() (of course, one will have
> > to provide his own cdefs.h in this case).
> 
> Simply adding "#include <sys/cdefs.h>" seems like the wrong approach.
> If cdefs.h is not guaranteed to exist, the appropriate thing to do
> is provide some autoconf machinery to define __P() in its absence.

OpenEmbedded provides comaptibility headers:
    http://git.openembedded.org/openembedded-core/tree/meta/recipes-core/bsd-headers/bsd-headers

In Buildroot, we're adding them too (not yet applied, WIP):
    http://lists.busybox.net/pipermail/buildroot/2016-August/169722.html

Other embedded buildsystem may each have their own fix in a way or
another...

Mainstream distros are more-or-less all based on glibc, except for a few
outliers, like Alpine Linux (also based on musl), and they've gone on
the "remove __P()" route:
    http://git.alpinelinux.org/cgit/aports/tree/main/rpcbind/0001-Avoid-use-of-glibc-sys-cdefs.h-header.patch

> On the other hand, I wonder if we need to continue to preserve K&R C
> compatibility in this code base. Perhaps instead the uses of __P()
> should be eliminated?

I tried to provide a minimalist approach, that consists in assuming that
cdefs.h is present.

But I do agree that pre-ANSI compatibility is probably a little tiny
wee bit excessive nowadays. Virtually all current compilers do accept
function prototypes, nowadays...

I can work on a patch that does just get rid of the use of __P(). (we
can't really vampirise the patch from Alpine, as there's no SoB or such
origin information on it; not that redoing the patch would be too
difficult either...).

So, what route, now? ;-)

Regards,
Yann E. MORIN.

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
