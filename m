Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58563 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757450Ab0BDSwa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 13:52:30 -0500
Subject: Re: [RFC PATCH 4/4] If 'wsync' pass datasync=1 to vfs_fsync().
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: bpm@sgi.com, linux-nfs@vger.kernel.org
In-Reply-To: <20100204184040.GA15442@infradead.org>
References: <20100203233755.17677.96582.stgit@case>
	 <20100203234444.17677.32390.stgit@case>
	 <20100204151926.GA22014@infradead.org> <20100204172016.GJ5702@sgi.com>
	 <20100204183037.GA9329@infradead.org> <1265308680.3317.19.camel@localhost>
	 <20100204184040.GA15442@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Feb 2010 13:52:07 -0500
Message-ID: <1265309527.3317.25.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-02-04 at 13:40 -0500, Christoph Hellwig wrote: 
> On Thu, Feb 04, 2010 at 01:38:00PM -0500, Trond Myklebust wrote:
> > > Indeed, both write_inode_now and vfs_fsync will also cause data to
> > > be written.  But my understanding of nfsd is that we manage the data
> > > writeout separately anyway and we care about the metadata here, which
> > > the placement of these calls would suggest:
> > > 
> > > 	- nfsd_setattr for attribute updates
> > > 	- nfsd_create for creating a new file (of any type)
> > > 	- nfsd_link for adding a new link
> > 
> > Yes. Most operations in NFS are required to be synchronous (the only
> > exception being "unstable" write requests), and so those
> > fsync/write_inode_now calls are there in order to ensure that the
> > metadata and/or directory contents that were changed hits the disk
> > before the RPC call completes.
> 
> Yeah.  But currently both the fsync and write_inode_now calls will force
> those unstable writes to disk.  I'm not sure if that is an intentional
> or unintentional side-effect of those metadata operations.

Syncing the unstable writes before the client sends a COMMIT request is
completely unnecessary. If we can avoid that, then that might indeed
give a performance boost for some workloads.

Cheers
  Trond
