Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:34160 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab1KJIuD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 03:50:03 -0500
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>, <bergwolf@gmail.com>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>
Date: Thu, 10 Nov 2011 03:49:34 -0500
Subject: RE: [PATCH 3/8] pnfsblock: move find lock page logic out of
 bl_write_pagelist
Message-ID: <F19688880B763E40B28B2B462677FBF805DD054C30@MX09A.corp.emc.com>
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
 <1320851766-1834-4-git-send-email-bergwolf@gmail.com>
 <4EBB8C14.2090209@tonian.com>
In-Reply-To: <4EBB8C14.2090209@tonian.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> On Behalf Of Benny Halevy
> Sent: Thursday, November 10, 2011 4:32 PM
> To: Peng Tao
> Cc: linux-nfs@vger.kernel.org; Trond.Myklebust@netapp.com; Peng, Tao
> Subject: Re: [PATCH 3/8] pnfsblock: move find lock page logic out of
> bl_write_pagelist
> 
> On 2011-11-09 17:16, Peng Tao wrote:
> > Also avoid unnecessary lock_page if page is handled by others.
> >
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> > ---
> >  fs/nfs/blocklayout/blocklayout.c |   78
> ++++++++++++++++++++++++++------------
> >  1 files changed, 54 insertions(+), 24 deletions(-)
> >
> > diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> > index 4ced0b0..e8e13f3 100644
> > --- a/fs/nfs/blocklayout/blocklayout.c
> > +++ b/fs/nfs/blocklayout/blocklayout.c
> > @@ -484,6 +484,56 @@ cleanup:
> >  	return ret;
> >  }
> >
> > +/* Find or create a zeroing page marked being writeback.
> > + * Return ERR_PTR on error, NULL to indicate skip this page and page itself
> > + * to indicate write out.
> > + */
> > +static struct page*
> 
> coding style nit: "page *" rather than "page*"
> 
> > +bl_find_get_zeroing_page(struct inode *inode, pgoff_t index,
> > +			struct pnfs_block_extent *cow_read)
> > +{
> > +	struct page* page;
> 
> checkpatch nit:
> ERROR: "foo* bar" should be "foo *bar"
Thank you! Will change both.


> 
> > +	int locked = 0;
> > +	page = find_get_page(inode->i_mapping, index);
> > +	if (page)
> > +		goto check_page;
> > +
> > +	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
> > +	if (unlikely(!page)) {
> > +		dprintk("%s oom\n", __func__);
> > +		return ERR_PTR(-ENOMEM);
> > +	}
> > +	locked = 1;
> 
> Why not just call find_or_create_page in the first place?
> dealing with both the locked and unlocked cases here just
> seems to add unneeded complexity.
It is to avoid lock page when possible. find_or_create_page() calls find_and_lock_page() but there are cases that the page is already locked by someone (e.g., in nfs_writepage_locked()) and current process has to wait. Pressure tests show many such contention. So I want to optimize it out.

Thanks,
Tao
> 
> Benny
> 
> > +
> > +check_page:
> > +	/* PageDirty: Other will write this out
> > +	 * PageWriteback: Other is writing this out
> > +	 * PageUptodate: It was read before
> > +	 */
> > +	if (PageDirty(page) || PageWriteback(page)) {
> > +		print_page(page);
> > +		if (locked)
> > +			unlock_page(page);
> > +		page_cache_release(page);
> > +		return NULL;
> > +	}
> > +
> > +	if (!locked) {
> > +		lock_page(page);
> > +		if (PageDirty(page) || PageWriteback(page))
> > +			unlock_page(page);
> > +		return NULL;
> > +	}
> > +	if (!PageUptodate(page)) {
> > +		/* New page, readin or zero it */
> > +		init_page_for_write(page, cow_read);
> > +	}
> > +	set_page_writeback(page);
> > +	unlock_page(page);
> > +
> > +	return page;
> > +}
> > +
> >  static enum pnfs_try_status
> >  bl_write_pagelist(struct nfs_write_data *wdata, int sync)
> >  {
> > @@ -543,32 +593,12 @@ fill_invalid_ext:
> >  			dprintk("%s zero %dth page: index %lu isect %llu\n",
> >  				__func__, npg_zero, index,
> >  				(unsigned long long)isect);
> > -			page =
> > -			    find_or_create_page(wdata->inode->i_mapping, index,
> > -						GFP_NOFS);
> > -			if (!page) {
> > -				dprintk("%s oom\n", __func__);
> > -				wdata->pnfs_error = -ENOMEM;
> > +			page = bl_find_get_zeroing_page(wdata->inode, index, cow_read);
> > +			if (unlikely(IS_ERR(page))) {
> > +				wdata->pnfs_error = PTR_ERR(page);
> >  				goto out;
> > -			}
> > -
> > -			/* PageDirty: Other will write this out
> > -			 * PageWriteback: Other is writing this out
> > -			 * PageUptodate: It was read before
> > -			 * sector_initialized: already written out
> > -			 */
> > -			if (PageDirty(page) || PageWriteback(page)) {
> > -				print_page(page);
> > -				unlock_page(page);
> > -				page_cache_release(page);
> > +			} else if (page == NULL)
> >  				goto next_page;
> > -			}
> > -			if (!PageUptodate(page)) {
> > -				/* New page, readin or zero it */
> > -				init_page_for_write(page, cow_read);
> > -			}
> > -			set_page_writeback(page);
> > -			unlock_page(page);
> >
> >  			ret = bl_mark_sectors_init(be->be_inval, isect,
> >  						       PAGE_CACHE_SECTORS);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

