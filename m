Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:41260 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752130AbeCPNqs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Mar 2018 09:46:48 -0400
From: Jeff Layton <jlayton@kernel.org>
To: bfields@fieldses.org
Cc: smayhew@redhat.com, sorenson@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: remove blocked locks on client teardown
Date: Fri, 16 Mar 2018 09:46:46 -0400
Message-Id: <20180316134646.25845-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

We had some reports of panics in nfsd4_lm_notify, and that showed a
nfs4_lockowner that had outlived its so_client.

Ensure that we walk any leftover lockowners after tearing down all of
the stateids, and remove any blocked locks that they hold.

Fixes: 76d348fadff5 (nfsd: have nfsd4_lock use blocking locks for v4.1+ locks)
Reported-by: Frank Sorenson <fsorenso@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
Cc: stable@vger.kernel.org # 4.9
---
 fs/nfsd/nfs4state.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 08c700864fee..0c1eff2be2e8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -268,6 +268,35 @@ free_blocked_lock(struct nfsd4_blocked_lock *nbl)
 	kfree(nbl);
 }
 
+static void
+remove_blocked_locks(struct nfs4_lockowner *lo)
+{
+	struct nfs4_client *clp = lo->lo_owner.so_client;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfsd4_blocked_lock *nbl;
+	LIST_HEAD(reaplist);
+
+	/* Dequeue all blocked locks */
+	spin_lock(&nn->blocked_locks_lock);
+	while (!list_empty(&lo->lo_blocked)) {
+		nbl = list_first_entry(&lo->lo_blocked,
+					struct nfsd4_blocked_lock,
+					nbl_list);
+		list_del_init(&nbl->nbl_list);
+		list_move(&nbl->nbl_lru, &reaplist);
+	}
+	spin_unlock(&nn->blocked_locks_lock);
+
+	/* Now free them */
+	while (!list_empty(&reaplist)) {
+		nbl = list_first_entry(&reaplist, struct nfsd4_blocked_lock,
+					nbl_lru);
+		list_del_init(&nbl->nbl_lru);
+		posix_unblock_lock(&nbl->nbl_lock);
+		free_blocked_lock(nbl);
+	}
+}
+
 static int
 nfsd4_cb_notify_lock_done(struct nfsd4_callback *cb, struct rpc_task *task)
 {
@@ -1866,6 +1895,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 static void
 __destroy_client(struct nfs4_client *clp)
 {
+	int i;
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
@@ -1895,6 +1925,16 @@ __destroy_client(struct nfs4_client *clp)
 		nfs4_get_stateowner(&oo->oo_owner);
 		release_openowner(oo);
 	}
+	for (i = 0; i < OWNER_HASH_SIZE; i++) {
+		struct nfs4_stateowner *so, *tmp;
+
+		list_for_each_entry_safe(so, tmp, &clp->cl_ownerstr_hashtbl[i],
+					 so_strhash) {
+			/* Should be no openowners at this point */
+			WARN_ON_ONCE(so->so_is_open_owner);
+			remove_blocked_locks(lockowner(so));
+		}
+	}
 	nfsd4_return_all_client_layouts(clp);
 	nfsd4_shutdown_callback(clp);
 	if (clp->cl_cb_conn.cb_xprt)
@@ -6366,6 +6406,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	}
 	spin_unlock(&clp->cl_lock);
 	free_ol_stateid_reaplist(&reaplist);
+	remove_blocked_locks(lo);
 	nfs4_put_stateowner(&lo->lo_owner);
 
 	return status;
-- 
2.14.3

