Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15345 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169Ab3H0U7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 16:59:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH 13/15] SUNRPC: Remove the rpc_client->cl_dentry
Date: Tue, 27 Aug 2013 16:58:50 -0400
Message-ID: <1377637132-53318-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377637132-53318-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1377637132-53318-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-12-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is now redundant.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h        |  1 -
 include/linux/sunrpc/rpc_pipe_fs.h |  2 +-
 net/sunrpc/clnt.c                  | 24 +++++++++++++-----------
 net/sunrpc/rpc_pipe.c              | 13 +++++++------
 4 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 0dccd01..76c0bf6 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -57,7 +57,6 @@ struct rpc_clnt {
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
 	struct rpc_pipe_dir_head cl_pipedir_objects;
-	struct dentry *		cl_dentry;
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 188e7fc..b0cf181 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -94,7 +94,7 @@ extern int rpc_queue_upcall(struct rpc_pipe *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
 extern struct dentry *rpc_create_client_dir(struct dentry *, const char *, struct rpc_clnt *);
-extern int rpc_remove_client_dir(struct dentry *, struct rpc_clnt *);
+extern int rpc_remove_client_dir(struct rpc_clnt *);
 
 extern void rpc_init_pipe_dir_head(struct rpc_pipe_dir_head *pdh);
 extern void rpc_init_pipe_dir_object(struct rpc_pipe_dir_object *pdo,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e60b135..f1c3896 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -102,9 +102,7 @@ static void rpc_unregister_client(struct rpc_clnt *clnt)
 
 static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 {
-	if (clnt->cl_dentry)
-		rpc_remove_client_dir(clnt->cl_dentry, clnt);
-	clnt->cl_dentry = NULL;
+	rpc_remove_client_dir(clnt);
 }
 
 static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
@@ -154,21 +152,26 @@ rpc_setup_pipedir(struct super_block *pipefs_sb, struct rpc_clnt *clnt)
 {
 	struct dentry *dentry;
 
-	clnt->cl_dentry = NULL;
 	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
-	clnt->cl_dentry = dentry;
 	return 0;
 }
 
 static inline int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event)
 {
-	if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
-	    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
-		return 1;
-	if ((event == RPC_PIPEFS_MOUNT) && atomic_read(&clnt->cl_count) == 0)
-		return 1;
+	switch (event) {
+	case RPC_PIPEFS_MOUNT:
+		if (clnt->cl_pipedir_objects.pdh_dentry != NULL)
+			return 1;
+		if (atomic_read(&clnt->cl_count) == 0)
+			return 1;
+		break;
+	case RPC_PIPEFS_UMOUNT:
+		if (clnt->cl_pipedir_objects.pdh_dentry == NULL)
+			return 1;
+		break;
+	}
 	return 0;
 }
 
@@ -185,7 +188,6 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 			return -ENOENT;
 		if (IS_ERR(dentry))
 			return PTR_ERR(dentry);
-		clnt->cl_dentry = dentry;
 		break;
 	case RPC_PIPEFS_UMOUNT:
 		__rpc_clnt_remove_pipedir(clnt);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index cfeba77..a35b2f4 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1055,15 +1055,16 @@ struct dentry *rpc_create_client_dir(struct dentry *dentry,
 
 /**
  * rpc_remove_client_dir - Remove a directory created with rpc_create_client_dir()
- * @dentry: dentry for the pipe
  * @rpc_client: rpc_client for the pipe
  */
-int rpc_remove_client_dir(struct dentry *dentry, struct rpc_clnt *rpc_client)
+int rpc_remove_client_dir(struct rpc_clnt *rpc_client)
 {
-	if (rpc_client->cl_pipedir_objects.pdh_dentry) {
-		rpc_destroy_pipe_dir_objects(&rpc_client->cl_pipedir_objects);
-		rpc_client->cl_pipedir_objects.pdh_dentry = NULL;
-	}
+	struct dentry *dentry = rpc_client->cl_pipedir_objects.pdh_dentry;
+
+	if (dentry == NULL)
+		return 0;
+	rpc_destroy_pipe_dir_objects(&rpc_client->cl_pipedir_objects);
+	rpc_client->cl_pipedir_objects.pdh_dentry = NULL;
 	return rpc_rmdir_depopulate(dentry, rpc_clntdir_depopulate);
 }
 
-- 
1.8.3.1

