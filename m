Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45389 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756556Ab2HTOCg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 10:02:36 -0400
Subject: [PATCH v4 09/10] NFS: callback per-net usage counting introduced
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 20 Aug 2012 18:00:46 +0400
Message-ID: <20120820140046.17404.26919.stgit@localhost.localdomain>
In-Reply-To: <20120820134734.17404.53946.stgit@localhost.localdomain>
References: <20120820134734.17404.53946.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch also introduces refcount-aware nfs_callback_down_net() wrapper for
svc_shutdown_net().

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/callback.c |   19 +++++++++++++++++--
 fs/nfs/netns.h    |    1 +
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index baafa0f..6dfdc83 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -260,10 +260,25 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 	return 0;
 }
 
+static void nfs_callback_down_net(u32 minorversion, struct svc_serv *serv, struct net *net)
+{
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
+
+	if (--nn->cb_users[minorversion])
+		return;
+
+	dprintk("NFS: destroy per-net callback data; net=%p\n", net);
+	svc_shutdown_net(serv, net);
+}
+
 static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct net *net)
 {
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	int ret;
 
+	if (nn->cb_users[minorversion]++)
+		return 0;
+
 	dprintk("NFS: create per-net callback data; net=%p\n", net);
 
 	ret = svc_bind(serv, net);
@@ -378,7 +393,7 @@ err_create:
 	return ret;
 
 err_start:
-	svc_shutdown_net(serv, net);
+	nfs_callback_down_net(minorversion, serv, net);
 	dprintk("NFS: Couldn't create server thread; err = %d\n", ret);
 	goto err_net;
 }
@@ -391,10 +406,10 @@ void nfs_callback_down(int minorversion, struct net *net)
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 
 	mutex_lock(&nfs_callback_mutex);
+	nfs_callback_down_net(minorversion, cb_info->serv, net);
 	cb_info->users--;
 	if (cb_info->users == 0 && cb_info->task != NULL) {
 		kthread_stop(cb_info->task);
-		svc_shutdown_net(cb_info->serv, net);
 		svc_exit_thread(cb_info->rqst);
 		cb_info->serv = NULL;
 		cb_info->rqst = NULL;
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index 137238b..b9c7f9b 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -24,6 +24,7 @@ struct nfs_net {
 	struct idr cb_ident_idr; /* Protected by nfs_client_lock */
 	unsigned short nfs_callback_tcpport;
 	unsigned short nfs_callback_tcpport6;
+	int cb_users[NFS4_MAX_MINOR_VERSION + 1];
 #endif
 	spinlock_t nfs_client_lock;
 	struct timespec boot_time;

