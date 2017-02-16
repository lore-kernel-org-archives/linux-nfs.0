Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:33974 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754715AbdBPNKh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2017 08:10:37 -0500
Received: by mail-qt0-f177.google.com with SMTP id w20so13304901qtb.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2017 05:10:32 -0800 (PST)
Message-ID: <1487250627.3661.1.camel@redhat.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
From: Jeff Layton <jlayton@redhat.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>,
        Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Thu, 16 Feb 2017 08:10:27 -0500
In-Reply-To: <20170202095125.GF27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
         <20170125133205.21704-1-jlayton@redhat.com>
         <20170202095125.GF27291@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-02-02 at 09:51 +0000, Al Viro wrote:
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
> 

While I do like the above proposal better than what I originally had,
I'm guessing it won't be ready in time for v4.11.

Would it be reasonable to take the patch I proposed for v4.11 as an
interim fix? It does fix a rather easy-to-trigger softlockup in the ceph
code that xfstests can reliably hit.

-- 
Jeff Layton <jlayton@redhat.com>
