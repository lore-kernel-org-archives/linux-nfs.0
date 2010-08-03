Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59435 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215Ab0HCBNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Aug 2010 21:13:52 -0400
Date: Tue, 3 Aug 2010 11:13:37 +1000
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
Message-ID: <20100803111337.43932aca@notabene>
In-Reply-To: <319.1280420115@redhat.com>
References: <20100729090401.4b0a21f8@notabene>
	<20100728111525.355a2bd3@notabene>
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
	<319.1280420115@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 29 Jul 2010 17:15:15 +0100
David Howells <dhowells@redhat.com> wrote:

> Neil Brown <neilb@suse.de> wrote:
> 
> > This justifies for me why a CIFS client would want to extract the
> > creation-time from the CIFS protocol, but not why you want to expose it via a
> > generic interface.
> 
> It would also be easier for NFSD if the creation time was in struct kstat.
> It's included as an optional element in NFSv4.  The same goes for the data
> version number.  I'm not sure about the inode generation, I suspect that's used
> as part of the FH construction.
> 
> However, someone was talking about a userspace NFS daemon, and there they may
> want all three bits.  Even Samba may want multiple bits.  Calling getxattr
> multiple times per file starts to add up, even for internal values.
> 
> Consider further: NFS, for example, could be made to retrieve the creation time
> from the server.  This can be merged with the attribute fetch done by the
> getattr() call, or it could be done separately by getxattr.  Unless it's stored
> in RAM, that's one NFS RPC op versus two.  Okay, that's a bit of an artificial
> example, but still.
> 
> > Given that we have an extensible attribute framework, it seems wrong to be
> > adding new attributes to *stat.  If a given filesystem wants to store certain
> > attributes more efficiently, then it is welcome to intercept xattr calls and
> > store (say) "cifs.birthtime" directly at a known offset in the inode.
> 
> It's not attribute storage I'm thinking about, but making attribute retrieval
> more efficient.
> 
> > The flip-side of extracting these various attributes is setting them.
> 
> I acknowledge that if we went down the getxattr() route, then that
> automatically makes setxattr() the obvious candidate for setting things.
> 
> But think about it another way: what if you want to set several attributes?
> You have to make a bunch of setxattr() calls.  But what if it were possible to
> do all of chmod, chgrp, chown, truncate, utimes, set_btime, etc. all in one go,
> atomically?  We more or less have this internally in the kernel, and it might
> stand to be exposed to userspace.
> 
> It might, for example, make untarring that little bit more efficient.
> 
> > I'm still pondering those extra flags:
> >   FS_SPECIAL_FL
> >   FS_AUTOMOUNT_FL
> >   FS_AUTOMOUNT_ANY_FL
> >   FS_REMOTE_FL
> >   FS_ENCRYPTED_FL
> >   FS_OFFLINE_FL
> > 
> > They sound like they might be useful, they are not file-metadata (like
> > btime) but rather implementation details (like st_blocks).  So it is probably
> > sensible to include them as you have done.
> 
> I've split these away from ioc flags as ioc flags is very ext2/3/4 centric, and
> those filesystems happily create their own ioc flags sets without updating the
> master set.
> 
> > If a filesystem is mounted on an network-block-device, or a loop-back of a
> > file on NFS, is FS_REMOTE_FL set?
> > Is ROT13 enough for FS_ENCRYPTED_FL to be set?
> > If the NFS server is "not responding, still trying", should FS_OFFLINE_FL get
> > set on all files?
> > And I cannot even guess at the different between the two FS_AUTOMOUNT flags.
> > I'm sure it is something useful, but doco would be good.  Should one of them
> > be set on mountpoints that NFSv4 detects from the server?
> 
> Yeah.  I have plans to write documentation for it, but I'd like to have a
> clearer idea of what the interface might be before doing that.
> 
> But to give you an idea of the flags:
> 
>  (*) FS_SPECIAL_FL - Kernel API file from a quasi-filesystem such as /proc or
>      /sys - the sort of thing you might not want to expose through NFSD.
> 
>  (*) FS_AUTOMOUNT_FL - A named automount/referral point.  You attempt to
>      transit this directory and the backing fs will mount something over the
>      top.
> 
>  (*) FS_AUTOMOUNT_ANY_FL - A directory in which you can look up a non-existent
>      directory entry, which will cause that dirent to be fabricated and the
>      target filesystem be mounted over the top.  Examples include looking up
>      arbitrary cell names in /afs, or arbitrary hostnames in autofs or amd
>      indirect mount directories.
> 
>  (*) FS_REMOTE_FL - A filesystem object that is assumed not to be stored on the
>      computer issuing the request.  It would be quite nice to have loopback NFS
>      not set the remote flag and to have NBD mounted filesystems to set the
>      remote flag, but this can get quite messy with things like overmounts.
> 
>      My thought is that this can be used by a GUI to choose its icons for
>      files.
> 
>  (*) FS_ENCRYPTED_FL - A file that is stored encrypted and that presumably
>      needs a key providing to decrypt it.  CIFS has an attribute bit for this
>      (ATTR_ENCRYPTED).
> 
>  (*) FS_OFFLINE_FL - A file that isn't immediately available, and that requires
>      a connection to the data store to be made.  CIFS has an attribute bit for
>      this (ATTR_OFFLINE).  AFS has a field in its volume data and an error code
>      indicating that a volume is offline and cannot currently be accessed.
> 
>      This could be set by network filesystems for which the network or the
>      server is absent for example.  Especially if the lightweight stat is
>      requested (non-blocking in essence).

