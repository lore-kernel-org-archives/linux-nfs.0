Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57228 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954AbbANNA0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 08:00:26 -0500
Date: Wed, 14 Jan 2015 14:00:21 +0100
From: Jan Kara <jack@suse.cz>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: Re: [PATCH 05/12] block_dev: get bdev inode bdi directly from the
 block device
Message-ID: <20150114130021.GG10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-6-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421228561-16857-6-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 14-01-15 10:42:34, Christoph Hellwig wrote:
> Directly grab the backing_dev_info from the request_queue instead of
> detouring through the address_space.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Tejun Heo <tj@kernel.org>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/fs-writeback.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 2d609a5..e8116a4 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -69,10 +69,10 @@ EXPORT_SYMBOL(writeback_in_progress);
>  static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
>  {
>  	struct super_block *sb = inode->i_sb;
> -
> +#ifdef CONFIG_BLOCK
>  	if (sb_is_blkdev_sb(sb))
> -		return inode->i_mapping->backing_dev_info;
> -
> +		return blk_get_backing_dev_info(I_BDEV(inode));
> +#endif
>  	return sb->s_bdi;
>  }
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
