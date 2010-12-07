Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:60505 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753621Ab0LGHIe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 02:08:34 -0500
Date: Tue, 7 Dec 2010 18:08:27 +1100
From: Nick Piggin <npiggin@kernel.dk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>, Simon Kirby <sim@hostway.ca>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v4 2/3] Call the filesystem back whenever a page is
 removed from the page cache
Message-ID: <20101207070827.GC3307@amd>
References: <AANLkTi=LJaSTREikZg3M=QFkihEcQEGCJLW4wUPsDm9s@mail.gmail.com>
 <1291654748-8921-3-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291654748-8921-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 06, 2010 at 11:59:07AM -0500, Trond Myklebust wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
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
>  Documentation/filesystems/Locking |    7 ++++++-
>  Documentation/filesystems/vfs.txt |    7 +++++++
>  include/linux/fs.h                |    1 +
>  mm/filemap.c                      |    5 +++++
>  mm/truncate.c                     |    4 ++++
>  mm/vmscan.c                       |    7 +++++++
>  6 files changed, 30 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> index a91f308..b6426f1 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -173,12 +173,13 @@ prototypes:
>  	sector_t (*bmap)(struct address_space *, sector_t);
>  	int (*invalidatepage) (struct page *, unsigned long);
>  	int (*releasepage) (struct page *, int);
> +	void (*freepage)(struct page *);
>  	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
>  			loff_t offset, unsigned long nr_segs);
>  	int (*launder_page) (struct page *);
>  
>  locking rules:
> -	All except set_page_dirty may block
> +	All except set_page_dirty and freepage may block
>  
>  			BKL	PageLocked(page)	i_mutex
>  writepage:		no	yes, unlocks (see below)
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
> index ed7e5ef..3b14a55 100644
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
> @@ -679,6 +680,12 @@ struct address_space_operations {
>          need to ensure this.  Possibly it can clear the PageUptodate
>          bit if it cannot free private data yet.
>  
> +  freepage: freepage is called once the page is no longer visible in
> +        the page cache in order to allow the cleanup of any private
> +	data. Since it may be called by the memory reclaimer, it
> +	should not assume that the original address_space mapping still
> +	exists, and it should not block.

Of course we still have bugs in this regard, without inode RCU and
filesystem deregistration RCU, but when those things are implemented
for RCU path-walk, this section should be updated somewhat, and we'll
have to look at RCU protecting the final mapping manipulations after
a page is removed from pagecache.

But I'll help work on that after RCU inodes / filesystems is merged.

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
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ea89840..6b9aee2 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -143,13 +143,18 @@ void __remove_from_page_cache(struct page *page)
>  void remove_from_page_cache(struct page *page)
>  {
>  	struct address_space *mapping = page->mapping;
> +	void (*freepage)(struct page *);
>  
>  	BUG_ON(!PageLocked(page));
>  
> +	freepage = mapping->a_ops->freepage;
>  	spin_lock_irq(&mapping->tree_lock);
>  	__remove_from_page_cache(page);
>  	spin_unlock_irq(&mapping->tree_lock);
>  	mem_cgroup_uncharge_cache_page(page);
> +
> +	if (freepage)
> +		freepage(page);
>  }
>  EXPORT_SYMBOL(remove_from_page_cache);
>  
> diff --git a/mm/truncate.c b/mm/truncate.c
> index ba887bf..3c2d5dd 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -390,6 +390,10 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
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

The generic parts of the code look OK to me, but why is there a
difference in your sequences of loading the freepage function pointer
here?

