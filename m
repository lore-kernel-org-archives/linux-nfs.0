From: bpm@sgi.com
Subject: Re: [RFC PATCH 2/2] xfs_export_operations.commit_metadata
Date: Wed, 10 Feb 2010 14:15:27 -0600
Message-ID: <20100210201527.GJ23654@sgi.com>
References: <20100210003220.6021.74943.stgit@case> <20100210003337.6021.10942.stgit@case> <20100210090750.GB21875@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:58833 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911Ab0BJUOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Feb 2010 15:14:51 -0500
In-Reply-To: <20100210090750.GB21875@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Howdy,

On Wed, Feb 10, 2010 at 04:07:50AM -0500, Christoph Hellwig wrote:
> On Tue, Feb 09, 2010 at 06:33:37PM -0600, Ben Myers wrote:
> > hopefully
> > the XFS gurus can continue to provide guidance.
> 
> Ccing the xfs list would help with that :) 

I'll cross-post the next rev.  ;)

> > +		if (xfs_ipincount(c_xip)) {
> > +			/*
> > +			 * AFAICS the child is always modified after the parent
> > +			 * in nfsd so should always have a larger lsn.
> > +			 */
> > +			if (c_xip->i_itemp->ili_last_lsn > force_lsn) {
> > +				force_lsn = c_xip->i_itemp->ili_last_lsn;
> > +			} else {
> > +				force_lsn = 0; /* whole thing */
> > +			}
> 
> I wouldn't rely on that and always take the larger one.

I am concerned that ili_last_lsn will roll over at some point.  I
haven't figured out how to detect that yet.
 
> Now with the simplification of always having a non-zero first argument
> suggested in the previous mail this might be simplified down to:
> 
> STATIC int
> xfs_fs_nfs_commit_metadata(
> 	struct dentry		*parent,
> 	struct dentry		*child)
> {
> 	struct xfs_inode	*dp = XFS_I(parent->d_inode);
> 	struct xfs_inode	*ip = NULL;
> 	struct xfs_mount	*mp = dp->i_mount;
> 	xfs_lsn_t		force_lsn = 0;
> 	int			error = 0;
> 
> 	if (child) {
> 		ip = XFS_I(child->d_inode);
> 		xfs_lock_two_inodes(dp, ip, XFS_ILOCK_SHARED);
> 	} else {
> 		xfs_ilock(dp, XFS_ILOCK_SHARED);
> 	}
> 
> 	if (xfs_ipincount(dp))
> 		force_lsn = dp->i_itemp->ili_last_lsn;
> 	if (ip && xfs_ipincount(ip))
> 		force_lsn = max(force_lsn, ip->i_itemp->ili_last_lsn);
> 
+	if (force_lsn)
>	 	error = _xfs_log_force_lsn(mp, force_lsn, NULL);
> 
> 	if (ip)
> 		xfs_iunlock(ip, XFS_ILOCK_SHARED);
> 	xfs_iunlock(dp, XFS_ILOCK_SHARED);
> 
> 	return error;
> }

That's nice!

> Note that _xfs_log_force_lsn is new in the XFS tree, mainline still
> has _xfs_log_force with an lsn argument.

I've been working with Bruce's tree.  Not sure how best to handle that.

Thanks,
	Ben
