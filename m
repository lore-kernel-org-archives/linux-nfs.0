Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756473Ab3LENmX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 08:42:23 -0500
Date: Thu, 5 Dec 2013 08:41:56 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH RFC 1/3] nfsd: don't try to reuse an expired DRC entry
 off the list
Message-ID: <20131205084156.5a9a2545@tlielax.poochiereds.net>
In-Reply-To: <20131205132919.GC3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
	<1386241253-5781-2-git-send-email-jlayton@redhat.com>
	<20131205132919.GC3381@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Dec 2013 05:29:19 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Dec 05, 2013 at 06:00:51AM -0500, Jeff Layton wrote:
> > Currently when we are processing a request, we try to scrape an expired
> > or over-limit entry off the list in preference to allocating a new one
> > from the slab.
> > 
> > This is unnecessarily complicated. Just use the slab layer.
> 
> I really don't think pruning caches from lookup functions is a good
> idea. To many chances for locking inversions, unbounded runtime and
> other issues.  So I'd prefer my earlier version of the patch to
> remove it entirely if we want to change anything beyond your minimal
> fix.
> 

It's not likely to hit a locking inversion here since we don't have a
lot of different locks, but point taken...

If we take that out, then that does mean that the cache may grow larger
than the max...possibly much larger since the pruner workqueue job
only runs every 120s and you can put a lot more entries into the cache
in that period.

That said, I don't feel too strongly about it, so if you think leaving
it to the workqueue job and the shrinker is the right thing to do, then
so be it.

-- 
Jeff Layton <jlayton@redhat.com>
