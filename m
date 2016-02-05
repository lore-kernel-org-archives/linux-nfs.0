Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13990 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbcBEVIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2016 16:08:48 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC Version 1 3/6] SUNRPC: allow rpc_xprt_switch_add_xprt to add xprts on the same net
Date: Fri, 5 Feb 2016 16:08:35 -0500
Message-ID: <1454706518-4641-4-git-send-email-andros@netapp.com>
In-Reply-To: <1454706518-4641-1-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSv4.1 session trunking wants to add multiple xprts to the same net.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c                      |  2 ++
 fs/nfs/nfs4client.c                  |  4 +++-
 include/linux/nfs_fs_sb.h            |  1 +
 include/linux/sunrpc/clnt.h          |  1 +
 include/linux/sunrpc/xprtmultipath.h |  6 +++++-
 net/sunrpc/clnt.c                    |  7 +++++--
 net/sunrpc/xprtmultipath.c           | 33 +++++++++++++++++++++++++++++++--
 7 files changed, 48 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d6d5d2a..f07d639 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -494,6 +494,8 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 	if (test_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_INFINITE_SLOTS;
+	if (test_bit(NFS_CS_SAME_NET_OK, &clp->cl_flags))
+		args.flags |= RPC_CLNT_CREATE_SAME_NET_OK;
 
 	if (!IS_ERR(clp->cl_rpcclient))
 		return 0;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 10410e8..5f20acf 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -365,8 +365,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
 
-	if (clp->cl_minorversion != 0)
+	if (clp->cl_minorversion != 0) {
+		__set_bit(NFS_CS_SAME_NET_OK, &clp->cl_flags);
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
+	}
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7fcc13c..8a63993 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -42,6 +42,7 @@ struct nfs_client {
 #define NFS_CS_MIGRATION	2		/* - transparent state migr */
 #define NFS_CS_INFINITE_SLOTS	3		/* - don't limit TCP slots */
 #define NFS_CS_NO_RETRANS_TIMEOUT	4	/* - Disable retransmit timeouts */
+#define NFS_CS_SAME_NET_OK	5		/* same net multiple xprts ok */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 9a7ddba..d8fa359 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -135,6 +135,7 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_INFINITE_SLOTS	(1UL << 7)
 #define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 8)
 #define RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT	(1UL << 9)
+#define RPC_CLNT_CREATE_SAME_NET_OK	(1UL << 10)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
diff --git a/include/linux/sunrpc/xprtmultipath.h b/include/linux/sunrpc/xprtmultipath.h
index 5a9acff..05697cf 100644
--- a/include/linux/sunrpc/xprtmultipath.h
+++ b/include/linux/sunrpc/xprtmultipath.h
@@ -18,6 +18,10 @@ struct rpc_xprt_switch {
 
 	struct net *		xps_net;
 
+#define XPRT_SWITCH_SAME_NET_OK		(1UL << 0)
+
+	int			xps_flags;
+
 	const struct rpc_xprt_iter_ops *xps_iter_ops;
 
 	struct rcu_head		xps_rcu;
@@ -38,7 +42,7 @@ struct rpc_xprt_iter_ops {
 };
 
 extern struct rpc_xprt_switch *xprt_switch_alloc(struct rpc_xprt *xprt,
-		gfp_t gfp_flags);
+		gfp_t gfp_flags, int flags);
 
 extern struct rpc_xprt_switch *xprt_switch_get(struct rpc_xprt_switch *xps);
 extern void xprt_switch_put(struct rpc_xprt_switch *xps);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a56a44c8..38676a8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -451,8 +451,11 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 {
 	struct rpc_clnt *clnt = NULL;
 	struct rpc_xprt_switch *xps;
+	int flags = 0;
 
-	xps = xprt_switch_alloc(xprt, GFP_KERNEL);
+	if (args->flags & RPC_CLNT_CREATE_SAME_NET_OK)
+		flags |= XPRT_SWITCH_SAME_NET_OK;
+	xps = xprt_switch_alloc(xprt, GFP_KERNEL, flags);
 	if (xps == NULL)
 		return ERR_PTR(-ENOMEM);
 
@@ -683,7 +686,7 @@ int rpc_switch_client_transport(struct rpc_clnt *clnt,
 		return PTR_ERR(xprt);
 	}
 
-	xps = xprt_switch_alloc(xprt, GFP_KERNEL);
+	xps = xprt_switch_alloc(xprt, GFP_KERNEL, 0);
 	if (xps == NULL) {
 		xprt_put(xprt);
 		return -ENOMEM;
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index 8b95ad1..7be5bd2 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -16,6 +16,7 @@
 #include <linux/spinlock.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/xprtmultipath.h>
+#include <linux/sunrpc/addr.h>
 
 typedef struct rpc_xprt *(*xprt_switch_find_xprt_t)(struct list_head *head,
 		const struct rpc_xprt *cur);
@@ -37,6 +38,22 @@ static void xprt_switch_add_xprt_locked(struct rpc_xprt_switch *xps,
 }
 
 /**
+ * See if xprt->addr is already in switch
+ */
+static int
+rpc_xprt_switch_find_addr(struct list_head *head, struct rpc_xprt *xprt)
+{
+	struct rpc_xprt *local;
+
+	list_for_each_entry_rcu(local, head, xprt_switch) {
+		if (rpc_cmp_addr_port((struct sockaddr *)&local->addr,
+				      (struct sockaddr *)&xprt->addr))
+				return 1;
+	}
+	return 0;
+}
+
+/**
  * rpc_xprt_switch_add_xprt - Add a new rpc_xprt to an rpc_xprt_switch
  * @xps: pointer to struct rpc_xprt_switch
  * @xprt: pointer to struct rpc_xprt
@@ -49,8 +66,19 @@ void rpc_xprt_switch_add_xprt(struct rpc_xprt_switch *xps,
 	if (xprt == NULL)
 		return;
 	spin_lock(&xps->xps_lock);
-	if (xps->xps_net != xprt->xprt_net || xps->xps_net == NULL)
+	if (xps->xps_net != xprt->xprt_net || xps->xps_net == NULL) {
+		pr_info("RPC:    ADD NEW NET xprt %p servername %s\n", xprt,
+			xprt->servername);
 		xprt_switch_add_xprt_locked(xps, xprt);
+	}
+	if (xps->xps_flags & XPRT_SWITCH_SAME_NET_OK &&
+	    xps->xps_net == xprt->xprt_net) {
+		if (!rpc_xprt_switch_find_addr(&xps->xps_xprt_list, xprt)) {
+			pr_info("RPC:    ADD SAME NET xprt %p servername %s\n",
+				__func__, xprt, xprt->servername);
+			xprt_switch_add_xprt_locked(xps, xprt);
+		}
+	}
 	spin_unlock(&xps->xps_lock);
 }
 
@@ -91,7 +119,7 @@ void rpc_xprt_switch_remove_xprt(struct rpc_xprt_switch *xps,
  * the entry xprt. Returns NULL on failure.
  */
 struct rpc_xprt_switch *xprt_switch_alloc(struct rpc_xprt *xprt,
-		gfp_t gfp_flags)
+		gfp_t gfp_flags, int flags)
 {
 	struct rpc_xprt_switch *xps;
 
@@ -102,6 +130,7 @@ struct rpc_xprt_switch *xprt_switch_alloc(struct rpc_xprt *xprt,
 		xps->xps_nxprts = 0;
 		INIT_LIST_HEAD(&xps->xps_xprt_list);
 		xps->xps_iter_ops = &rpc_xprt_iter_singular;
+		xps->xps_flags = flags;
 		xprt_switch_add_xprt_locked(xps, xprt);
 	}
 
-- 
1.8.3.1

