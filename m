Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752328Ab0HANhq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Aug 2010 09:37:46 -0400
Date: Sun, 1 Aug 2010 09:40:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Cc: David Howells <dhowells@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100801094018.522e2f53@corrin.poochiereds.net>
In-Reply-To: <20100729090401.4b0a21f8@notabene>
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
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 29 Jul 2010 09:04:01 +1000
Neil Brown <neilb@suse.de> wrote:

> On Wed, 28 Jul 2010 18:28:02 +0100
> David Howells <dhowells@redhat.com> wrote:
> 
> > Neil Brown <neilb@suse.de> wrote:
> > 
> > > ctime and mtime have real cache-coherence semantics which require them being
> > > updated by the kernel (whether the cache is on an NFS client, in a backup
> > > archive, or in a .o translation of a .c file).
> > 
> > So does creation time, at least for CIFS caching.  Creation time has potential
> > for spotting when the object at a pathname has changed for something else,
> > given the lack of inode number and inode generation from windows servers.
> > Creation time gives us one more datum to use.
> 
> This justifies for me why a CIFS client would want to extract the
> creation-time from the CIFS protocol, but not why you want to expose it via a
> generic interface.
> The kernel/filesystem doesn't need to maintain creation-time to meet this
> need, only the CIFS server needs to maintain it - the kernel/filesystem just
> needs to provide somewhere to store it - xattrs.
> 
> Given that we have an extensible attribute framework, it seems wrong to be
> adding new attributes to *stat.  If a given filesystem wants to store certain
> attributes more efficiently, then it is welcome to intercept xattr calls and
> store (say) "cifs.birthtime" directly at a known offset in the inode.
> 

The problem with the above approach is that you're assuming that the
data in question is always accessed via the CIFS server. If someone
comes along and messes with the data outside of CIFS, then samba won't
have knowledge of that and the birthtime will be wrong.

There's some history behind this as well -- samba tracks windows ACLs
via xattr and it can be very problematic keeping those up to date when
the data is accessed outside of samba.

I think presenting this data via xattr makes the most sense. It's
simple and as Neil points out, it also provides us with a clealy
settable interface. If we ever get an xstat-like syscall, we can always
present the same data via that as well.

I also think it's quite reasonable to consider tracking birthtime in a
generic inode field. In the absence of that, filesystems could track
this themselves in their filesystem-specific inode structs.

Furthermore, I'll go ahead and propose the following (simple) semantics:

1) birthtime is initialized to the current time when a new inode is
created

2) it's settable via the xattr to an arbitrary value

Either way, the xattr for this ought to be named the same on all
filesystems. Samba shouldn't need to know or care what the underlying
filesystem is, as long as it presents the correct xattr.

That should make samba happy, and be reasonably simple to implement.

-- 
Jeff Layton <jlayton@redhat.com>
