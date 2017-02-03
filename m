Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:32836 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdBCIyc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2017 03:54:32 -0500
Date: Fri, 3 Feb 2017 08:54:15 +0000
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
Message-ID: <20170203085415.GJ27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170202105651.GA32111@infradead.org>
 <20170202111625.GG27291@ZenIV.linux.org.uk>
 <1486040452.2812.6.camel@redhat.com>
 <20170203074901.GA19808@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170203074901.GA19808@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 02, 2017 at 11:49:01PM -0800, Christoph Hellwig wrote:
> On Thu, Feb 02, 2017 at 08:00:52AM -0500, Jeff Layton wrote:
> > Yeah, that might work. You could kmalloc the buffer array according to
> > the maxsize value. For small ones we could even consider using an on-
> > stack buffer.
> 
> For the block direct I/O code we defintively want to avoid any
> allocations for small I/O a that shows up in the performance numbers.
> And we'd like to reuse the on-stack bio_vec so that the defintion of
> a small I/O can be as big as possible without blowing up the stack.

Hmm...  Reuse part is really nasty ;-/  OTOH, it might make sense to have
a "fill bio_vec array" as separate primitive - having that sucker come
from bio looks like an artificial restriction.

OK, next question, seeing that you've dealt with O_DIRECT guts more than
I have.  When we have iov_iter_get_pages() fail on do_direct_IO() write
with some blocks already allocated, we pick zero page as data source.
So far, so good, but:
	* should we bother zeroing anything unless buffer_new() is true?
	* why, in case of more than a page worth of pending allocated
blocks, do we bother with calling iov_iter_get_pages() again and again?
We *do* take care not to allocate anything else after that point, but
dio_get_page() will be calling iov_iter_get_pages() every time in that
case - there's only one page in queue.
