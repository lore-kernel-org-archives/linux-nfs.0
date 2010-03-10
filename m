From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 10/12] NFS: Simplify nfs_wb_page()
Date: Wed, 10 Mar 2010 14:31:22 -0500
Message-ID: <1268249482.3096.76.camel@localhost.localdomain>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
	 <20100125221545.16750.19154.stgit@localhost.localdomain>
	 <16839.1268247109@jrobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab0CJTbe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Mar 2010 14:31:34 -0500
In-Reply-To: <16839.1268247109@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-03-11 at 03:51 +0900, J. R. Okajima wrote: 
> 
> INFO: task kswapd0:305 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> kswapd0       D 0000000000000001     0   305      2 0x00000000
>  ffff88001f21d4f0 0000000000000046 ffff88001fdea680 ffff88001f21c000
>  ffff88001f21dfd8 ffff88001f21c000 ffff88001f21dfd8 ffff88001f21dfd8
>  ffff88001fdea040 0000000000014c00 0000000000000001 ffff88001fdea040
> Call Trace:
>  [<ffffffff8146155d>] io_schedule+0x4d/0x70
>  [<ffffffff810d2be5>] sync_page+0x65/0xa0
>  [<ffffffff81461b12>] __wait_on_bit_lock+0x52/0xb0
>  [<ffffffff810d2b80>] ? sync_page+0x0/0xa0
>  [<ffffffff810d2b64>] __lock_page+0x64/0x70
>  [<ffffffff81070ce0>] ? wake_bit_function+0x0/0x40
>  [<ffffffff810df1d4>] truncate_inode_pages_range+0x344/0x4a0
>  [<ffffffff810df340>] truncate_inode_pages+0x10/0x20
>  [<ffffffff8112cbfe>] generic_delete_inode+0x15e/0x190
>  [<ffffffff8112cc8d>] generic_drop_inode+0x5d/0x80
>  [<ffffffff8112bb88>] iput+0x78/0x80
>  [<ffffffff811bc908>] nfs_dentry_iput+0x38/0x50
>  [<ffffffff811285f4>] dentry_iput+0x84/0x110
>  [<ffffffff811286ae>] d_kill+0x2e/0x60
>  [<ffffffff8112912a>] dput+0x7a/0x170
>  [<ffffffff8111e925>] path_put+0x15/0x40
>  [<ffffffff811c3a44>] __put_nfs_open_context+0xa4/0xb0
>  [<ffffffff811cb5d0>] ? nfs_free_request+0x0/0x50
>  [<ffffffff811c3b0b>] put_nfs_open_context+0xb/0x10
>  [<ffffffff811cb5f9>] nfs_free_request+0x29/0x50
>  [<ffffffff81234b7e>] kref_put+0x8e/0xe0
>  [<ffffffff811cb594>] nfs_release_request+0x14/0x20
>  [<ffffffff811cf769>] nfs_find_and_lock_request+0x89/0xa0
>  [<ffffffff811d1180>] nfs_wb_page+0x80/0x110
>  [<ffffffff811c0770>] nfs_release_page+0x70/0x90
>  [<ffffffff810d18ee>] try_to_release_page+0x5e/0x80
>  [<ffffffff810e1178>] shrink_page_list+0x638/0x860
>  [<ffffffff810e19de>] shrink_zone+0x63e/0xc40
>  [<ffffffff81464437>] ? _raw_spin_unlock+0x57/0x70
>  [<ffffffff8107641e>] ? up_read+0x1e/0x40
>  [<ffffffff810e26a9>] kswapd+0x6c9/0xa20
>  [<ffffffff810df700>] ? isolate_pages_global+0x0/0x280
>  [<ffffffff81070ca0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff810e1fe0>] ? kswapd+0x0/0xa20
>  [<ffffffff810706d6>] kthread+0x96/0xb0
>  [<ffffffff8100b5a4>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81464f14>] ? restore_args+0x0/0x30
>  [<ffffffff81070640>] ? kthread+0x0/0xb0
>  [<ffffffff8100b5a0>] ? kernel_thread_helper+0x0/0x10
> no locks held by kswapd0/305.
> 
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index ae8d022..ffa5463 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -491,8 +491,13 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
>  {
>  	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
>  
> -	if (gfp & __GFP_WAIT)
> +	if (gfp & __GFP_WAIT) {
> +		struct inode *inode;
> +
> +		inode = igrab(page->mapping->host);
>  		nfs_wb_page(page->mapping->host, page);
> +		iput(inode);
> +	}
>  	/* If PagePrivate() is set, then the page is not freeable */
>  	if (PagePrivate(page))
>  		return 0;
> 
> 
> J. R. Okajima

>From your trace it looks as if the problem is that the nfs_wb_page() is
triggering a dentry release, which deadlocks with in
truncate_inode_pages() because the _caller_ of nfs_release_page() holds
a page lock.

As far as I can see, your iput() call above can deadlock in exactly the
same way.

Note that shrink_page_list() is the only function that does this sort of
thing without holding a reference to the inode.

Cheers
  Trond
