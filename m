Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30820 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab3JVOVZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:21:25 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 4/5] SUNRPC: allow only existing buffered writes on creds with destroyed keys
Date: Tue, 22 Oct 2013 10:21:15 -0400
Message-ID: <1382451676-2963-5-git-send-email-andros@netapp.com>
In-Reply-To: <1382451676-2963-1-git-send-email-andros@netapp.com>
References: <1382451676-2963-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set the new RPC_TASK_BUF_WRITE task flag in the NFS layer in initiate_write,
the buffered write path. Pass the flag to the crmatch routine via the
rpcauth_bindcred lookup_flags.

This flag is only used when RPCAUTH_CRED_KEY_DESTROYED
is set on the gss_cred, and allows for buffered writes to use a "destroyed"
gss_context.

If the RPCAUTH_CRED_KEY_DESTROYED rpc_cred bit is set, set the
RPC_CRED_KEY_EXPIRE_SOON acred bit which tells the NFS layer to discontinue
any new buffered writes, turning to sync writes instead. The sync writes
will fail as gss_match will find but not return the DESTROYED gss_cred.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/write.c                 |  2 +-
 include/linux/sunrpc/sched.h   |  1 +
 net/sunrpc/auth.c              |  2 ++
 net/sunrpc/auth_gss/auth_gss.c | 10 ++++++++--
 4 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ac1dc33..40c3e8e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1006,7 +1006,7 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC | flags,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_BUF_WRITE | flags,
 		.priority = priority,
 	};
 	int ret = 0;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 3a847de..8ea50a7 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -123,6 +123,7 @@ struct rpc_task_setup {
 #define RPC_TASK_TIMEOUT	0x1000		/* fail with ETIMEDOUT on timeout */
 #define RPC_TASK_NOCONNECT	0x2000		/* return ENOTCONN if not connected */
 #define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		/* wait forever for a reply */
+#define RPC_TASK_BUF_WRITE	0x8000		/* allow buffered writes with destroyed credential key */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5285ead..646d38f 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -650,6 +650,8 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 	struct rpc_cred *new;
 	int lookupflags = 0;
 
+	if (flags & RPC_TASK_BUF_WRITE)
+		lookupflags |= RPC_TASK_BUF_WRITE;
 	if (flags & RPC_TASK_ASYNC)
 		lookupflags |= RPCAUTH_LOOKUP_NEW;
 	if (cred != NULL)
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index b7365b9..31c72c5 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1511,8 +1511,14 @@ check_expire:
 	if (ret == 0)
 		return ret;
 
-	if (test_bit(RPCAUTH_CRED_KEY_DESTROYED, &rc->cr_flags))
-		return 0;
+	/* Has kdestroy -> gss-ctx key destroy occurred? */
+	if (test_bit(RPCAUTH_CRED_KEY_DESTROYED, &rc->cr_flags)) {
+		/* tell NFS layer no more buffered writes */
+		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
+                /* if this is not a buffered write, return not found */
+		if (!(flags & RPC_TASK_BUF_WRITE))
+			return 0;
+	}
 
 	/* Notify acred users of GSS context expiration timeout */
 	if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags) &&
-- 
1.8.3.1

