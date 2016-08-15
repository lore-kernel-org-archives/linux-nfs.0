Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23663 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbcHOOXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 10:23:51 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH rpcbind] src: include cdefs.h for the __P() macro
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160814221352.GI30771@free.fr>
Date: Mon, 15 Aug 2016 10:23:35 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Message-Id: <5769F8D5-D7F9-4528-BC5C-B1EF921F52CD@oracle.com>
References: <1471097125-13193-1-git-send-email-yann.morin.1998@free.fr> <7736F23D-7AA5-4ABD-9693-99C9DCE03B91@oracle.com> <20160814221352.GI30771@free.fr>
To: "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ adding libtirpc-devel ]


> On Aug 14, 2016, at 6:13 PM, Yann E. MORIN <yann.morin.1998@free.fr> wrote:
> 
> Chuck, All,
> 
> On 2016-08-14 14:30 -0400, Chuck Lever spake thusly:
>>> On Aug 13, 2016, at 10:05 AM, Yann E. MORIN <yann.morin.1998@free.fr> wrote:
>>> 
>>> The __P() macro is defined in cdefs.h, so we must include it explicitly
>>> rather than relying on it being included by another header.
>>> 
>>> cdefs.h is a glibc-ism; glibc includes it almost everywhere from its own
>>> headers. So it automatically gets included for glibc.
>>> 
>>> However, cdefs.h is not present in musl, so its headers do not include
>>> it. We must thus include it when we need __P() (of course, one will have
>>> to provide his own cdefs.h in this case).
>> 
>> Simply adding "#include <sys/cdefs.h>" seems like the wrong approach.
>> If cdefs.h is not guaranteed to exist, the appropriate thing to do
>> is provide some autoconf machinery to define __P() in its absence.
> 
> OpenEmbedded provides comaptibility headers:
>    http://git.openembedded.org/openembedded-core/tree/meta/recipes-core/bsd-headers/bsd-headers
> 
> In Buildroot, we're adding them too (not yet applied, WIP):
>    http://lists.busybox.net/pipermail/buildroot/2016-August/169722.html
> 
> Other embedded buildsystem may each have their own fix in a way or
> another...
> 
> Mainstream distros are more-or-less all based on glibc, except for a few
> outliers, like Alpine Linux (also based on musl), and they've gone on
> the "remove __P()" route:
>    http://git.alpinelinux.org/cgit/aports/tree/main/rpcbind/0001-Avoid-use-of-glibc-sys-cdefs.h-header.patch
> 
>> On the other hand, I wonder if we need to continue to preserve K&R C
>> compatibility in this code base. Perhaps instead the uses of __P()
>> should be eliminated?
> 
> I tried to provide a minimalist approach, that consists in assuming that
> cdefs.h is present.

If cdefs.h presence cannot be guaranteed (and I think you've adequately
demonstrated that no guarantee exists), at the very least there needs
to be some autoconf logic to handle the "cdefs.h is not present" case.
IMO a strictly minimalist approach won't work here.


> But I do agree that pre-ANSI compatibility is probably a little tiny
> wee bit excessive nowadays. Virtually all current compilers do accept
> function prototypes, nowadays...
> 
> I can work on a patch that does just get rid of the use of __P(). (we
> can't really vampirise the patch from Alpine, as there's no SoB or such
> origin information on it; not that redoing the patch would be too
> difficult either...).
> 
> So, what route, now? ;-)

My preference as a reviewer and individual contributor:

Barring any further comments here, provide two different approaches:

1. add autoconf logic to detect when sys/cdefs.h is not available,
and provide a substitute __P() macro. That might be as simple as
defining __P in a local auto.m4 script when it is not provided by
system headers.

2. remove invocations of the __P() macro from the rpcbind source

Post both to the mailing lists and folks here can decide which is
better.

You might not have time for all that ;-) so you could pick one and
add a strong technical argument in the patch description why that
is the best choice.

I think I like 2. overall as it should leave the rpcbind source
code a little easier to read, no new autoconf logic is needed, and
there appears to be one distro that is already going that way.

Maybe there's someone with the Alpine distro that can provide an
SoB for their patch?


--
Chuck Lever



