Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42835 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab3LDIdh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 03:33:37 -0500
Date: Wed, 4 Dec 2013 00:33:36 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash it
 first
Message-ID: <20131204083336.GB30216@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
 <20131203102517.GA12576@infradead.org>
 <20131203132112.1f19c014@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131203132112.1f19c014@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 03, 2013 at 01:21:12PM -0500, Jeff Layton wrote:
> Most of this code is protected by a single spinlock (cache_lock). The
> main benefit to switching to list_lru would be that we could move to a
> per-node lock. But, to make that worthwhile would mean we'd need to
> redesign the locking and break the cache_lock into multiple locks.

No need to redo locks just yet, the biggest benefit is to use a well
debug library for lru list handling, with the second biggest one being
that you get out of the box shrinker support.

> Also, the existing code does take pains to reuse an expired entry off
> the LRU list in preference to allocating a new one. The list_lru code
> doesn't have a mechanism to scrape the first entry off the LRU list,
> though I suppose we could add one or abuse the cb_arg in the walk
> callback as a return pointer.

That's just because it is an old-school cache with a fixed upper bound
of entries and no shrinker support.  With proper shrinker integration
this nasty code isn't needed.
