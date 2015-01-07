Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:59249 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064AbbAGKkP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 05:40:15 -0500
Date: Wed, 7 Jan 2015 11:40:10 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 17/18] xfs: implement pnfs export operations
Message-ID: <20150107104010.GD28783@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-18-git-send-email-hch@lst.de> <20150107002434.GG31508@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150107002434.GG31508@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 07, 2015 at 11:24:34AM +1100, Dave Chinner wrote:
> > diff --git a/fs/xfs/xfs_fsops.c b/fs/xfs/xfs_fsops.c
> > index fdc6422..2b86be8 100644
> > --- a/fs/xfs/xfs_fsops.c
> > +++ b/fs/xfs/xfs_fsops.c
> > @@ -601,6 +601,8 @@ xfs_growfs_data(
> >  	if (!mutex_trylock(&mp->m_growlock))
> >  		return -EWOULDBLOCK;
> >  	error = xfs_growfs_data_private(mp, in);
> > +	if (!error)
> > +		mp->m_generation++;
> >  	mutex_unlock(&mp->m_growlock);
> >  	return error;
> >  }
> 
> I couldn't find an explanation of what this generation number is
> for. What are it's semantics w.r.t. server crashes?

The generation is incremented when we grow the filesystem, so that
a new layout (block mapping) returned to the clіent referers to the
new NFS device ID, which will make the client aware of the new size.

The device IDs aren't persistent, so after a server crash / reboot
we'll start at zero again.

I'll add comments explaining this to the code.

> Why does this function get passed an offset it is not actually used?

Historic reasons..

> > +static int
> > +xfs_fs_update_flags(
> > +	struct xfs_inode	*ip)
> > +{
> > +	struct xfs_mount	*mp = ip->i_mount;
> > +	struct xfs_trans	*tp;
> > +	int			error;
> > +
> > +	/*
> > +	 * Update the mode, and prealloc flag bits.
> > +	 */
> > +	tp = xfs_trans_alloc(mp, XFS_TRANS_WRITEID);
> > +	error = xfs_trans_reserve(tp, &M_RES(mp)->tr_writeid, 0, 0);
> > +	if (error) {
> > +		xfs_trans_cancel(tp, 0);
> > +		return error;
> > +	}
> > +
> > +	xfs_ilock(ip, XFS_ILOCK_EXCL);
> > +	xfs_trans_ijoin(tp, ip, XFS_ILOCK_EXCL);
> > +	ip->i_d.di_mode &= ~S_ISUID;
> > +	if (ip->i_d.di_mode & S_IXGRP)
> > +		ip->i_d.di_mode &= ~S_ISGID;
> > +
> > +	ip->i_d.di_flags |= XFS_DIFLAG_PREALLOC;
> > +
> > +	xfs_trans_log_inode(tp, ip, XFS_ILOG_CORE);
> > +	return xfs_trans_commit(tp, 0);
> > +}
> 
> That needs timestamp changes as well. i.e.:
> 
> 	xfs_trans_ichgtime(tp, ip, XFS_ICHGTIME_MOD | XFS_ICHGTIME_CHG);

The time stamps are only updated when we actually commit the data.
Updating them here might be harmless, but I'll have to dig into the
protocol specification and tests a bit more to check if doing the
additional timestamp update would be harmless.

> > +
> > +/*
> > + * Get a layout for the pNFS client.
> > + *
> > + * Note that in the allocation case we do force out the transaction here.
> > + * There is no metadata update that is required to be stable for NFS
> > + * semantics, and layouts are not valid over a server crash.  Instead
> > + * we'll have to be careful in the commit routine as it might pass us
> > + * blocks for an allocation that never made it to disk in the recovery
> > + * case.
> 
> I think you are saying that because block allocation is an async
> transaction, then we have to deal with the possibility that we crash
> before the transaction hits the disk.
> 
> How often do we have to allocate
> new blocks like this? Do we need to use async transactions for this
> case, or should we simply do the brute force thing (by making the
> allocation transaction synchronous) initially and then, if
> performance problems arise, optimise from there?

Every block allocation from a pNFS client goes through this path, so
yes it is performance critical.

> > +	xfs_map_iomap(ip, iomap, &imap, offset);
> > +	*device_generation = mp->m_generation;
> 
> So whenever the server first starts up the generation number in a
> map is going to be zero - what purpose does this actually serve?

So that we can communicate if a device was grown to the client, which
in this case needs to re-read the device information.

> > +		if (!length)
> > +			continue;
> > +
> > +		error = xfs_iomap_write_unwritten(ip, start, length);
> > +		if (error)
> > +			goto out_drop_iolock;
> > +	}
> > +
> > +	/*
> > +	 * Make sure reads through the pagecache see the new data.
> > +	 */
> > +	invalidate_inode_pages2(inode->i_mapping);
> 
> Probably should do that first. Also, what happens if there is local
> dirty data on the file at this point? Doesn't this just toss them
> away?

If there was local data it will be tossed.  For regular writes this can't
happen because we really outstanding layouts in the write path.  For
mmap we for now ignore this problem, as a pNFS server should generally
not be used locally.  
