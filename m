Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57237 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754464Ab2KHAo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:44:28 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd4: common helper to initialize callback work
Date: Wed,  7 Nov 2012 19:44:22 -0500
Message-Id: <1352335463-29084-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1352335463-29084-1-git-send-email-bfields@redhat.com>
References: <1352335463-29084-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I've found it confusing having the only references to
nfsd4_do_callback_rpc() in a different file.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    7 ++++++-
 fs/nfsd/nfs4state.c    |    4 ++--
 fs/nfsd/state.h        |    2 +-
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index b32639e..a1aa18d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1016,7 +1016,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		run_nfsd4_cb(cb);
 }
 
-void nfsd4_do_callback_rpc(struct work_struct *w)
+static void nfsd4_do_callback_rpc(struct work_struct *w)
 {
 	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
@@ -1036,6 +1036,11 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
 			cb->cb_ops, cb);
 }
 
+void nfsd4_init_callback(struct nfsd4_callback *cb)
+{
+	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
+}
+
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfsd4_callback *cb = &dp->dl_recall;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4023e77..13f3471 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -340,7 +340,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
-	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_do_callback_rpc);
+	nfsd4_init_callback(&dp->dl_recall);
 	return dp;
 }
 
@@ -1313,7 +1313,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	INIT_LIST_HEAD(&clp->cl_lru);
 	INIT_LIST_HEAD(&clp->cl_callbacks);
 	spin_lock_init(&clp->cl_lock);
-	INIT_WORK(&clp->cl_cb_null.cb_work, nfsd4_do_callback_rpc);
+	nfsd4_init_callback(&clp->cl_cb_null);
 	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 758bc9c..0fd342a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -470,10 +470,10 @@ extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions);
 extern void nfs4_free_openowner(struct nfs4_openowner *);
 extern void nfs4_free_lockowner(struct nfs4_lockowner *);
 extern int set_callback_cred(void);
+extern void nfsd4_init_callback(struct nfsd4_callback *);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
-extern void nfsd4_do_callback_rpc(struct work_struct *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
-- 
1.7.9.5

