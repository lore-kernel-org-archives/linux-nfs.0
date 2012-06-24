Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga14.intel.com ([143.182.124.37]:61192 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab2FXVeS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Jun 2012 17:34:18 -0400
Date: Sun, 24 Jun 2012 14:34:17 -0700
From: Andi Kleen <ak@linux.intel.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux-NFS <linux-nfs@vger.kernel.org>
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120624213417.GI4152@tassilo.jf.intel.com>
References: <20120623122604.GA10887@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120623122604.GA10887@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 23, 2012 at 08:26:04PM +0800, Fengguang Wu wrote:
> Hi,
> 
> When doing parallel kernel builds on an NFSROOT system with 32 logical
> CPUs, I see half CPU time spent in kernel:
> 
> top - 20:08:28 up  5:01,  8 users,  load average: 62.97, 55.82, 54.56
> Tasks: 751 total,  80 running, 671 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.1%us, 53.5%sy, 46.4%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.1%si,  0.0%st
> Mem:  65401132k total, 36455604k used, 28945528k free,        0k buffers
> Swap:        0k total,        0k used,        0k free, 31858244k cached
> 
> The attached lock_stat shows that rpcauth_lookup_credcache() has the
> outstanding contentions.

Hmm, the cache is already using RCU for the read case, just takes
a lock for writing. Or when checking an entry.

So you either have a lot of lookups on the same entry, or you thrash
the cache.

When you look up the look address, is it the one in the first loop?
If yes then it's the first.

I'm not fully sure why it takes the lock in the read case anyways. Neither
test_bit nor atomic_inc under RCU should need a lock, so I suppose
it can be just removed.

367                 spin_lock(&cache->lock);
368                 if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
369                         spin_unlock(&cache->lock);
370                         continue;
371                 }
372                 cred = get_rpccred(entry);
373                 spin_unlock(&cache->lock);

and get_rpccred is just

154 static inline
155 struct rpc_cred *       get_rpccred(struct rpc_cred *cred)
156 {
157         atomic_inc(&cred->cr_count);
158         return cred;
159 }

Can you try this patch?

-andi


commit fa1eef2ec22f2fc31e0381b864044fbb753dd572
Author: Andi Kleen <ak@linux.intel.com>
Date:   Sun Jun 24 14:31:06 2012 -0700

    sunrpc: remove useless spinlocks in credential lookup path
    
    Fengguang noticed that rpcauth_lookup_credcache has high lock contention
    on the nfs server when doing kernel builds on nfsroot.
    
    There is no reason to take the spinlock in the read loop: the RCU
    makes sure the object does not go away, and either test_bit
    nor atomic_inc in get_rpccred() needs a lock.
    
    So just remove the spinlock in the read lookup path.
    
    Reported-by: Fengguang Wu
    Signed-off-by: Andi Kleen <ak@linux.intel.com>

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 727e506..13c2b58 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -364,13 +364,10 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
-		spin_lock(&cache->lock);
 		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
-			spin_unlock(&cache->lock);
 			continue;
 		}
 		cred = get_rpccred(entry);
-		spin_unlock(&cache->lock);
 		break;
 	}
 	rcu_read_unlock();
