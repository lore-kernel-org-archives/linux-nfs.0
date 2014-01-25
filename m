Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbaAYAz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 19:55:27 -0500
Date: Fri, 24 Jan 2014 19:54:56 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20140124195456.5db4f830@tlielax.poochiereds.net>
In-Reply-To: <7DB95D70-9E9E-49B9-80BE-EB891F5D72DB@primarydata.com>
References: <20131114165027.355613182@bombadil.infradead.org>
	<20131114165042.205194841@bombadil.infradead.org>
	<20131114133551.5d08b5cd@tlielax.poochiereds.net>
	<20131115142847.GA1107@infradead.org>
	<20131115095241.2c5e1cfb@tlielax.poochiereds.net>
	<20131115150204.GA8105@infradead.org>
	<20131115103324.6a3cf978@tlielax.poochiereds.net>
	<20140121142159.210ca0b8@tlielax.poochiereds.net>
	<20140122082414.GA12530@infradead.org>
	<20140122070409.503db5c2@tlielax.poochiereds.net>
	<20140124105213.2c40a783@tlielax.poochiereds.net>
	<1C06779A-6513-4460-9A12-6AAE7E6BD446@primarydata.com>
	<20140124122924.0eb2e6bd@tlielax.poochiereds.net>
	<1390585206.2927.9.camel@leira.trondhjem.org>
	<20140124130013.22f706de@tlielax.poochiereds.net>
	<1390589201.2927.46.camel@leira.trondhjem.org>
	<20140124162104.3a588571@tlielax.poochiereds.net>
	<7DB95D70-9E9E-49B9-80BE-EB891F5D72DB@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Jan 2014 17:39:45 -0700
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 24, 2014, at 14:21, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Fri, 24 Jan 2014 11:46:41 -0700
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >> 
> >> Convert your patch to use wait_on_bit(), and then to call
> >> wait_on_bit_lock() if and only if you see NFS_INO_INVALID_DATA is set.
> >> 
> > 
> > I think that too would be racy...
> > 
> > We have to clear NFS_INO_INVALID_DATA while holding the i_lock, but we
> > can't wait_on_bit_lock() under that. So (pseudocode):
> > 
> > wait_on_bit
> > take i_lock
> > check and clear NFS_INO_INVALID_DATA
> > drop i_lock
> > wait_on_bit_lock
> > 
> > ...so between dropping the i_lock and wait_on_bit_lock, we have a place
> > where another task could check the flag and find it clear.
> 
> 
> 	for(;;) {
> 		wait_on_bit(NFS_INO_INVALIDATING)
> 		/* Optimisation: don’t lock NFS_INO_INVALIDATING
> 		 * if NFS_INO_INVALID_DATA was cleared while we waited.
> 		 */
> 		if (!test_bit(NFS_INO_INVALID_DATA))
> 			return;
> 		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING))
> 			break;
> 	}
> 	spin_lock(inode->i_lock);
> 	if (!test_and_clear_bit(NFS_INO_INVALID_DATA)) {
> 		spin_unlock(inode->i_lock);
> 		goto out_raced;
> 	}
> ….
> out_raced:
> 	clear_bit(NFS_INO_INVALIDATING)
> 	wake_up_bit(NFS_INO_INVALIDATING)
> 
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 

Hmm maybe. OTOH, if we're using atomic bitops do we need to deal with
the spinlock?  I'll ponder it over the weekend and give it a harder
look on Monday.

Thanks for the thoughts so far...
-- 
Jeff Layton <jlayton@redhat.com>
