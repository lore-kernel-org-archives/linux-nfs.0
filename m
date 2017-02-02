Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:40746 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdBBK44 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2017 05:56:56 -0500
Date: Thu, 2 Feb 2017 02:56:51 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, lustre-devel@lists.lustre.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170202105651.GA32111@infradead.org>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170202095125.GF27291@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 02, 2017 at 09:51:25AM +0000, Al Viro wrote:
> On Wed, Jan 25, 2017 at 08:32:03AM -0500, Jeff Layton wrote:
> > Small respin of the patch that I sent yesterday for the same thing.
> > 
> > This moves the maxsize handling into iov_iter_pvec_size, so that we don't
> > end up iterating past the max size we'll use anyway when trying to
> > determine the pagevec length.
> > 
> > Also, a respun patch to make ceph use iov_iter_get_pages_alloc instead of
> > trying to do it via its own routine.
> > 
> > Al, if these look ok, do you want to pick these up or shall I ask
> > Ilya to merge them via the ceph tree?
> 
> I'd rather have that kind of work go through the vfs tree; said that,
> I really wonder if this is the right approach.  Most of the users of
> iov_iter_get_pages()/iov_iter_get_pages_alloc() look like they want
> something like
> 	iov_iter_for_each_page(iter, size, f, data)
> with int (*f)(struct page *page, size_t from, size_t size, void *data)
> passed as callback.  Not everything fits that model, but there's a whole
> lot of things that do.

I was planning to do that, mostly because of the iomap dio code that
would not only get a lot cleaner with this, but also support multi-page
bvecs that we hope to have in the block layer soon.  The issue with it
is that we need to touch all the arch get_user_pages_fast
implementations, so it's going to be a relatively invasive change that I
didn't want to fix with just introducing the new direct I/O code.
