From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [PATCH] NFS: add a sysctl for disable the reconnect delay
Date: Thu, 18 Mar 2010 18:11:32 +0800
Message-ID: <4BA1FC54.9020209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54972 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750922Ab0CRKKL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Mar 2010 06:10:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If network partition or some other reason cause a reconnect, it cannot 
succeed immediately when environment recover, but client want to connect
timely sometimes. 

This patch can provide a proc file(/proc/sys/fs/nfs/nfs_disable_reconnect_delay)
to allow client disable the reconnect delay(reestablish_timeout) when using NFS.

It's only useful for NFS.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfs/client.c             |    3 +++
 fs/nfs/sysctl.c             |    8 ++++++++
 include/linux/nfs_fs.h      |    6 ++++++
 include/linux/sunrpc/clnt.h |    1 +
 include/linux/sunrpc/xprt.h |    3 ++-
 net/sunrpc/clnt.c           |    2 ++
 net/sunrpc/xprtsock.c       |    2 +-
 7 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8d25ccb..e878724 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -55,6 +55,8 @@ static LIST_HEAD(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 
+int nfs_disable_reconnect_delay = 0;
+
 /*
  * RPC cruft for NFS
  */
@@ -607,6 +609,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
+		.no_recon_delay	= nfs_disable_reconnect_delay,
 	};
 
 	if (discrtry)
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index b62481d..6c04479 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -58,6 +58,14 @@ static ctl_table nfs_cb_sysctls[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nfs_disable_reconnect_delay",
+		.data		= &nfs_disable_reconnect_delay,
+		.maxlen		= sizeof(nfs_disable_reconnect_delay),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f6b9024..e031496 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -390,6 +390,12 @@ static inline struct rpc_cred *nfs_file_cred(struct file *file)
 }
 
 /*
+ * linux/fs/nfs/client.c
+ */
+
+extern int nfs_disable_reconnect_delay;
+
+/*
  * linux/fs/nfs/xattr.c
  */
 #ifdef CONFIG_NFS_V3_ACL
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 5bd17f6..f73eae1 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -115,6 +115,7 @@ struct rpc_create_args {
 	rpc_authflavor_t	authflavor;
 	unsigned long		flags;
 	char			*client_name;
+	int			no_recon_delay;  /* no delay when reconnect */
 };
 
 /* Values for "flags" field */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1175d58..a177348 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -153,7 +153,8 @@ struct rpc_xprt {
 	unsigned int		max_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
-				resvport   : 1; /* use a reserved port */
+				resvport   : 1, /* use a reserved port */
+				no_recon_delay: 1; /* no delay when reconnect */
 	unsigned int		bind_index;	/* bind function index */
 
 	/*
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index df1039f..7a90d1a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -316,6 +316,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
+	xprt->no_recon_delay = !!args->no_recon_delay;
+
 	clnt = rpc_new_client(args, xprt);
 	if (IS_ERR(clnt))
 		return clnt;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 24c9605..52f2367 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2089,7 +2089,7 @@ static void xs_connect(struct rpc_task *task)
 	if (xprt_test_and_set_connecting(xprt))
 		return;
 
-	if (transport->sock != NULL) {
+	if (!xprt->no_recon_delay && transport->sock != NULL) {
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
-- 
1.6.4


