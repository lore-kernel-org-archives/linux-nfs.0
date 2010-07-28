Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753089Ab0G1R2a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jul 2010 13:28:30 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100728111525.355a2bd3@notabene>
References: <20100728111525.355a2bd3@notabene> <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE> <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com> <E1Obxpd-00CRIo-SF@intern.SerNet.DE> <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com> <20100722162712.GB10352@jeremy-laptop> <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com> <alpine.LSU.2.01.1007221859180.27496@obet.zrqbmnf.qr> <AANLkTilmVdyVdO4EmVtTYi_cvMmPqNEPEnzUkJdk1XyR@mail.gmail.com> 
To: Neil Brown <neilb@suse.de>
Cc: dhowells@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Wed, 28 Jul 2010 18:28:02 +0100
Message-ID: <13591.1280338082@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Neil Brown <neilb@suse.de> wrote:

> ctime and mtime have real cache-coherence semantics which require them being
> updated by the kernel (whether the cache is on an NFS client, in a backup
> archive, or in a .o translation of a .c file).

So does creation time, at least for CIFS caching.  Creation time has potential
for spotting when the object at a pathname has changed for something else,
given the lack of inode number and inode generation from windows servers.
Creation time gives us one more datum to use.

> The only role the kernel might have would be setting the 'creation time' when
> the file was created, but it seems even that isn't always what is wanted,
> because people don't so much what the time of create of the
> container-on-disk, but the time of creation of the data-content.

That should be a timestamp in the content itself, not a filesystem metadata
timestamp.

> I would want to see a pretty convincing use-case that cannot be solved with
> xattrs before 'creation time' was added to a generic kernel interface.

Then there's no point even considering this.  You could emulate the entirety
of stat() with getxattr().  I've previously posted a patch to implement the
retrieval of creation time, inode gen and data version as xattrs and been told
that it's the wrong way to do it and I should extend stat instead.

> So just use xattrs and don't involve the kernel in any detailed knowledge of
> this value.

Why not?  BSD has it in its stat struct.  Windows has it in its Win32
equivalents.  Samba for one will look for it there, and use it if it is.

Using an xattr means an extra pathwalk and extra locking per access for any
program that wants it.  It's a reasonable bet such a program will also be
stat'ing the file it wants the creation time for.

If we are going to extend stat anyway, then why not make out a short list of
extra things we could usefully return and consider adding them?  Something
like creation time is reasonably easy to come by for little extra overhead.
Ext4, for example, retains a copy of it in RAM in its inode struct.

> Maybe xstat should take a list of xattrs to be retrieved as well??  or maybe
> not.

The idea of xstat() having a variable-length buffer and variable arguments has
been well derided.  It ain't going to happen, much though I'd like it to.  I'd
quite like to offer the opportunity to return the security label, for example.

David
