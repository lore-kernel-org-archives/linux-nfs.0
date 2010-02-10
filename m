From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 1/2] commit_metadata export operation and nfsd_sync2
Date: Wed, 10 Feb 2010 16:56:59 -0500
Message-ID: <20100210215659.GA25004@infradead.org>
References: <20100210003220.6021.74943.stgit@case> <20100210003331.6021.55867.stgit@case> <20100210085614.GA21875@infradead.org> <20100210195343.GI23654@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
To: bpm@sgi.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51641 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab0BJV5A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 16:57:00 -0500
In-Reply-To: <20100210195343.GI23654@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 10, 2010 at 01:53:43PM -0600, bpm@sgi.com wrote:
> > I think Trond explained that we do not want force data to disk here.
> 
> Thought so.  I was making an effort to punch all the same buttons as
> before so that behavior wouldn't change for filesystems other than xfs
> until they're ready.

Well, the data writing really isn't filesystem dependent, but depends
on the nfs semantics.

> > Btw, as we don't need to write data to disk this should be a
> > sync_inode calls with the following second argument:
> > 
> > struct writeback_control wbc = {
> > 	.sync_mode = WB_SYNC_ALL,
> > 	.nr_to_write = 0, /* metadata-only */
> > };
> 
> So, uh, are you suggesting that I use file_operations.fsync,
> write_inode_now, vfs_fsync, write_inode, sync_inode, or
> super_operations.write_inode?  Would it be good to stay away from the
> inode_lock?

->write_inode is the method that both write_inode_now and sync_inode
end up calling, in fact write_inode_now could be implemented on top
of sync_inode.  The difference is that write_inode_now already
prepares a writeback_control structure that already writes out data,
and optionally waits for data I/O to complete, while sync_inode
leaves all that to the caller.  If we dont want to bother with
writing out data we have to use sync_inode if we want to use
the ->write_inode path.  Given that we want to make changes that
happened through the filesystem metadata methods stable and not
user data using ->write_inode makes more sense to me than ->fsync.
Especially as ->fsync normally requires a file pointer and only
allows that to be NULL for nfs, which requires special cases all
over the place that we could get rid of.

The global lock in that path is not nice, but Nick Piggin has already
started splitting it up.
