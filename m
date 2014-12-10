Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:48736 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932931AbaLJTIW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:08:22 -0500
Received: by mail-qg0-f43.google.com with SMTP id i50so2647161qgf.30
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:08:21 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 09/16] sunrpc: set up svc_rqst work if it's defined
Date: Wed, 10 Dec 2014 14:07:53 -0500
Message-Id: <1418238480-18857-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to queue most of the work in the context of the svc_rqst. Add a
work_struct to the svc_rqst and a new operation for svc_rqst_work. If
that's defined then initialize it when setting up the service.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/svc.h | 4 ++++
 net/sunrpc/svc.c           | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8bd53f723485..70bee4e86a9f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -61,6 +61,9 @@ struct svc_serv_ops {
 	/* xprt work function */
 	work_func_t	svo_xprt_work;
 
+	/* rqst work function */
+	work_func_t	svo_rqst_work;
+
 	/* queue up a transport for servicing */
 	void		(*svo_enqueue_xprt)(struct svc_xprt *);
 
@@ -293,6 +296,7 @@ struct svc_rqst {
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	struct task_struct	*rq_task;	/* service thread */
 	spinlock_t		rq_lock;	/* per-request lock */
+	struct work_struct	rq_work;	/* per-request work */
 };
 
 #define SVC_NET(svc_rqst)	(svc_rqst->rq_xprt->xpt_net)
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 135ffbe9d983..ed243eb80e5b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -595,6 +595,8 @@ svc_rqst_alloc(struct svc_serv *serv, struct svc_pool *pool, int node)
 	spin_lock_init(&rqstp->rq_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
+	if (serv->sv_ops->svo_rqst_work)
+		INIT_WORK(&rqstp->rq_work, serv->sv_ops->svo_rqst_work);
 
 	rqstp->rq_argp = kmalloc_node(serv->sv_xdrsize, GFP_KERNEL, node);
 	if (!rqstp->rq_argp)
-- 
2.1.0

