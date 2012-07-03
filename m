Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:20695 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123Ab2GCQYU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jul 2012 12:24:20 -0400
Subject: [PATCH v3 06/11] NFS: callback up - users counting cleanup
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 03 Jul 2012 20:20:08 +0400
Message-ID: <20120703162008.11911.84958.stgit@localhost.localdomain>
In-Reply-To: <20120703161844.11911.92996.stgit@localhost.localdomain>
References: <20120703161844.11911.92996.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Usage coutner now increased only is the service was started sccessfully.
Even if service is running already, then goto is not required anymore, because
service creation and start will be skipped.
With this patch code looks clearer.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/callback.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 550d2a2..f2a7605 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -253,6 +253,9 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 
 	nfs_callback_bc_serv(minorversion, xprt, serv);
 
+	if (cb_info->task)
+		return 0;
+
 	minorversion_setup =  nfs_minorversion_callback_svc_setup(minorversion,
 					serv, &rqstp, &callback_svc);
 	if (!minorversion_setup) {
@@ -308,6 +311,8 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct n
 err_socks:
 	svc_rpcb_cleanup(serv, net);
 err_bind:
+	dprintk("NFS: Couldn't create callback socket: err = %d; "
+			"net = %p\n", ret, net);
 	return ret;
 }
 
@@ -352,7 +357,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 {
 	struct svc_serv *serv;
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
-	int ret = 0;
+	int ret;
 	struct net *net = xprt->xprt_net;
 
 	mutex_lock(&nfs_callback_mutex);
@@ -363,11 +368,6 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 		goto err_create;
 	}
 
-	if (cb_info->users++ || cb_info->task != NULL) {
-		nfs_callback_bc_serv(minorversion, xprt, serv);
-		goto out;
-	}
-
 	ret = nfs_callback_up_net(minorversion, serv, net);
 	if (ret < 0)
 		goto err_net;
@@ -376,13 +376,14 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 	if (ret < 0)
 		goto err_start;
 
-out:
+	cb_info->users++;
 	/*
 	 * svc_create creates the svc_serv with sv_nrthreads == 1, and then
 	 * svc_prepare_thread increments that. So we need to call svc_destroy
 	 * on both success and failure so that the refcount is 1 when the
 	 * thread exits.
 	 */
+err_net:
 	svc_destroy(serv);
 err_create:
 	mutex_unlock(&nfs_callback_mutex);
@@ -390,11 +391,8 @@ err_create:
 
 err_start:
 	svc_shutdown_net(serv, net);
-err_net:
-	dprintk("NFS: Couldn't create callback socket or server thread; "
-		"err = %d\n", ret);
-	cb_info->users--;
-	goto out;
+	dprintk("NFS: Couldn't create server thread; err = %d\n", ret);
+	goto err_net;
 }
 
 /*

