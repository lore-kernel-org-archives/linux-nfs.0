Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39490 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441Ab0BDSjI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 13:39:08 -0500
Date: Thu, 4 Feb 2010 13:39:08 -0500
From: Christoph Hellwig <hch@infradead.org>
To: bpm@sgi.com
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [RFC PATCH 0/4] wsync export option
Message-ID: <20100204183908.GB9329@infradead.org>
References: <20100203233755.17677.96582.stgit@case> <20100204153006.GC22014@infradead.org> <20100204181529.GK5702@sgi.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100204181529.GK5702@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 04, 2010 at 12:15:29PM -0600, bpm@sgi.com wrote:
> Rather than having X number of synchronous log transactions written
> separately as with wsync you have X number of log transactions written
> out together in one go by vfs_fsync (if datasync==0).  That should be
> faster than wsync.

Indeed, except that there aren't a lot of different transactions
usually.

 - nfsd_setattr is one SETATTR transaction
 - nfsd_create might be multiple transactions, indeed - especially
   the nfsv3 variant that also adds a setattr transaction
 - nfsd_link should be a single one

but yes, doing the log force from nfsd should be a benefit for
the create side at least.  The additional benefit is that we can
just drive it from NFSD and don't need to force mount options on
the fs.  So yes, let's do it from nfsd.

> Trond also suggested an export_operation and I think it's a good idea.
> I'll explore that and repost.

Indeed.  For XFS that export_operation could probably be a lot
simpler than xfs_fsync.  I don't think we need to catch the
non-transactional timestamp and size updates at all, and we're
guaranteed the transaction has already commited.  So the
method might be as simple as:

static int xfs_nfs_force_inode(struct inode *inode)
{
	struct xfs_inode *ip = XFS_I(inode);

	xfs_ilock(ip, XFS_ILOCK_SHARED);
	if (xfs_ipincount(ip)) {
		xfs_lsn_t force_lsn = ip->i_itemp->ili_last_lsn;

		ASSERT(force_lsn);
		xfs_log_force_lsn(ip->i_mount, force_lsn, XFS_LOG_SYNC);
	}
	xfs_iunlock(ip, XFS_ILOCK_SHARED);

	return 0;
}
