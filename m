Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58649 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751936AbdK2LQC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 06:16:02 -0500
From: Elena Reshetova <elena.reshetova@intel.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, bfields@fieldses.org,
        jlayton@kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 3/4] lockd: convert nlm_lockowner.count from atomic_t to refcount_t
Date: Wed, 29 Nov 2017 13:15:45 +0200
Message-Id: <1511954146-11793-4-git-send-email-elena.reshetova@intel.com>
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

The variable nlm_lockowner.count is used as pure reference counter.
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

For the nlm_lockowner.count it might make a difference
in following places:
 - nlm_put_lockowner(): decrement in refcount_dec_and_lock() only
   provides RELEASE ordering, control dependency on success and
   holds a spin lock on success vs. fully ordered atomic counterpart.
   No changes in spin lock guarantees.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/lockd/clntproc.c         | 6 +++---
 include/linux/lockd/lockd.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 066ac31..112173d 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -48,13 +48,13 @@ void nlmclnt_next_cookie(struct nlm_cookie *c)
 
 static struct nlm_lockowner *nlm_get_lockowner(struct nlm_lockowner *lockowner)
 {
-	atomic_inc(&lockowner->count);
+	refcount_inc(&lockowner->count);
 	return lockowner;
 }
 
 static void nlm_put_lockowner(struct nlm_lockowner *lockowner)
 {
-	if (!atomic_dec_and_lock(&lockowner->count, &lockowner->host->h_lock))
+	if (!refcount_dec_and_lock(&lockowner->count, &lockowner->host->h_lock))
 		return;
 	list_del(&lockowner->list);
 	spin_unlock(&lockowner->host->h_lock);
@@ -105,7 +105,7 @@ static struct nlm_lockowner *nlm_find_lockowner(struct nlm_host *host, fl_owner_
 		res = __nlm_find_lockowner(host, owner);
 		if (res == NULL && new != NULL) {
 			res = new;
-			atomic_set(&new->count, 1);
+			refcount_set(&new->count, 1);
 			new->owner = owner;
 			new->pid = __nlm_alloc_pid(host);
 			new->host = nlm_get_host(host);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index cded0ad..86d012a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -123,7 +123,7 @@ static inline struct sockaddr *nlm_srcaddr(const struct nlm_host *host)
  */
 struct nlm_lockowner {
 	struct list_head list;
-	atomic_t count;
+	refcount_t count;
 
 	struct nlm_host *host;
 	fl_owner_t owner;
-- 
2.7.4

