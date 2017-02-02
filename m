Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33470 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdBBNA5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2017 08:00:57 -0500
Received: by mail-yw0-f172.google.com with SMTP id u68so8647579ywg.0
        for <linux-nfs@vger.kernel.org>; Thu, 02 Feb 2017 05:00:57 -0800 (PST)
Message-ID: <1486040452.2812.6.camel@redhat.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
From: Jeff Layton <jlayton@redhat.com>
To: Al Viro <viro@ZenIV.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Thu, 02 Feb 2017 08:00:52 -0500
In-Reply-To: <20170202111625.GG27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
         <20170125133205.21704-1-jlayton@redhat.com>
         <20170202095125.GF27291@ZenIV.linux.org.uk>
         <20170202105651.GA32111@infradead.org>
         <20170202111625.GG27291@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-02-02 at 11:16 +0000, Al Viro wrote:
> On Thu, Feb 02, 2017 at 02:56:51AM -0800, Christoph Hellwig wrote:
> > > I really wonder if this is the right approach.  Most of the users of
> > > iov_iter_get_pages()/iov_iter_get_pages_alloc() look like they want
> > > something like
> > > 	iov_iter_for_each_page(iter, size, f, data)
> > > with int (*f)(struct page *page, size_t from, size_t size, void *data)
> > > passed as callback.  Not everything fits that model, but there's a whole
> > > lot of things that do.
> > 

Yeah, that does seem nicer.

My only concern is that it sounds more invasive, and I'd like to get
some sort of interim fix in for Ceph in the meantime (preferably
something we can send to stable). It really is trivial to vmsplice some
data into the kernel, and then splice write that to a DIO file --
instant softlockup in my testing.

This patch also makes vectored DIO with small iovecs on NFS a lot more
efficient, which is a nice bonus.
 
> > I was planning to do that, mostly because of the iomap dio code that
> > would not only get a lot cleaner with this, but also support multi-page
> > bvecs that we hope to have in the block layer soon.  The issue with it
> > is that we need to touch all the arch get_user_pages_fast
> > implementations, so it's going to be a relatively invasive change that I
> > didn't want to fix with just introducing the new direct I/O code.
> 
> I'm not sure we need to touch any get_user_pages_fast() at all; let it
> fill a medium-sized array and use that as a buffer.  In particular,
> I *really* don't like the idea of having the callbacks done in an
> inconsistent locking environment - sometimes under ->mmap_sem, sometimes
> not.
> 

Yeah, that might work. You could kmalloc the buffer array according to
the maxsize value. For small ones we could even consider using an on-
stack buffer.

> I played with "let it fill bio_vec array", but it doesn't really fit the
> users; variant with callbacks is cleaner, IMO.

I looked at converting this over to a bio_vec array as well, but that
really doesn't work well for Ceph. I like the callback idea better too.

-- 
Jeff Layton <jlayton@redhat.com>
