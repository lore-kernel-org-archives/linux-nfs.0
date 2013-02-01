Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43920 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756017Ab3BAL1m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 06:27:42 -0500
Subject: [PATCH 2/2] SUNRPC: protect transport processing with per-cpu rw
	semaphore
To: bfields@fieldses.org, akpm@linux-foundation.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 01 Feb 2013 14:28:35 +0300
Message-ID: <20130201112835.24066.20617.stgit@localhost.localdomain>
In-Reply-To: <20130201111046.24066.72836.stgit@localhost.localdomain>
References: <20130201111046.24066.72836.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There could be a service transport, which is processed by service thread and
racing in the same time with per-net service shutdown like listed below:

CPU#0:                            CPU#1:

svc_recv                        svc_close_net
svc_get_next_xprt (list_del_init(xpt_ready))
                            svc_close_list (set XPT_BUSY and XPT_CLOSE)
                            svc_clear_pools(xprt was gained on CPU#0 already)
                            svc_delete_xprt (set XPT_DEAD)
svc_handle_xprt (is XPT_CLOSE => svc_delete_xprt()
BUG()

There can be different solutions of the problem.
Probably, the patch doesn't implement the best one, but I hope the simple one.
IOW, it protects critical section (dequeuing of pending transport and
enqueuing it back to the pool) by per-service rw semaphore, taken for read.
On per-net transports shutdown, this semaphore have to be taken for write.

Note: add the PERCPU_RWSEM config option selected by SUNRPC.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/Kconfig         |    1 +
 net/sunrpc/svc.c           |    2 ++
 net/sunrpc/svc_xprt.c      |   33 +++++++++++++++++++++++++++------
 4 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 1f0216b..2031d14 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -103,6 +103,8 @@ struct svc_serv {
 						 * entries in the svc_cb_list */
 	struct svc_xprt		*sv_bc_xprt;	/* callback on fore channel */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
+
+	struct percpu_rw_semaphore	sv_xprt_sem; /* sem to sync against per-net transports shutdown */
 };
 
 /*
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 03d03e3..5e6548c 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -1,5 +1,6 @@
 config SUNRPC
 	tristate
+	select PERCPU_RWSEM
 
 config SUNRPC_GSS
 	tristate
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b9ba2a8..ef74c72 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -483,6 +483,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	if (svc_uses_rpcbind(serv) && (!serv->sv_shutdown))
 		serv->sv_shutdown = svc_rpcb_cleanup;
 
+	percpu_init_rwsem(&serv->sv_xprt_sem);
+
 	return serv;
 }
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5a9d40c..855a6ba 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -471,6 +471,8 @@ static void svc_xprt_release(struct svc_rqst *rqstp)
 	svc_reserve(rqstp, 0);
 	rqstp->rq_xprt = NULL;
 
+	percpu_up_read(&rqstp->rq_server->sv_xprt_sem);
+
 	svc_xprt_put(xprt);
 }
 
@@ -618,12 +620,14 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 	struct svc_pool		*pool = rqstp->rq_pool;
 	DECLARE_WAITQUEUE(wait, current);
 	long			time_left;
+	struct svc_serv		*serv = rqstp->rq_server;
 
 	/* Normally we will wait up to 5 seconds for any required
 	 * cache information to be provided.
 	 */
 	rqstp->rq_chandle.thread_wait = 5*HZ;
 
+	percpu_down_read(&serv->sv_xprt_sem);
 	spin_lock_bh(&pool->sp_lock);
 	xprt = svc_xprt_dequeue(pool);
 	if (xprt) {
@@ -640,7 +644,8 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 		if (pool->sp_task_pending) {
 			pool->sp_task_pending = 0;
 			spin_unlock_bh(&pool->sp_lock);
-			return ERR_PTR(-EAGAIN);
+			xprt = ERR_PTR(-EAGAIN);
+			goto out_err;
 		}
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
@@ -661,16 +666,19 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 		if (kthread_should_stop()) {
 			set_current_state(TASK_RUNNING);
 			spin_unlock_bh(&pool->sp_lock);
-			return ERR_PTR(-EINTR);
+			xprt = ERR_PTR(-EINTR);
+			goto out_err;
 		}
 
 		add_wait_queue(&rqstp->rq_wait, &wait);
 		spin_unlock_bh(&pool->sp_lock);
+		percpu_up_read(&serv->sv_xprt_sem);
 
 		time_left = schedule_timeout(timeout);
 
 		try_to_freeze();
 
+		percpu_down_read(&serv->sv_xprt_sem);
 		spin_lock_bh(&pool->sp_lock);
 		remove_wait_queue(&rqstp->rq_wait, &wait);
 		if (!time_left)
@@ -681,13 +689,24 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 			svc_thread_dequeue(pool, rqstp);
 			spin_unlock_bh(&pool->sp_lock);
 			dprintk("svc: server %p, no data yet\n", rqstp);
-			if (signalled() || kthread_should_stop())
-				return ERR_PTR(-EINTR);
-			else
-				return ERR_PTR(-EAGAIN);
+			if (signalled() || kthread_should_stop()) {
+				xprt = ERR_PTR(-EINTR);
+				goto out_err;
+			} else {
+				xprt = ERR_PTR(-EAGAIN);
+				goto out_err;
+			}
 		}
 	}
 	spin_unlock_bh(&pool->sp_lock);
+out_err:
+	if (IS_ERR(xprt))
+		/*
+		 * Note: we relased semaphore only if an error occured.
+		 * Otherwise we hold it till transport processing will be
+		 * completed in svc_xprt_release().
+		 */
+		percpu_up_read(&serv->sv_xprt_sem);
 	return xprt;
 }
 
@@ -1020,10 +1039,12 @@ static void svc_clear_list(struct svc_serv *serv, struct list_head *xprt_list, s
 
 void svc_close_net(struct svc_serv *serv, struct net *net)
 {
+	percpu_down_write(&serv->sv_xprt_sem);
 	svc_close_list(serv, &serv->sv_tempsocks, net);
 	svc_close_list(serv, &serv->sv_permsocks, net);
 
 	svc_clear_pools(serv, net);
+	percpu_up_write(&serv->sv_xprt_sem);
 	/*
 	 * At this point the sp_sockets lists will stay empty, since
 	 * svc_xprt_enqueue will not add new entries without taking the

