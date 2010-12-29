Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:33567 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547Ab0L2NOc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 08:14:32 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v2 04/12] sunrpc: tag svc_serv with rpc_pipefs mount point
Date: Wed, 29 Dec 2010 15:14:22 +0200
Message-Id: <1293628470-28386-5-git-send-email-kas@openvz.org>
In-Reply-To: <1293628470-28386-1-git-send-email-kas@openvz.org>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..3b6b26c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -64,6 +64,7 @@ struct svc_pool {
  */
 struct svc_serv {
 	struct svc_program *	sv_program;	/* RPC program */
+	struct vfsmount *	sv_rpcmount;	/* rpc_pipefs mount point*/
 	struct svc_stat *	sv_stats;	/* RPC statistics */
 	spinlock_t		sv_lock;
 	unsigned int		sv_nrthreads;	/* # of server threads */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6359c42..d2f7c03 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/kthread.h>
 #include <linux/slab.h>
+#include <linux/mount.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -27,6 +28,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
@@ -371,6 +373,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		return NULL;
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
+	serv->sv_rpcmount  = mntget(init_rpc_pipefs);
 	serv->sv_nrthreads = 1;
 	serv->sv_stats     = prog->pg_stats;
 	if (bufsize > RPCSVC_MAXPAYLOAD)
@@ -492,6 +495,7 @@ svc_destroy(struct svc_serv *serv)
 	svc_sock_destroy(serv->bc_xprt);
 #endif /* CONFIG_NFS_V4_1 */
 
+	mntput(serv->sv_rpcmount);
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
-- 
1.7.3.4

