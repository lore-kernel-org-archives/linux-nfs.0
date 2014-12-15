Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34160 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbaLOQ1M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2014 11:27:12 -0500
Date: Mon, 15 Dec 2014 17:27:05 +0100
From: Jan Kara <jack@suse.cz>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141215162705.GA23887@quack.suse.cz>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun 14-12-14 21:26:56, Omar Sandoval wrote:
> The generic write code locks i_mutex for a direct_IO. Swap-over-NFS
> doesn't grab the mutex because nfs_direct_IO doesn't expect i_mutex to
> be held, but most direct_IO implementations do.
  I think you are speaking about direct IO writes only, aren't you? For DIO
reads we don't hold i_mutex AFAICS. And also for DIO writes we don't
necessarily hold i_mutex - see for example XFS which doesn't take i_mutex
for direct IO writes. It uses it's internal rwlock for this (see
xfs_file_dio_aio_write()). So I think this is just wrong.

								Honza

> Signed-off-by: Omar Sandoval <osandov@osandov.com>
> ---
>  mm/page_io.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 955db8b..1630ac0 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -263,6 +263,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
>  	if (sis->flags & SWP_FILE) {
>  		struct kiocb kiocb;
>  		struct file *swap_file = sis->swap_file;
> +		struct inode *inode = file_inode(swap_file);
>  		struct address_space *mapping = swap_file->f_mapping;
>  		struct bio_vec bv = {
>  			.bv_page = page,
> @@ -283,9 +284,11 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
>  
>  		set_page_writeback(page);
>  		unlock_page(page);
> +		mutex_lock(&inode->i_mutex);
>  		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
>  						&kiocb, &from,
>  						kiocb.ki_pos);
> +		mutex_unlock(&inode->i_mutex);
>  		if (ret == PAGE_SIZE) {
>  			count_vm_event(PSWPOUT);
>  			ret = 0;
> -- 
> 2.1.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
