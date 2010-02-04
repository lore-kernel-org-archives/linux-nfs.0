Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34031 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753611Ab0BDSiW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 13:38:22 -0500
Subject: Re: [RFC PATCH 4/4] If 'wsync' pass datasync=1 to vfs_fsync().
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: bpm@sgi.com, linux-nfs@vger.kernel.org
In-Reply-To: <20100204183037.GA9329@infradead.org>
References: <20100203233755.17677.96582.stgit@case>
	 <20100203234444.17677.32390.stgit@case>
	 <20100204151926.GA22014@infradead.org> <20100204172016.GJ5702@sgi.com>
	 <20100204183037.GA9329@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Feb 2010 13:38:00 -0500
Message-ID: <1265308680.3317.19.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-02-04 at 13:30 -0500, Christoph Hellwig wrote: 
> On Thu, Feb 04, 2010 at 11:20:16AM -0600, bpm@sgi.com wrote:
> > > I think this is incorrect.  datasync = 1 means to only write out
> > > metadata that is required to access the file data.
> > 
> > My thinking there was that the XFS wsync mount option would have ensured
> > that the metadata that changed is already in the log.  I wonder if when
> > using the wsync xfs mount option, could one drop the vfs_fsync
> > altogether?  Looks to me like O_SYNC would also have taken care of any
> > metadata that is required to access the file data.
> 
> Indeed, both write_inode_now and vfs_fsync will also cause data to
> be written.  But my understanding of nfsd is that we manage the data
> writeout separately anyway and we care about the metadata here, which
> the placement of these calls would suggest:
> 
> 	- nfsd_setattr for attribute updates
> 	- nfsd_create for creating a new file (of any type)
> 	- nfsd_link for adding a new link

Yes. Most operations in NFS are required to be synchronous (the only
exception being "unstable" write requests), and so those
fsync/write_inode_now calls are there in order to ensure that the
metadata and/or directory contents that were changed hits the disk
before the RPC call completes.

Cheers
  Trond