Thanks for these.  It particularly helps when you identify how the flag might
be used - guiding GUI icon choice is certainly valid and tells me that if I
don't set the flag 'correctly' (maybe because it is too difficult) then it
isn't the end of the world.

I get the AUTOMOUNT distinction too - FS_AUTHMOUNT_ANY_FL would be good for a
GUI as it could allow you to type in a filename for it to try to follow.

I'm not sure exactly how FS_ENCRYPTED_FL would be used - if the gui might be
prompted to ask for a key there would either need to be a completely general
interface for presenting keys, or the flag should be specific to CIFS and
should mean that a key must be given to CIFS to unlock the file.

Similarly, what can you do with an OFFLINE file?  Do CIFS and AFS offline
files behave the same way?  If not there should be two different flags.  If
so then that behaviour should be specified with the flag ... unless this flag
is just for GUI cosmetics too.


Anyway, I've been thinking more about this and have refined my position
somewhat.  I'll present it here for what it is worth - feel free to ignore
bits you don't like.

Your proposed 'xstat' seems to combine a number of different goals - doing
that is always a bit dangerous as you have defend it on multiple fronts...

I see the separate goals are:
 A/ allowing attributes to be accessed independently - an explicit list of
    required attributes is given and the FS doesn't need to collect the other
    attributes.
 B/ allowing  synthetic attributes to be identified - if the FS doesn't
    natively support some attribute but must synthesise it, you can now
    discover that fact 
 C/ add an ad-hoc collection of new attributes that filesystems can return if
    they happen to support them
 D/ do all the above with a single system call for efficiency.

I think pushing all these together is asking for trouble - arguments about one
aspect will interfere with completion of the others.

Given that we already have the 'xattr' interface it seems most sensible to
achieve 'A' by defining xattr names for all 'standard' attributes and
handling them in a common library function.  Maybe 'linux.inum' to get the
inode numbers, etc.  There is doubtlessly a better name than 'linux.inum'.
I understand that you tried something like this before and it was rejected.
To borrow Linus's hyperbole from up-thread:
>> Hey, whoever denounced it as stupid obviously doesn't have the neurons
>> to go around to be involved in the discussion. Ignore them.

With that in place, 'B' can be achieved by the simple expedient of not
listing (in listxattr) the system attributes that the filesystem doesn't
support natively.  So if a filesystem doesn't support uid and has to fake it,
then it would not list 'linux.uid' in the xattr list, but will still return
the faked uid if explicitly asked for it.

The various proposed new attributes (C) could then be added one at a time or
as groups depending on how much opposition they receive.  Some might be
generic (linux.*) while others should possibly be filesystem-specific (FAT.*,
CIFS.*).

This could result in the need to make multiple system calls to get all of the
attributes that you want.  Maybe this would be a problem ... I keep hearing
that in Linux context switches are really cheap and system calls are also
really cheap, so maybe it isn't a problem.

However if you can demonstrate a cost in a credible workload you would then
have ammunition to defend a new syscall (D) which would get multiple xattrs.
And maybe one that would set multiple xattrs.

Thus you can address each goal one at a time and the more contentious parts
can be delayed without interfering with the clearly valuable parts.

Whether a particular attribute were stored in kstat, or whether the fs needed
extra disk access to get the attribute would be entirely internal details
which we are free to get wrong the first few times and then fix up once we
understand all the issues properly.


> > Providing everybody imposes exactly the same semantics for "creation time"...
> 
> We can invent some for Linux.  The time at which an inode is created would seem
> to be a sensible course, but with the ability for the creation time to be set
> by archiving tools.  Overwriting an existing inode by truncating it and then
> writing it should keep the creation time of the inode.
> 
> I think this would then be the same behaviour as Windows.

Yes, it seems that supporting the Windows behaviour is the only actual
use-case that has been suggested - so I think that we should be explicit that
this attribute has exactly the same semantics as the windows attribute.  i.e.
we shouldn't invent some, we should precisely copy them.

> 
> > "well derided" like high-mem and SMP support?  or "real-time" support and
> > priority inheritance?
> > I guess the deriders are wrong, and will eventually realise that they are
> > wrong.  The difficult bit is we cannot know how long it will take them, or
> > how much you have to care.
> 
> Almost everyone hates the idea of having a stat function with a variable length
> buffer.  To quote Linus:
> 
> 	the "buffer+buflen" thing is still disgusting.
> 
> You might be right, though: the deriders might be wrong; it just doesn't help
> at this particular point in time.

We do seem to suffer from the squeaky-wheel syndrome - the louder someone
complains the more attention they are given - I'm sorry I wasn't listening
when you first suggested using xattrs for accessing creation-time - maybe I
could have squeaked loudly too .... though probably I wouldn't have
considered the issues deeply enough by that time.

(Look - getxattr has buffer+buflen ! - it may well be disgusting, but
following established practice is good for consistency).

> 
> > (unambiguous documentation!! the rest is just details)
> 
> I normally do write documentation.  It's just that I don't want to have to keep
> changing the docs as well as constantly rewriting the code.

I understand that desire ... but with an interface, the docs really are just
as important as the code!


thanks,
NeilBrown
