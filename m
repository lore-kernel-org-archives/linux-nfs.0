Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29133 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994Ab1LJAKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Dec 2011 19:10:08 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Do not accept delegated opens when a delegation recall is in effect
Date: Fri,  9 Dec 2011 19:09:58 -0500
Message-Id: <1323475798-28642-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and report the servers that try to return a delegation when the client
is using the CLAIM_DELEG_CUR open mode. That behaviour is explicitly
forbidden in RFC3530.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index be2bbac..d9f4d78 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -39,6 +39,8 @@
 #include <linux/delay.h>
 #include <linux/errno.h>
 #include <linux/string.h>
+#include <linux/ratelimit.h>
+#include <linux/printk.h>
 #include <linux/slab.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/gss_api.h>
@@ -894,6 +896,8 @@ out:
 
 static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
 {
+	if (delegation == NULL)
+		return 0;
 	if ((delegation->type & fmode) != fmode)
 		return 0;
 	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
@@ -1036,8 +1040,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		}
 		rcu_read_lock();
 		delegation = rcu_dereference(nfsi->delegation);
-		if (delegation == NULL ||
-		    !can_open_delegated(delegation, fmode)) {
+		if (!can_open_delegated(delegation, fmode)) {
 			rcu_read_unlock();
 			break;
 		}
@@ -1091,7 +1094,12 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 		if (delegation)
 			delegation_flags = delegation->flags;
 		rcu_read_unlock();
-		if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
+		if (data->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR) {
+			pr_err_ratelimited("NFS: Broken NFSv4 server %s is "
+					"returning a delegation for "
+					"OPEN(CLAIM_DELEGATE_CUR)\n",
+					NFS_CLIENT(inode)->cl_server);
+		} else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
 			nfs_inode_set_delegation(state->inode,
 					data->owner->so_cred,
 					&data->o_res);
@@ -1423,11 +1431,9 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 			goto out_no_action;
 		rcu_read_lock();
 		delegation = rcu_dereference(NFS_I(data->state->inode)->delegation);
-		if (delegation != NULL &&
-		    test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags) == 0) {
-			rcu_read_unlock();
-			goto out_no_action;
-		}
+		if (data->o_arg.claim != NFS4_OPEN_CLAIM_DELEGATE_CUR &&
+		    can_open_delegated(delegation, data->o_arg.fmode))
+			goto unlock_no_action;
 		rcu_read_unlock();
 	}
 	/* Update sequence id. */
@@ -1444,6 +1450,8 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		return;
 	rpc_call_start(task);
 	return;
+unlock_no_action:
+	rcu_read_unlock();
 out_no_action:
 	task->tk_action = NULL;
 
-- 
1.7.7.3

