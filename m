Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:48043 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbaKUTTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2014 14:19:40 -0500
Received: by mail-qg0-f41.google.com with SMTP id j5so4234317qga.28
        for <linux-nfs@vger.kernel.org>; Fri, 21 Nov 2014 11:19:40 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] sunrpc: add a rcu_head to svc_rqst and use kfree_rcu to free it
Date: Fri, 21 Nov 2014 14:19:28 -0500
Message-Id: <1416597571-4265-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...also make the manipulation of sp_all_threads list use RCU-friendly
functions.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Tested-by: Chris Worley <chris.worley@primarydata.com>
---
 include/linux/sunrpc/svc.h    |  2 ++
 include/trace/events/sunrpc.h |  3 ++-
 net/sunrpc/svc.c              | 10 ++++++----
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5f0ab39bf7c3..7f80a99c59e4 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -223,6 +223,7 @@ static inline void svc_putu32(struct kvec *iov, __be32 val)
 struct svc_rqst {
 	struct list_head	rq_list;	/* idle list */
 	struct list_head	rq_all;		/* all threads list */
+	struct rcu_head		rq_rcu_head;	/* for RCU deferred kfree */
 	struct svc_xprt *	rq_xprt;	/* transport ptr */
 
 	struct sockaddr_storage	rq_addr;	/* peer address */
@@ -262,6 +263,7 @@ struct svc_rqst {
 #define	RQ_SPLICE_OK	(4)			/* turned off in gss privacy
 						 * to prevent encrypting page
 						 * cache pages */
+#define	RQ_VICTIM	(5)			/* about to be shut down */
 	unsigned long		rq_flags;	/* flags field */
 
 	void *			rq_argp;	/* decoded arguments */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 5848fc235869..08a5fed50f34 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -418,7 +418,8 @@ TRACE_EVENT(xs_tcp_data_recv,
 		{ (1UL << RQ_LOCAL),		"RQ_LOCAL"},		\
 		{ (1UL << RQ_USEDEFERRAL),	"RQ_USEDEFERRAL"},	\
 		{ (1UL << RQ_DROPME),		"RQ_DROPME"},		\
-		{ (1UL << RQ_SPLICE_OK),	"RQ_SPLICE_OK"})
+		{ (1UL << RQ_SPLICE_OK),	"RQ_SPLICE_OK"},	\
+		{ (1UL << RQ_VICTIM),		"RQ_VICTIM"})
 
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 5d9a443d21f6..4edef32f3b9f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -616,7 +616,7 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
 	serv->sv_nrthreads++;
 	spin_lock_bh(&pool->sp_lock);
 	pool->sp_nrthreads++;
-	list_add(&rqstp->rq_all, &pool->sp_all_threads);
+	list_add_rcu(&rqstp->rq_all, &pool->sp_all_threads);
 	spin_unlock_bh(&pool->sp_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
@@ -684,7 +684,8 @@ found_pool:
 		 * so we don't try to kill it again.
 		 */
 		rqstp = list_entry(pool->sp_all_threads.next, struct svc_rqst, rq_all);
-		list_del_init(&rqstp->rq_all);
+		set_bit(RQ_VICTIM, &rqstp->rq_flags);
+		list_del_rcu(&rqstp->rq_all);
 		task = rqstp->rq_task;
 	}
 	spin_unlock_bh(&pool->sp_lock);
@@ -782,10 +783,11 @@ svc_exit_thread(struct svc_rqst *rqstp)
 
 	spin_lock_bh(&pool->sp_lock);
 	pool->sp_nrthreads--;
-	list_del(&rqstp->rq_all);
+	if (!test_and_set_bit(RQ_VICTIM, &rqstp->rq_flags))
+		list_del_rcu(&rqstp->rq_all);
 	spin_unlock_bh(&pool->sp_lock);
 
-	kfree(rqstp);
+	kfree_rcu(rqstp, rq_rcu_head);
 
 	/* Release the server */
 	if (serv)
-- 
2.1.0

