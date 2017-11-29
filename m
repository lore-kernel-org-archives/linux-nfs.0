Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:1750 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752847AbdK2LP7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 06:15:59 -0500
From: Elena Reshetova <elena.reshetova@intel.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, bfields@fieldses.org,
        jlayton@kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 2/4] lockd: convert nsm_handle.sm_count from atomic_t to refcount_t
Date: Wed, 29 Nov 2017 13:15:44 +0200
Message-Id: <1511954146-11793-3-git-send-email-elena.reshetova@intel.com>
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

The variable nsm_handle.sm_count is used as pure reference counter.
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

For the nsm_handle.sm_count it might make a difference
in following places:
 - nsm_release(): decrement in refcount_dec_and_lock() only
   provides RELEASE ordering, control dependency on success
   and holds a spin lock on success vs. fully ordered atomic
   counterpart. No change for the spin lock guarantees.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/lockd/host.c             |  2 +-
 fs/lockd/mon.c              | 14 +++++++-------
 include/linux/lockd/lockd.h |  2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 11b6832..7d6ab72 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -114,7 +114,7 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	unsigned long now = jiffies;
 
 	if (nsm != NULL)
-		atomic_inc(&nsm->sm_count);
+		refcount_inc(&nsm->sm_count);
 	else {
 		host = NULL;
 		nsm = nsm_get_handle(ni->net, ni->sap, ni->salen,
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 96cfb29..654594e 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -191,7 +191,7 @@ void nsm_unmonitor(const struct nlm_host *host)
 	struct nsm_res	res;
 	int status;
 
-	if (atomic_read(&nsm->sm_count) == 1
+	if (refcount_read(&nsm->sm_count) == 1
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
 		dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
 
@@ -279,7 +279,7 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 	if (unlikely(new == NULL))
 		return NULL;
 
-	atomic_set(&new->sm_count, 1);
+	refcount_set(&new->sm_count, 1);
 	new->sm_name = (char *)(new + 1);
 	memcpy(nsm_addr(new), sap, salen);
 	new->sm_addrlen = salen;
@@ -337,13 +337,13 @@ struct nsm_handle *nsm_get_handle(const struct net *net,
 		cached = nsm_lookup_addr(&ln->nsm_handles, sap);
 
 	if (cached != NULL) {
-		atomic_inc(&cached->sm_count);
+		refcount_inc(&cached->sm_count);
 		spin_unlock(&nsm_lock);
 		kfree(new);
 		dprintk("lockd: found nsm_handle for %s (%s), "
 				"cnt %d\n", cached->sm_name,
 				cached->sm_addrbuf,
-				atomic_read(&cached->sm_count));
+				refcount_read(&cached->sm_count));
 		return cached;
 	}
 
@@ -388,12 +388,12 @@ struct nsm_handle *nsm_reboot_lookup(const struct net *net,
 		return cached;
 	}
 
-	atomic_inc(&cached->sm_count);
+	refcount_inc(&cached->sm_count);
 	spin_unlock(&nsm_lock);
 
 	dprintk("lockd: host %s (%s) rebooted, cnt %d\n",
 			cached->sm_name, cached->sm_addrbuf,
-			atomic_read(&cached->sm_count));
+			refcount_read(&cached->sm_count));
 	return cached;
 }
 
@@ -404,7 +404,7 @@ struct nsm_handle *nsm_reboot_lookup(const struct net *net,
  */
 void nsm_release(struct nsm_handle *nsm)
 {
-	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
+	if (refcount_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
 		list_del(&nsm->sm_link);
 		spin_unlock(&nsm_lock);
 		dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 39dfeea..cded0ad 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -84,7 +84,7 @@ struct nlm_host {
 
 struct nsm_handle {
 	struct list_head	sm_link;
-	atomic_t		sm_count;
+	refcount_t		sm_count;
 	char			*sm_mon_name;
 	char			*sm_name;
 	struct sockaddr_storage	sm_addr;
-- 
2.7.4

