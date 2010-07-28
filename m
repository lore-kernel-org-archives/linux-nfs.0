Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43135 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab0G1BPk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jul 2010 21:15:40 -0400
Date: Wed, 28 Jul 2010 11:15:25 +1000
From: Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100728111525.355a2bd3@notabene>
In-Reply-To: <AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
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
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 22 Jul 2010 10:24:17 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Of people can just use xattrs and do it all entirely in user space. I
> assume that's what samba does now, even outside of birthtime.

Much as I despise xattrs, this would definitely be my preference.

ctime and mtime have real cache-coherence semantics which require them being
updated by the kernel (whether the cache is on an NFS client, in a backup
archive, or in a .o translation of a .c file).

create-time, on the other hand, would never be updated by the kernel, and
might sometimes be updated by an application.  So it is a very different sort
of attribute, much like a hypothetical 'last archived' time.

The only role the kernel might have would be setting the 'creation time' when
the file was created, but it seems even that isn't always what is wanted,
because people don't so much what the time of create of the
container-on-disk, but the time of creation of the data-content.

I would want to see a pretty convincing use-case that cannot be solved with
xattrs before 'creation time' was added to a generic kernel interface.

So just use xattrs and don't involve the kernel in any detailed knowledge of
this value.

Maybe xstat should take a list of xattrs to be retrieved as well??  or maybe
not.


But I hope the xstat debate doesn't get bogged down about whether 'create
time' is sensible or not.  Quite apart from the ability to return more
attributes,  I think it has real value is being able to return fewer
attributes, and being allowed to ask for 'best guess' values.  Being able to
do an 'fstat' and being certain that you won't be blocked by a non-responsive
NFS server would be a GOOD THING (TM).

NeilBrown
