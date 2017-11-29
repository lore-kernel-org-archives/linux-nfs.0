Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:1750 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751936AbdK2LP4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 06:15:56 -0500
From: Elena Reshetova <elena.reshetova@intel.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, bfields@fieldses.org,
        jlayton@kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 1/4] lockd: convert nlm_host.h_count from atomic_t to refcount_t
Date: Wed, 29 Nov 2017 13:15:43 +0200
Message-Id: <1511954146-11793-2-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nlm_host.h_count  is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the nlm_host.h_count it might make a difference
in following places:
 - nlmsvc_release_host(): decrement in refcount_dec()
   provides RELEASE ordering, while original atomic_dec()
   was fully unordered. Since the change is for better, it
   should not matter.
 - nlmclnt_release_host(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart. It doesn't seem to
   matter in this case since object freeing happens under mutex
   lock anyway.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/lockd/host.c             | 14 +++++++-------
 include/linux/lockd/lockd.h |  3 ++-
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 826a891..11b6832 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -151,7 +151,7 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	host->h_state      = 0;
 	host->h_nsmstate   = 0;
 	host->h_pidcount   = 0;
-	atomic_set(&host->h_count, 1);
+	refcount_set(&host->h_count, 1);
 	mutex_init(&host->h_mutex);
 	host->h_nextrebind = now + NLM_HOST_REBIND;
 	host->h_expires    = now + NLM_HOST_EXPIRE;
@@ -290,7 +290,7 @@ void nlmclnt_release_host(struct nlm_host *host)
 
 	WARN_ON_ONCE(host->h_server);
 
-	if (atomic_dec_and_test(&host->h_count)) {
+	if (refcount_dec_and_test(&host->h_count)) {
 		WARN_ON_ONCE(!list_empty(&host->h_lockowners));
 		WARN_ON_ONCE(!list_empty(&host->h_granted));
 		WARN_ON_ONCE(!list_empty(&host->h_reclaim));
@@ -410,7 +410,7 @@ void nlmsvc_release_host(struct nlm_host *host)
 	dprintk("lockd: release server host %s\n", host->h_name);
 
 	WARN_ON_ONCE(!host->h_server);
-	atomic_dec(&host->h_count);
+	refcount_dec(&host->h_count);
 }
 
 /*
@@ -504,7 +504,7 @@ struct nlm_host * nlm_get_host(struct nlm_host *host)
 {
 	if (host) {
 		dprintk("lockd: get host %s\n", host->h_name);
-		atomic_inc(&host->h_count);
+		refcount_inc(&host->h_count);
 		host->h_expires = jiffies + NLM_HOST_EXPIRE;
 	}
 	return host;
@@ -593,7 +593,7 @@ static void nlm_complain_hosts(struct net *net)
 		if (net && host->net != net)
 			continue;
 		dprintk("       %s (cnt %d use %d exp %ld net %x)\n",
-			host->h_name, atomic_read(&host->h_count),
+			host->h_name, refcount_read(&host->h_count),
 			host->h_inuse, host->h_expires, host->net->ns.inum);
 	}
 }
@@ -662,11 +662,11 @@ nlm_gc_hosts(struct net *net)
 	for_each_host_safe(host, next, chain, nlm_server_hosts) {
 		if (net && host->net != net)
 			continue;
-		if (atomic_read(&host->h_count) || host->h_inuse
+		if (refcount_read(&host->h_count) || host->h_inuse
 		 || time_before(jiffies, host->h_expires)) {
 			dprintk("nlm_gc_hosts skipping %s "
 				"(cnt %d use %d exp %ld net %x)\n",
-				host->h_name, atomic_read(&host->h_count),
+				host->h_name, refcount_read(&host->h_count),
 				host->h_inuse, host->h_expires,
 				host->net->ns.inum);
 			continue;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index d7d313f..39dfeea 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -17,6 +17,7 @@
 #include <net/ipv6.h>
 #include <linux/fs.h>
 #include <linux/kref.h>
+#include <linux/refcount.h>
 #include <linux/utsname.h>
 #include <linux/lockd/bind.h>
 #include <linux/lockd/xdr.h>
@@ -58,7 +59,7 @@ struct nlm_host {
 	u32			h_state;	/* pseudo-state counter */
 	u32			h_nsmstate;	/* true remote NSM state */
 	u32			h_pidcount;	/* Pseudopids */
-	atomic_t		h_count;	/* reference count */
+	refcount_t		h_count;	/* reference count */
 	struct mutex		h_mutex;	/* mutex for pmap binding */
 	unsigned long		h_nextrebind;	/* next portmap call */
 	unsigned long		h_expires;	/* eligible for GC */
-- 
2.7.4

