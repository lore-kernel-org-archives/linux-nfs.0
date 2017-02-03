Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49934 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752232AbdBCLJd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2017 06:09:33 -0500
Date: Fri, 3 Feb 2017 03:09:30 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>,
        Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170203110930.GA22173@infradead.org>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170202105651.GA32111@infradead.org>
 <20170202111625.GG27291@ZenIV.linux.org.uk>
 <1486040452.2812.6.camel@redhat.com>
 <20170203074901.GA19808@infradead.org>
 <20170203085415.GJ27291@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170203085415.GJ27291@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 03, 2017 at 08:54:15AM +0000, Al Viro wrote:
> Hmm...  Reuse part is really nasty ;-/  OTOH, it might make sense to have
> a "fill bio_vec array" as separate primitive - having that sucker come
> from bio looks like an artificial restriction.

Or just the only usecase :)  But yes, it could be generalized to take a
bio_vec without too much effort.

> OK, next question, seeing that you've dealt with O_DIRECT guts more than
> I have.  When we have iov_iter_get_pages() fail on do_direct_IO() write
> with some blocks already allocated, we pick zero page as data source.
> So far, so good, but:
> 	* should we bother zeroing anything unless buffer_new() is true?

I don't think so.

> 	* why, in case of more than a page worth of pending allocated
> blocks, do we bother with calling iov_iter_get_pages() again and again?
> We *do* take care not to allocate anything else after that point, but
> dio_get_page() will be calling iov_iter_get_pages() every time in that
> case - there's only one page in queue.

There shouldn't be a need for it.

But take it with a grain of salt - fs/direct-io.c is a hairy mess,
that's one of the reasons why I replaced it with the new iomap
code instead of trying to gradually move it to iomap API.
