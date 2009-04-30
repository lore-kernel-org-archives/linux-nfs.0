From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 17/39] nfs41: create a svc_xprt for nfs41 callback thread and use for incoming callbacks
Date: Fri,  1 May 2009 02:22:05 +0300
Message-ID: <1241133725-857-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:5579 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757197AbZD3XWM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:22:12 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |   17 ++++++++++++++++-
 net/sunrpc/svc.c  |    1 +
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 9ee174c..8d7c142 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -184,16 +184,31 @@ nfs41_callback_svc(void *vrqstp)
 struct svc_rqst *
 nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 {
+	struct svc_xprt *bc_xprt;
+	struct svc_rqst *rqstp = ERR_PTR(-ENOMEM);
+
+	dprintk("--> %s\n", __func__);
+	/* Create a svc_sock for the service */
+	bc_xprt = svc_sock_create(serv, xprt->prot);
+	if (!bc_xprt)
+		goto out;
+
 	/*
 	 * Save the svc_serv in the transport so that it can
 	 * be referenced when the session backchannel is initialized
 	 */
+	serv->bc_xprt = bc_xprt;
 	xprt->bc_serv = serv;
 
 	INIT_LIST_HEAD(&serv->sv_cb_list);
 	spin_lock_init(&serv->sv_cb_lock);
 	init_waitqueue_head(&serv->sv_cb_waitq);
-	return svc_prepare_thread(serv, &serv->sv_pools[0]);
+	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
+	if (IS_ERR(rqstp))
+		svc_sock_destroy(bc_xprt);
+out:
+	dprintk("--> %s return %p\n", __func__, rqstp);
+	return rqstp;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b35048f..6b90ce4 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1258,6 +1258,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	int 		error;
 
 	/* Build the svc_rqst used by the common processing routine */
+	rqstp->rq_xprt = serv->bc_xprt;
 	rqstp->rq_xid = req->rq_xid;
 	rqstp->rq_prot = req->rq_xprt->prot;
 	rqstp->rq_server = serv;
-- 
1.6.2.1

