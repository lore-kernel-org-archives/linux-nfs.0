From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
Date: Sat, 21 Jun 2008 16:46:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806211636090.18642@schroedinger.engr.sgi.com>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
 <20080621224135.GD4692@csn.ul.ie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	kernel-testers@vger.kernel.org,
	kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	Lee Schermerhorn <lee.schermerhorn@hp.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>,
	Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Return-path: <kernel-testers-owner@vger.kernel.org>
In-Reply-To: <20080621224135.GD4692-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Sender: kernel-testers-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 21 Jun 2008, Mel Gorman wrote:

> @@ -3257,10 +3259,10 @@ retry:
>  	 * Look through allowed nodes for objects available
>  	 * from existing per node queues.
>  	 */
> -	for (z = zonelist->zones; *z && !obj; z++) {
> -		nid = zone_to_nid(*z);
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> +		nid = zone_to_nid(zone);
>  
> -		if (cpuset_zone_allowed_hardwall(*z, flags) &&
> +		if (cpuset_zone_allowed_hardwall(zone, flags) &&
>  			cache->nodelists[nid] &&
>  			cache->nodelists[nid]->free_objects)
>  				obj = ____cache_alloc_node(cache,
> 
> Note how that loop no longer breaks out when an object is found before the
> patch but not afterwards. The patch to fix that is below but I don't think
> it helps Alexander assuming he is using SLUB.

Right we have a significant memory leak here. Potentially one object for 
each zone is allocated and abandoned. May trigger more allocations
and therefore trigger more frequent reclaim because the free objects are
rapidly consumed on a system that relies on fallback allocations 
(memoryless nodes f.e.). Not a direct explanation for the problem but the
memory wastage could certainly can heretofore undiscovered locking 
dependencies to be exposed.

> --- linux-2.6.26-rc5-clean/mm/slab.c	2008-06-05 04:10:44.000000000 +0100
> +++ linux-2.6.26-rc5-fix-slab-leak/mm/slab.c	2008-06-21 22:50:07.000000000 +0100
> @@ -3266,6 +3266,10 @@ retry:
>  			cache->nodelists[nid]->free_objects)
>  				obj = ____cache_alloc_node(cache,
>  					flags | GFP_THISNODE, nid);
> +
> +		/* Do not scan further once an object has been allocated */
> +		if (obj)
> +			break;
>  	}
>  
>  	if (!obj) {
> 

Ok. That would work but its better to put the check into the if branch:


Subject: Slab: Fix memory leak in fallback_alloc()

The zonelist patches caused the loop that checks for available
objects in permitted zones to not terminate immediately. One object
per zone per allocation may be allocated and then abandoned.

Break the loop when we have successfully allocated one object.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slab.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2008-06-21 16:39:04.336377178 -0700
+++ linux-2.6/mm/slab.c	2008-06-21 16:40:07.637834699 -0700
@@ -3263,9 +3263,12 @@ retry:
 
 		if (cpuset_zone_allowed_hardwall(zone, flags) &&
 			cache->nodelists[nid] &&
-			cache->nodelists[nid]->free_objects)
+			cache->nodelists[nid]->free_objects) {
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
+				if (obj)
+					break;
+		}
 	}
 
 	if (!obj) {

