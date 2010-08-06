Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59394 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933645Ab0HFDiy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 23:38:54 -0400
Date: Fri, 6 Aug 2010 13:38:36 +1000
From: Neil Brown <neilb@suse.de>
To: Jeremy Allison <jra@samba.org>
Cc: Jeff Layton <jlayton@redhat.com>, utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100806133836.49757af9@notabene>
In-Reply-To: <20100805235218.GB31233@jeremy-laptop>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<1280524978.2452.9.camel@segv.aura.of.mankind>
	<20100801092529.5e6ba0e0@corrin.poochiereds.net>
	<20100805235218.GB31233@jeremy-laptop>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 5 Aug 2010 16:52:18 -0700
Jeremy Allison <jra@samba.org> wrote:

> On Sun, Aug 01, 2010 at 09:25:29AM -0400, Jeff Layton wrote:
> > On Fri, 30 Jul 2010 23:22:58 +0200
> > utz lehmann <lkml123@s2y4n2c.de> wrote:
> > 
> > > On Thu, 2010-07-22 at 09:40 -0700, Linus Torvalds wrote:
> > > > But the fact is, th Unix ctime semantics are insane and largely
> > > > useless. There's a damn good reason almost nobody uses ctime under
> > > > unix.
> > > > 
> > > > So what I'm suggesting is that we have a flag - either per-process or
> > > > per-mount - that just says "use windows semantics for ctime".
> > > 
> > > When abusing an existing time stamp use atime not ctime please.
> > > ctime has it's uses. atime was just a mistake and is nearly useless.
> > > 
> > > And with noatime we already have creation time semantics for atime.
> > > 
> > 
> > Ugh. Honestly all of this talk of abusing different time fields seems
> > like craziness to me. It's going to be very hard to do that without
> > breaking *something*. There's also very little reason to do this when
> > xattrs are a much cleaner approach.
> > 
> > Neil Brown has put forth a very reasoned justification for putting the
> > birthtime in an xattr. After reading it, I think that makes more sense
> > than anything. It's also something that can be done without any extra
> > infrastructure. If at some point in the future we get an xstat-like
> > syscall then we can always add birthtime to that as well.
> 
> Just my 2 cents (as a Samba server implementor). I *hate* the idea
> of adding a "virtual" EA for birthtime. If you're going to add it,
> just add it to the stat struct like *BSD does. Don't abuse the other
> time fields, it's a new one.
> 
> Jeff, please don't advocate for an EA for the Samba server to use.
> Don't add it as an EA. It's *not* an EA, it's a timestamp.

I'm curious.  Why do you particularly care what interface the kernel uses to
provide you with access to this attribute?

And given that it is an attribute that is not part of 'POSIX' or "UNIX", it
would seem to be an extension - an extended attribute.
As the Linux kernel does virtually nothing with this attribute except provide
access, it seems to be a very different class of thing to other timestamps.
Surely it is simply some storage associated with a file which is capable of
storing a timestamp, which can be set or retrieved by an application, and
which happens to be initialised to the current time when a file is created.

Yes, to you it is a timestamp.  But to Linux it is a few bytes of
user-settable metadata.  Sounds like an EA to me.

Or do you really want something like BSD's 'btime' which as I understand it
cannot be set.  Would that be really useful to you?

Is there something important that I am missing?

NeilBrown
