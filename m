Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760718Ab0GSR1Z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jul 2010 13:27:25 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <AANLkTinVns77R7yCCh-lydd0eQufdAF9O2OaWmCL7uSn@mail.gmail.com>
References: <AANLkTinVns77R7yCCh-lydd0eQufdAF9O2OaWmCL7uSn@mail.gmail.com> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <AANLkTikuzYqYpGHcubb7QVciZW0dNFjOG82qIwy5M4gO@mail.gmail.com> <10783.1279556132@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Content-Type: text/plain; charset=iso-8859-1
Date: Mon, 19 Jul 2010 18:26:40 +0100
Message-ID: <11817.1279560400@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> > The new information is useful for some cases.  Samba for example.  At
> > least two of the fields I'm adding are also made available through BSD's
> > stat() call, and will automatically be used for some things by autoconf
> > magic if they become available.
> 
> .. that' a pointless argument. If the only way something gets used is
> through autoconf, then clearly nobody cares.

That's not what I meant at all.  I meant there may be things out there that
will just use st_btime and st_gen as soon as they appear without anything
having to be done to them because these fields already exist in the BSD stat
struct.

Samba is such an example as this.  It will use st_btime immediately if it
exists as the SMB protocol wants to pass the creation time around.

> Yeah, maybe it adds a flag to "ls", but let's face is - that isn't actually
> _buying_ anything.

Not having ls cause a mass automount just because you did an ls of a directory
full of automount points would be very nice.

> So the only thing that matters for new system calls is who actually
> really seriously wants to use the information, even if it's not there
> by default. Is it _anybody_ else than samba?

Perhaps.  As previously mentioned, BSD (and other unices) already make some of
these fields available (notably st_btime and st_gen).  We could also make a
BSD-compatible st_flags available.

> In other words, in the absense of some seriously generic users, it
> sounds more like an ioctl to me to ask for something like "creation
> time" or "inode version", when not all filesystems support anything
> like that.

I initially did them by getxattr(), but that didn't go down too well.

> Ask your samba people, for example, if they'd _ever_ do just a "xstat()"?

I suspect they would, though maybe they can say otherwise.  What about SMB
directory enumeration?  I believe that is effectively getdents-with-stat.
Having to do open+stat for each file for that would be painful.

David
