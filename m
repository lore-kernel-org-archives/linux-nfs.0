Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:47142 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbbAKRcN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 12:32:13 -0500
Date: Sun, 11 Jan 2015 12:32:09 -0500
From: Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH 04/12] block_dev: only write bdev inode on close
Message-ID: <20150111173209.GK25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-5-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420739133-27514-5-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Thu, Jan 08, 2015 at 06:45:25PM +0100, Christoph Hellwig wrote:
> Since "bdi: reimplement bdev_inode_switch_bdi()" the block device code

018a17bdc865 ("bdi: reimplement bdev_inode_switch_bdi()") would be
better.

> writes out all dirty data whenever switching the backing_dev_info for
> a block device inode.  But a block device inode can only be dirtied
> when it is in use, which means we only have to write it out on the
> final blkdev_put, but not when doing a blkdev_get.
> @@ -1464,9 +1469,11 @@ static void __blkdev_put(struct block_device *bdev, fmode_t mode, int for_part)
>  		WARN_ON_ONCE(bdev->bd_holders);
>  		sync_blockdev(bdev);
>  		kill_bdev(bdev);
> -		/* ->release can cause the old bdi to disappear,
> -		 * so must switch it out first
> +		/*
> +		 * ->release can cause the queue to disappaear, so flush all
                                                         ^^^^^
							 typo
> +		 * dirty data before.
>  		 */
> +		bdev_write_inode(bdev->bd_inode);

Is this an optimization or something necessary for the following
changes?  If latter, maybe it's a good idea to state why this is
necessary in the description?  Otherwise,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
