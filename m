Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f50.google.com ([209.85.214.50]:42276 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbaA0SiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 13:38:00 -0500
Received: by mail-bk0-f50.google.com with SMTP id w16so3035732bkz.37
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 10:37:59 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: turn warn_gssd() log message into a dprintk()
Date: Mon, 27 Jan 2014 13:37:50 -0500
Message-Id: <1390847870-16490-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The original printk() made sense when the GSSAPI codepaths were called
only when sec=krb5* was explicitly requested. Now however, in many cases
the nfs client will try to acquire GSSAPI credentials by default, even
when it's not requested.

Since we don't have a great mechanism to distinguish between the two
cases, just turn the pr_warn into a dprintk instead. With this change
we can also get rid of the ratelimiting, and eliminate the export of
gssd_running(), since attempting to acquire them when gssd isn't running
will no longer cause a warning message to pop up.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4client.c            | 5 +----
 net/sunrpc/auth_gss/auth_gss.c | 8 +-------
 net/sunrpc/rpc_pipe.c          | 1 -
 3 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 73d4ecd..dbb3e1f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -372,10 +372,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
 
-	error = -EINVAL;
-	if (gssd_running(clp->cl_net))
-		error = nfs_create_rpc_client(clp, timeparms,
-					      RPC_AUTH_GSS_KRB5I);
+	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
 	if (error == -EINVAL)
 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0a2aee0..6c0513a 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -532,13 +532,7 @@ gss_setup_upcall(struct gss_auth *gss_auth, struct rpc_cred *cred)
 
 static void warn_gssd(void)
 {
-	static unsigned long ratelimit;
-	unsigned long now = jiffies;
-
-	if (time_after(now, ratelimit)) {
-		pr_warn("RPC: AUTH_GSS upcall failed. Please check user daemon is running.\n");
-		ratelimit = now + 15*HZ;
-	}
+	dprintk("AUTH_GSS upcall failed. Please check user daemon is running.\n");
 }
 
 static inline int
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b185548..3a0c778 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1442,7 +1442,6 @@ gssd_running(struct net *net)
 
 	return pipe->nreaders || pipe->nwriters;
 }
-EXPORT_SYMBOL_GPL(gssd_running);
 
 static struct dentry *
 rpc_mount(struct file_system_type *fs_type,
-- 
1.8.5.3

