Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:27217 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141Ab2GENwk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 09:52:40 -0400
Date: Thu, 5 Jul 2012 21:11:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andi Kleen <ak@linux.intel.com>
Cc: Linux-NFS <linux-nfs@vger.kernel.org>, Trond.Myklebust@netapp.com
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120705131105.GA13775@localhost>
References: <20120623122604.GA10887@localhost>
 <20120624213417.GI4152@tassilo.jf.intel.com>
 <20120625024211.GA11057@localhost>
 <20120627180353.GO4152@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120627180353.GO4152@tassilo.jf.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 27, 2012 at 11:03:53AM -0700, Andi Kleen wrote:
> > > Can you try this patch?
> > 
> > Thank you! This patch brings %sys down to 24%, a pretty large improvement!
> 
> I redid the patch now and fixed the race Trond pointed out.
> 
> Fengguang, can you retest please? Trond, does it look good now?

Andi, this patch performs equally well! And it runs stable for over a week.

wfg@snb ~% vmstat 3
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
78  0      0 14084304      0 15489456    0    0     0     0    2    5 43 17 39  0
76  0      0 14077684      0 15501356    0    0     0     0 32553 14948 76 24  0  0
100  0      0 14079660      0 15513388    0    0     0     0 32562 14961 75 25  0  0
120  0      0 12934440      0 15523132    0    0     0     0 32780 15917 74 26  0  0
118  0      0 12845200      0 15531784    0    0     0     0 32495 14932 78 22  0  0
108  0      0 13004212      0 15543092    0    0     0     0 32541 15020 78 22  0  0
120  0      0 13114864      0 15551964    0    0     0     0 32502 14900 78 22  0  0
100  0      0 13305164      0 15562040    0    0     0     0 32497 14980 77 23  0  0
95  0      0 13094524      0 15573836    0    0     0     0 32551 14992 78 22  0  0


Now the most contented locks are 

                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acqui
sitions   holdtime-min   holdtime-max holdtime-total
------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------

               &(&zone->lru_lock)->rlock:     766782640      767439846           0.09         359.51  1315341516.73     6714323642    1003
4569711           0.10       13565.21 22972522899.23
               -------------------------
               &(&zone->lru_lock)->rlock      403547412          [<ffffffff8110dcf7>] release_pages+0xd9/0x197
               &(&zone->lru_lock)->rlock      363659746          [<ffffffff8110de31>] pagevec_lru_move_fn+0x7c/0xd1
               &(&zone->lru_lock)->rlock         232683          [<ffffffff8110d965>] __page_cache_release.part.8+0x47/0xcc
               &(&zone->lru_lock)->rlock              4          [<ffffffff811126c8>] isolate_lru_page+0x66/0x118
               -------------------------
               &(&zone->lru_lock)->rlock      402927785          [<ffffffff8110dcf7>] release_pages+0xd9/0x197
               &(&zone->lru_lock)->rlock      364420999          [<ffffffff8110de31>] pagevec_lru_move_fn+0x7c/0xd1
               &(&zone->lru_lock)->rlock          91058          [<ffffffff8110d965>] __page_cache_release.part.8+0x47/0xcc
               &(&zone->lru_lock)->rlock              3          [<ffffffff8110e269>] add_page_to_unevictable_list+0x43/0x90

..........................................................................................................................................
.....................................................

                     cpufreq_driver_lock:     443785151      443792591           0.14          60.87  7083609116.92      511710115      51
3985181           0.11          31.25   303483059.29
                     -------------------
                     cpufreq_driver_lock      443792591          [<ffffffff817d5eef>] cpufreq_cpu_get+0x22/0x9f
                     -------------------
                     cpufreq_driver_lock      443792591          [<ffffffff817d5eef>] cpufreq_cpu_get+0x22/0x9f

..........................................................................................................................................
.....................................................

                        rcu_node_level_1:     333497521      345451048           0.10          38.72   742394589.16      676477679     175
3637221           0.00          24.74   698337725.87
                        ----------------
                        rcu_node_level_1      320813377          [<ffffffff810d6bc2>] rcu_report_qs_rdp.isra.26+0x25/0x78
                        rcu_node_level_1       23968287          [<ffffffff810d6ac1>] force_qs_rnp+0x3b/0x117
                        rcu_node_level_1          35937          [<ffffffff810d69d8>] rcu_report_qs_rnp+0x1ed/0x29b
                        rcu_node_level_1         633447          [<ffffffff810d6668>] rcu_start_gp+0x158/0x2db
                        ----------------
                        rcu_node_level_1      278686102          [<ffffffff810d6bc2>] rcu_report_qs_rdp.isra.26+0x25/0x78
                        rcu_node_level_1       31540615          [<ffffffff810d6ac1>] force_qs_rnp+0x3b/0x117
                        rcu_node_level_1         634856          [<ffffffff810d69d8>] rcu_report_qs_rnp+0x1ed/0x29b
                        rcu_node_level_1       34589475          [<ffffffff810d6668>] rcu_start_gp+0x158/0x2db

Thanks,
Fengguang

> ---
> 
> From: Andi Kleen <ak@linux.intel.com>
> Date: Sun, 24 Jun 2012 14:31:06 -0700
> Subject: [PATCH] sunrpc: Improve spinlocks in credential lookup path v2
> 
> Fengguang noticed that rpcauth_lookup_credcache has high lock contention
> on the nfs server when doing kernel builds on nfsroot.
> 
> The only reason the spinlock is needed in the lockup path is to
> synchronize with the garbage collector. First the object itself
> is stable because it's RCU'ed.
> 
> So now we use an atomic_add_return and check for the 0 reference
> count case.  When the count was 0 assume the garbage collector
> is active on this entry and take the lock and recheck.
> 
> Otherwise the path is lockless.
> 
> v2: Add GC race check based on Trond's feedback
> Cc: Trond.Myklebust@netapp.com
> Reported-by: Fengguang Wu
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  net/sunrpc/auth.c |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 727e506..645769e 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -364,13 +364,24 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
>  	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
>  		if (!entry->cr_ops->crmatch(acred, entry, flags))
>  			continue;
> -		spin_lock(&cache->lock);
>  		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
> -			spin_unlock(&cache->lock);
>  			continue;
>  		}
> -		cred = get_rpccred(entry);
> -		spin_unlock(&cache->lock);
> +		cred = entry;
> +		if (atomic_add_return(1, &cred->cr_count) == 1) {
> +			/*
> +			 * When the count was 0 we could race with the GC.
> +			 * Take the lock and recheck.
> +			 */
> +			spin_lock(&cache->lock);
> +			if (!test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags)) {
> +				/* Lost the race. */
> +				atomic_dec(&cred->cr_count);
> +				spin_unlock(&cache->lock);
> +				continue;
> +			}
> +			spin_unlock(&cache->lock);
> +		}
>  		break;
>  	}
>  	rcu_read_unlock();
> -- 
> 1.7.7
