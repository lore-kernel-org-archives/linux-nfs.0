Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:54241 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410Ab3KNMZ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 07:25:29 -0500
Received: by mail-qa0-f51.google.com with SMTP id i13so97374qae.10
        for <linux-nfs@vger.kernel.org>; Thu, 14 Nov 2013 04:25:29 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, neilb@suse.de, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/3] sunrpc: replace sunrpc_net->gssd_running flag with a more reliable check
Date: Thu, 14 Nov 2013 07:25:18 -0500
Message-Id: <1384431919-20921-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384431919-20921-1-git-send-email-jlayton@redhat.com>
References: <1384431919-20921-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have a more reliable method to tell if gssd is running, we
can replace the sn->gssd_running flag with a function that will query to
see if it's up and running.

There's also no need to attempt an upcall that we know will fail, so
just return -EACCES if gssd isn't running. Finally, fix the warn_gss()
message not to claim that that the upcall timed out since we don't
necesarily perform one now when gssd isn't running, and remove the
extraneous newline from the message.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h |  2 ++
 net/sunrpc/auth_gss/auth_gss.c     | 17 +++++++----------
 net/sunrpc/netns.h                 |  2 --
 net/sunrpc/rpc_pipe.c              | 14 ++++++++++----
 4 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 85f1342..7f490be 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -131,5 +131,7 @@ extern int rpc_unlink(struct dentry *);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
+extern bool gssd_running(struct net *net);
+
 #endif
 #endif
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 97912b4..0316b8d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -536,8 +536,7 @@ static void warn_gssd(void)
 	unsigned long now = jiffies;
 
 	if (time_after(now, ratelimit)) {
-		printk(KERN_WARNING "RPC: AUTH_GSS upcall timed out.\n"
-				"Please check user daemon is running.\n");
+		pr_warn("RPC: AUTH_GSS upcall failed. Please check user daemon is running.\n");
 		ratelimit = now + 15*HZ;
 	}
 }
@@ -600,7 +599,6 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	struct rpc_pipe *pipe;
 	struct rpc_cred *cred = &gss_cred->gc_base;
 	struct gss_upcall_msg *gss_msg;
-	unsigned long timeout;
 	DEFINE_WAIT(wait);
 	int err;
 
@@ -608,17 +606,16 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 		__func__, from_kuid(&init_user_ns, cred->cr_uid));
 retry:
 	err = 0;
-	/* Default timeout is 15s unless we know that gssd is not running */
-	timeout = 15 * HZ;
-	if (!sn->gssd_running)
-		timeout = HZ >> 2;
+	/* if gssd is down, just skip upcalling altogether */
+	if (!gssd_running(net)) {
+		warn_gssd();
+		return -EACCES;
+	}
 	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
-				sn->pipe_version >= 0, timeout);
+				sn->pipe_version >= 0, 15 * HZ);
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
index 34efdbf..9ce0082 100644
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
@@ -1385,6 +1381,16 @@ err_depopulate:
 	return err;
 }
 
+bool
+gssd_running(struct net *net)
+{
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	struct rpc_pipe *pipe = sn->gssd_dummy;
+
+	return pipe->nreaders || pipe->nwriters;
+}
+EXPORT_SYMBOL_GPL(gssd_running);
+
 static struct dentry *
 rpc_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *data)
-- 
1.8.3.1

