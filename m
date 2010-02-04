Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:59340 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757471Ab0BDSai (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 13:30:38 -0500
Date: Thu, 4 Feb 2010 13:30:37 -0500
From: Christoph Hellwig <hch@infradead.org>
To: bpm@sgi.com
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 4/4] If 'wsync' pass datasync=1 to vfs_fsync().
Message-ID: <20100204183037.GA9329@infradead.org>
References: <20100203233755.17677.96582.stgit@case> <20100203234444.17677.32390.stgit@case> <20100204151926.GA22014@infradead.org> <20100204172016.GJ5702@sgi.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100204172016.GJ5702@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 04, 2010 at 11:20:16AM -0600, bpm@sgi.com wrote:
> > I think this is incorrect.  datasync = 1 means to only write out
> > metadata that is required to access the file data.
> 
> My thinking there was that the XFS wsync mount option would have ensured
> that the metadata that changed is already in the log.  I wonder if when
> using the wsync xfs mount option, could one drop the vfs_fsync
> altogether?  Looks to me like O_SYNC would also have taken care of any
> metadata that is required to access the file data.

Indeed, both write_inode_now and vfs_fsync will also cause data to
be written.  But my understanding of nfsd is that we manage the data
writeout separately anyway and we care about the metadata here, which
the placement of these calls would suggest:

	- nfsd_setattr for attribute updates
	- nfsd_create for creating a new file (of any type)
	- nfsd_link for adding a new link

interestingly we use nfsd_sync_dir in all those same places, just for
the parent directory.   So if we want to stick to also writing data
out in the child (which most of them time probably won't be dirty
anyway) we really should make sure to use the same method for both,
be that ->fsync or a new export operation.


