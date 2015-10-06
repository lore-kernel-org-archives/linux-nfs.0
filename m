Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35390 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbJFLnp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 07:43:45 -0400
Received: by qgt47 with SMTP id 47so171407252qgt.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 04:43:45 -0700 (PDT)
Date: Tue, 6 Oct 2015 07:43:41 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Dave Chinner <david@fromorbit.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5 01/20] list_lru: add list_lru_rotate
Message-ID: <20151006074341.0e2f796e@tlielax.poochiereds.net>
In-Reply-To: <20151005214717.GC23350@dastard>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
	<1444042962-6947-2-git-send-email-jeff.layton@primarydata.com>
	<20151005214717.GC23350@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Oct 2015 08:47:17 +1100
Dave Chinner <david@fromorbit.com> wrote:

> On Mon, Oct 05, 2015 at 07:02:23AM -0400, Jeff Layton wrote:
> > Add a function that can move an entry to the MRU end of the list.
> > 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: linux-mm@kvack.org
> > Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> 
> Having read through patch 10 (nfsd: add a new struct file caching
> facility to nfsd) that uses this function, I think it is unnecessary
> as it's usage is incorrect from the perspective of the list_lru
> shrinker management.
> 
> What you are attempting to do is rotate the object to the tail of
> the LRU when the last reference is dropped, so that it gets a full
> trip through the LRU before being reclaimed by the shrinker. And to
> ensure this "works", the scan from the shrinker checks for reference
> counts and skip the item being isolated (i.e. return LRU_SKIP) and
> so leave it in it's place in the LRU.
> 
> i.e. you're attempting to manage LRU-ness of the list yourself when,
> in fact, the list_lru infrastructure does this and doesn't have the
> subtle bugs your version has. By trying to manage it yourself, the
> list_lru lists are no longer sorted into memory pressure driven
> LRU order.
> 
> e.g. your manual rotation technique means if there are nr_to_walk
> referenced items at the head of the list, the shrinker will skip
> them all and do nothing, even though there are reclaimable objects
> further down the list. i.e. it can't do any reclaim because it
> doesn't sort the list into LRU order any more.
> 
> This comes from using LRU_SKIP improperly. LRU_SKIP is there for
> objects that we can't lock in the isolate callback due to lock
> inversion issues (e.g. see dentry_lru_isolate()), and so we need to
> look at it again on the next scan pass. hence it gets left in place.
> 
> However, if we can lock the item and peer at it's reference counts
> safely and we decide that we cannot reclaim it because it is
> referenced, the isolate callback should be returning LRU_ROTATE
> to move the referenced item to the tail of the list. (Again, see
> dentry_lru_isolate() for an example.) The means that
> the next nr_to_walk scan of the list will not rescan that item and
> skip it again (unless the list is very short), but will instead scan
> items that it hasn't yet reached.
> 
> This avoids the "shrinker does nothing due to skipped items at the
> head of the list" problem, and makes the LRU function as an actual
> LRU. i.e.  referenced items all cluster towards the tail of the LRU
> under memory pressure and the head of the LRU contains the
> reclaimable objects.
> 
> So I think the correct solution is to use LRU_ROTATE correctly
> rather than try to manage the LRU list order externally like this.
> 

Thanks for looking, Dave. Ok, fair enough.

I grafted the LRU list stuff on after I did the original set, and I
think the way I designed the refcounting doesn't really work very well
with it. It has been a while since I added that in, but I do remember
struggling a bit with lock inversion problems trying to do it the more
standard way. It's solvable with a nfsd_file spinlock, but I wanted
to avoid that -- still maybe it's the best way.

What I don't quite get conceptually is how the list_lru stuff really
works...

Looking at the dcache's usage, dentry_lru_add is only called from dput
and only removed from the list when you're shrinking the dcache or from
__dentry_kill. It will rotate entries to the end of the list via
LRU_ROTATE from the shrinker callback if DCACHE_REFERENCED was set, but
I don't see how you end up with stuff at the end of the list otherwise.

So, the dcache's LRU list doesn't really seem to keep the entries in LRU
order at all. It just prunes a number of entries that haven't been used
since the last time the shrinker callback was called, and the rest end
up staying on the list in whatever order they were originally added.

So...

dentry1			dentry2
allocated
dput
			allocated
			dput

found
dput again
(maybe many more times)

Now, the shrinker runs once and skips both because DCACHE_REFERENCED is
set. It then runs again later and prunes dentry1 before dentry2 even
though it has been used many more times since dentry2 has.

Am I missing something in how this works?
-- 
Jeff Layton <jlayton@poochiereds.net>
