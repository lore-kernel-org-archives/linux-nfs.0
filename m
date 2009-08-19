From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 17/32] SUNRPC: Replace rpc_client->cl_dentry and cl_mnt,
 with a cl_path
Date: Wed, 19 Aug 2009 19:38:40 -0400
Message-ID: <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754039AbZHSXky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:54 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePRJ001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:42 -0700 (PDT)
In-Reply-To: <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c                 |    4 ++--
 include/linux/sunrpc/clnt.h    |    4 ++--
 net/sunrpc/auth_gss/auth_gss.c |    4 ++--
 net/sunrpc/clnt.c              |   24 ++++++++++++------------
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index fae0d3e..21a84d4 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -119,8 +119,8 @@ nfs_idmap_new(struct nfs_client *clp)
 	if (idmap == NULL)
 		return -ENOMEM;
 
-	idmap->idmap_dentry = rpc_mkpipe(clp->cl_rpcclient->cl_dentry, "idmap",
-					 idmap, &idmap_upcall_ops, 0);
+	idmap->idmap_dentry = rpc_mkpipe(clp->cl_rpcclient->cl_path.dentry,
+			"idmap", idmap, &idmap_upcall_ops, 0);
 	if (IS_ERR(idmap->idmap_dentry)) {
 		error = PTR_ERR(idmap->idmap_dentry);
 		kfree(idmap);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 37881f1..38ad162 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -17,6 +17,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/timer.h>
 #include <asm/signal.h>
+#include <linux/path.h>
 
 struct rpc_inode;
 
@@ -51,8 +52,7 @@ struct rpc_clnt {
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
 	char			cl_pathname[30];/* Path in rpc_pipe_fs */
-	struct vfsmount *	cl_vfsmnt;
-	struct dentry *		cl_dentry;	/* inode */
+	struct path		cl_path;
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 23eb386..fc6a43c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -777,7 +777,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	 * that we supported only the old pipe.  So we instead create
 	 * the new pipe first.
 	 */
-	gss_auth->dentry[1] = rpc_mkpipe(clnt->cl_dentry,
+	gss_auth->dentry[1] = rpc_mkpipe(clnt->cl_path.dentry,
 					 "gssd",
 					 clnt, &gss_upcall_ops_v1,
 					 RPC_PIPE_WAIT_FOR_OPEN);
@@ -786,7 +786,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 		goto err_put_mech;
 	}
 
-	gss_auth->dentry[0] = rpc_mkpipe(clnt->cl_dentry,
+	gss_auth->dentry[0] = rpc_mkpipe(clnt->cl_path.dentry,
 					 gss_auth->mech->gm_name,
 					 clnt, &gss_upcall_ops_v0,
 					 RPC_PIPE_WAIT_FOR_OPEN);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6ec3770..b3f8633 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -99,24 +99,24 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	static uint32_t clntid;
 	int error;
 
-	clnt->cl_vfsmnt = ERR_PTR(-ENOENT);
-	clnt->cl_dentry = ERR_PTR(-ENOENT);
+	clnt->cl_path.mnt = ERR_PTR(-ENOENT);
+	clnt->cl_path.dentry = ERR_PTR(-ENOENT);
 	if (dir_name == NULL)
 		return 0;
 
-	clnt->cl_vfsmnt = rpc_get_mount();
-	if (IS_ERR(clnt->cl_vfsmnt))
-		return PTR_ERR(clnt->cl_vfsmnt);
+	clnt->cl_path.mnt = rpc_get_mount();
+	if (IS_ERR(clnt->cl_path.mnt))
+		return PTR_ERR(clnt->cl_path.mnt);
 
 	for (;;) {
 		snprintf(clnt->cl_pathname, sizeof(clnt->cl_pathname),
 				"%s/clnt%x", dir_name,
 				(unsigned int)clntid++);
 		clnt->cl_pathname[sizeof(clnt->cl_pathname) - 1] = '\0';
-		clnt->cl_dentry = rpc_create_client_dir(clnt->cl_pathname, clnt);
-		if (!IS_ERR(clnt->cl_dentry))
+		clnt->cl_path.dentry = rpc_create_client_dir(clnt->cl_pathname, clnt);
+		if (!IS_ERR(clnt->cl_path.dentry))
 			return 0;
-		error = PTR_ERR(clnt->cl_dentry);
+		error = PTR_ERR(clnt->cl_path.dentry);
 		if (error != -EEXIST) {
 			printk(KERN_INFO "RPC: Couldn't create pipefs entry %s, error %d\n",
 					clnt->cl_pathname, error);
@@ -231,8 +231,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	return clnt;
 
 out_no_auth:
-	if (!IS_ERR(clnt->cl_dentry)) {
-		rpc_remove_client_dir(clnt->cl_dentry);
+	if (!IS_ERR(clnt->cl_path.dentry)) {
+		rpc_remove_client_dir(clnt->cl_path.dentry);
 		rpc_put_mount();
 	}
 out_no_path:
@@ -423,8 +423,8 @@ rpc_free_client(struct kref *kref)
 
 	dprintk("RPC:       destroying %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
-	if (!IS_ERR(clnt->cl_dentry)) {
-		rpc_remove_client_dir(clnt->cl_dentry);
+	if (!IS_ERR(clnt->cl_path.dentry)) {
+		rpc_remove_client_dir(clnt->cl_path.dentry);
 		rpc_put_mount();
 	}
 	if (clnt->cl_parent != clnt) {
-- 
1.6.0.4
