Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34244 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdBBLQb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2017 06:16:31 -0500
Date: Thu, 2 Feb 2017 11:16:25 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, lustre-devel@lists.lustre.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170202111625.GG27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170202105651.GA32111@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170202105651.GA32111@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 02, 2017 at 02:56:51AM -0800, Christoph Hellwig wrote:
> > I really wonder if this is the right approach.  Most of the users of
> > iov_iter_get_pages()/iov_iter_get_pages_alloc() look like they want
> > something like
> > 	iov_iter_for_each_page(iter, size, f, data)
> > with int (*f)(struct page *page, size_t from, size_t size, void *data)
> > passed as callback.  Not everything fits that model, but there's a whole
> > lot of things that do.
> 
> I was planning to do that, mostly because of the iomap dio code that
> would not only get a lot cleaner with this, but also support multi-page
> bvecs that we hope to have in the block layer soon.  The issue with it
> is that we need to touch all the arch get_user_pages_fast
> implementations, so it's going to be a relatively invasive change that I
> didn't want to fix with just introducing the new direct I/O code.

I'm not sure we need to touch any get_user_pages_fast() at all; let it
fill a medium-sized array and use that as a buffer.  In particular,
I *really* don't like the idea of having the callbacks done in an
inconsistent locking environment - sometimes under ->mmap_sem, sometimes
not.

I played with "let it fill bio_vec array", but it doesn't really fit the
users; variant with callbacks is cleaner, IMO.
