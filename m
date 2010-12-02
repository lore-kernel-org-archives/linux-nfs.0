Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:37579 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756745Ab0LBDeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 22:34:25 -0500
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id oB23YN37009067
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 19:34:23 -0800
Received: from pvc22 (pvc22.prod.google.com [10.241.209.150])
	by kpbe19.cbf.corp.google.com with ESMTP id oB23YLir013160
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 19:34:22 -0800
Received: by pvc22 with SMTP id 22so4585307pvc.27
        for <linux-nfs@vger.kernel.org>; Wed, 01 Dec 2010 19:34:21 -0800 (PST)
Date: Wed, 1 Dec 2010 19:34:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v3 2/3] Call the filesystem back whenever a page is
 removed from the page cache
In-Reply-To: <1291259285-26803-3-git-send-email-Trond.Myklebust@netapp.com>
Message-ID: <alpine.LSU.2.00.1012011925580.25894@tigran.mtv.corp.google.com>
References: <1291259285-26803-1-git-send-email-Trond.Myklebust@netapp.com> <1291259285-26803-2-git-send-email-Trond.Myklebust@netapp.com> <1291259285-26803-3-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 1 Dec 2010, Trond Myklebust wrote:
> 
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

I think Linus recommended that one be done in remove_from_page_cache()
to catch all instances: did that get overruled later for some reason?

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -454,6 +454,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(mapping != page_mapping(page));
>  
> +	preempt_disable();
>  	spin_lock_irq(&mapping->tree_lock);
>  	/*
>  	 * The non racy check for a busy page.
> @@ -492,10 +493,19 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
>  		swp_entry_t swap = { .val = page_private(page) };
>  		__delete_from_swap_cache(page);
>  		spin_unlock_irq(&mapping->tree_lock);
> +		preempt_enable();
>  		swapcache_free(swap, page);
>  	} else {
> +		void (*freepage)(struct page *);
> +
> +		freepage = mapping->a_ops->freepage;
> +
>  		__remove_from_page_cache(page);
>  		spin_unlock_irq(&mapping->tree_lock);
> +		if (freepage != NULL)
> +			freepage(page);
> +		preempt_enable();
> +
>  		mem_cgroup_uncharge_cache_page(page);
>  	}
>  
> @@ -503,6 +513,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
>  
>  cannot_free:
>  	spin_unlock_irq(&mapping->tree_lock);
> +	preempt_enable();
>  	return 0;
>  }

I took his "stop_machine()" explanation ("an idle period for everything.
And just a preemption reschedule isn't enough for that") to imply that
there's no need for your preempt_disable/preempt_enable there: they
don't add anything to the module unload case, and they don't help the
spin_unlock_irq issue (and you're already being rightly careful to note
freepage in advance).

But maybe I misunderstood.

Hugh
