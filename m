Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:10286 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933256AbeGIT0f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:26:35 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 9/9] NFSD stop ongoing async copies on client shutdown
Date: Mon, 9 Jul 2018 15:26:38 -0400
Message-ID: <20180709192638.44799-10-kolga@netapp.com>
In-Reply-To: <20180709192638.44799-1-kolga@netapp.com>
References: <20180709192638.44799-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <olga.kornievskaia@gmail.com>

If client received DESTROY_CLIENTID and there are (for some reason)
on-going async copies, send CLIENT_BUSY error back (eg., client
didn't send OFFLOAD_CANCEL).

If client's lease expired and client structure is being shutdown
and there are on-going async copies, then shutdown the copies.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 53 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c |  4 +++-
 fs/nfsd/state.h     |  1 +
 fs/nfsd/xdr4.h      |  1 +
 4 files changed, 53 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1343640..9d0d52a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1108,6 +1108,51 @@ void nfs4_put_copy(struct nfsd4_copy *copy)
 	kfree(copy);
 }
 
+static bool
+check_and_set_stop_copy(struct nfsd4_copy *copy)
+{
+	bool value;
+
+	spin_lock(&copy->cp_clp->async_lock);
+	value = copy->stopped;
+	if (!copy->stopped)
+		copy->stopped = true;
+	spin_unlock(&copy->cp_clp->async_lock);
+	return value;
+}
+
+static void nfsd4_stop_copy(struct nfsd4_copy *copy)
+{
+	/* only 1 thread should stop the copy */
+	if (!check_and_set_stop_copy(copy)) {
+		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
+		kthread_stop(copy->copy_task);
+	}
+	nfs4_put_copy(copy);
+}
+
+static struct nfsd4_copy *nfsd4_get_copy(struct nfs4_client *clp)
+{
+	struct nfsd4_copy *copy = NULL;
+
+	spin_lock(&clp->async_lock);
+	if (!list_empty(&clp->async_copies)) {
+		copy = list_first_entry(&clp->async_copies, struct nfsd4_copy,
+					copies);
+		refcount_inc(&copy->refcount);
+	}
+	spin_unlock(&clp->async_lock);
+	return copy;
+}
+
+void nfsd4_shutdown_copy(struct nfs4_client *clp)
+{
+	struct nfsd4_copy *copy;
+
+	while ((copy = nfsd4_get_copy(clp)) != NULL)
+		nfsd4_stop_copy(copy);
+}
+
 static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
 {
 	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
@@ -1301,11 +1346,9 @@ struct nfsd4_copy *
 	struct nfs4_client *clp = cstate->clp;
 
 	copy = find_async_copy(clp, &os->stateid);
-	if (copy) {
-		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
-		kthread_stop(copy->copy_task);
-		nfs4_put_copy(copy);
-	} else
+	if (copy)
+		nfsd4_stop_copy(copy);
+	else
 		status = nfserr_bad_stateid;
 
 	return status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ede1603..51b008e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1974,6 +1974,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 		}
 	}
 	nfsd4_return_all_client_layouts(clp);
+	nfsd4_shutdown_copy(clp);
 	nfsd4_shutdown_callback(clp);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
@@ -2504,7 +2505,8 @@ static bool client_has_state(struct nfs4_client *clp)
 		|| !list_empty(&clp->cl_lo_states)
 #endif
 		|| !list_empty(&clp->cl_delegations)
-		|| !list_empty(&clp->cl_sessions);
+		|| !list_empty(&clp->cl_sessions)
+		|| !list_empty(&clp->async_copies);
 }
 
 __be32
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0bd4329..8db45f9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -634,6 +634,7 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
 extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index beb048d..bf67f27 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -543,6 +543,7 @@ struct nfsd4_copy {
 	struct list_head	copies;
 	struct task_struct	*copy_task;
 	refcount_t		refcount;
+	bool			stopped;
 };
 extern bool async_copy_offload_enable;
 
-- 
1.8.3.1

