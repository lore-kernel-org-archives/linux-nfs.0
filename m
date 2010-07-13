Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54309 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753909Ab0GMTvS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 15:51:18 -0400
Subject: Re: [PATCH 1/3] NFS: Fix up the fsync code
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100713011306.GA364@infradead.org>
References: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
	 <20100713011306.GA364@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 13 Jul 2010 15:50:36 -0400
Message-ID: <1279050636.17993.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-07-12 at 21:13 -0400, Christoph Hellwig wrote:
> >  	/* Flush writes to the server and return any errors */
> > -	return nfs_do_fsync(ctx, inode);
> > +	return vfs_fsync(file, 0);
> 
> Either the argument to vfs_fsync or the comment needs some changes.
> datasync = 0 means we don't just flush writes but also metadata.  I
> don't know enough about the NFS CTO guarantees to figure which one you
> actually want.
> 

NFS can't distinguish between a datasync and a full sync: a successful
COMMIT operation guarantees that both data+metadata updates are on disk.
For this reason we ignore the 'datasync' parameter in our fsync
implementation.

Would it perhaps help if I added a comment to that effect in
nfs_file_fsync() itself?

Cheers
  Trond
