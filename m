Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:31864 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932247Ab2GCQXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jul 2012 12:23:40 -0400
Subject: [PATCH v3 08/11] NFS: make nfs_callback_tcpport6 per network context
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 03 Jul 2012 20:20:22 +0400
Message-ID: <20120703162022.11911.7120.stgit@localhost.localdomain>
In-Reply-To: <20120703161844.11911.92996.stgit@localhost.localdomain>
References: <20120703161844.11911.92996.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/callback.c  |    5 ++---
 fs/nfs/callback.h  |    1 -
 fs/nfs/netns.h     |    1 +
 fs/nfs/nfs4state.c |    2 +-
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 80032fc..97bccb1 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -39,7 +39,6 @@ static DEFINE_MUTEX(nfs_callback_mutex);
 static struct svc_program nfs4_callback_program;
 
 unsigned int nfs_callback_set_tcpport;
-unsigned short nfs_callback_tcpport6;
 #define NFS_CALLBACK_MAXPORTNR (65535U)
 
 static int param_set_portnr(const char *val, const struct kernel_param *kp)
@@ -79,9 +78,9 @@ static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 	ret = svc_create_xprt(serv, "tcp", net, PF_INET6,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret > 0) {
-		nfs_callback_tcpport6 = ret;
+		nn->nfs_callback_tcpport6 = ret;
 		dprintk("NFS: Callback listener port = %u (af %u, net %p)\n",
-				nfs_callback_tcpport6, PF_INET6, net);
+				nn->nfs_callback_tcpport6, PF_INET6, net);
 	} else if (ret != -EAFNOSUPPORT)
 		goto out_err;
 	return 0;
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 8006959..86b5671 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -208,6 +208,5 @@ extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
 #define NFS41_BC_MAX_CALLBACKS 1
 
 extern unsigned int nfs_callback_set_tcpport;
-extern unsigned short nfs_callback_tcpport6;
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index 06a23fc..097dae1 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -23,6 +23,7 @@ struct nfs_net {
 #ifdef CONFIG_NFS_V4
 	struct idr cb_ident_idr; /* Protected by nfs_client_lock */
 	unsigned short nfs_callback_tcpport;
+	unsigned short nfs_callback_tcpport6;
 #endif
 	spinlock_t nfs_client_lock;
 	struct timespec boot_time;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index bc0ddf8..9313249 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -80,7 +80,7 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 		goto do_confirm;
 	port = nn->nfs_callback_tcpport;
 	if (clp->cl_addr.ss_family == AF_INET6)
-		port = nfs_callback_tcpport6;
+		port = nn->nfs_callback_tcpport6;
 
 	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
 	if (status != 0)

