From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/10] SUNRPC: Add a (empty for the moment) destructor for
	rpc_wait_queues
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.59129.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752140AbYBZXit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:49 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNclLP027322
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:48 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c                |    1 +
 fs/nfs/nfs4state.c             |    6 +++++-
 include/linux/sunrpc/sched.h   |    1 +
 net/sunrpc/auth_gss/auth_gss.c |    1 +
 net/sunrpc/sched.c             |   21 ++++++++++++++-------
 net/sunrpc/xprt.c              |    5 +++++
 6 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c5c0175..2b20650 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -189,6 +189,7 @@ static void nfs_free_client(struct nfs_client *clp)
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
 		nfs_callback_down();
 
+	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a2ef028..7775435 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -292,8 +292,10 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct
 	spin_unlock(&clp->cl_lock);
 	if (sp == new)
 		get_rpccred(cred);
-	else
+	else {
+		rpc_destroy_wait_queue(&new->so_sequence.wait);
 		kfree(new);
+	}
 	return sp;
 }
 
@@ -310,6 +312,7 @@ void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 		return;
 	nfs4_remove_state_owner(clp, sp);
 	spin_unlock(&clp->cl_lock);
+	rpc_destroy_wait_queue(&sp->so_sequence.wait);
 	put_rpccred(cred);
 	kfree(sp);
 }
@@ -529,6 +532,7 @@ static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
 	spin_lock(&clp->cl_lock);
 	nfs_free_unique_id(&clp->cl_lockowner_id, &lsp->ls_id);
 	spin_unlock(&clp->cl_lock);
+	rpc_destroy_wait_queue(&lsp->ls_sequence.wait);
 	kfree(lsp);
 }
 
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 503a937..d39729e 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -228,6 +228,7 @@ void		rpc_killall_tasks(struct rpc_clnt *);
 void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
+void		rpc_destroy_wait_queue(struct rpc_wait_queue *);
 void		rpc_sleep_on(struct rpc_wait_queue *, struct rpc_task *,
 					rpc_action action);
 void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index dc6391b..ef63849 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -266,6 +266,7 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 	BUG_ON(!list_empty(&gss_msg->list));
 	if (gss_msg->ctx != NULL)
 		gss_put_ctx(gss_msg->ctx);
+	rpc_destroy_wait_queue(&gss_msg->rpc_waitqueue);
 	kfree(gss_msg);
 }
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index caf12fd..86aa897 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -214,6 +214,11 @@ void rpc_init_wait_queue(struct rpc_wait_queue *queue, const char *qname)
 }
 EXPORT_SYMBOL_GPL(rpc_init_wait_queue);
 
+void rpc_destroy_wait_queue(struct rpc_wait_queue *queue)
+{
+}
+EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
+
 static int rpc_wait_bit_killable(void *word)
 {
 	if (fatal_signal_pending(current))
@@ -1020,11 +1025,20 @@ rpc_destroy_mempool(void)
 		kmem_cache_destroy(rpc_task_slabp);
 	if (rpc_buffer_slabp)
 		kmem_cache_destroy(rpc_buffer_slabp);
+	rpc_destroy_wait_queue(&delay_queue);
 }
 
 int
 rpc_init_mempool(void)
 {
+	/*
+	 * The following is not strictly a mempool initialisation,
+	 * but there is no harm in doing it here
+	 */
+	rpc_init_wait_queue(&delay_queue, "delayq");
+	if (!rpciod_start())
+		goto err_nomem;
+
 	rpc_task_slabp = kmem_cache_create("rpc_tasks",
 					     sizeof(struct rpc_task),
 					     0, SLAB_HWCACHE_ALIGN,
@@ -1045,13 +1059,6 @@ rpc_init_mempool(void)
 						      rpc_buffer_slabp);
 	if (!rpc_buffer_mempool)
 		goto err_nomem;
-	if (!rpciod_start())
-		goto err_nomem;
-	/*
-	 * The following is not strictly a mempool initialisation,
-	 * but there is no harm in doing it here
-	 */
-	rpc_init_wait_queue(&delay_queue, "delayq");
 	return 0;
 err_nomem:
 	rpc_destroy_mempool();
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 9bf118c..85199c6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1052,6 +1052,11 @@ static void xprt_destroy(struct kref *kref)
 	xprt->shutdown = 1;
 	del_timer_sync(&xprt->timer);
 
+	rpc_destroy_wait_queue(&xprt->binding);
+	rpc_destroy_wait_queue(&xprt->pending);
+	rpc_destroy_wait_queue(&xprt->sending);
+	rpc_destroy_wait_queue(&xprt->resend);
+	rpc_destroy_wait_queue(&xprt->backlog);
 	/*
 	 * Tear down transport state and free the rpc_xprt
 	 */

