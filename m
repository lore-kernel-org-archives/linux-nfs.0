Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f43.google.com ([209.85.213.43]:39852 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab3KMVxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 16:53:04 -0500
Received: by mail-yh0-f43.google.com with SMTP id v1so573272yhn.2
        for <linux-nfs@vger.kernel.org>; Wed, 13 Nov 2013 13:53:04 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, neilb@suse.de, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/3] sunrpc: replace sunrpc_net->gssd_running flag with a more reliable check
Date: Wed, 13 Nov 2013 16:52:54 -0500
Message-Id: <1384379575-8997-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384379575-8997-1-git-send-email-jlayton@redhat.com>
References: <1384379575-8997-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have a more reliable method to tell if gssd is running, we
can replace the sn->gssd_running flag with a function that will query to
see if it's up and running.

There's also no need to attempt an upcall that we know will fail, so
just return -EACCES if gssd isn't running in that case.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h | 14 ++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c     | 10 +++++-----
 net/sunrpc/netns.h                 |  2 --
 net/sunrpc/rpc_pipe.c              | 16 ++++++++++++----
 4 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 85f1342..438e606 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -131,5 +131,19 @@ extern int rpc_unlink(struct dentry *);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
+#if IS_ENABLED(CONFIG_SUNRPC_GSS)
+
+extern bool gssd_running(struct net *net);
+
+#else /* !CONFIG_SUNRPC_GSS */
+
+static inline bool
+gssd_running(struct net *net)
+{
+	return false;
+}
+
+#endif /* CONFIG_SUNRPC_GSS */
+
 #endif
 #endif
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 97912b4..e2fd448 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -608,17 +608,17 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 		__func__, from_kuid(&init_user_ns, cred->cr_uid));
 retry:
 	err = 0;
-	/* Default timeout is 15s unless we know that gssd is not running */
+	/* if gssd is down, just skip upcalling altogether */
+	if (!gssd_running(net)) {
+		warn_gssd();
+		return -EACCES;
+	}
 	timeout = 15 * HZ;
-	if (!sn->gssd_running)
-		timeout = HZ >> 2;
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
index 8a8e841..94e506f 100644
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
index 34efdbf..3cc6320 100644
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
@@ -1231,7 +1228,6 @@ int rpc_pipefs_init_net(struct net *net)
 		return PTR_ERR(sn->gssd_dummy);
 
 	mutex_init(&sn->pipefs_sb_lock);
-	sn->gssd_running = 1;
 	sn->pipe_version = -1;
 	return 0;
 }
@@ -1385,6 +1381,18 @@ err_depopulate:
 	return err;
 }
 
+#if IS_ENABLED(CONFIG_SUNRPC_GSS)
+bool
+gssd_running(struct net *net)
+{
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	struct rpc_pipe *pipe = sn->gssd_dummy;
+
+	return (pipe->nreaders || pipe->nwriters);
+}
+EXPORT_SYMBOL_GPL(gssd_running);
+#endif /* CONFIG_SUNRPC_GSS */
+
 static struct dentry *
 rpc_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *data)
-- 
1.8.3.1

