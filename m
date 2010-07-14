Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56090 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525Ab0GNHAL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jul 2010 03:00:11 -0400
Date: Wed, 14 Jul 2010 03:00:08 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Fix up the fsync code
Message-ID: <20100714070008.GA22884@infradead.org>
References: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
 <20100713011306.GA364@infradead.org>
 <1279050636.17993.14.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1279050636.17993.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jul 13, 2010 at 03:50:36PM -0400, Trond Myklebust wrote:
> NFS can't distinguish between a datasync and a full sync: a successful
> COMMIT operation guarantees that both data+metadata updates are on disk.
> For this reason we ignore the 'datasync' parameter in our fsync
> implementation.

That's not what the datasync parameter means.

Both fsync and fdatasync will commit data and metadata to disk, the
questions is how much metadata we need to commit.  For fdatasync it's
only the metadata requires to locate the file data on disk, an
fsync requires everything (which is the above + timestamps basically).

I suspect for NFS the difference still doesn't matter, I'd just try
to make it clear.

> Would it perhaps help if I added a comment to that effect in
> nfs_file_fsync() itself?

Yes, comments explaining such higher level concepts are always good.

