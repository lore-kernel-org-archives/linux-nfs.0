From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/32] SUNRPC: Rename rpc_mkdir to rpc_create_client_dir()
Date: Wed, 19 Aug 2009 19:38:38 -0400
Message-ID: <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
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
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380AbZHSXlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:03 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe90b028534
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:51 -0700 (PDT)
In-Reply-To: <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reflects the fact that rpc_mkdir() as it stands today, can only create
a RPC client type directory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    5 +++--
 net/sunrpc/clnt.c                  |    6 +++---
 net/sunrpc/rpc_pipe.c              |   11 +++++------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 91f5b13..8de0ac2 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -44,8 +44,9 @@ RPC_I(struct inode *inode)
 
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
-extern struct dentry *rpc_mkdir(char *, struct rpc_clnt *);
-extern int rpc_rmdir(struct dentry *);
+struct rpc_clnt;
+extern struct dentry *rpc_create_client_dir(const char *, struct rpc_clnt *);
+extern int rpc_remove_client_dir(struct dentry *);
 extern struct dentry *rpc_mkpipe(struct dentry *, const char *, void *,
 				 const struct rpc_pipe_ops *, int flags);
 extern int rpc_unlink(struct dentry *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ebfcf9b..6ec3770 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -113,7 +113,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 				"%s/clnt%x", dir_name,
 				(unsigned int)clntid++);
 		clnt->cl_pathname[sizeof(clnt->cl_pathname) - 1] = '\0';
-		clnt->cl_dentry = rpc_mkdir(clnt->cl_pathname, clnt);
+		clnt->cl_dentry = rpc_create_client_dir(clnt->cl_pathname, clnt);
 		if (!IS_ERR(clnt->cl_dentry))
 			return 0;
 		error = PTR_ERR(clnt->cl_dentry);
@@ -232,7 +232,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 out_no_auth:
 	if (!IS_ERR(clnt->cl_dentry)) {
-		rpc_rmdir(clnt->cl_dentry);
+		rpc_remove_client_dir(clnt->cl_dentry);
 		rpc_put_mount();
 	}
 out_no_path:
@@ -424,7 +424,7 @@ rpc_free_client(struct kref *kref)
 	dprintk("RPC:       destroying %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
 	if (!IS_ERR(clnt->cl_dentry)) {
-		rpc_rmdir(clnt->cl_dentry);
+		rpc_remove_client_dir(clnt->cl_dentry);
 		rpc_put_mount();
 	}
 	if (clnt->cl_parent != clnt) {
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 2a4e6eb..08580be 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -755,7 +755,7 @@ out_bad:
 }
 
 /**
- * rpc_mkdir - Create a new directory in rpc_pipefs
+ * rpc_create_client_dir - Create a new rpc_client directory in rpc_pipefs
  * @path: path from the rpc_pipefs root to the new directory
  * @rpc_client: rpc client to associate with this directory
  *
@@ -764,8 +764,8 @@ out_bad:
  * information about the client, together with any "pipes" that may
  * later be created using rpc_mkpipe().
  */
-struct dentry *
-rpc_mkdir(char *path, struct rpc_clnt *rpc_client)
+struct dentry *rpc_create_client_dir(const char *path,
+				     struct rpc_clnt *rpc_client)
 {
 	struct nameidata nd;
 	struct dentry *dentry;
@@ -797,11 +797,10 @@ out_err:
 }
 
 /**
- * rpc_rmdir - Remove a directory created with rpc_mkdir()
+ * rpc_remove_client_dir - Remove a directory created with rpc_create_client_dir()
  * @dentry: directory to remove
  */
-int
-rpc_rmdir(struct dentry *dentry)
+int rpc_remove_client_dir(struct dentry *dentry)
 {
 	struct dentry *parent;
 	struct inode *dir;
-- 
1.6.0.4
