From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 4/5] nfs4: renewd renew operations should take/put a client reference
Date: Fri,  5 Feb 2010 03:32:33 -0800
Message-ID: <1265369554-2105-5-git-send-email-batsakis@netapp.com>
References: <1265369554-2105-1-git-send-email-batsakis@netapp.com>
 <1265369554-2105-2-git-send-email-batsakis@netapp.com>
 <1265369554-2105-3-git-send-email-batsakis@netapp.com>
 <1265369554-2105-4-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, root <vadmin.root@vadmin (none) >,
	Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58310 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757069Ab0BKUl1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 15:41:27 -0500
In-Reply-To: <1265369554-2105-4-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: root <root@vadmin.(none)>

renewd sends RENEW requests to the NFS server in order to renew state.
As the request is asynchronous, renewd should take a reference to the
nfs_client to prevent concurrent umounts from freeing the client

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

