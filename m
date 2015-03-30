Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34059 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbbC3V6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 17:58:25 -0400
Received: by qgep97 with SMTP id p97so202266204qge.1
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 14:58:24 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, gregkh@linuxfoundation.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: make debugfs file creation failure non-fatal
Date: Mon, 30 Mar 2015 17:58:18 -0400
Message-Id: <1427752698-32431-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently have a problem that SELinux policy is being enforced when
creating debugfs files. If a debugfs file is created as a side effect of
doing some syscall, then that creation can fail if the SELinux policy
for that process prevents it.

This seems wrong. We don't do that for files under /proc, for instance,
so Bruce has proposed a patch to fix that.

While discussing that patch however, Greg K.H. stated:

    "No kernel code should care / fail if a debugfs function fails, so
     please fix up the sunrpc code first."

This patch converts all of the sunrpc debugfs setup code to be void
return functins, and the callers to not look for errors from those
functions.

This should allow rpc_clnt and rpc_xprt creation to work, even if the
kernel fails to create debugfs files for some reason.

Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/sunrpc/debug.h | 18 +++++++++---------
 net/sunrpc/clnt.c            |  4 +---
 net/sunrpc/debugfs.c         | 34 +++++++++++++---------------------
 net/sunrpc/sunrpc_syms.c     |  7 +------
 net/sunrpc/xprt.c            |  7 +------
 5 files changed, 25 insertions(+), 45 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index c57d8ea0716c..59a7889e15db 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -60,17 +60,17 @@ struct rpc_xprt;
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 void		rpc_register_sysctl(void);
 void		rpc_unregister_sysctl(void);
-int		sunrpc_debugfs_init(void);
+void		sunrpc_debugfs_init(void);
 void		sunrpc_debugfs_exit(void);
-int		rpc_clnt_debugfs_register(struct rpc_clnt *);
+void		rpc_clnt_debugfs_register(struct rpc_clnt *);
 void		rpc_clnt_debugfs_unregister(struct rpc_clnt *);
-int		rpc_xprt_debugfs_register(struct rpc_xprt *);
+void		rpc_xprt_debugfs_register(struct rpc_xprt *);
 void		rpc_xprt_debugfs_unregister(struct rpc_xprt *);
 #else
-static inline int
+static inline void
 sunrpc_debugfs_init(void)
 {
-	return 0;
+	return;
 }
 
 static inline void
@@ -79,10 +79,10 @@ sunrpc_debugfs_exit(void)
 	return;
 }
 
-static inline int
+static inline void
 rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 {
-	return 0;
+	return;
 }
 
 static inline void
@@ -91,10 +91,10 @@ rpc_clnt_debugfs_unregister(struct rpc_clnt *clnt)
 	return;
 }
 
-static inline int
+static inline void
 rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
 {
-	return 0;
+	return;
 }
 
 static inline void
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 612aa73bbc60..e6ce1517367f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -303,9 +303,7 @@ static int rpc_client_register(struct rpc_clnt *clnt,
 	struct super_block *pipefs_sb;
 	int err;
 
-	err = rpc_clnt_debugfs_register(clnt);
-	if (err)
-		return err;
+	rpc_clnt_debugfs_register(clnt);
 
 	pipefs_sb = rpc_get_sb_net(net);
 	if (pipefs_sb) {
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index e811f390f9f6..1c2e3960b939 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -129,32 +129,30 @@ static const struct file_operations tasks_fops = {
 	.release	= tasks_release,
 };
 
-int
+void
 rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 {
-	int len, err;
+	int len;
 	char name[24]; /* enough for "../../rpc_xprt/ + 8 hex digits + NULL */
 
 	/* Already registered? */
 	if (clnt->cl_debugfs)
-		return 0;
+		return;
 
 	len = snprintf(name, sizeof(name), "%x", clnt->cl_clid);
 	if (len >= sizeof(name))
-		return -EINVAL;
+		return;
 
 	/* make the per-client dir */
 	clnt->cl_debugfs = debugfs_create_dir(name, rpc_clnt_dir);
 	if (!clnt->cl_debugfs)
-		return -ENOMEM;
+		return;
 
 	/* make tasks file */
-	err = -ENOMEM;
 	if (!debugfs_create_file("tasks", S_IFREG | S_IRUSR, clnt->cl_debugfs,
 				 clnt, &tasks_fops))
 		goto out_err;
 
-	err = -EINVAL;
 	rcu_read_lock();
 	len = snprintf(name, sizeof(name), "../../rpc_xprt/%s",
 			rcu_dereference(clnt->cl_xprt)->debugfs->d_name.name);
@@ -162,15 +160,13 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	if (len >= sizeof(name))
 		goto out_err;
 
-	err = -ENOMEM;
 	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs, name))
 		goto out_err;
 
-	return 0;
+	return;
 out_err:
 	debugfs_remove_recursive(clnt->cl_debugfs);
 	clnt->cl_debugfs = NULL;
-	return err;
 }
 
 void
