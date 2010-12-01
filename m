Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:42809 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756576Ab0LATXi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 14:23:38 -0500
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id oB1JNbjn007811
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 11:23:37 -0800
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by hpaq7.eem.corp.google.com with ESMTP id oB1JNZix009368
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 11:23:35 -0800
Received: by pxi2 with SMTP id 2so1465273pxi.12
        for <linux-nfs@vger.kernel.org>; Wed, 01 Dec 2010 11:23:34 -0800 (PST)
Date: Wed, 1 Dec 2010 11:23:26 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
In-Reply-To: <1291229669.6609.24.camel@heimdal.trondhjem.org>
Message-ID: <alpine.LSU.2.00.1012011058560.16407@tigran.mtv.corp.google.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com> <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com> <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com> <1291229669.6609.24.camel@heimdal.trondhjem.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 1 Dec 2010, Trond Myklebust wrote:
> On Wed, 2010-12-01 at 08:17 -0800, Linus Torvalds wrote:
> > On Wed, Dec 1, 2010 at 7:36 AM, Trond Myklebust
> > <Trond.Myklebust@netapp.com> wrote:
> > >
> > > We need to ensure that the entries in the nfs_cache_array get cleared
> > > when the page is removed from the page cache. To do so, we use the
> > > releasepage address_space operation (which also requires us to set
> > > the Pg_private flag).
> > 
> > So I really think that the whole "releasepage" use in NFS is simply
> > overly complicated and was obviously too subtle.
> > 
> > The whole need for odd return values, for the page lock, and for the
> > addition of clearing the up-to-date bit comes from the fact that this
> > wasn't really what releasepage was designed for.
> > 
> > 'releasepage' was really designed for the filesystem having its own
> > version of 'try_to_free_buffers()', which is just an optimistic "ok,
> > we may be releasing this page, so try to get rid of any IO structures
> > you have cached". It wasn't really a memory management thing.
> > 
> > And the thing is, it looks trivial to do the memory management
> > approach by adding a new callback that gets called after the page is
> > actually removed from the page cache. If we do that, then there are no
> > races with any other users, since we remove things from the page cache
> > atomically wrt page cache lookup. So the need for playing games with
> > page locking and 'uptodate' simply goes away. As does the PG_private
> > thing or the interaction with invalidatepage() etc.
> > 
> > So this is a TOTALLY UNTESTED trivial patch that just adds another
> > callback. Does this work? I dunno. But I get the feeling that instead
> > of having NFS work around the odd semantics that don't actually match
> > what NFS wants, introducing a new callback with much simpler semantics
> > would be simpler for everybody, and avoid the need for subtle code.
> > 
> > Hmm?
> > 
> >                    Linus
> 
> 
> > include/linux/fs.h |    1 +
> >  mm/vmscan.c        |    3 +++
> >  2 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index c9e06cc..090f0ea 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -602,6 +602,7 @@ struct address_space_operations {
> >         sector_t (*bmap)(struct address_space *, sector_t);
> >         void (*invalidatepage) (struct page *, unsigned long);
> >         int (*releasepage) (struct page *, gfp_t);
> > +       void (*freepage)(struct page *);
> >         ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec
> > *iov,
> >                         loff_t offset, unsigned long nr_segs);
> >         int (*get_xip_mem)(struct address_space *, pgoff_t, int,
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d31d7ce..1accb01 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -499,6 +499,9 @@ static int __remove_mapping(struct address_space
> > *mapping, struct page *page)
> >                 mem_cgroup_uncharge_cache_page(page);
> >         }
> >  
> > +       if (mapping->a_ops->freepage)
> > +               mapping->a_ops->freepage(page);
> 
> Hmm... Looking again at the problem, it appears that the same callback
> needs to be added to truncate_complete_page() and
> invalidate_complete_page2(). Otherwise we end up in a situation where
> the page can sometimes be removed from the page cache without calling
> freepage().
> 
> > +
> >         return 1;
> >  
> >  cannot_free:

Yes, I was wondering quite how we would define this ->freepage thing,
if it gets called from one place that removes from page cache and not
from others.

Another minor problem with it: it would probably need to take the
struct address_space *mapping as arg as well as struct page *page:
because by this time page->mapping has been reset to NULL.

But I'm not at all keen on adding a calllback in this very special
frozen-to-0-references place: please let's not do it without an okay
from Nick Piggin (now Cc'ed).

I agree completely with what Linus said originally about how the
page cannot be freed while there's a reference to it, and it should
be possible to work this without your additional page locks.

Your ->releasepage should be able to judge whether the page is likely
(not certain) to be freed - page_count 3? 1 for the page cache, 1 for
the page_private reference, 1 for vmscan's reference, I think.  Then
it can mark !PageUptodate and proceed with freeing the stuff you had
allocated, undo page_has_private and its reference, and return 1 (or
return 0 if it decides to hold on to the page).

If something races in and grabs another reference to prevent removal
from page cache and freeing, then won't read_cache_page(), seeing
!Uptodate, do the right thing and set up the required info again?

Or perhaps I haven't looked far enough, and you do have races which
actually need your page locks, I can see they make it easier to think
about.

But I'd prefer us not to throw in another callback if it's well
workable with the ->releasepage we already have.  (If it helps,
perhaps we could adjust shrink_page_list() to allow for the page
being removed from page cache inside try_to_release_page() - but
I don't think that should be necessary.)

Hugh
