Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f50.google.com ([209.85.128.50]:45369 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab3KLNAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 08:00:33 -0500
Received: by mail-qe0-f50.google.com with SMTP id 1so5575114qee.9
        for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 05:00:33 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH 1/2] sunrpc: create a new dummy pipe for gssd to hold open
Date: Tue, 12 Nov 2013 08:00:24 -0500
Message-Id: <1384261225-28559-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
References: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc.gssd will naturally hold open any pipe named */clnt*/gssd that shows
up under rpc_pipefs. That behavior gives us a reliable mechanism to tell
whether it's actually running or not.

Create a new toplevel "dummy" directory in rpc_pipefs when it's mounted.
Under that directory create another directory called "clntXX", and then
within that a pipe called "gssd".

We'll never send an upcall along that pipe, and any downcall written to
it will just return -EINVAL.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/netns.h    |  1 +
 net/sunrpc/rpc_pipe.c | 84 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+)

diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 779742c..6b82968 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -15,6 +15,7 @@ struct sunrpc_net {
 
 	struct super_block *pipefs_sb;
 	struct mutex pipefs_sb_lock;
+	struct dentry *gssd_dummy;
 
 	struct list_head all_clients;
 	spinlock_t rpc_client_lock;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index f94567b..1c54de6 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1168,6 +1168,7 @@ enum {
 	RPCAUTH_nfsd4_cb,
 	RPCAUTH_cache,
 	RPCAUTH_nfsd,
+	RPCAUTH_dummy,
 	RPCAUTH_RootEOF
 };
 
@@ -1204,6 +1205,10 @@ static const struct rpc_filelist files[] = {
 		.name = "nfsd",
 		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
 	},
+	[RPCAUTH_dummy] = {
+		.name = "dummy",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
 };
 
 /*
@@ -1253,6 +1258,80 @@ void rpc_put_sb_net(const struct net *net)
 }
 EXPORT_SYMBOL_GPL(rpc_put_sb_net);
 
+static const struct rpc_filelist dummy_clnt_dir[] = {
+	[0] = {
+		.name = "clntXX",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+};
+
+static ssize_t
+dummy_downcall(struct file *filp, const char __user *src, size_t len)
+{
+	return -EINVAL;
+}
+
+static const struct rpc_pipe_ops dummy_pipe_ops = {
+	.upcall		= rpc_pipe_generic_upcall,
+	.downcall	= dummy_downcall,
+};
+
+/**
+ * rpc_gssd_dummy_populate - create a dummy gssd pipe
+ * @root: root of the rpc_pipefs filesystem
+ *
+ * Create a dummy set of directories and a pipe that gssd can hold open to
+ * indicate that it is up and running.
+ */
+static struct dentry *
+rpc_gssd_dummy_populate(struct dentry *root)
+{
+	int ret = 0;
+	struct dentry *gssd_dentry;
+	struct dentry *clnt_dentry = NULL;
+	struct dentry *pipe_dentry = NULL;
+	struct rpc_pipe *pipe_data = NULL;
+	struct qstr q = QSTR_INIT(files[RPCAUTH_dummy].name,
+				  strlen(files[RPCAUTH_dummy].name));
+
+	/* We should never get this far if "gssd" doesn't exist */
+	gssd_dentry = d_hash_and_lookup(root, &q);
+	if (!gssd_dentry)
+		return ERR_PTR(-ENOENT);
+
+	ret = rpc_populate(gssd_dentry, dummy_clnt_dir, 0, 1, NULL);
+	if (ret) {
+		pipe_dentry = ERR_PTR(ret);
+		goto out;
+	}
+
+	pipe_data = rpc_mkpipe_data(&dummy_pipe_ops, 0);
+	if (IS_ERR(pipe_data)) {
+		pipe_dentry = ERR_CAST(pipe_data);
+		pipe_data = NULL;
+		goto out;
+	}
+
+	q.name = dummy_clnt_dir[0].name;
+	q.len = strlen(dummy_clnt_dir[0].name);
+	clnt_dentry = d_hash_and_lookup(gssd_dentry, &q);
+	if (!clnt_dentry) {
+		pipe_dentry = ERR_PTR(-ENOENT);
+		goto out;
+	}
+
+	pipe_dentry = rpc_mkpipe_dentry(clnt_dentry, "gssd", NULL, pipe_data);
+	if (IS_ERR(pipe_dentry))
+		goto out;
+
+	pipe_data = NULL;
+out:
+	rpc_destroy_pipe_data(pipe_data);
+	dput(clnt_dentry);
+	dput(gssd_dentry);
+	return pipe_dentry;
+}
+
 static int
 rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
@@ -1275,6 +1354,11 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		return -ENOMEM;
 	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
 		return -ENOMEM;
+
+	sn->gssd_dummy = rpc_gssd_dummy_populate(root);
+	if (IS_ERR(sn->gssd_dummy))
+		return PTR_ERR(sn->gssd_dummy);
+
 	dprintk("RPC:       sending pipefs MOUNT notification for net %p%s\n",
 		net, NET_NAME(net));
 	mutex_lock(&sn->pipefs_sb_lock);
-- 
1.8.3.1

