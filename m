Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5862 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab0HBOjw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Aug 2010 10:39:52 -0400
Date: Mon, 2 Aug 2010 10:42:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Greg Freemyer <greg.freemyer@gmail.com>
Cc: Neil Brown <neilb@suse.de>, David Howells <dhowells@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100802104200.2f058428@corrin.poochiereds.net>
In-Reply-To: <AANLkTi=JvwrwpmteFcXW1f5s95+_w_iCT+04Sy7bbTtR@mail.gmail.com>
References: <20100728111525.355a2bd3@notabene>
	<alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	<AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr>
	<AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
	<13591.1280338082@redhat.com>
	<20100729090401.4b0a21f8@notabene>
	<20100801094018.522e2f53@corrin.poochiereds.net>
	<AANLkTi=JvwrwpmteFcXW1f5s95+_w_iCT+04Sy7bbTtR@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2 Aug 2010 10:09:49 -0400
Greg Freemyer <greg.freemyer@gmail.com> wrote:

> > Furthermore, I'll go ahead and propose the following (simple) semantics:
> >
> > 1) birthtime is initialized to the current time when a new inode is
> > created
> >
> > 2) it's settable via the xattr to an arbitrary value
> >
> > Either way, the xattr for this ought to be named the same on all
> > filesystems. Samba shouldn't need to know or care what the underlying
> > filesystem is, as long as it presents the correct xattr.
> >
> > That should make samba happy, and be reasonably simple to implement.
> 
> Is there any reason to allow birthtime to be set in advance of the
> current birthtime?
> 
> ie restore / copy tools clearly need to backdate it, but I'd prefer to
> see it not advance-able.
> 
> Greg

Why not? Is there a good argument for prohibiting it? We allow people
to set mtime in the future. Why not allow the same semantics here?

We also have to consider that this may eventually be settable by via
networked filesystem interfaces. If the client and server don't have
synchronized clocks you may end up with the client getting an error
back in some cases if you don't allow it.

-- 
Jeff Layton <jlayton@redhat.com>
