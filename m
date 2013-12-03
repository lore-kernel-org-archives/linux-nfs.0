Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716Ab3LCSVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Dec 2013 13:21:43 -0500
Date: Tue, 3 Dec 2013 13:21:12 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash
 it first
Message-ID: <20131203132112.1f19c014@tlielax.poochiereds.net>
In-Reply-To: <20131203102517.GA12576@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
	<20131203102517.GA12576@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 3 Dec 2013 02:25:17 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Dec 02, 2013 at 03:26:19PM -0500, Jeff Layton wrote:
> > The DRC code will attempt to reuse an existing, expired cache entry in
> > preference to allocating a new one. It'll then search the cache, and if
> > it gets a hit it'll then free the cache entry that it was going to
> > reuse.
> > 
> > The cache code doesn't unhash the entry that it's going to reuse
> > however, so it's possible for it end up designating an entry for reuse
> > and then subsequently freeing the same entry after it finds it.  This
> > leads it to a later use-after-free situation and usually some list
> > corruption warnings or an oops.
> > 
> > Fix this by simply unhashing the entry that we intend to reuse. That
> > will mean that it's not findable via a search and should prevent this
> > situation from occurring.
> 
> The fix looks reasonable to me,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 

Thanks.

> Btw, it seems like this code would benefit from being converted to
> the list_lru structure.

Maybe.

Most of this code is protected by a single spinlock (cache_lock). The
main benefit to switching to list_lru would be that we could move to a
per-node lock. But, to make that worthwhile would mean we'd need to
redesign the locking and break the cache_lock into multiple locks.

Also, the existing code does take pains to reuse an expired entry off
the LRU list in preference to allocating a new one. The list_lru code
doesn't have a mechanism to scrape the first entry off the LRU list,
though I suppose we could add one or abuse the cb_arg in the walk
callback as a return pointer.

I'm not sure the resulting code would be any clearer however...

Maybe when we get to the point that the cache_lock shows up as a
bottleneck, it'll make more sense?

-- 
Jeff Layton <jlayton@redhat.com>
