Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f44.google.com ([209.85.214.44]:59177 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbaA0Txi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 14:53:38 -0500
Received: by mail-bk0-f44.google.com with SMTP id mz12so3090443bkb.17
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 11:53:36 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2] sunrpc: turn warn_gssd() log message into a dprintk()
Date: Mon, 27 Jan 2014 14:53:27 -0500
Message-Id: <1390852407-20641-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The original printk() made sense when the GSSAPI codepaths were called
only when sec=krb5* was explicitly requested. Now however, in many cases
the nfs client will try to acquire GSSAPI credentials by default, even
when it's not requested.

Since we don't have a great mechanism to distinguish between the two
cases, just turn the pr_warn into a dprintk instead. With this change we
can also get rid of the ratelimiting.

We do need to keep the EXPORT_SYMBOL(gssd_running) in place since
auth_gss.ko needs it and sunrpc.ko provides it. We can however,
eliminate the gssd_running call in the nfs code since that's a bit of a
layering violation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4client.c            | 5 +----
 net/sunrpc/auth_gss/auth_gss.c | 8 +-------
 2 files changed, 2 insertions(+), 11 deletions(-)

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
-- 
1.8.5.3

