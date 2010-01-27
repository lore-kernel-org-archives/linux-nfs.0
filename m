From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 2/4] nfs4: prevent backlogging of renewd requests
Date: Tue, 26 Jan 2010 18:43:53 -0800
Message-ID: <1264560235-2478-2-git-send-email-batsakis@netapp.com>
References: <1264560235-2478-1-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28703 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754747Ab0A0Cne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 21:43:34 -0500
In-Reply-To: <1264560235-2478-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c   |    3 +++
 fs/nfs/nfs4renewd.c |   13 -------------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3644c35..9fc99e9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3162,6 +3162,7 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	if (time_before(clp->cl_last_renewal,timestamp))
 		clp->cl_last_renewal = timestamp;
 	spin_unlock(&clp->cl_lock);
+	nfs4_schedule_state_renewal(clp);
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
@@ -5049,6 +5050,8 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	}
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
+	nfs4_schedule_state_renewal(clp);
+
 	kfree(task->tk_msg.rpc_argp);
 	kfree(task->tk_msg.rpc_resp);
 
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 0156c01..f514902 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -36,11 +36,6 @@
  * as an rpc_task, not a real kernel thread, so it always runs in rpciod's
  * context.  There is one renewd per nfs_server.
  *
- * TODO: If the send queue gets backlogged (e.g., if the server goes down),
- * we will keep filling the queue with periodic RENEW requests.  We need a
- * mechanism for ensuring that if renewd successfully sends off a request,
- * then it only wakes up when the request is finished.  Maybe use the
- * child task framework of the RPC layer?
  */
 
 #include <linux/mm.h>
@@ -92,17 +87,9 @@ nfs4_renew_state(struct work_struct *work)
 			put_rpccred(cred);
 		}
 		timeout = (2 * lease) / 3;
-		spin_lock(&clp->cl_lock);
 	} else
 		dprintk("%s: failed to call renewd. Reason: lease not expired \n",
 				__func__);
-	if (timeout < 5 * HZ)    /* safeguard */
-		timeout = 5 * HZ;
-	dprintk("%s: requeueing work. Lease period = %ld\n",
-			__func__, (timeout + HZ - 1) / HZ);
-	cancel_delayed_work(&clp->cl_renewd);
-	schedule_delayed_work(&clp->cl_renewd, timeout);
-	spin_unlock(&clp->cl_lock);
 	nfs_expire_unreferenced_delegations(clp);
 out:
 	dprintk("%s: done\n", __func__);
-- 
1.6.2.5

