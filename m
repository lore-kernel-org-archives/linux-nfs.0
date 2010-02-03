From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 4/6] nfs4: fix race between umount and renewd renew operations
Date: Tue,  2 Feb 2010 16:06:14 -0800
Message-ID: <1265155576-7618-5-git-send-email-batsakis@netapp.com>
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com>
 <1265155576-7618-2-git-send-email-batsakis@netapp.com>
 <1265155576-7618-3-git-send-email-batsakis@netapp.com>
 <1265155576-7618-4-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64043 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932905Ab0BDUdM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 15:33:12 -0500
In-Reply-To: <1265155576-7618-4-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 87fd43a..ffc84d4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3163,11 +3163,18 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	if (time_before(clp->cl_last_renewal,timestamp))
 		clp->cl_last_renewal = timestamp;
 	spin_unlock(&clp->cl_lock);
-	nfs4_schedule_state_renewal(clp);
+	if (atomic_read(&clp->cl_count) > 1)
+		nfs4_schedule_state_renewal(clp);
+}
+
+static void nfs4_renew_release(void *calldata)
+{
+	nfs_put_client((struct nfs_client *) calldata);
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
 	.rpc_call_done = nfs4_renew_done,
+	.rpc_release = nfs4_renew_release,
 };
 
 int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
@@ -3178,6 +3185,8 @@ int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 		.rpc_cred	= cred,
 	};
 
+	if (!atomic_inc_not_zero(&clp->cl_count))
+		return -EIO;
 	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_SOFT,
 			&nfs4_renew_ops, (void *)jiffies);
 }
-- 
1.6.2.5

