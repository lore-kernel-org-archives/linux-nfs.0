Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21405 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756862Ab0LAUbb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 15:31:31 -0500
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id oB1KVUF2009871
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 12:31:30 -0800
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq1.eem.corp.google.com with ESMTP id oB1KVRxS004228
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 12:31:28 -0800
Received: by pzk2 with SMTP id 2so1541365pzk.18
        for <linux-nfs@vger.kernel.org>; Wed, 01 Dec 2010 12:31:27 -0800 (PST)
Date: Wed, 1 Dec 2010 12:31:18 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
In-Reply-To: <1291234251.6609.39.camel@heimdal.trondhjem.org>
Message-ID: <alpine.LSU.2.00.1012011224460.18014@tigran.mtv.corp.google.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com> <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com> <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com> <1291229669.6609.24.camel@heimdal.trondhjem.org> <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
 <1291234251.6609.39.camel@heimdal.trondhjem.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Adding Nick Piggin back to the Cc.

I do think it needs to be freepage(struct address_space *, struct page *),
even if you happen not to need to know the mapping in the NFS case.

On Wed, 1 Dec 2010, Trond Myklebust wrote:
> On Wed, 2010-12-01 at 11:47 -0800, Linus Torvalds wrote:
> > On Wed, Dec 1, 2010 at 10:54 AM, Trond Myklebust
> > <Trond.Myklebust@netapp.com> wrote:
> > >
> > > Hmm... Looking again at the problem, it appears that the same callback
> > > needs to be added to truncate_complete_page() and
> > > invalidate_complete_page2(). Otherwise we end up in a situation where
> > > the page can sometimes be removed from the page cache without calling
> > > freepage().
> > 
> > Yes, I think any caller of __remove_from_page_cache() should do it
> > once it has dropped all locks.
> > 
> > And to be consistent with that rule, even in the __remove_mapping()
> > function I suspect the code to call ->freepage() might as well be done
> > only in the __remove_from_page_cache() case (ie not in the
> > PageSwapCache() case).
> > 
> > Then, add the case to the end of "remove_page_cache()" itself, and now
> > it's really easy to just grep for __remove_from_page_cache() and make
> > sure they all do it.
> > 
> > That sounds sane, no?
> > 
> >                 Linus
> 
> Something like the following then?
> 
> -----------------------------------------------------------------------------------------
> From 3a46d5eab1ac6efe9dfaf873e23de7589e0acccc Mon Sep 17 00:00:00 2001
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 1 Dec 2010 13:35:19 -0500
> Subject: [PATCH] Call the filesystem back whenever a page is removed from the page cache
> 
> NFS needs to be able to release objects that are stored in the page
> cache once the page itself is no longer visible from the page cache.
> 
> This patch adds a callback to the address space operations that allows
> filesystems to perform page cleanups once the page has been removed
> from the page cache.
> 
> Original patch by: Linus Torvalds <torvalds@linux-foundation.org>
> [trondmy: cover the cases of invalidate_inode_pages2() and
>           truncate_inode_pages()]
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  Documentation/filesystems/Locking |    5 +++++
>  Documentation/filesystems/vfs.txt |    5 +++++
>  include/linux/fs.h                |    1 +
>  mm/truncate.c                     |    8 ++++++++
>  mm/vmscan.c                       |    3 +++
>  5 files changed, 22 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> index a91f308..06d6b71 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -173,6 +173,7 @@ prototypes:
>  	sector_t (*bmap)(struct address_space *, sector_t);
>  	int (*invalidatepage) (struct page *, unsigned long);
>  	int (*releasepage) (struct page *, int);
> +	void (*freepage)(struct page *);
>  	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
>  			loff_t offset, unsigned long nr_segs);
>  	int (*launder_page) (struct page *);
> @@ -193,6 +194,7 @@ perform_write:		no	n/a			yes
>  bmap:			no
>  invalidatepage:		no	yes
>  releasepage:		no	yes
> +freepage:		no	yes
>  direct_IO:		no
>  launder_page:		no	yes
>  
> @@ -288,6 +290,9 @@ buffers from the page in preparation for freeing it.  It returns zero to
>  indicate that the buffers are (or may be) freeable.  If ->releasepage is zero,
>  the kernel assumes that the fs has no private interest in the buffers.
>  
> +	->freepage() is called when the kernel is done dropping the page
> +from the page cache.
> +
>  	->launder_page() may be called prior to releasing a page if
>  it is still found to be dirty. It returns zero if the page was successfully
>  cleaned, or an error value if not. Note that in order to prevent the page
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index ed7e5ef..76de6fd 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -534,6 +534,7 @@ struct address_space_operations {
>  	sector_t (*bmap)(struct address_space *, sector_t);
>  	int (*invalidatepage) (struct page *, unsigned long);
>  	int (*releasepage) (struct page *, int);
> +	void (*freepage)(struct page *);
>  	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
>  			loff_t offset, unsigned long nr_segs);
>  	struct page* (*get_xip_page)(struct address_space *, sector_t,
> @@ -679,6 +680,10 @@ struct address_space_operations {
>          need to ensure this.  Possibly it can clear the PageUptodate
>          bit if it cannot free private data yet.
>  
> +  freepage: freepage is called once the page is no longer visible in
> +        the page cache in order to allow the cleanup of any private
> +	data.
> +
>    direct_IO: called by the generic read/write routines to perform
>          direct_IO - that is IO requests which bypass the page cache
>          and transfer data directly between the storage and the
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index c9e06cc..090f0ea 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -602,6 +602,7 @@ struct address_space_operations {
>  	sector_t (*bmap)(struct address_space *, sector_t);
>  	void (*invalidatepage) (struct page *, unsigned long);
>  	int (*releasepage) (struct page *, gfp_t);
> +	void (*freepage)(struct page *);
>  	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
>  			loff_t offset, unsigned long nr_segs);
>  	int (*get_xip_mem)(struct address_space *, pgoff_t, int,
> diff --git a/mm/truncate.c b/mm/truncate.c
> index ba887bf..76ab2a8 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -108,6 +108,10 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
>  	clear_page_mlock(page);
>  	remove_from_page_cache(page);
>  	ClearPageMappedToDisk(page);
> +
> +	if (mapping->a_ops->freepage)
> +		mapping->a_ops->freepage(page);
> +
>  	page_cache_release(page);	/* pagecache ref */
>  	return 0;
>  }
> @@ -390,6 +394,10 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
>  	__remove_from_page_cache(page);
>  	spin_unlock_irq(&mapping->tree_lock);
>  	mem_cgroup_uncharge_cache_page(page);
> +
> +	if (mapping->a_ops->freepage)
> +		mapping->a_ops->freepage(page);
> +
>  	page_cache_release(page);	/* pagecache ref */
>  	return 1;
>  failed:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d31d7ce..c6fc55d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -497,6 +497,9 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
>  		__remove_from_page_cache(page);
>  		spin_unlock_irq(&mapping->tree_lock);
>  		mem_cgroup_uncharge_cache_page(page);
> +
> +		if (mapping->a_ops->freepage)
> +			mapping->a_ops->freepage(page);
>  	}
>  
>  	return 1;
> -- 
> 1.7.3.2
