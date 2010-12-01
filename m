Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57341 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756985Ab0LAUj7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 15:39:59 -0500
Date: Wed, 1 Dec 2010 12:39:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Hugh Dickins <hughd@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Nick Piggin <npiggin@kernel.dk>, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
Message-Id: <20101201123929.ab7cef1d.akpm@linux-foundation.org>
In-Reply-To: <1291233938.6609.37.camel@heimdal.trondhjem.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
	<1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
	<20101201150428.GA2879@elliptictech.com>
	<1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
	<1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
	<AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
	<1291229669.6609.24.camel@heimdal.trondhjem.org>
	<alpine.LSU.2.00.1012011058560.16407@tigran.mtv.corp.google.com>
	<1291233938.6609.37.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 01 Dec 2010 15:05:38 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2010-12-01 at 11:23 -0800, Hugh Dickins wrote:
> > On Wed, 1 Dec 2010, Trond Myklebust wrote:
> > > On Wed, 2010-12-01 at 08:17 -0800, Linus Torvalds wrote:
> > > > include/linux/fs.h |    1 +
> > > >  mm/vmscan.c        |    3 +++
> > > >  2 files changed, 4 insertions(+), 0 deletions(-)
> > > > 
> > > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > > > index c9e06cc..090f0ea 100644
> > > > --- a/include/linux/fs.h
> > > > +++ b/include/linux/fs.h
> > > > @@ -602,6 +602,7 @@ struct address_space_operations {
> > > >         sector_t (*bmap)(struct address_space *, sector_t);
> > > >         void (*invalidatepage) (struct page *, unsigned long);
> > > >         int (*releasepage) (struct page *, gfp_t);
> > > > +       void (*freepage)(struct page *);
> > > >         ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec
> > > > *iov,
> > > >                         loff_t offset, unsigned long nr_segs);
> > > >         int (*get_xip_mem)(struct address_space *, pgoff_t, int,
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index d31d7ce..1accb01 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -499,6 +499,9 @@ static int __remove_mapping(struct address_space
> > > > *mapping, struct page *page)
> > > >                 mem_cgroup_uncharge_cache_page(page);
> > > >         }
> > > >  
> > > > +       if (mapping->a_ops->freepage)
> > > > +               mapping->a_ops->freepage(page);
> > > 
> > > Hmm... Looking again at the problem, it appears that the same callback
> > > needs to be added to truncate_complete_page() and
> > > invalidate_complete_page2(). Otherwise we end up in a situation where
> > > the page can sometimes be removed from the page cache without calling
> > > freepage().
> > > 
> > > > +
> > > >         return 1;
> > > >  
> > > >  cannot_free:
> > 
> > Yes, I was wondering quite how we would define this ->freepage thing,
> > if it gets called from one place that removes from page cache and not
> > from others.
> > 
> > Another minor problem with it: it would probably need to take the
> > struct address_space *mapping as arg as well as struct page *page:
> > because by this time page->mapping has been reset to NULL.
> > 
> > But I'm not at all keen on adding a calllback in this very special
> > frozen-to-0-references place: please let's not do it without an okay
> > from Nick Piggin (now Cc'ed).
> > 
> > I agree completely with what Linus said originally about how the
> > page cannot be freed while there's a reference to it, and it should
> > be possible to work this without your additional page locks.
> > 
> > Your ->releasepage should be able to judge whether the page is likely
> > (not certain) to be freed - page_count 3? 1 for the page cache, 1 for
> > the page_private reference, 1 for vmscan's reference, I think.  Then
> > it can mark !PageUptodate and proceed with freeing the stuff you had
> > allocated, undo page_has_private and its reference, and return 1 (or
> > return 0 if it decides to hold on to the page).
> 
> That is very brittle. I'd prefer not to have to scan linux-mm every week
> in order to find out if someone changed the page_count.
> 
> However, while reading Documentation/filesystems/vfs.txt (in order to
> add documentation for freepage) I was surprised to read that the
> ->releasepage() is itself supposed to be allowed to actually remove the
> page from the address space if it so desires.

That doesn't sound right.  It came from Neil in 2006.

Neil, what were you thinking there?   Did you find such a ->releasepage()?

> Looking at the actual code in shrink_page_list() and friends I can't see
> how that can possibly fail to break things, but if it were true, then
> that might enable us to call remove_mapping() in order to safely free
> the page before it gets cleared.
> 
