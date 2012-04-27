Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:1444 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759546Ab2D0TbK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 15:31:10 -0400
Subject: Re: [PATCH 0/6] Extended file stat system call
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120427131306.GG9541@dastard>
Date: Fri, 27 Apr 2012 13:31:07 -0600
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Message-Id: <F2018580-9ACC-4A63-A8D1-155FA371749A@dilger.ca>
References: <20120427010610.GE9541@dastard> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <4111.1335519545@redhat.com> <20120427131306.GG9541@dastard>
To: Dave Chinner <david@fromorbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-27, at 7:13 AM, Dave Chinner wrote:
> Have a look at fs/xfs/xfs_dinode.h. There's a bunch of flags defined
> at the bottom of the file.
> 
> Stuff like the "nodefrag", "nodump", and "prealloc" bits seem fairly
> generic - they are for indicating that files are to be avoided for
> defrag or backup purposes, the prealloc bit indicates that fallocate
> has been used to reserve space on the inode (finding files that space
> can be punched out of safely), and so on.

There is already the FS_NODUMP_FL in the standard FS_IOC_GETFLAGS ioctl
and I expect this to be in statxat() also.  In ext4 there was also an
EXT4_EOFBLOCKS_FL added for inodes with fallocate'd data beyond EOF,
but Eric thought it was a pain to maintain and it has been deprecated
in ext4 and e2fsprogs recently.

> Currently these things are queried and manipulated by ioctls
> (XFS_IOC_FSX[GS]ETATTR) along with extent size hints, project
> quotas, etc. but I think there's some wider use for many of the
> flags, which is why I was asking is there's any thought to this sort
> of flag being exposed by the VFS.
> 
> Historically the flags exposed by the VFS are those used by extN - I
> see little reason why we should favour one filesystem's flags over
> any others in an extended stat interface if they are generically
> useful....

Sure, they started as ext4 flags because the "lsattr" and "chattr"
tools were using this ioctl/flags, but have become more generic in
recent years.  FS_NOTAIL_FL was added for Reiserfs, and FS_NOCOW_FL
was added for another filesystem (maybe Btrfs?).  I'm not against
adding more flags here that are generically useful, and recommended
that statxat() have a 64-bit st_ioc_flags, since there are already
22 FS_*_FL flags defined today.

>> Either you can add some of them to the ioc flags (which may be
>> impractical, I grant you) or we'd have to add an arbitrary fs-type
>> specific field and specify the host fs (the provision of which might
>> not be a bad idea in and of itself) to tell userspace how to interpret them.
> 
> Well, that's the complexity, isn't it. I have no good answer to
> that...
> 
>>> Along the same lines, filesytsems can have different allocation
>>> constraints to IO the filesystem block size - ext4 with it's
>>> bigalloc hack, XFS with it's per-inode extent size hints and the
>>> realtime device, etc. Then there's optimal IO characteristics
>>> (e.g. geometery hints like stripe unit/stripe width for the
>>> allocation policy of that given file) that applications could
>>> use if they were present rather than having to expose them
>>> through ioctls that nobody even knows about...
>> 
>> Yeah...  Not representable by one number.  You'd have to unset a
>> flag to say you were providing this information.
>> 
>> However, providing a whole bunch of hints about I/O characteristics
>> is probably beyond this syscall - especially if it isn't constant
>> over the length of a file.  That's specialist knowledge that most
>> applications don't need to know.  
>> Having a generic way to retrieve it, though, may be a good idea.
> 
> We're continually talking about applications giving us usage hints
> on what IO they are going to do so the storage can optimise the IO.
> IO is still a GIGO problem, though, and the idea of geometry hints
> is to enable us to tell the application to do well formed IO. i.e.
> less garbage.
> 
> XFS has ioctls to expose filesystem geometry, optimal IO sizes, the
> alignment limits for direct IO, etc, and they are very useful to
> applications that care about high performance IO. A lot of this can
> be distilled down to a simple set of geometries, and generally
> speaking they don't change mid way through a file....
> 
>> OTOH, there's plenty of uncommitted space, so if we can condense
>> the hints down to something small, we could perhaps add it later -
>> but from your paragraph above, it doesn't sound like it'll be small.
> 
> Allocation block size, minimum sane IO size (to avoid page cache RMW
> cycles or DIO zeroing), minimum prefered IO size (e.g. stripe unit),
> optimal IO size for bandwidth (e.g. stripe width). I don't think
> there's much more than that which will be really usable by
> applications.

I think this is a minimal set that makes sense, and is manageable for
both the interface and for users.  Even if it isn't 100% correct for
every file of every filesystem, it still makes sense for many systems.
I'd suggest st_frsize (like BSD statvfs() f_frsize) would be the
minimum fragment or page size, st_iosize (BSD f_iosize) could be
the optimal IO size, and "st_stripesize" for the minimum preferred RAID/chunk size.

One could argue that "st_blksize" is used for the "optimal IO size"
on Linux today, but this is an overloaded term.  It _appears_ to
represent the filesystem blocksize, which it usually is not, and on
BSD st_bsize means the minimum blocksize and has a confusingly
similar name.  Since any application using this API needs to do some
extra coding already, we may as well give the structure members good
names that are not ambiguous.

>>> Perhaps also exposing the project ID for quota purposes, like we
>>> do UID and GID. That way we wouldn't need a filesystem specific
>>> ioctl to read it....
>> 
>> Is this an XFS only thing?  If so, can it be generalised?
> 
> Right now it is, but there's been patches in the past to introduce
> project quotas to ext4. That didn't go far because it was done in a
> way that was semantically different to XFS (for no reason that I
> could understand) and nobody wanted two different sets of semantics
> for the "same" feature.  The most common use of project quotas is to
> implement sub-tree quotas, which is probably of more interest to
> btrfs folks as it is an exact match for per-subvolume quotas.
> 
> So, yes, I do see it as something generically useful - it's a
> feature that a lot of people use XFS specifically for....

I'd agree.  There was the tree quota project for ext4, and I've also
heard this is available in other filesystems.

Cheers, Andreas





