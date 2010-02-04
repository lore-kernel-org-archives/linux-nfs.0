Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39811 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757615Ab0BDSkl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 13:40:41 -0500
Date: Thu, 4 Feb 2010 13:40:40 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, bpm@sgi.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 4/4] If 'wsync' pass datasync=1 to vfs_fsync().
Message-ID: <20100204184040.GA15442@infradead.org>
References: <20100203233755.17677.96582.stgit@case> <20100203234444.17677.32390.stgit@case> <20100204151926.GA22014@infradead.org> <20100204172016.GJ5702@sgi.com> <20100204183037.GA9329@infradead.org> <1265308680.3317.19.camel@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1265308680.3317.19.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 04, 2010 at 01:38:00PM -0500, Trond Myklebust wrote:
> > Indeed, both write_inode_now and vfs_fsync will also cause data to
> > be written.  But my understanding of nfsd is that we manage the data
> > writeout separately anyway and we care about the metadata here, which
> > the placement of these calls would suggest:
> > 
> > 	- nfsd_setattr for attribute updates
> > 	- nfsd_create for creating a new file (of any type)
> > 	- nfsd_link for adding a new link
> 
> Yes. Most operations in NFS are required to be synchronous (the only
> exception being "unstable" write requests), and so those
> fsync/write_inode_now calls are there in order to ensure that the
> metadata and/or directory contents that were changed hits the disk
> before the RPC call completes.

Yeah.  But currently both the fsync and write_inode_now calls will force
those unstable writes to disk.  I'm not sure if that is an intentional
or unintentional side-effect of those metadata operations.
