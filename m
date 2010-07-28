Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60433 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344Ab0G1XEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jul 2010 19:04:14 -0400
Date: Thu, 29 Jul 2010 09:04:01 +1000
From: Neil Brown <neilb@suse.de>
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Engelhardt <jengelh@medozas.de>, Jeremy Allison <jra@samba.org>,
        Volker.Lendecke@sernet.de, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100729090401.4b0a21f8@notabene>
In-Reply-To: <13591.1280338082@redhat.com>
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
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 28 Jul 2010 18:28:02 +0100
David Howells <dhowells@redhat.com> wrote:

> Neil Brown <neilb@suse.de> wrote:
> 
> > ctime and mtime have real cache-coherence semantics which require them being
> > updated by the kernel (whether the cache is on an NFS client, in a backup
> > archive, or in a .o translation of a .c file).
> 
> So does creation time, at least for CIFS caching.  Creation time has potential
> for spotting when the object at a pathname has changed for something else,
> given the lack of inode number and inode generation from windows servers.
> Creation time gives us one more datum to use.

This justifies for me why a CIFS client would want to extract the
creation-time from the CIFS protocol, but not why you want to expose it via a
generic interface.
The kernel/filesystem doesn't need to maintain creation-time to meet this
need, only the CIFS server needs to maintain it - the kernel/filesystem just
needs to provide somewhere to store it - xattrs.

Given that we have an extensible attribute framework, it seems wrong to be
adding new attributes to *stat.  If a given filesystem wants to store certain
attributes more efficiently, then it is welcome to intercept xattr calls and
store (say) "cifs.birthtime" directly at a known offset in the inode.

The flip-side of extracting these various attributes is setting them.  One
presumably doesn't want to set st_data_version and possibly not st_gen, but
there seems to be a need to set st_btime and FS_SYSTEM_FL and FS_TEMPORARY_FL
might want to be set.  Your xstat doesn't give any way to do that, xattrs
already does - you just need to define names for the attributes.

So I'm against adding new attributes that simply involve the fs storing some
information for the application to use.

I'm still pondering those extra flags:
  FS_SPECIAL_FL
  FS_AUTOMOUNT_FL
  FS_AUTOMOUNT_ANY_FL
  FS_REMOTE_FL
  FS_ENCRYPTED_FL
  FS_OFFLINE_FL

They sound like they might be useful, they are not file-metadata (like
btime) but rather implementation details (like st_blocks).  So it is probably
sensible to include them as you have done.

However I would really like to see clear and complete documentation for them.
When exactly should a filesystem set these flag, and what exactly can an
application assume if they are (or are not) set.

If a filesystem is mounted on an network-block-device, or a loop-back of a
file on NFS, is FS_REMOTE_FL set?
Is ROT13 enough for FS_ENCRYPTED_FL to be set?
If the NFS server is "not responding, still trying", should FS_OFFLINE_FL get
set on all files?
And I cannot even guess at the different between the two FS_AUTOMOUNT flags.
I'm sure it is something useful, but doco would be good.  Should one of them
be set on mountpoints that NFSv4 detects from the server?

They sound useful, but they are only really useful if they have precise
meanings.


> 
> > The only role the kernel might have would be setting the 'creation time' when
> > the file was created, but it seems even that isn't always what is wanted,
> > because people don't so much what the time of create of the
> > container-on-disk, but the time of creation of the data-content.
> 
> That should be a timestamp in the content itself, not a filesystem metadata
> timestamp.
> 
> > I would want to see a pretty convincing use-case that cannot be solved with
> > xattrs before 'creation time' was added to a generic kernel interface.
> 
> Then there's no point even considering this.  You could emulate the entirety
> of stat() with getxattr().  I've previously posted a patch to implement the
> retrieval of creation time, inode gen and data version as xattrs and been told
> that it's the wrong way to do it and I should extend stat instead.

:-(  stuck between a rock and a hard-place ??

It would probably help to keep that sort of decision process (complete with
who to blame) documented in the change-log entry, but one never thinks of
doing that at the time.

I don't have any veto power here, and I don't want any.  I think creation
time and inode gen make more sense as xattrs.  I'm less certain about
data-version as the kernel has to know about it as a first-class concept.

If I have any power to influence the results, I would much rather spend it on
requiring clear precise useful definitions for each new attribute than on
determining which attributes should be first-class and which should be xattrs.


> 
> > So just use xattrs and don't involve the kernel in any detailed knowledge of
> > this value.
> 
> Why not?  BSD has it in its stat struct.  Windows has it in its Win32
> equivalents.  Samba for one will look for it there, and use it if it is.
> 
> Using an xattr means an extra pathwalk and extra locking per access for any
> program that wants it.  It's a reasonable bet such a program will also be
> stat'ing the file it wants the creation time for.
> 
> If we are going to extend stat anyway, then why not make out a short list of
> extra things we could usefully return and consider adding them?  Something
> like creation time is reasonably easy to come by for little extra overhead.
> Ext4, for example, retains a copy of it in RAM in its inode struct.

Providing everybody imposes exactly the same semantics for "creation time"...

> 
> > Maybe xstat should take a list of xattrs to be retrieved as well??  or maybe
> > not.
> 
> The idea of xstat() having a variable-length buffer and variable arguments has
> been well derided.  It ain't going to happen, much though I'd like it to.  I'd
> quite like to offer the opportunity to return the security label, for example.

"well derided" like high-mem and SMP support?  or "real-time" support and
priority inheritance?
I guess the deriders are wrong, and will eventually realise that they are
wrong.  The difficult bit is we cannot know how long it will take them, or
how much you have to care.

NeilBrown
(unambiguous documentation!! the rest is just details)

