Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60656 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865Ab3EOTvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 15:51:13 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] SUNRPC: Faster detection if gssd is actually running
Date: Wed, 15 May 2013 12:50:40 -0700
Message-Id: <1368647441-24815-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1368647441-24815-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
 <1368647441-24815-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent changes to the NFS security flavour negotiation mean that
we have a stronger dependency on rpc.gssd. If the latter is not
running, because the user failed to start it, then we time out
and mark the container as not having an instance. We then
use that information to time out faster the next time.

If, on the other hand, the rpc.gssd successfully binds to an rpc_pipe,
then we mark the container as having an rpc.gssd instance.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 13 ++++++++++++-
 net/sunrpc/netns.h             |  2 ++
 net/sunrpc/rpc_pipe.c          |  4 ++++
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index f17f3c5..3aff72f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -52,6 +52,8 @@
 #include <linux/sunrpc/gss_api.h>
 #include <asm/uaccess.h>
 
+#include "../netns.h"
+
 static const struct rpc_authops authgss_ops;
 
 static const struct rpc_credops gss_credops;
@@ -559,9 +561,12 @@ out:
 static inline int
 gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 {
+	struct net *net = rpc_net_ns(gss_auth->client);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct rpc_pipe *pipe;
 	struct rpc_cred *cred = &gss_cred->gc_base;
 	struct gss_upcall_msg *gss_msg;
+	unsigned long timeout;
 	DEFINE_WAIT(wait);
 	int err;
 
@@ -569,11 +574,17 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 		__func__, from_kuid(&init_user_ns, cred->cr_uid));
 retry:
 	err = 0;
+	/* Default timeout is 15s unless we know that gssd is not running */
+	timeout = 15 * HZ;
+	if (!sn->gssd_running)
+		timeout = HZ >> 2;
 	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
-				pipe_version >= 0, 15*HZ);
+				pipe_version >= 0, timeout);
 		if (pipe_version < 0) {
+			if (err == 0)
+				sn->gssd_running = 0;
 			warn_gssd();
 			err = -EACCES;
 		}
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 7111a4c..0827f64 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -29,6 +29,8 @@ struct sunrpc_net {
 	struct rpc_clnt *gssp_clnt;
 	int use_gss_proxy;
 	struct proc_dir_entry *use_gssp_proc;
+
+	unsigned int gssd_running;
 };
 
 extern int sunrpc_net_id;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index a9129f8..415b705 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -216,11 +216,14 @@ rpc_destroy_inode(struct inode *inode)
 static int
 rpc_pipe_open(struct inode *inode, struct file *filp)
 {
+	struct net *net = inode->i_sb->s_fs_info;
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct rpc_pipe *pipe;
 	int first_open;
 	int res = -ENXIO;
 
 	mutex_lock(&inode->i_mutex);
+	sn->gssd_running = 1;
 	pipe = RPC_I(inode)->pipe;
 	if (pipe == NULL)
 		goto out;
@@ -1069,6 +1072,7 @@ void rpc_pipefs_init_net(struct net *net)
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	mutex_init(&sn->pipefs_sb_lock);
+	sn->gssd_running = -1;
 }
 
 /*
-- 
1.8.1.4

