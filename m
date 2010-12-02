Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26796 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756863Ab0LBDx4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 22:53:56 -0500
Subject: Re: [PATCH v3 2/3] Call the filesystem back whenever a page is
 removed from the page cache
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
In-Reply-To: <alpine.LSU.2.00.1012011925580.25894@tigran.mtv.corp.google.com>
References: <1291259285-26803-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1291259285-26803-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1291259285-26803-3-git-send-email-Trond.Myklebust@netapp.com>
	 <alpine.LSU.2.00.1012011925580.25894@tigran.mtv.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 22:53:36 -0500
Message-ID: <1291262016.6609.115.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 19:34 -0800, Hugh Dickins wrote:
> On Wed, 1 Dec 2010, Trond Myklebust wrote:
> > 
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -108,6 +108,10 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
> >  	clear_page_mlock(page);
> >  	remove_from_page_cache(page);
> >  	ClearPageMappedToDisk(page);
> > +
> > +	if (mapping->a_ops->freepage)
> > +		mapping->a_ops->freepage(page);
> > +
> >  	page_cache_release(page);	/* pagecache ref */
> >  	return 0;
> >  }
> 
> I think Linus recommended that one be done in remove_from_page_cache()
> to catch all instances: did that get overruled later for some reason?

I'm fine with doing that as long as everyone is happy that there is no
chance of races. I was a bit nervous given the discussion that ensued
from the vmscan case.

> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -454,6 +454,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
> >  	BUG_ON(!PageLocked(page));
> >  	BUG_ON(mapping != page_mapping(page));
> >  
> > +	preempt_disable();
> >  	spin_lock_irq(&mapping->tree_lock);
> >  	/*
> >  	 * The non racy check for a busy page.
> > @@ -492,10 +493,19 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
> >  		swp_entry_t swap = { .val = page_private(page) };
> >  		__delete_from_swap_cache(page);
> >  		spin_unlock_irq(&mapping->tree_lock);
> > +		preempt_enable();
> >  		swapcache_free(swap, page);
> >  	} else {
> > +		void (*freepage)(struct page *);
> > +
> > +		freepage = mapping->a_ops->freepage;
> > +
> >  		__remove_from_page_cache(page);
> >  		spin_unlock_irq(&mapping->tree_lock);
> > +		if (freepage != NULL)
> > +			freepage(page);
> > +		preempt_enable();
> > +
> >  		mem_cgroup_uncharge_cache_page(page);
> >  	}
> >  
> > @@ -503,6 +513,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
> >  
> >  cannot_free:
> >  	spin_unlock_irq(&mapping->tree_lock);
> > +	preempt_enable();
> >  	return 0;
> >  }
> 
> I took his "stop_machine()" explanation ("an idle period for everything.
> And just a preemption reschedule isn't enough for that") to imply that
> there's no need for your preempt_disable/preempt_enable there: they
> don't add anything to the module unload case, and they don't help the
> spin_unlock_irq issue (and you're already being rightly careful to note
> freepage in advance).
> 
> But maybe I misunderstood.

Again, I was being cautious (I freely admit to not having studied
stop_machine()). If nobody disagrees with your interpretation, then I'm
very happy to drop the preempt disable/enable crud.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

