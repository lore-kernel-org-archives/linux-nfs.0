Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:64763 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbAKSQz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 13:16:55 -0500
Date: Sun, 11 Jan 2015 13:16:51 -0500
From: Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH 07/12] fs: export inode_to_bdi and use it in favor of
 mapping->backing_dev_info
Message-ID: <20150111181651.GN25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-8-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420739133-27514-8-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Thu, Jan 08, 2015 at 06:45:28PM +0100, Christoph Hellwig wrote:
> Now that we got ri of the bdi abuse on character devices we can always use
                  ^^^
		  rid

> sb->s_bdi to get at the backing_dev_info for a file, except for the block
> device special case.  Export inode_to_bdi and replace uses of
> mapping->backing_dev_info with it to prepare for the removal of
> mapping->backing_dev_info.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Ah, this is so much better.  Thanks a lot for doing this.  Just one
nit below.

> +struct backing_dev_info *inode_to_bdi(struct inode *inode)
>  {
>  	struct super_block *sb = inode->i_sb;
>  #ifdef CONFIG_BLOCK
> @@ -75,6 +75,7 @@ static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
>  #endif
>  	return sb->s_bdi;
>  }
> +EXPORT_SYMBOL_GPL(inode_to_bdi);

This is rather trivial.  Maybe we wanna make this an inline function?

 Reviewed-by: Tejun Heo <tj@kernel.org>

-- 
tejun
