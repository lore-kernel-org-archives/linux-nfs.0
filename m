From: bpm@sgi.com
Subject: Re: [RFC PATCH 1/2] commit_metadata export operation and nfsd_sync2
Date: Wed, 10 Feb 2010 13:53:43 -0600
Message-ID: <20100210195343.GI23654@sgi.com>
References: <20100210003220.6021.74943.stgit@case> <20100210003331.6021.55867.stgit@case> <20100210085614.GA21875@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:42105 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755759Ab0BJTxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Feb 2010 14:53:05 -0500
In-Reply-To: <20100210085614.GA21875@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Christoph, 

Thanks for the suggestions.

On Wed, Feb 10, 2010 at 03:56:14AM -0500, Christoph Hellwig wrote:
> A better calling convention would be for the first paramter to
> always be non-zero (and we could take the file handle for that one),

Yeah that works out much nicer.

> Currently the only caller passing a NULL first argument is
> nfsd_setattr.  If we use ->write_inode as fallback we could just
> pass it as first, if using ->fsync we'd need to take i_mutex before,
> but we might just stick to using ->write_inode to keep things
> simple (and get rid of the NULL file pointer in ->fsync).
> 
> > +	if (export_ops->commit_metadata) {
> > +		if (parent) 
> > +			error = filemap_write_and_wait(p_inode->i_mapping);
> > +		if (child) 
> > +		       	error2 = filemap_write_and_wait(c_inode->i_mapping);
> 
> I think Trond explained that we do not want force data to disk here.

Thought so.  I was making an effort to punch all the same buttons as
before so that behavior wouldn't change for filesystems other than xfs
until they're ready.

> > +		if (parent) {
> > +			error = filemap_write_and_wait(p_inode->i_mapping);
> > +			if (!error && p_inode->i_fop->fsync) 
> > +				error = p_inode->i_fop->fsync(NULL, parent, 0);
> > +		}
> > +		if (child)
> > +			write_inode_now(c_inode, 1);
> > +	}
> 
> Btw, as we don't need to write data to disk this should be a
> sync_inode calls with the following second argument:
> 
> struct writeback_control wbc = {
> 	.sync_mode = WB_SYNC_ALL,
> 	.nr_to_write = 0, /* metadata-only */
> };

So, uh, are you suggesting that I use file_operations.fsync,
write_inode_now, vfs_fsync, write_inode, sync_inode, or
super_operations.write_inode?  Would it be good to stay away from the
inode_lock?

-Ben
