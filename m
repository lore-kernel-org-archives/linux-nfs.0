From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 69/85] nfs41: create a svc_xprt for nfs41 callback thread and use for incoming callbacks
Date: Mon, 10 Nov 2008 22:30:32 +0200
Message-ID: <1226349032-9533-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60047 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbYKJUaj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:30:39 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |   17 ++++++++++++++++-
 net/sunrpc/svc.c  |    1 +
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 86f4d88..fc30f87 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -179,16 +179,31 @@ nfs41_callback_svc(void *vrqstp)
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
index b84ae54..1b95de7 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1272,6 +1272,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	int 		error;
 
 	/* Build the svc_rqst used by the common processing routine */
+	rqstp->rq_xprt = serv->bc_xprt;
 	rqstp->rq_xid = req->rq_xid;
 	rqstp->rq_prot = req->rq_xprt->prot;
 	rqstp->rq_server = serv;
-- 
1.6.0.2

