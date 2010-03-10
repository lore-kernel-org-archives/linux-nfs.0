From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 08/11] nfsd4: don't sleep in lease-break callback
Date: Tue,  9 Mar 2010 19:28:13 -0500
Message-ID: <1268180896-30921-9-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-4-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-5-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-6-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-7-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-8-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42176 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755693Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-8-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 server's fl_break callback can sleep (dropping the BKL), in
order to allocate a new rpc task to send a recall to the client.

As far as I can tell this doesn't cause any races in the current code,
but the analysis is difficult.  Also, the sleep here may complicate the
move away from the BKL.

So, just schedule some work to do the job for us instead.  The work will
later also prove useful for restarting a call after the callback
information is changed.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c    |   34 ++++++++++++++----------------
 fs/nfsd/state.h        |    5 ++++
 3 files changed, 73 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f84686..a8592be 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/svc_xprt.h>
 #include "nfsd.h"
 #include "state.h"
 
@@ -692,11 +693,41 @@ static const struct rpc_call_ops nfsd4_cb_recall_ops = {
 	.rpc_release = nfsd4_cb_recall_release,
 };
 
+static struct workqueue_struct *callback_wq;
+
+int nfsd4_create_callback_queue(void)
+{
+	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
+	if (!callback_wq)
+		return -ENOMEM;
+	return 0;
+}
+
+void nfsd4_destroy_callback_queue(void)
+{
+	destroy_workqueue(callback_wq);
+}
+
+void nfsd4_set_callback_client(struct nfs4_client *clp, struct rpc_clnt
+*new)
+{
+	struct rpc_clnt *old = clp->cl_cb_conn.cb_client;
+
+	clp->cl_cb_conn.cb_client = new;
+	/*
+	 * After this, any work that saw the old value of cb_client will
+	 * be gone:
+	 */
+	flush_workqueue(callback_wq);
+	/* So we can safely shut it down: */
+	if (old)
+		rpc_shutdown_client(old);
+}
+
 /*
  * called with dp->dl_count inc'ed.
  */
-void
-nfsd4_cb_recall(struct nfs4_delegation *dp)
+static void _nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
 	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
@@ -707,6 +738,9 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 	};
 	int status;
 
+	if (clnt == NULL)
+		return; /* Client is shutting down; give up. */
+
 	args->args_op = dp;
 	msg.rpc_argp = args;
 	dp->dl_retries = 1;
@@ -717,3 +751,19 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		nfs4_put_delegation(dp);
 	}
 }
+
+void nfsd4_do_callback_rpc(struct work_struct *w)
+{
+	/* XXX: for now, just send off delegation recall. */
+	/* In future, generalize to handle any sort of callback. */
+	struct nfsd4_callback *c = container_of(w, struct nfsd4_callback, cb_work);
+	struct nfs4_delegation *dp = container_of(c, struct nfs4_delegation, dl_recall);
+
+	_nfsd4_cb_recall(dp);
+}
+
+
+void nfsd4_cb_recall(struct nfs4_delegation *dp)
+{
+	queue_work(callback_wq, &dp->dl_recall.cb_work);
+}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1b2637b..239a90c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -198,6 +198,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	atomic_set(&dp->dl_count, 1);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
+	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_do_callback_rpc);
 	return dp;
 }
 
@@ -679,21 +680,6 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 	return clp;
 }
 
-static void
-shutdown_callback_client(struct nfs4_client *clp)
-{
-	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
-
-	if (clnt) {
-		/*
-		 * Callback threads take a reference on the client, so there
-		 * should be no outstanding callbacks at this point.
-		 */
-		clp->cl_cb_conn.cb_client = NULL;
-		rpc_shutdown_client(clnt);
-	}
-}
-
 static inline void
 free_client(struct nfs4_client *clp)
 {
@@ -746,7 +732,7 @@ expire_client(struct nfs4_client *clp)
 				 se_perclnt);
 		release_session(ses);
 	}
-	shutdown_callback_client(clp);
+	nfsd4_set_callback_client(clp, NULL);
 	put_nfs4_client(clp);
 }
 
@@ -1388,7 +1374,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	spin_unlock(&sessionid_lock);
 
 	/* wait for callbacks */
-	shutdown_callback_client(ses->se_client);
+	nfsd4_set_callback_client(ses->se_client, NULL);
 	nfsd4_put_session(ses);
 	status = nfs_ok;
 out:
@@ -4000,16 +3986,27 @@ set_max_delegations(void)
 static int
 __nfs4_state_start(void)
 {
+	int ret;
+
 	boot_time = get_seconds();
 	locks_start_grace(&nfsd4_manager);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
 	       nfsd4_grace);
+	ret = set_callback_cred();
+	if (ret)
+		return -ENOMEM;
 	laundry_wq = create_singlethread_workqueue("nfsd4");
 	if (laundry_wq == NULL)
 		return -ENOMEM;
+	ret = nfsd4_create_callback_queue();
+	if (ret)
+		goto out_free_laundry;
 	queue_delayed_work(laundry_wq, &laundromat_work, nfsd4_grace * HZ);
 	set_max_delegations();
-	return set_callback_cred();
+	return 0;
+out_free_laundry:
+	destroy_workqueue(laundry_wq);
+	return ret;
 }
 
 int
@@ -4071,6 +4068,7 @@ nfs4_state_shutdown(void)
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
+	nfsd4_destroy_callback_queue();
 	nfs4_unlock_state();
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 6e5b005..92b0bf0 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -77,6 +77,7 @@ struct nfs4_rpc_args {
 
 struct nfsd4_callback {
 	struct nfs4_rpc_args cb_args;
+	struct work_struct cb_work;
 };
 
 struct nfs4_delegation {
@@ -390,7 +391,11 @@ extern void put_nfs4_client(struct nfs4_client *clp);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern int set_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp, struct svc_xprt *);
+extern void nfsd4_do_callback_rpc(struct work_struct *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
+extern int nfsd4_create_callback_queue(void);
+extern void nfsd4_destroy_callback_queue(void);
+extern void nfsd4_set_callback_client(struct nfs4_client *, struct rpc_clnt *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
 extern void nfsd4_init_recdir(char *recdir_name);
-- 
1.6.3.3

