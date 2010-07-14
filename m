Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12353 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab0GNNSB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jul 2010 09:18:01 -0400
Subject: Re: [PATCH 1/3] NFS: Fix up the fsync code
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100714070008.GA22884@infradead.org>
References: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
	 <20100713011306.GA364@infradead.org>
	 <1279050636.17993.14.camel@heimdal.trondhjem.org>
	 <20100714070008.GA22884@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Jul 2010 09:17:23 -0400
Message-ID: <1279113443.3103.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-07-14 at 03:00 -0400, Christoph Hellwig wrote:
> On Tue, Jul 13, 2010 at 03:50:36PM -0400, Trond Myklebust wrote:
> > NFS can't distinguish between a datasync and a full sync: a successful
> > COMMIT operation guarantees that both data+metadata updates are on disk.
> > For this reason we ignore the 'datasync' parameter in our fsync
> > implementation.
> 
> That's not what the datasync parameter means.
> 
> Both fsync and fdatasync will commit data and metadata to disk, the
> questions is how much metadata we need to commit.  For fdatasync it's
> only the metadata requires to locate the file data on disk, an
> fsync requires everything (which is the above + timestamps basically).
> 
> I suspect for NFS the difference still doesn't matter, I'd just try
> to make it clear.

Right. My point was that in NFSv3 and NFSv4, COMMIT always acts like
fsync(): it commits data + _all_ metadata (i.e. including size
+timestamps) to disk.

The exception is NFSv4.1 with pNFS, where you have an extra
'LAYOUTCOMMIT' operation that tells the metadata server when to write
the size+timestamps (because the WRITE and COMMIT operations are sent to
the data servers). So we might want to distinguish between fsync() and
fdatasync() when we merge that code.

> > Would it perhaps help if I added a comment to that effect in
> > nfs_file_fsync() itself?
> 
> Yes, comments explaining such higher level concepts are always good.

OK. I'll add something to that effect.

Thanks for the review!

  Trond
