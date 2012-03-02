Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51937 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030601Ab2CBUml (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 15:42:41 -0500
Received: by mail-yw0-f46.google.com with SMTP id m54so1008975yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 12:42:41 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, skinsbursky@parallels.com
Subject: [PATCH v8 6/6] nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
Date: Fri,  2 Mar 2012 15:42:30 -0500
Message-Id: <1330720950-5872-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1330720950-5872-1-git-send-email-jlayton@redhat.com>
References: <1330720950-5872-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the event that rpc_pipefs isn't mounted when nfsd starts, we
must register a notifier to handle creating the dentry once it
is mounted, and to remove the dentry on unmount.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index d928c58..31af1d0 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -38,6 +38,7 @@
 #include <linux/crypto.h>
 #include <linux/sched.h>
 #include <linux/fs.h>
+#include <linux/module.h>
 #include <net/net_namespace.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/clnt.h>
@@ -658,6 +659,48 @@ nfsd4_cld_unregister_net(struct net *net, struct rpc_pipe *pipe)
 	}
 }
 
+static int
+rpc_pipefs_event(struct notifier_block *nb, unsigned long event, void *ptr)
+{
+	struct super_block *sb = ptr;
+	struct net *net = sb->s_fs_info;
+	struct dentry *dentry;
+	int ret = 0;
+
+	if (!try_module_get(THIS_MODULE))
+		return 0;
+
+	/* FIXME: containerize this code */
+	if (!cld_pipe || net != &init_net) {
+		module_put(THIS_MODULE);
+		return 0;
+	}
+
+	switch (event) {
+	case RPC_PIPEFS_MOUNT:
+		dentry = nfsd4_cld_register_sb(sb, cld_pipe);
+		if (IS_ERR(dentry)) {
+			ret = PTR_ERR(dentry);
+			break;
+		}
+		cld_pipe->dentry = dentry;
+		break;
+	case RPC_PIPEFS_UMOUNT:
+		if (cld_pipe->dentry)
+			nfsd4_cld_unregister_sb(cld_pipe);
+		break;
+	default:
+		ret = -ENOTSUPP;
+		break;
+	}
+	module_put(THIS_MODULE);
+	return ret;
+}
+
+static struct notifier_block nfsd4_cld_block = {
+	.notifier_call = rpc_pipefs_event,
+};
+
 /* Initialize rpc_pipefs pipe for communication with client tracking daemon */
 static int
 nfsd4_init_cld_pipe(void)
@@ -669,10 +712,14 @@ nfsd4_init_cld_pipe(void)
 	if (cld_pipe)
 		return 0;
 
+	ret = rpc_pipefs_notifier_register(&nfsd4_cld_block);
+	if (ret)
+		goto err;
+
 	cld_pipe = rpc_mkpipe_data(&cld_upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
 	if (IS_ERR(cld_pipe)) {
 		ret = PTR_ERR(cld_pipe);
-		goto err;
+		goto err_notifier;
 	}
 
 	dentry = nfsd4_cld_register_net(&init_net, cld_pipe);
@@ -686,6 +733,8 @@ nfsd4_init_cld_pipe(void)
 
 err_destroy_data:
 	rpc_destroy_pipe_data(cld_pipe);
+err_notifier:
+	rpc_pipefs_notifier_unregister(&nfsd4_cld_block);
 err:
 	cld_pipe = NULL;
 	printk(KERN_ERR "NFSD: unable to create nfsdcld upcall pipe (%d)\n",
@@ -696,6 +745,7 @@ err:
 static void
 nfsd4_remove_cld_pipe(void)
 {
+	rpc_pipefs_notifier_unregister(&nfsd4_cld_block);
 	/* FIXME: containerize... */
 	nfsd4_cld_unregister_net(&init_net, cld_pipe);
 	rpc_destroy_pipe_data(cld_pipe);
-- 
1.7.7.6

