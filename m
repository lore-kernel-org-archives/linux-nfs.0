Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:9090 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758385Ab2D1A7F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 20:59:05 -0400
Date: Sat, 28 Apr 2012 10:58:56 +1000
From: Dave Chinner <david@fromorbit.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Message-ID: <20120428005856.GI9541@dastard>
References: <20120427010610.GE9541@dastard>
 <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <4111.1335519545@redhat.com>
 <20120427131306.GG9541@dastard>
 <F2018580-9ACC-4A63-A8D1-155FA371749A@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F2018580-9ACC-4A63-A8D1-155FA371749A@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 01:31:07PM -0600, Andreas Dilger wrote:
> On 2012-04-27, at 7:13 AM, Dave Chinner wrote:
> > Have a look at fs/xfs/xfs_dinode.h. There's a bunch of flags defined
> > at the bottom of the file.
> > 
> > Stuff like the "nodefrag", "nodump", and "prealloc" bits seem fairly
> > generic - they are for indicating that files are to be avoided for
> > defrag or backup purposes, the prealloc bit indicates that fallocate
> > has been used to reserve space on the inode (finding files that space
> > can be punched out of safely), and so on.
> 
> There is already the FS_NODUMP_FL in the standard FS_IOC_GETFLAGS ioctl
> and I expect this to be in statxat() also.

I forgot that was one of the generic flags :/

> In ext4 there was also an
> EXT4_EOFBLOCKS_FL added for inodes with fallocate'd data beyond EOF,
> but Eric thought it was a pain to maintain and it has been deprecated
> in ext4 and e2fsprogs recently.

I'd think that flag is more of a "filesystem implementation
specific" flag than a general "this file contained persistent
preallocation" flag, which is essentially what the XFS flag says.
XFS uses in various ways to optimise extent management on the file
(e.g. don't truncate extents past EOF when closing the file), but it
is not specific to one particular aspect of the preallocation
implementation.

> >> OTOH, there's plenty of uncommitted space, so if we can condense
> >> the hints down to something small, we could perhaps add it later -
> >> but from your paragraph above, it doesn't sound like it'll be small.
> > 
> > Allocation block size, minimum sane IO size (to avoid page cache RMW
> > cycles or DIO zeroing), minimum prefered IO size (e.g. stripe unit),
> > optimal IO size for bandwidth (e.g. stripe width). I don't think
> > there's much more than that which will be really usable by
> > applications.
> 
> I think this is a minimal set that makes sense, and is manageable for
> both the interface and for users.  Even if it isn't 100% correct for
> every file of every filesystem, it still makes sense for many systems.

That's the aim, isn't it? To expose what is useful to the majority
in a simple manner?

> I'd suggest st_frsize (like BSD statvfs() f_frsize) would be the
> minimum fragment or page size, st_iosize (BSD f_iosize) could be
> the optimal IO size, and "st_stripesize" for the minimum preferred RAID/chunk size.

Personally, I think those names are, well, terribly lacking in
obviousness. Something more along the lines of:

	st_blksize		- file block size
	st_alloc_blksize	- allocation block size/alignment
	st_small_io_size	- IO size/alignment that avoids
				  filesystem/page cache RMW
	st_preferred_io_size	- preferred IO size for general
				  usage.
	st_large_io_size	- IO size/alignment for high
				  bandwidth sequential IO

With the aim that applications tend to use st_preferred_io_size for
all general IO (i.e. the default), st_small_io_size for small IO,
IOPS intensive workloads, and st_large_io_size for writing large
chunks of sequential data.

> One could argue that "st_blksize" is used for the "optimal IO size"
> on Linux today, but this is an overloaded term.  It _appears_ to
> represent the filesystem blocksize, which it usually is not, and on
> BSD st_bsize means the minimum blocksize and has a confusingly
> similar name.  Since any application using this API needs to do some
> extra coding already, we may as well give the structure members good
> names that are not ambiguous.

Well said - I couldn't have stated the case better myself. ;)

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com
