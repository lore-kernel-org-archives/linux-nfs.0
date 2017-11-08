Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48685 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdKHF5E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 00:57:04 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 3/4] nfs: remove net pointer from messages
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <680458de-808d-cde1-631e-82f4df0b9a10@virtuozzo.com>
Date: Wed, 8 Nov 2017 08:56:55 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Publishing of net pointer is not safe,
use net->ns.inum instead

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/callback.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index cd9d992..509dc5a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -49,15 +49,15 @@ static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 	if (ret <= 0)
 		goto out_err;
 	nn->nfs_callback_tcpport = ret;
-	dprintk("NFS: Callback listener port = %u (af %u, net %p)\n",
-			nn->nfs_callback_tcpport, PF_INET, net);
+	dprintk("NFS: Callback listener port = %u (af %u, net %x)\n",
+		nn->nfs_callback_tcpport, PF_INET, net->ns.inum);
 
 	ret = svc_create_xprt(serv, "tcp", net, PF_INET6,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret > 0) {
 		nn->nfs_callback_tcpport6 = ret;
-		dprintk("NFS: Callback listener port = %u (af %u, net %p)\n",
-				nn->nfs_callback_tcpport6, PF_INET6, net);
+		dprintk("NFS: Callback listener port = %u (af %u, net %x\n",
+			nn->nfs_callback_tcpport6, PF_INET6, net->ns.inum);
 	} else if (ret != -EAFNOSUPPORT)
 		goto out_err;
 	return 0;
@@ -185,7 +185,7 @@ static void nfs_callback_down_net(u32 minorversion, struct svc_serv *serv, struc
 	if (--nn->cb_users[minorversion])
 		return;
 
-	dprintk("NFS: destroy per-net callback data; net=%p\n", net);
+	dprintk("NFS: destroy per-net callback data; net=%x\n", net->ns.inum);
 	svc_shutdown_net(serv, net);
 }
 
@@ -198,7 +198,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
 	if (nn->cb_users[minorversion]++)
 		return 0;
 
-	dprintk("NFS: create per-net callback data; net=%p\n", net);
+	dprintk("NFS: create per-net callback data; net=%x\n", net->ns.inum);
 
 	ret = svc_bind(serv, net);
 	if (ret < 0) {
@@ -223,7 +223,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
 err_bind:
 	nn->cb_users[minorversion]--;
 	dprintk("NFS: Couldn't create callback socket: err = %d; "
-			"net = %p\n", ret, net);
+			"net = %x\n", ret, net->ns.inum);
 	return ret;
 }
 
-- 
2.7.4

