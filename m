Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:33562 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539Ab0L2NOc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 08:14:32 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v2 03/12] sunrpc: push init_rpc_pipefs up to rpc_create() callers
Date: Wed, 29 Dec 2010 15:14:21 +0200
Message-Id: <1293628470-28386-4-git-send-email-kas@openvz.org>
In-Reply-To: <1293628470-28386-1-git-send-email-kas@openvz.org>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 fs/lockd/host.c             |    2 ++
 fs/lockd/mon.c              |    2 ++
 fs/nfs/client.c             |    2 ++
 fs/nfs/mount_clnt.c         |    2 ++
 fs/nfsd/nfs4callback.c      |    2 ++
 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |   11 +++++++----
 net/sunrpc/rpcb_clnt.c      |    3 +++
 8 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index ed0c59f..b033a2d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -14,6 +14,7 @@
 #include <linux/in6.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/lockd/lockd.h>
 #include <linux/mutex.h>
 
@@ -360,6 +361,7 @@ nlm_bind_host(struct nlm_host *host)
 			.authflavor	= RPC_AUTH_UNIX,
 			.flags		= (RPC_CLNT_CREATE_NOPING |
 					   RPC_CLNT_CREATE_AUTOBIND),
+			.rpcmount	= init_rpc_pipefs,
 		};
 
 		/*
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e0c9189..37e5328 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/lockd/lockd.h>
 
 #include <asm/unaligned.h>
@@ -78,6 +79,7 @@ static struct rpc_clnt *nsm_create(void)
 		.version		= NSM_VERSION,
 		.authflavor		= RPC_AUTH_NULL,
 		.flags			= RPC_CLNT_CREATE_NOPING,
+		.rpcmount		= init_rpc_pipefs,
 	};
 
 	return rpc_create(&args);
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0870d0d..e041f39 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -25,6 +25,7 @@
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/xprtrdma.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
@@ -614,6 +615,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
+		.rpcmount	= init_rpc_pipefs,
 	};
 
 	if (discrtry)
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 4f981f1..67b4b8d 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -13,6 +13,7 @@
 #include <linux/in.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/nfs_fs.h>
 #include "internal.h"
 
@@ -161,6 +162,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		.program	= &mnt_program,
 		.version	= info->version,
 		.authflavor	= RPC_AUTH_UNIX,
+		.rpcmount	= init_rpc_pipefs,
 	};
 	struct rpc_clnt		*mnt_clnt;
 	int			status;
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 143da2e..a95150d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -33,6 +33,7 @@
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc_xprt.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/slab.h>
 #include "nfsd.h"
 #include "state.h"
@@ -488,6 +489,7 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 		.version	= 0,
 		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
+		.rpcmount	= init_rpc_pipefs,
 	};
 	struct rpc_clnt *client;
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a5a55f2..f052712 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -116,6 +116,7 @@ struct rpc_create_args {
 	unsigned long		flags;
 	char			*client_name;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
+	struct vfsmount		*rpcmount;
 };
 
 /* Values for "flags" field */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index da2507a..6d88fb7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -96,7 +96,8 @@ static void rpc_unregister_client(struct rpc_clnt *clnt)
 }
 
 static int
-rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
+rpc_setup_pipedir(struct rpc_clnt *clnt, struct vfsmount *rpcmount,
+		char *dir_name)
 {
 	static uint32_t clntid;
 	struct nameidata nd;
@@ -112,7 +113,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	if (dir_name == NULL)
 		return 0;
 
-	path.mnt = mntget(init_rpc_pipefs);
+	path.mnt = mntget(rpcmount);
 	error = vfs_path_lookup(path.mnt->mnt_root, path.mnt, dir_name, 0, &nd);
 	if (error)
 		goto err;
@@ -226,7 +227,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 	atomic_set(&clnt->cl_count, 1);
 
-	err = rpc_setup_pipedir(clnt, program->pipe_dir_name);
+	BUG_ON(!args->rpcmount);
+	err = rpc_setup_pipedir(clnt, args->rpcmount, program->pipe_dir_name);
 	if (err < 0)
 		goto out_no_path;
 
@@ -390,7 +392,8 @@ rpc_clone_client(struct rpc_clnt *clnt)
 			goto out_no_principal;
 	}
 	atomic_set(&new->cl_count, 1);
-	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
+	err = rpc_setup_pipedir(new, clnt->cl_path.mnt,
+			clnt->cl_program->pipe_dir_name);
 	if (err != 0)
 		goto out_no_path;
 	if (new->cl_auth)
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index fa6d7ca..8d04380 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -27,6 +27,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xprtsock.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_BIND
@@ -186,6 +187,7 @@ static int rpcb_create_local(void)
 		.version	= RPCBVERS_2,
 		.authflavor	= RPC_AUTH_UNIX,
 		.flags		= RPC_CLNT_CREATE_NOPING,
+		.rpcmount	= init_rpc_pipefs,
 	};
 	struct rpc_clnt *clnt, *clnt4;
 	int result = 0;
@@ -240,6 +242,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.authflavor	= RPC_AUTH_UNIX,
 		.flags		= (RPC_CLNT_CREATE_NOPING |
 					RPC_CLNT_CREATE_NONPRIVPORT),
+		.rpcmount	= init_rpc_pipefs,
 	};
 
 	switch (srvaddr->sa_family) {
-- 
1.7.3.4

