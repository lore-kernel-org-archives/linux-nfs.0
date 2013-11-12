Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f43.google.com ([209.85.128.43]:37701 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab3KLNAe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 08:00:34 -0500
Received: by mail-qe0-f43.google.com with SMTP id nc12so5448056qeb.2
        for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 05:00:33 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH 2/2] sunrpc: replace sunrpc_net->gssd_running flag with a better mechanism
Date: Tue, 12 Nov 2013 08:00:25 -0500
Message-Id: <1384261225-28559-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
References: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have a more reliable method to tell if gssd is running, we
can replace the sn->gssd_running flag with a function that will query to
see if it's up and running.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h |  4 ++++
 net/sunrpc/auth_gss/auth_gss.c     | 13 ++++++++++---
 net/sunrpc/netns.h                 |  2 --
 net/sunrpc/rpc_pipe.c              | 11 +++++++----
 4 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index a353e03..0ba459f 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -5,6 +5,8 @@
 
 #include <linux/workqueue.h>
 
+struct sunrpc_net;
+
 struct rpc_pipe_dir_head {
 	struct list_head pdh_entries;
 	struct dentry *pdh_dentry;
@@ -130,5 +132,7 @@ extern int rpc_unlink(struct dentry *);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
+extern bool rpc_pipe_is_open(struct rpc_pipe *pipe);
+
 #endif
 #endif
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 97912b4..d324563 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -592,6 +592,15 @@ out:
 	return err;
 }
 
+static bool
+gssd_running(struct sunrpc_net *sn)
+{
+	struct inode *inode = sn->gssd_dummy->d_inode;
+	struct rpc_pipe *pipe = RPC_I(inode)->pipe;
+
+	return rpc_pipe_is_open(pipe);
+}
+
 static inline int
 gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 {
@@ -610,15 +619,13 @@ retry:
 	err = 0;
 	/* Default timeout is 15s unless we know that gssd is not running */
 	timeout = 15 * HZ;
-	if (!sn->gssd_running)
+	if (!gssd_running(sn))
 		timeout = HZ >> 2;
 	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
 				sn->pipe_version >= 0, timeout);
 		if (sn->pipe_version < 0) {
-			if (err == 0)
-				sn->gssd_running = 0;
 			warn_gssd();
 			err = -EACCES;
 		}
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 6b82968..39ab6bc 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -33,8 +33,6 @@ struct sunrpc_net {
 	int pipe_version;
 	atomic_t pipe_users;
 	struct proc_dir_entry *use_gssp_proc;
-
-	unsigned int gssd_running;
 };
 
 extern int sunrpc_net_id;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 1c54de6..497261f 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -216,14 +216,11 @@ rpc_destroy_inode(struct inode *inode)
 static int
 rpc_pipe_open(struct inode *inode, struct file *filp)
 {
-	struct net *net = inode->i_sb->s_fs_info;
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct rpc_pipe *pipe;
 	int first_open;
 	int res = -ENXIO;
 
 	mutex_lock(&inode->i_mutex);
-	sn->gssd_running = 1;
 	pipe = RPC_I(inode)->pipe;
 	if (pipe == NULL)
 		goto out;
@@ -1227,7 +1224,6 @@ void rpc_pipefs_init_net(struct net *net)
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	mutex_init(&sn->pipefs_sb_lock);
-	sn->gssd_running = 1;
 	sn->pipe_version = -1;
 }
 
@@ -1382,6 +1378,13 @@ err_depopulate:
 	return err;
 }
 
+bool
+rpc_pipe_is_open(struct rpc_pipe *pipe)
+{
+	return (pipe->nreaders || pipe->nwriters);
+}
+EXPORT_SYMBOL_GPL(rpc_pipe_is_open);
+
 static struct dentry *
 rpc_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *data)
-- 
1.8.3.1

