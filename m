Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40604 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbcFOHNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 03:13:44 -0400
Date: Wed, 15 Jun 2016 00:13:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Message-ID: <20160615071343.GC4318@infradead.org>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +void
> +nfs_lock_bio(struct nfs_inode *nfsi)

bio stands for buffered I/O?  This could really use a more descriptive
name and/or a comment..

> +{
> +	/* Be an optimist! */
> +	down_read(&nfsi->io_lock);
> +	if (test_bit(NFS_INO_ODIRECT, &nfsi->flags) == 0)
> +		return;
> +	up_read(&nfsi->io_lock);

So if no direct I/O is going on this locks shared?

> +	/* Slow path.... */
> +	down_write(&nfsi->io_lock);
> +	clear_bit(NFS_INO_ODIRECT, &nfsi->flags);
> +	downgrade_write(&nfsi->io_lock);

The whole locking here seems rather confusing.  Why not use the XFS
locking model:

buffered write:		exclusive
buffered read:		shared
direct write:		shared (exclusive for pagecache invalidate)
direct read:		shared (exclusive for pagecache invalidate)

The nice thing is than in 4.7-rc i_mutex has been replaced with a
rw_mutex so you can just use that in shared mode for direct I/O
as-is without needing any new lock.
