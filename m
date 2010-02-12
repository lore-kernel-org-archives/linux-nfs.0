From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] xfs_export_operations.commit_metadata
Date: Fri, 12 Feb 2010 12:47:07 -0500
Message-ID: <20100212174706.GB22633@infradead.org>
References: <20100211220454.26466.37578.stgit@case> <20100211220505.26466.99037.stgit@case> <1265986006.3201.112.camel@doink1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Myers <bpm@sgi.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Alex Elder <aelder@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52219 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756992Ab0BLRrK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2010 12:47:10 -0500
In-Reply-To: <1265986006.3201.112.camel@doink1>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 12, 2010 at 08:46:46AM -0600, Alex Elder wrote:
> On Thu, 2010-02-11 at 16:05 -0600, Ben Myers wrote:
> > This is the commit_metadata export operation for XFS, including the changes
> > suggested by hch and dgc:
> > 
> > - Takes two two inodes instead of dentries and can assume the parent is
> > always set.
> 
> I alluded to this in my review of the first patch.
> This could be changed considered in a more generic
> sense, "sync one or two inodes' metadata" rather
> than presupposing the two inodes have a parent/child
> relationship.

Or just implement my later suggestion to only pass one inode to the
method and cal in on both inodes.   For the non-create case where
we have only one transaction to deal with fhr first call will take
care of it and unpin the second inode by forcing the log buffer out.
For the create case we need to make sure to call it on the child first
so that we force out the setattr transaction which also forced out the
earlier one.   This keeps the calling convention quite a bit simpler,
and also means we don't have to bother with locking two inodes or lsn
comparisms.

> > - Uses xfs_lock_two_inodes for the ilock.
> > 
> > - Forces the log up to the larger lsn of parent and child.
> > 
> > - Uses XFS_LSN_CMP for lsn comparison.
> > 
> > - Doesn't force the log if nobody had a pincount.
> 
> So if the log doesn't get forced, what causes the
> desired metadata sync expected as a result of this
> call?  (Maybe this is a dumb question.)

Inodes get pinned on transaction commit, and unpinned when the log I/O
for that transaction completes.  If the inode is not pinned this implies
it has already been written to disk, e.g. because we're filling the log
so fast that we need to write out more log buffers in that tiny window
between the metada operation and the commit_metadata call.

> > +		force_lsn = ip->i_itemp->ili_last_lsn;
> > +	}
> > +
> > +	if (force_lsn != NULLCOMMITLSN) {
> > +		error = _xfs_log_force(mp, force_lsn,
> > +				XFS_LOG_FORCE | XFS_LOG_SYNC, NULL);
> 
> You want this here:
>  error = xfs_log_force_lsn(mp, force_lsn, XFS_LOG_FORCE | XFS_LOG_SYNC);

In the XFS tree we do want either

	xfs_log_force_lsn(mp, force_lsn, XFS_LOG_SYNC);

or
	error = _xfs_log_force_lsn(mp, force_lsn, XFS_LOG_SYNC, NULL);

if we care enough about the returned error.  But Ben is working against
the NFS tree which doesn't have that change yet.

We can deal with that by either commiting the old variant to the nfs
tree and then leaving sending Stephen a patch to fix it up in -next,
or just not apply the xfs commit_metadata implementation yet, and wait
for it until both the xfs and nfs trees have hit mainline.

