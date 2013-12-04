Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932201Ab3LDMyb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 07:54:31 -0500
Date: Wed, 4 Dec 2013 07:54:02 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash
 it first
Message-ID: <20131204075402.7b00d09d@tlielax.poochiereds.net>
In-Reply-To: <20131204083336.GB30216@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
	<20131203102517.GA12576@infradead.org>
	<20131203132112.1f19c014@tlielax.poochiereds.net>
	<20131204083336.GB30216@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 4 Dec 2013 00:33:36 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Dec 03, 2013 at 01:21:12PM -0500, Jeff Layton wrote:
> > Most of this code is protected by a single spinlock (cache_lock). The
> > main benefit to switching to list_lru would be that we could move to a
> > per-node lock. But, to make that worthwhile would mean we'd need to
> > redesign the locking and break the cache_lock into multiple locks.
> 
> No need to redo locks just yet, the biggest benefit is to use a well
> debug library for lru list handling, with the second biggest one being
> that you get out of the box shrinker support.
> 
> > Also, the existing code does take pains to reuse an expired entry off
> > the LRU list in preference to allocating a new one. The list_lru code
> > doesn't have a mechanism to scrape the first entry off the LRU list,
> > though I suppose we could add one or abuse the cb_arg in the walk
> > callback as a return pointer.
> 
> That's just because it is an old-school cache with a fixed upper bound
> of entries and no shrinker support.  With proper shrinker integration
> this nasty code isn't needed.

Well, the old code just had a fixed number of entries (1024 or so?),
which was ridiculously small on modern server. A busy server could blow
out the cache in less than the retransmit interval, which made it
effectively worthless.

The new code has a much larger upper bound, but it is still bounded by
the amount of low memory on the host. We have shrinker integration
(though its propriety might be in question).

Are you suggesting that we shouldn't try to bound the cache at all and
should instead just let it grow and rely on the shrinker to keep it in
check?

-- 
Jeff Layton <jlayton@redhat.com>
