Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga09.intel.com ([134.134.136.24]:11856 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab2F0SDx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 14:03:53 -0400
Date: Wed, 27 Jun 2012 11:03:53 -0700
From: Andi Kleen <ak@linux.intel.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux-NFS <linux-nfs@vger.kernel.org>, Trond.Myklebust@netapp.com
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120627180353.GO4152@tassilo.jf.intel.com>
References: <20120623122604.GA10887@localhost>
 <20120624213417.GI4152@tassilo.jf.intel.com>
 <20120625024211.GA11057@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120625024211.GA11057@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > Can you try this patch?
> 
> Thank you! This patch brings %sys down to 24%, a pretty large improvement!

I redid the patch now and fixed the race Trond pointed out.

Fengguang, can you retest please? Trond, does it look good now?

---

From: Andi Kleen <ak@linux.intel.com>
Date: Sun, 24 Jun 2012 14:31:06 -0700
Subject: [PATCH] sunrpc: Improve spinlocks in credential lookup path v2

Fengguang noticed that rpcauth_lookup_credcache has high lock contention
on the nfs server when doing kernel builds on nfsroot.

The only reason the spinlock is needed in the lockup path is to
synchronize with the garbage collector. First the object itself
is stable because it's RCU'ed.

So now we use an atomic_add_return and check for the 0 reference
count case.  When the count was 0 assume the garbage collector
is active on this entry and take the lock and recheck.

Otherwise the path is lockless.

v2: Add GC race check based on Trond's feedback
Cc: Trond.Myklebust@netapp.com
Reported-by: Fengguang Wu
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/sunrpc/auth.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 727e506..645769e 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -364,13 +364,24 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
-		spin_lock(&cache->lock);
 		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
-			spin_unlock(&cache->lock);
 			continue;
 		}
-		cred = get_rpccred(entry);
-		spin_unlock(&cache->lock);
+		cred = entry;
+		if (atomic_add_return(1, &cred->cr_count) == 1) {
+			/*
+			 * When the count was 0 we could race with the GC.
+			 * Take the lock and recheck.
+			 */
+			spin_lock(&cache->lock);
+			if (!test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags)) {
+				/* Lost the race. */
+				atomic_dec(&cred->cr_count);
+				spin_unlock(&cache->lock);
+				continue;
+			}
+			spin_unlock(&cache->lock);
+		}
 		break;
 	}
 	rcu_read_unlock();
-- 
1.7.7

