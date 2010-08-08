Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753786Ab0HHMxi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Aug 2010 08:53:38 -0400
Date: Sun, 8 Aug 2010 08:53:01 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeremy Allison <jra@samba.org>
Cc: Neil Brown <neilb@suse.de>, utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100808085301.24f53e5a@tlielax.poochiereds.net>
In-Reply-To: <20100808121208.GA7329@jeremy-laptop>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<1280524978.2452.9.camel@segv.aura.of.mankind>
	<20100801092529.5e6ba0e0@corrin.poochiereds.net>
	<20100805235218.GB31233@jeremy-laptop>
	<20100806133836.49757af9@notabene>
	<20100808121208.GA7329@jeremy-laptop>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 8 Aug 2010 05:12:09 -0700
Jeremy Allison <jra@samba.org> wrote:

> On Fri, Aug 06, 2010 at 01:38:36PM +1000, Neil Brown wrote:
> > I'm curious.  Why do you particularly care what interface the kernel uses to
> > provide you with access to this attribute?
> 
> It's a matter of taste. The *BSD's have this right IMHO. It
> should be part of the stat information. A file timestamp is not
> an EA. Making it available that way just feels like an appalingly
> tasteless kludge. It offends the artist in me :-).
> 

It would be more convenient if this were part of stat() but adding a
new stat call is non-trivial. Even if we did that, it still doesn't
solve the problem of being able to set the create time. The fact that
that's rarely done doesn't really matter much -- we ought to shoot for
the semantics that are needed to handle this properly.

If we do settle on a xstat() interface, it might also end up being able
to report things like selinux labels which are also available and
settable via xattr. I don't see a problem with presenting the same data
via multiple interfaces. If presenting this data via xattr solves the
immediate problem of being able to properly store and report the create
time then it seems like a win.

> > Or do you really want something like BSD's 'btime' which as I understand it
> > cannot be set.  Would that be really useful to you?
> 
> It is *already* useful to us, and is widely used in
> existing code. The occasions when btime is set are
> relatively rare, and at that point we store it in a
> separate EA for Windows reporting purposes.
> 

If that's the case, don't you have to query for this EA every time you
need to return the create time anyway? If so, then doing this really
isn't any more costly -- you'd just be querying a different EA, right?

-- 
Jeff Layton <jlayton@redhat.com>
