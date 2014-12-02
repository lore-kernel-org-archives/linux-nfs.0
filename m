Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:47426 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754761AbaLBSYm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 13:24:42 -0500
Received: by mail-qg0-f52.google.com with SMTP id a108so9581294qge.39
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 10:24:41 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [RFC PATCH 08/14] sunrpc: set up workqueue function in svc_xprt
Date: Tue,  2 Dec 2014 13:24:17 -0500
Message-Id: <1417544663-13299-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For workqueue-based services we'll want to queue a workqueue job
whenever a xprt needs to be serviced. Add a work_struct to svc_xprt
and initialize it from a new work_func_t field in the svc_serv_ops.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/svc.h      | 3 +++
 include/linux/sunrpc/svc_xprt.h | 1 +
 net/sunrpc/svc.c                | 2 +-
 net/sunrpc/svc_xprt.c           | 2 ++
 4 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 3d2113222dda..8bd53f723485 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -58,6 +58,9 @@ struct svc_serv_ops {
 	/* function for service threads to run */
 	int		(*svo_function)(void *);
 
+	/* xprt work function */
+	work_func_t	svo_xprt_work;
+
 	/* queue up a transport for servicing */
 	void		(*svo_enqueue_xprt)(struct svc_xprt *);
 
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 78512cfe1fe6..096937871cda 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -53,6 +53,7 @@ struct svc_xprt {
 	struct kref		xpt_ref;
 	struct list_head	xpt_list;
 	struct list_head	xpt_ready;
+	struct work_struct	xpt_work;
 	unsigned long		xpt_flags;
 #define	XPT_BUSY	0		/* enqueued/receiving */
 #define	XPT_CONN	1		/* conn pending */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 165fa1803a0a..135ffbe9d983 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -34,7 +34,7 @@
 
 static void svc_unregister(const struct svc_serv *serv, struct net *net);
 
-#define svc_serv_is_pooled(serv)    ((serv)->sv_ops->svo_function)
+#define svc_serv_is_pooled(serv)    ((serv)->sv_ops->svo_function || (serv)->sv_ops->svo_xprt_work)
 
 #define SVC_POOL_DEFAULT	SVC_POOL_GLOBAL
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 4954339315b7..63b42a8578c0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -157,6 +157,8 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	xprt->xpt_ops = xcl->xcl_ops;
 	kref_init(&xprt->xpt_ref);
 	xprt->xpt_server = serv;
+	if (serv->sv_ops->svo_xprt_work)
+		INIT_WORK(&xprt->xpt_work, serv->sv_ops->svo_xprt_work);
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_ready);
 	INIT_LIST_HEAD(&xprt->xpt_deferred);
-- 
2.1.0

