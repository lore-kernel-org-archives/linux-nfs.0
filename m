Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067Ab0EMVIc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:32 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCY021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:31 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/15] SUNRPC: Don't spam gssd with upcall requests when the kerberos key expired
Date: Thu, 13 May 2010 17:08:21 -0400
Message-Id: <1273784901-25599-15-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-14-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-10-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-11-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-12-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-13-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-14-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Now that the rpc.gssd daemon can explicitly tell us that the key expired,
we should cache that information to avoid spamming gssd.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/auth.h     |    1 +
 include/linux/sunrpc/auth_gss.h |    1 +
 net/sunrpc/auth_gss/auth_gss.c  |   65 +++++++++++++++++++++++++++++++-------
 3 files changed, 55 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 996df4d..87d7ec0 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -54,6 +54,7 @@ struct rpc_cred {
 #define RPCAUTH_CRED_NEW	0
 #define RPCAUTH_CRED_UPTODATE	1
 #define RPCAUTH_CRED_HASHED	2
+#define RPCAUTH_CRED_NEGATIVE	3
 
 #define RPCAUTH_CRED_MAGIC	0x0f4aa4f0
 
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index d48d4e6..671538d 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -82,6 +82,7 @@ struct gss_cred {
 	enum rpc_gss_svc	gc_service;
 	struct gss_cl_ctx	*gc_ctx;
 	struct gss_upcall_msg	*gc_upcall;
+	unsigned long		gc_upcall_timestamp;
 	unsigned char		gc_machine_cred : 1;
 };
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 48a7939..8da2a0e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -57,6 +57,9 @@ static const struct rpc_authops authgss_ops;
 static const struct rpc_credops gss_credops;
 static const struct rpc_credops gss_nullops;
 
+#define GSS_RETRY_EXPIRED 5
+static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
+
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
@@ -350,6 +353,24 @@ gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static void
+gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss_msg)
+{
+	switch (gss_msg->msg.errno) {
+	case 0:
+		if (gss_msg->ctx == NULL)
+			break;
+		clear_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
+		gss_cred_set_ctx(&gss_cred->gc_base, gss_msg->ctx);
+		break;
+	case -EKEYEXPIRED:
+		set_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
+	}
+	gss_cred->gc_upcall_timestamp = jiffies;
+	gss_cred->gc_upcall = NULL;
+	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
+}
+
+static void
 gss_upcall_callback(struct rpc_task *task)
 {
 	struct gss_cred *gss_cred = container_of(task->tk_msg.rpc_cred,
@@ -358,13 +379,9 @@ gss_upcall_callback(struct rpc_task *task)
 	struct inode *inode = &gss_msg->inode->vfs_inode;
 
 	spin_lock(&inode->i_lock);
-	if (gss_msg->ctx)
-		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_msg->ctx);
-	else
-		task->tk_status = gss_msg->msg.errno;
-	gss_cred->gc_upcall = NULL;
-	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
+	gss_handle_downcall_result(gss_cred, gss_msg);
 	spin_unlock(&inode->i_lock);
+	task->tk_status = gss_msg->msg.errno;
 	gss_release_msg(gss_msg);
 }
 
@@ -513,18 +530,16 @@ gss_refresh_upcall(struct rpc_task *task)
 	spin_lock(&inode->i_lock);
 	if (gss_cred->gc_upcall != NULL)
 		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL);
-	else if (gss_msg->ctx != NULL) {
-		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_msg->ctx);
-		gss_cred->gc_upcall = NULL;
-		rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
-	} else if (gss_msg->msg.errno >= 0) {
+	else if (gss_msg->ctx == NULL && gss_msg->msg.errno >= 0) {
 		task->tk_timeout = 0;
 		gss_cred->gc_upcall = gss_msg;
 		/* gss_upcall_callback will release the reference to gss_upcall_msg */
 		atomic_inc(&gss_msg->count);
 		rpc_sleep_on(&gss_msg->rpc_waitqueue, task, gss_upcall_callback);
-	} else
+	} else {
+		gss_handle_downcall_result(gss_cred, gss_msg);
 		err = gss_msg->msg.errno;
+	}
 	spin_unlock(&inode->i_lock);
 	gss_release_msg(gss_msg);
 out:
@@ -1123,6 +1138,23 @@ static int gss_renew_cred(struct rpc_task *task)
 	return 0;
 }
 
+static int gss_cred_is_negative_entry(struct rpc_cred *cred)
+{
+	if (test_bit(RPCAUTH_CRED_NEGATIVE, &cred->cr_flags)) {
+		unsigned long now = jiffies;
+		unsigned long begin, expire;
+		struct gss_cred *gss_cred; 
+
+		gss_cred = container_of(cred, struct gss_cred, gc_base);
+		begin = gss_cred->gc_upcall_timestamp;
+		expire = begin + gss_expired_cred_retry_delay * HZ;
+
+		if (time_in_range_open(now, begin, expire))
+			return 1;
+	}
+	return 0;
+}
+
 /*
 * Refresh credentials. XXX - finish
 */
@@ -1132,6 +1164,9 @@ gss_refresh(struct rpc_task *task)
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
 	int ret = 0;
 
+	if (gss_cred_is_negative_entry(cred))
+		return -EKEYEXPIRED;
+
 	if (!test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags) &&
 			!test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags)) {
 		ret = gss_renew_cred(task);
@@ -1585,5 +1620,11 @@ static void __exit exit_rpcsec_gss(void)
 }
 
 MODULE_LICENSE("GPL");
+module_param_named(expired_cred_retry_delay,
+		   gss_expired_cred_retry_delay,
+		   uint, 0644);
+MODULE_PARM_DESC(expired_cred_retry_delay, "Timeout (in seconds) until "
+		"the RPC engine retries an expired credential");
+
 module_init(init_rpcsec_gss)
 module_exit(exit_rpcsec_gss)
-- 
1.6.6.1

