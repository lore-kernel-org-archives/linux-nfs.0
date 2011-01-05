Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19703 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab1AEUvy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 15:51:54 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V8 05/13] NFS use svc_create_xprt for NFSv4.1 callback service
Date: Wed,  5 Jan 2011 15:51:23 -0500
Message-Id: <1294260690-3095-6-git-send-email-andros@netapp.com>
In-Reply-To: <1294260690-3095-5-git-send-email-andros@netapp.com>
References: <1294260690-3095-1-git-send-email-andros@netapp.com>
 <1294260690-3095-2-git-send-email-andros@netapp.com>
 <1294260690-3095-3-git-send-email-andros@netapp.com>
 <1294260690-3095-4-git-send-email-andros@netapp.com>
 <1294260690-3095-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

The new back channel transport means we call the normal creation routine as
well as svc_xprt_put.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 93a8b3b..0e9fae8 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -177,30 +177,38 @@ nfs41_callback_svc(void *vrqstp)
 struct svc_rqst *
 nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 {
-	struct svc_xprt *bc_xprt;
-	struct svc_rqst *rqstp = ERR_PTR(-ENOMEM);
+	struct svc_rqst *rqstp;
+	int ret;
 
-	dprintk("--> %s\n", __func__);
-	/* Create a svc_sock for the service */
-	bc_xprt = svc_sock_create(serv, xprt->prot);
-	if (!bc_xprt)
+	/*
+	 * Create an svc_sock for the back channel service that shares the
+	 * fore channel connection.
+	 * Returns the input port (0) and sets the svc_serv bc_xprt on success
+	 */
+	ret = svc_create_xprt(serv, "tcp-bc", &init_net, PF_INET, 0,
+			      SVC_SOCK_ANONYMOUS);
+	if (ret < 0) {
+		rqstp = ERR_PTR(ret);
 		goto out;
+	}
 
 	/*
 	 * Save the svc_serv in the transport so that it can
 	 * be referenced when the session backchannel is initialized
 	 */
-	serv->bc_xprt = bc_xprt;
 	xprt->bc_serv = serv;
 
 	INIT_LIST_HEAD(&serv->sv_cb_list);
 	spin_lock_init(&serv->sv_cb_lock);
 	init_waitqueue_head(&serv->sv_cb_waitq);
 	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
-	if (IS_ERR(rqstp))
-		svc_sock_destroy(bc_xprt);
+	if (IS_ERR(rqstp)) {
+		svc_xprt_put(serv->bc_xprt);
+		serv->bc_xprt = NULL;
+	}
 out:
-	dprintk("--> %s return %p\n", __func__, rqstp);
+	dprintk("--> %s return %ld\n", __func__,
+		IS_ERR(rqstp) ? PTR_ERR(rqstp) : 0);
 	return rqstp;
 }
 
-- 
1.6.6

