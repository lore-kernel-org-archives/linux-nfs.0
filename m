Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:43196 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757665Ab2D1Aii (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 20:38:38 -0400
Date: Sat, 28 Apr 2012 10:38:33 +1000
From: Dave Chinner <david@fromorbit.com>
To: Andreas Dilger <adilger@whamcloud.com>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Message-ID: <20120428003833.GH9541@dastard>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <20120427010610.GE9541@dastard>
 <ED5B8F1B-6C99-4516-85FA-A767E94B635F@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ED5B8F1B-6C99-4516-85FA-A767E94B635F@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 09:22:04PM -0600, Andreas Dilger wrote:
> On 2012-04-26, at 7:06 PM, Dave Chinner wrote:
> > On Thu, Apr 19, 2012 at 03:05:58PM +0100, David Howells wrote:
> >> 
> >> Implement a pair of new system calls to provide extended and further extensible stat functions.
> >> 
> >> The second of the associated patches is the main patch that provides these new system calls:
> >> 
> >> 	ssize_t ret = xstat(int dfd,
> >> 			    const char *filename,
> >> 			    unsigned atflag,
> >> 			    unsigned mask,
> >> 			    struct xstat *buffer);
> >> 
> >> 	ssize_t ret = fxstat(int fd,
> >> 			     unsigned atflag,
> >> 			     unsigned mask,
> >> 			     struct xstat *buffer);
> >> 
> >> which are more fully documented in the first patch's description.
> >> 
> >> These new stat functions provide a number of useful features, in summary:
> >> 
> >> (1) More information: creation time, inode generation number, data
> >>     version number, flags/attributes.  A subset of these is available
> >>     through a number of filesystems (CIFS, NFS, AFS, Ext4 and BTRFS).
> > 
> > If we are adding per-inode flags, then what do we do with filesystem
> > specific flags? e.g. XFS has quite a number of per-inode flags that
> > don't align with any other filesystem (e.g. filestream allocator,
> > real time file, behaviour inheritence flags, etc), but may be useful
> > to retrieve in such a call. We currently have an ioctl to get that
> > information from each inode. Have you thought about how to handle
> > such flags?
> 
> I'm sympathetic to your cause, but I don't want this to degrade into
> the same morass that it did last time when every attribute under the
> sun was added to the call.

Understood, which is why I'm not asking for everything under the sun
to be supported. I'm more interested in finding the useful subset of
information that a typical application might make use of.

> The intent is to replace the stat() call
> with something that can avoid overhead on filesystems for which some
> attributes are expensive, and that applications may not need.  Some
> common attributes were added that are used by multiple filesystems.
> 
> If it is too filesystem-specific, and there is little possibility
> that these attributes will be usable on other filesystems, then it
> should remain a filesystem specific ioctl() call.

Right, that's why I didn't mention the real-time bits, the
filestream allocation bits, or other things that are tightly bound
to the way XFS works....

> If you can make
> a case that these attributes have value on a few other filesystems,
> and applications are reasonably likely to be able to use them, and
> their addition does not make the API overly complex, then suggest
> away.

Exactly my thoughts ;)

> > Along the same lines, filesytsems can have different allocation
> > constraints to IO the filesystem block size - ext4 with it's
> > bigalloc hack, XFS with it's per-inode extent size hints and the
> > realtime device, etc. Then there's optimal IO characteristics
> > (e.g. geometery hints like stripe unit/stripe width for the
> > allocation policy of that given file) that applications could use
> > if they were present rather than having to expose them through
> > ioctls that nobody even knows about...
> 
> There is already "optimal IO size" that the application can use,
> how do the geometry hints differ?

Have a look at how XFS overloads stat.st_blksize depending on the
filesystem and inode config. It's amazingly convoluted, and based on
a combination of filesystem geometry, inode bits and mount options:

xfs_vn_getattr()
....
                if (XFS_IS_REALTIME_INODE(ip)) {
                        /*
                         * If the file blocks are being allocated from a
                         * realtime volume, then return the inode's realtime
                         * extent size or the realtime volume's extent size.
                         */
                        stat->blksize =
                                xfs_get_extsz_hint(ip) << mp->m_sb.sb_blocklog;
                } else
                        stat->blksize = xfs_preferred_iosize(mp);
......

xfs_extlen_t
xfs_get_extsz_hint(
        struct xfs_inode        *ip)
{
        if ((ip->i_d.di_flags & XFS_DIFLAG_EXTSIZE) && ip->i_d.di_extsize)
                return ip->i_d.di_extsize;
        if (XFS_IS_REALTIME_INODE(ip))
                return ip->i_mount->m_sb.sb_rextsize;
        return 0;
}

....

static inline unsigned long
xfs_preferred_iosize(xfs_mount_t *mp)
{
        if (mp->m_flags & XFS_MOUNT_COMPAT_IOSIZE)
                return PAGE_CACHE_SIZE;
        return (mp->m_swidth ?
                (mp->m_swidth << mp->m_sb.sb_blocklog) :
                ((mp->m_flags & XFS_MOUNT_DFLT_IOSIZE) ?
                        (1 << (int)MAX(mp->m_readio_log, mp->m_writeio_log)) :
                        PAGE_CACHE_SIZE));
}

All of that can be exported as 4 parameters for normal files:

	allocation block size 	(extent size hint)
	minimum io size		(PAGE_CACHE_SIZE)
	preferred minimum IO size (mp->m_readio_log/mp->m_writeio_log)
	best aligned IO size	(stripe width)

And for realtime files it's a bit different because of the
block-based bitmap allocator it uses:

	allocation block size	(extent size hint)
	minimum io size		(PAGE_CACHE_SIZE)
	preferred minimum IO size (extent size hint)
	best aligned IO size	(some multiple of extent size hint)

> Userspace is able to handle
> st_blksize of several MB in size without problems, and any sane
> application will do the IO sized + aligned on multiples of this.

Actually, some applications still have problems with that. That's
the reason we only expose stripe widths in st_blksize when a mount
option is set. Stripe widths are known to get into the tens of MB,
and applications using st_blksize for memory allocation of IO
buffers tend to get into trouble with those.

That's why I'd prefer specific optimal IO hints - we don't have to
overload st_blksize with lots of meanings to pass what is relatively
trivial information back to the application.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
