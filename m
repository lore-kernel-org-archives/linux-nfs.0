Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:53310 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757522Ab1ANNtj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 08:49:39 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Rob Landley <rlandley@parallels.com>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        containers@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v3 05/16] sunrpc: get rpc_pipefs mount point for svc_serv from callers
Date: Fri, 14 Jan 2011 15:49:03 +0200
Message-Id: <1295012954-7769-6-git-send-email-kas@openvz.org>
In-Reply-To: <1295012954-7769-1-git-send-email-kas@openvz.org>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 fs/lockd/svc.c             |    4 +++-
 fs/nfs/callback.c          |    4 +++-
 fs/nfsd/nfssvc.c           |    6 ++++--
 include/linux/sunrpc/svc.h |    8 ++++----
 net/sunrpc/svc.c           |   18 +++++++++---------
 5 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index abfff9d..32310b1 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -31,6 +31,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <net/ip.h>
 #include <linux/lockd/lockd.h>
 #include <linux/nfs.h>
@@ -269,7 +270,8 @@ int lockd_up(void)
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
+	serv = svc_create(&nlmsvc_program, init_rpc_pipefs, LOCKD_BUFSIZE,
+			NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 1990165..7a535c8 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -16,6 +16,7 @@
 #include <linux/freezer.h>
 #include <linux/kthread.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/bc_xprt.h>
 
 #include <net/inet_sock.h>
@@ -290,7 +291,8 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 		nfs_callback_bc_serv(minorversion, xprt, cb_info);
 		goto out;
 	}
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
+	serv = svc_create(&nfs4_callback_program, init_rpc_pipefs,
+			NFS4_CALLBACK_BUFSIZE, NULL);
 	if (!serv) {
 		ret = -ENOMEM;
 		goto out_err;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2bae1d8..d96c32b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -13,6 +13,7 @@
 
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
@@ -331,8 +332,9 @@ int nfsd_create_serv(void)
 	}
 	nfsd_reset_versions();
 
-	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, THIS_MODULE);
+	nfsd_serv = svc_create_pooled(&nfsd_program, init_rpc_pipefs,
+				      nfsd_max_blksize, nfsd_last_thread, nfsd,
+				      THIS_MODULE);
 	if (nfsd_serv == NULL)
 		return -ENOMEM;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 534ea8e..ad30e5d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -400,13 +400,13 @@ struct svc_procedure {
 /*
  * Function prototypes.
  */
-struct svc_serv *svc_create(struct svc_program *, unsigned int,
-			    void (*shutdown)(struct svc_serv *));
+struct svc_serv *svc_create(struct svc_program *, struct vfsmount *,
+			    unsigned int, void (*shutdown)(struct svc_serv *));
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 					struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
-struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			void (*shutdown)(struct svc_serv *),
+struct svc_serv *  svc_create_pooled(struct svc_program *, struct vfsmount *,
+			unsigned int, void (*shutdown)(struct svc_serv *),
 			svc_thread_fn, struct module *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8cc6e79..8472798 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -28,7 +28,6 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/bc_xprt.h>
-#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
@@ -361,7 +360,8 @@ svc_pool_for_cpu(struct svc_serv *serv, int cpu)
  * Create an RPC service
  */
 static struct svc_serv *
-__svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
+__svc_create(struct svc_program *prog, struct vfsmount *rpcmount,
+	     unsigned int bufsize, int npools,
 	     void (*shutdown)(struct svc_serv *serv))
 {
 	struct svc_serv	*serv;
@@ -373,7 +373,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		return NULL;
 	serv->sv_name      = prog->pg_name;
 	serv->sv_program   = prog;
-	serv->sv_rpcmount  = mntget(init_rpc_pipefs);
+	serv->sv_rpcmount  = mntget(rpcmount);
 	serv->sv_nrthreads = 1;
 	serv->sv_stats     = prog->pg_stats;
 	if (bufsize > RPCSVC_MAXPAYLOAD)
@@ -429,22 +429,22 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 }
 
 struct svc_serv *
-svc_create(struct svc_program *prog, unsigned int bufsize,
-	   void (*shutdown)(struct svc_serv *serv))
+svc_create(struct svc_program *prog, struct vfsmount *rpcmount,
+	   unsigned int bufsize, void (*shutdown)(struct svc_serv *serv))
 {
-	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
+	return __svc_create(prog, rpcmount, bufsize, /*npools*/1, shutdown);
 }
 EXPORT_SYMBOL_GPL(svc_create);
 
 struct svc_serv *
-svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  void (*shutdown)(struct svc_serv *serv),
+svc_create_pooled(struct svc_program *prog, struct vfsmount *rpcmount,
+		  unsigned int bufsize, void (*shutdown)(struct svc_serv *serv),
 		  svc_thread_fn func, struct module *mod)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();
 
-	serv = __svc_create(prog, bufsize, npools, shutdown);
+	serv = __svc_create(prog, rpcmount, bufsize, npools, shutdown);
 
 	if (serv != NULL) {
 		serv->sv_function = func;
-- 
1.7.3.4

