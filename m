Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:11971 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752713AbbJGBPd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 21:15:33 -0400
Date: Wed, 7 Oct 2015 12:09:55 +1100
From: Dave Chinner <david@fromorbit.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5 01/20] list_lru: add list_lru_rotate
Message-ID: <20151007010955.GD32150@dastard>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
 <1444042962-6947-2-git-send-email-jeff.layton@primarydata.com>
 <20151005214717.GC23350@dastard>
 <20151006074341.0e2f796e@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151006074341.0e2f796e@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 06, 2015 at 07:43:41AM -0400, Jeff Layton wrote:
> On Tue, 6 Oct 2015 08:47:17 +1100
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Mon, Oct 05, 2015 at 07:02:23AM -0400, Jeff Layton wrote:
> > > Add a function that can move an entry to the MRU end of the list.
> > > 
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: linux-mm@kvack.org
> > > Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
> > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > 
> > Having read through patch 10 (nfsd: add a new struct file caching
> > facility to nfsd) that uses this function, I think it is unnecessary
> > as it's usage is incorrect from the perspective of the list_lru
> > shrinker management.
> > 
> > What you are attempting to do is rotate the object to the tail of
> > the LRU when the last reference is dropped, so that it gets a full
> > trip through the LRU before being reclaimed by the shrinker. And to
> > ensure this "works", the scan from the shrinker checks for reference
> > counts and skip the item being isolated (i.e. return LRU_SKIP) and
> > so leave it in it's place in the LRU.
> > 
> > i.e. you're attempting to manage LRU-ness of the list yourself when,
> > in fact, the list_lru infrastructure does this and doesn't have the
> > subtle bugs your version has. By trying to manage it yourself, the
> > list_lru lists are no longer sorted into memory pressure driven
> > LRU order.
> > 
> > e.g. your manual rotation technique means if there are nr_to_walk
> > referenced items at the head of the list, the shrinker will skip
> > them all and do nothing, even though there are reclaimable objects
> > further down the list. i.e. it can't do any reclaim because it
> > doesn't sort the list into LRU order any more.
> > 
> > This comes from using LRU_SKIP improperly. LRU_SKIP is there for
> > objects that we can't lock in the isolate callback due to lock
> > inversion issues (e.g. see dentry_lru_isolate()), and so we need to
> > look at it again on the next scan pass. hence it gets left in place.
> > 
> > However, if we can lock the item and peer at it's reference counts
> > safely and we decide that we cannot reclaim it because it is
> > referenced, the isolate callback should be returning LRU_ROTATE
> > to move the referenced item to the tail of the list. (Again, see
> > dentry_lru_isolate() for an example.) The means that
> > the next nr_to_walk scan of the list will not rescan that item and
> > skip it again (unless the list is very short), but will instead scan
> > items that it hasn't yet reached.
> > 
> > This avoids the "shrinker does nothing due to skipped items at the
> > head of the list" problem, and makes the LRU function as an actual
> > LRU. i.e.  referenced items all cluster towards the tail of the LRU
> > under memory pressure and the head of the LRU contains the
> > reclaimable objects.
> > 
> > So I think the correct solution is to use LRU_ROTATE correctly
> > rather than try to manage the LRU list order externally like this.
> > 
> 
> Thanks for looking, Dave. Ok, fair enough.
> 
> I grafted the LRU list stuff on after I did the original set, and I
> think the way I designed the refcounting doesn't really work very well
> with it. It has been a while since I added that in, but I do remember
> struggling a bit with lock inversion problems trying to do it the more
> standard way. It's solvable with a nfsd_file spinlock, but I wanted
> to avoid that -- still maybe it's the best way.
> 
> What I don't quite get conceptually is how the list_lru stuff really
> works...
> 
> Looking at the dcache's usage, dentry_lru_add is only called from dput
> and only removed from the list when you're shrinking the dcache or from
> __dentry_kill. It will rotate entries to the end of the list via
> LRU_ROTATE from the shrinker callback if DCACHE_REFERENCED was set, but
> I don't see how you end up with stuff at the end of the list otherwise.

The LRU lists are managed lazily to keep overhead down. You add them
to the list the first time the object becomes unreferenced, and then
don't remove it until the object is reclaimed.

This means that when you do repeated "lookup, grab first reference,
drop last reference" operations on an object, there is no LRU list
management overhead. YOu don't touch the list, you don't touch the
locks, etc. All you touch is the referenced flag in the object and
when memory pressure occurs the object will then be rotated.

> So, the dcache's LRU list doesn't really seem to keep the entries in LRU
> order at all. It just prunes a number of entries that haven't been used
> since the last time the shrinker callback was called, and the rest end
> up staying on the list in whatever order they were originally added.
> So...
> 
> dentry1			dentry2
> allocated
> dput
> 			allocated
> 			dput
> 
> found
> dput again
> (maybe many more times)
> 
> Now, the shrinker runs once and skips both because DCACHE_REFERENCED is
> set. It then runs again later and prunes dentry1 before dentry2 even
> though it has been used many more times since dentry2 has.
> 
> Am I missing something in how this works?

Yes - the frame of reference. When you look at individual cases like
this, it's only "roughly LRU". However, when you scale it up
this small "inaccuracy" turns into noise. Put a thousand entries on
the LRU, and these two inodes don't get reclaimed until 998 others
are reclaimed. Whether d1 or d2 gets reclaimed first really doesn't
matter.

Also, the list_lru code needs to scale to tens of millions
of objects in the LRU and turning over hundreds of thousands of
objects every second, so little inaccuracies really don't matter at
this level - performance and scalability are much more important.

Further, the list_lru is not a true global LRU list at all. It's a
segmented LRU, with separate LRUs for each node or memcg in the
machine. So the LRU really isn't a global LRU at all, it's a bunch
of isolated LRUs designed to allow the mm/ subsystem to do NUMA and
memcg aware object reclaim...

Combine this all and it becomes obvious why the shrinker is
responsible for maintainer LRU order. That comes from object having
a "referenced flag" in it to tell the shrinker that since it has
seen this object the last time, the object has been referenced
again. The shrinker can then remove the referenced flag and rotate
the object to the tail of the list.

If sustained memory pressure occurs, then object will eventually
make it's way back to the head of the LRU, at which time the
shrinker will check the referenced flag again. If it's not set, it
gets reclaimed, if it is set, it gets rotated again.

IOWs, the LRU frame of reference is *memory pressure* - the amount
of object rotation is determined by the amount of memory pressure.
It doesn't matter how many times the code accesses the object,
it's whether it is accessed frequently enough during periods of
memory pressure that it constantly gets rotated to the tail of the
LRU. This basically means the objects that are kept under sustained
heavy memory pressure are the objects that are being constantly
referenced. Anything that is not regularly referenced will filter to
the head of the LRU and hence get reclaimed.

Some subsystems are a bit more complex with their reference "flags".
e.g. the XFS buffer cache keeps a "reclaim count" rather than a
reference flag that determine the number of times an object will be
rotated without an active reference before being reclaimed. This is
done becuase no all buffers are equal e.g. btree roots are much more
important than interior tree nodes which are more important than
leaf nodes, and you can't express this with a single "reference
flag". Hence in terms of reclaim count, root > node > leaf and so we
hold on to metadata that is more likely to be referenced under
sustained memory pressure...

So, it you were expecting a "perfect LRU" list mechanism, the
list_lru abstraction isn't it. When looked at from a macro level it
gives solid, scalable LRU cache reclaim with NUMA and memcg
awareness. When looked at from a micro level, it will display all
sorts of quirks that are a result of the design decisions to enable
performance, scalability and reclaim features at the macro level...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
