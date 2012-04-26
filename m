Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4471 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757794Ab2DZPzw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 11:55:52 -0400
Subject: [PATCH 07/10] NFS: make nfs_callback_tcpport per network context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 26 Apr 2012 19:55:41 +0400
Message-ID: <20120426155541.3763.44124.stgit@localhost6.localdomain6>
In-Reply-To: <20120426155250.3763.98748.stgit@localhost6.localdomain6>
References: <20120426155250.3763.98748.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/callback.c  |    7 ++++---
 fs/nfs/callback.h  |    1 -
 fs/nfs/netns.h     |    1 +
 fs/nfs/nfs4state.c |    5 ++++-
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 4b8169c..a587c61 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -24,6 +24,7 @@
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "internal.h"
+#include "netns.h"
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
@@ -39,7 +40,6 @@ static DEFINE_MUTEX(nfs_callback_mutex);
 static struct svc_program nfs4_callback_program;
 
 unsigned int nfs_callback_set_tcpport;
-unsigned short nfs_callback_tcpport;
 unsigned short nfs_callback_tcpport6;
 #define NFS_CALLBACK_MAXPORTNR (65535U)
 
@@ -67,14 +67,15 @@ module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, 0644);
 static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 {
 	int ret;
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	ret = svc_create_xprt(serv, "tcp", net, PF_INET,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
 		goto out_err;
-	nfs_callback_tcpport = ret;
+	nn->nfs_callback_tcpport = ret;
 	dprintk("NFS: Callback listener port = %u (af %u, net %p)\n",
-			nfs_callback_tcpport, PF_INET, net);
+			nn->nfs_callback_tcpport, PF_INET, net);
 
 	ret = svc_create_xprt(serv, "tcp", net, PF_INET6,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 6d900cf..8006959 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -208,7 +208,6 @@ extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
 #define NFS41_BC_MAX_CALLBACKS 1
 
 extern unsigned int nfs_callback_set_tcpport;
-extern unsigned short nfs_callback_tcpport;
 extern unsigned short nfs_callback_tcpport6;
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index aa14ec3..8e4e8f8 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -18,6 +18,7 @@ struct nfs_net {
 	struct list_head nfs_volume_list;
 #ifdef CONFIG_NFS_V4
 	struct idr cb_ident_idr; /* Protected by nfs_client_lock */
+	unsigned short nfs_callback_tcpport;
 #endif
 	spinlock_t nfs_client_lock;
 };
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0f43414..5d68b3b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -57,6 +57,8 @@
 #include "internal.h"
 #include "pnfs.h"
 
+#include "netns.h"
+
 #define OPENOWNER_POOL_SIZE	8
 
 const nfs4_stateid zero_stateid;
@@ -71,10 +73,11 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	};
 	unsigned short port;
 	int status;
+	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
 
 	if (test_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state))
 		goto do_confirm;
-	port = nfs_callback_tcpport;
+	port = nn->nfs_callback_tcpport;
 	if (clp->cl_addr.ss_family == AF_INET6)
 		port = nfs_callback_tcpport6;
 