@@ -226,7 +222,7 @@ static const struct file_operations xprt_info_fops = {
 	.release	= xprt_info_release,
 };
 
-int
+void
 rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
 {
 	int len, id;
@@ -237,22 +233,19 @@ rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
 
 	len = snprintf(name, sizeof(name), "%x", id);
 	if (len >= sizeof(name))
-		return -EINVAL;
+		return;
 
 	/* make the per-client dir */
 	xprt->debugfs = debugfs_create_dir(name, rpc_xprt_dir);
 	if (!xprt->debugfs)
-		return -ENOMEM;
+		return;
 
 	/* make tasks file */
 	if (!debugfs_create_file("info", S_IFREG | S_IRUSR, xprt->debugfs,
 				 xprt, &xprt_info_fops)) {
 		debugfs_remove_recursive(xprt->debugfs);
 		xprt->debugfs = NULL;
-		return -ENOMEM;
 	}
-
-	return 0;
 }
 
 void
@@ -266,14 +259,15 @@ void __exit
 sunrpc_debugfs_exit(void)
 {
 	debugfs_remove_recursive(topdir);
+	topdir = NULL;
 }
 
-int __init
+void __init
 sunrpc_debugfs_init(void)
 {
 	topdir = debugfs_create_dir("sunrpc", NULL);
 	if (!topdir)
-		goto out;
+		return;
 
 	rpc_clnt_dir = debugfs_create_dir("rpc_clnt", topdir);
 	if (!rpc_clnt_dir)
@@ -283,10 +277,8 @@ sunrpc_debugfs_init(void)
 	if (!rpc_xprt_dir)
 		goto out_remove;
 
-	return 0;
+	return;
 out_remove:
 	debugfs_remove_recursive(topdir);
 	topdir = NULL;
-out:
-	return -ENOMEM;
 }
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index e37fbed87956..ee5d3d253102 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -98,10 +98,7 @@ init_sunrpc(void)
 	if (err)
 		goto out4;
 
-	err = sunrpc_debugfs_init();
-	if (err)
-		goto out5;
-
+	sunrpc_debugfs_init();
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	rpc_register_sysctl();
 #endif
@@ -109,8 +106,6 @@ init_sunrpc(void)
 	init_socket_xprt();	/* clnt sock transport */
 	return 0;
 
-out5:
-	unregister_rpc_pipefs();
 out4:
 	unregister_pernet_subsys(&sunrpc_net_ops);
 out3:
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e3015aede0d9..9949722d99ce 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1331,7 +1331,6 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
  */
 struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 {
-	int err;
 	struct rpc_xprt	*xprt;
 	struct xprt_class *t;
 
@@ -1372,11 +1371,7 @@ found:
 		return ERR_PTR(-ENOMEM);
 	}
 
-	err = rpc_xprt_debugfs_register(xprt);
-	if (err) {
-		xprt_destroy(xprt);
-		return ERR_PTR(err);
-	}
+	rpc_xprt_debugfs_register(xprt);
 
 	dprintk("RPC:       created transport %p with %u slots\n", xprt,
 			xprt->max_reqs);
-- 
2.1.0

