Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188Ab0HANXK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Aug 2010 09:23:10 -0400
Date: Sun, 1 Aug 2010 09:25:29 -0400
From: Jeff Layton <jlayton@redhat.com>
To: utz lehmann <lkml123@s2y4n2c.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, Volker.Lendecke@sernet.de,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100801092529.5e6ba0e0@corrin.poochiereds.net>
In-Reply-To: <1280524978.2452.9.camel@segv.aura.of.mankind>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEw  <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<1280524978.2452.9.camel@segv.aura.of.mankind>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 30 Jul 2010 23:22:58 +0200
utz lehmann <lkml123@s2y4n2c.de> wrote:

> On Thu, 2010-07-22 at 09:40 -0700, Linus Torvalds wrote:
> > But the fact is, th Unix ctime semantics are insane and largely
> > useless. There's a damn good reason almost nobody uses ctime under
> > unix.
> > 
> > So what I'm suggesting is that we have a flag - either per-process or
> > per-mount - that just says "use windows semantics for ctime".
> 
> When abusing an existing time stamp use atime not ctime please.
> ctime has it's uses. atime was just a mistake and is nearly useless.
> 
> And with noatime we already have creation time semantics for atime.
> 

Ugh. Honestly all of this talk of abusing different time fields seems
like craziness to me. It's going to be very hard to do that without
breaking *something*. There's also very little reason to do this when
xattrs are a much cleaner approach.

Neil Brown has put forth a very reasoned justification for putting the
birthtime in an xattr. After reading it, I think that makes more sense
than anything. It's also something that can be done without any extra
infrastructure. If at some point in the future we get an xstat-like
syscall then we can always add birthtime to that as well.

Ditto for the other fields under discussion (i_generation and the like).

-- 
Jeff Layton <jlayton@redhat.com>
