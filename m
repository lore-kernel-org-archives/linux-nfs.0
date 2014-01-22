Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153AbaAVMEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jan 2014 07:04:34 -0500
Date: Wed, 22 Jan 2014 07:04:09 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20140122070409.503db5c2@tlielax.poochiereds.net>
In-Reply-To: <20140122082414.GA12530@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
	<20131114165042.205194841@bombadil.infradead.org>
	<20131114133551.5d08b5cd@tlielax.poochiereds.net>
	<20131115142847.GA1107@infradead.org>
	<20131115095241.2c5e1cfb@tlielax.poochiereds.net>
	<20131115150204.GA8105@infradead.org>
	<20131115103324.6a3cf978@tlielax.poochiereds.net>
	<20140121142159.210ca0b8@tlielax.poochiereds.net>
	<20140122082414.GA12530@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 22 Jan 2014 00:24:14 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jan 21, 2014 at 02:21:59PM -0500, Jeff Layton wrote:
> > In any case, this helps but it's a little odd. With this patch, you add
> > an invalidate_inode_pages2 call prior to doing the DIO. But, you've
> > also left in the call to nfs_zap_mapping in the completion codepath.
> > 
> > So now, we shoot down the mapping prior to doing a DIO write, and then
> > mark the mapping for invalidation again when the write completes. Was
> > that intentional?
> > 
> > It seems a little excessive and might hurt performance in some cases.
> > OTOH, if you mix buffered and DIO you're asking for trouble anyway and
> > this approach seems to give better cache coherency.
> 
> Thile follows the model implemented and documented in
> generic_file_direct_write().
> 

Ok, thanks. That makes sense, and the problem described in those
comments is almost exactly the one I've seen in practice.

I'm still not 100% thrilled with the way that the NFS_INO_INVALID_DATA
flag is handled, but that really has nothing to do with this patchset.

You can add my Tested-by to the set if you like...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
