From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] xfs_export_operations.commit_metadata
Date: Fri, 12 Feb 2010 15:35:59 -0500
Message-ID: <20100212203559.GA28731@infradead.org>
References: <20100211220454.26466.37578.stgit@case> <20100211220505.26466.99037.stgit@case> <1265986006.3201.112.camel@doink1> <20100212174706.GB22633@infradead.org> <20100212195647.GQ23654@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, Alex Elder <aelder@sgi.com>,
	bfields@fieldses.org, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: bpm@sgi.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37060 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757584Ab0BLUgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2010 15:36:00 -0500
In-Reply-To: <20100212195647.GQ23654@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 12, 2010 at 01:56:47PM -0600, bpm@sgi.com wrote:
> I chose not implement that suggestion because I prefer not to rely upon
> the coincidence that the child be modified last and synced first in
> knfsd.

It does ot rely on that coincidence for correctness, just for a small
performance optimization.

> It is better that the intent of the patch be clear, and that
> filesystems other than xfs also have enough information to sort out how
> to sync more efficiently.  knfsd shouldn't be forced to sync in a
> specific order just because that's what works best for xfs.  Or, mebbe
> it should and I'm being thick.  ;)

The order of parent and child only happens in the create case where
NFS does a separate ->setattr call.  For all the operations handled
by the filesystem parent and child are in the same transaction for
every transactional filesystem.

> > This keeps the calling convention quite a bit simpler,
> > and also means we don't have to bother with locking two inodes or lsn
> > comparisms.
> 
> Don't need the ilock to check pincount?

Ah sorry, that should have read not bothering with locking two inodes
at the same time, which always is a bit troublesome.  We do need to lock
the inode for looking at the pincount.

> > We can deal with that by either commiting the old variant to the nfs
> > tree and then leaving sending Stephen a patch to fix it up in -next,
> > or just not apply the xfs commit_metadata implementation yet, and wait
> > for it until both the xfs and nfs trees have hit mainline.
> 
> Yeah.  I don't know who Stephen is.

Stephen Rothwell is the maintainer of the linux-next tree.

