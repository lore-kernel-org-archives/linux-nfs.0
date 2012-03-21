Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:34461 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964786Ab2CUNwX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 09:52:23 -0400
Received: by gghe5 with SMTP id e5so917199ggh.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Mar 2012 06:52:23 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v10 7/8] nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
Date: Wed, 21 Mar 2012 09:52:08 -0400
Message-Id: <1332337929-18580-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the event that rpc_pipefs isn't mounted when nfsd starts, we
must register a notifier to handle creating the dentry once it
is mounted, and to remove the dentry on unmount.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/netns.h       |    1 +
 fs/nfsd/nfs4recover.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c      |    9 ++++++++-
 3 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 12e0cff..66eac33 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -31,4 +31,5 @@ struct nfsd_net {
 };
 
 extern int nfsd_net_id;
+extern struct notifier_block nfsd4_cld_block;
 #endif /* __NFSD_NETNS_H__ */
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index cec62ed..6f13281 100644
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
@@ -982,3 +983,46 @@ nfsd4_record_grace_done(struct net *net, time_t boot_time)
 	if (client_tracking_ops)
 		client_tracking_ops->grace_done(net, boot_time);
 }
+
+static int
+rpc_pipefs_event(struct notifier_block *nb, unsigned long event, void *ptr)
+{
+	struct super_block *sb = ptr;
+	struct net *net = sb->s_fs_info;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct cld_net *cn = nn->cld_net;
+	struct dentry *dentry;
+	int ret = 0;
+
+	if (!try_module_get(THIS_MODULE))
+		return 0;
+
+	if (!cn) {
+		module_put(THIS_MODULE);
+		return 0;
+	}
+
+	switch (event) {
+	case RPC_PIPEFS_MOUNT:
+		dentry = nfsd4_cld_register_sb(sb, cn->cn_pipe);
+		if (IS_ERR(dentry)) {
+			ret = PTR_ERR(dentry);
+			break;
+		}
+		cn->cn_pipe->dentry = dentry;
+		break;
+	case RPC_PIPEFS_UMOUNT:
+		if (cn->cn_pipe->dentry)
+			nfsd4_cld_unregister_sb(cn->cn_pipe);
+		break;
+	default:
+		ret = -ENOTSUPP;
+		break;
+	}
+	module_put(THIS_MODULE);
+	return ret;
+}
+
+struct notifier_block nfsd4_cld_block = {
+	.notifier_call = rpc_pipefs_event,
+};
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 141197e..dee6c1b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -13,6 +13,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/sunrpc/gss_krb5_enctypes.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/module.h>
 
 #include "idmap.h"
@@ -1136,9 +1137,12 @@ static int __init init_nfsd(void)
 	int retval;
 	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
 
+	retval = rpc_pipefs_notifier_register(&nfsd4_cld_block);
+	if (retval)
+		return retval;
 	retval = register_pernet_subsys(&nfsd_net_ops);
 	if (retval < 0)
-		return retval;
+		goto out_unregister_notifier;
 	retval = nfsd4_init_slabs();
 	if (retval)
 		goto out_unregister_pernet;
@@ -1181,6 +1185,8 @@ out_free_slabs:
 	nfsd4_free_slabs();
 out_unregister_pernet:
 	unregister_pernet_subsys(&nfsd_net_ops);
+out_unregister_notifier:
+	rpc_pipefs_notifier_unregister(&nfsd4_cld_block);
 	return retval;
 }
 
@@ -1197,6 +1203,7 @@ static void __exit exit_nfsd(void)
 	nfsd_fault_inject_cleanup();
 	unregister_filesystem(&nfsd_fs_type);
 	unregister_pernet_subsys(&nfsd_net_ops);
+	rpc_pipefs_notifier_unregister(&nfsd4_cld_block);
 }
 
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
-- 
1.7.7.6

