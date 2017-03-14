Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34832 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750724AbdCNHH3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:29 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 01/12] fs, nfsd: convert nfs4_stid.sc_count from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:09 +0200
Message-Id: <1489475240-6594-2-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfsd/nfs4layouts.c |  4 ++--
 fs/nfsd/nfs4state.c   | 24 ++++++++++++------------
 fs/nfsd/state.h       |  3 ++-
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index e122da6..fed0760 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -335,7 +335,7 @@ nfsd4_recall_file_layout(struct nfs4_layout_stateid *ls)
 
 	trace_layout_recall(&ls->ls_stid.sc_stateid);
 
-	atomic_inc(&ls->ls_stid.sc_count);
+	refcount_inc(&ls->ls_stid.sc_count);
 	nfsd4_run_cb(&ls->ls_recall);
 
 out_unlock:
@@ -440,7 +440,7 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 			goto done;
 	}
 
-	atomic_inc(&ls->ls_stid.sc_count);
+	refcount_inc(&ls->ls_stid.sc_count);
 	list_add_tail(&new->lo_perstate, &ls->ls_layouts);
 	new = NULL;
 done:
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9ef50a..ea1ce57 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -656,7 +656,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	stid->sc_stateid.si_opaque.so_id = new_id;
 	stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
 	/* Will be incremented before return to client: */
-	atomic_set(&stid->sc_count, 1);
+	refcount_set(&stid->sc_count, 1);
 	spin_lock_init(&stid->sc_lock);
 
 	/*
@@ -813,7 +813,7 @@ nfs4_put_stid(struct nfs4_stid *s)
 
 	might_lock(&clp->cl_lock);
 
-	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock)) {
+	if (!refcount_dec_and_lock(&s->sc_count, &clp->cl_lock)) {
 		wake_up_all(&close_wq);
 		return;
 	}
@@ -913,7 +913,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	if (status)
 		return status;
 	++fp->fi_delegees;
-	atomic_inc(&dp->dl_stid.sc_count);
+	refcount_inc(&dp->dl_stid.sc_count);
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
@@ -1214,7 +1214,7 @@ static void put_ol_stateid_locked(struct nfs4_ol_stateid *stp,
 
 	WARN_ON_ONCE(!list_empty(&stp->st_locks));
 
-	if (!atomic_dec_and_test(&s->sc_count)) {
+	if (!refcount_dec_and_test(&s->sc_count)) {
 		wake_up_all(&close_wq);
 		return;
 	}
@@ -2085,7 +2085,7 @@ find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 	s = find_stateid_locked(cl, t);
 	if (s != NULL) {
 		if (typemask & s->sc_type)
-			atomic_inc(&s->sc_count);
+			refcount_inc(&s->sc_count);
 		else
 			s = NULL;
 	}
@@ -3515,7 +3515,7 @@ nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
 			continue;
 		if (local->st_stateowner == &oo->oo_owner) {
 			ret = local;
-			atomic_inc(&ret->st_stid.sc_count);
+			refcount_inc(&ret->st_stid.sc_count);
 			break;
 		}
 	}
@@ -3574,7 +3574,7 @@ init_open_stateid(struct nfs4_file *fp, struct nfsd4_open *open)
 		goto out_unlock;
 
 	open->op_stp = NULL;
-	atomic_inc(&stp->st_stid.sc_count);
+	refcount_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	stp->st_stateowner = nfs4_get_stateowner(&oo->oo_owner);
@@ -3622,7 +3622,7 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 	 * there should be no danger of the refcount going back up again at
 	 * this point.
 	 */
-	wait_event(close_wq, atomic_read(&s->st_stid.sc_count) == 2);
+	wait_event(close_wq, refcount_read(&s->st_stid.sc_count) == 2);
 
 	release_all_access(s);
 	if (s->st_stid.sc_file) {
@@ -3784,7 +3784,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	 * lock) we know the server hasn't removed the lease yet, we know
 	 * it's safe to take a reference.
 	 */
-	atomic_inc(&dp->dl_stid.sc_count);
+	refcount_inc(&dp->dl_stid.sc_count);
 	nfsd4_run_cb(&dp->dl_recall);
 }
 
@@ -5069,7 +5069,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfserr_locks_held;
 		break;
 	case NFS4_LOCK_STID:
-		atomic_inc(&s->sc_count);
+		refcount_inc(&s->sc_count);
 		spin_unlock(&cl->cl_lock);
 		ret = nfsd4_free_lock_stateid(stateid, s);
 		goto out;
@@ -5573,7 +5573,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 
 	lockdep_assert_held(&clp->cl_lock);
 
-	atomic_inc(&stp->st_stid.sc_count);
+	refcount_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = nfs4_get_stateowner(&lo->lo_owner);
 	get_nfs4_file(fp);
@@ -5599,7 +5599,7 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
 		if (lst->st_stid.sc_file == fp) {
-			atomic_inc(&lst->st_stid.sc_count);
+			refcount_inc(&lst->st_stid.sc_count);
 			return lst;
 		}
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 005c911..f927aa4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -36,6 +36,7 @@
 #define _NFSD4_STATE_H
 
 #include <linux/idr.h>
+#include <linux/refcount.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include "nfsfh.h"
 
@@ -83,7 +84,7 @@ struct nfsd4_callback_ops {
  * fields that are of general use to any stateid.
  */
 struct nfs4_stid {
-	atomic_t		sc_count;
+	refcount_t		sc_count;
 #define NFS4_OPEN_STID 1
 #define NFS4_LOCK_STID 2
 #define NFS4_DELEG_STID 4
-- 
2.7.4

