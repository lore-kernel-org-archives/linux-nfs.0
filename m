From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 2/6] nfs: prevent backlogging of renewd requests
Date: Tue,  2 Feb 2010 16:06:12 -0800
Message-ID: <1265155576-7618-3-git-send-email-batsakis@netapp.com>
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com>
 <1265155576-7618-2-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64043 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933316Ab0BDUdL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 15:33:11 -0500
In-Reply-To: <1265155576-7618-2-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c   |    3 +++
 fs/nfs/nfs4renewd.c |   19 +++++++------------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 84b53d3..ce44b5a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3162,6 +3162,7 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	if (time_before(clp->cl_last_renewal,timestamp))
 		clp->cl_last_renewal = timestamp;
 	spin_unlock(&clp->cl_lock);
+	nfs4_schedule_state_renewal(clp);
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
@@ -5040,6 +5041,8 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	}
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
+	nfs4_schedule_state_renewal(clp);
+
 	kfree(task->tk_msg.rpc_argp);
 	kfree(task->tk_msg.rpc_resp);
 
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 0156c01..eec481b 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -63,7 +63,7 @@ nfs4_renew_state(struct work_struct *work)
 	struct nfs_client *clp =
 		container_of(work, struct nfs_client, cl_renewd.work);
 	struct rpc_cred *cred;
-	long lease, timeout;
+	long lease;
 	unsigned long last, now;
 
 	ops = nfs4_state_renewal_ops[clp->cl_minorversion];
@@ -75,7 +75,6 @@ nfs4_renew_state(struct work_struct *work)
 	lease = clp->cl_lease_time;
 	last = clp->cl_last_renewal;
 	now = jiffies;
-	timeout = (2 * lease) / 3 + (long)last - (long)now;
 	/* Are we close to a lease timeout? */
 	if (time_after(now, last + lease/3)) {
 		cred = ops->get_state_renewal_cred_locked(clp);
@@ -90,19 +89,15 @@ nfs4_renew_state(struct work_struct *work)
 			/* Queue an asynchronous RENEW. */
 			ops->sched_state_renewal(clp, cred);
 			put_rpccred(cred);
+			goto out_exp;
 		}
-		timeout = (2 * lease) / 3;
-		spin_lock(&clp->cl_lock);
-	} else
+	} else {
 		dprintk("%s: failed to call renewd. Reason: lease not expired \n",
 				__func__);
-	if (timeout < 5 * HZ)    /* safeguard */
-		timeout = 5 * HZ;
-	dprintk("%s: requeueing work. Lease period = %ld\n",
-			__func__, (timeout + HZ - 1) / HZ);
-	cancel_delayed_work(&clp->cl_renewd);
-	schedule_delayed_work(&clp->cl_renewd, timeout);
-	spin_unlock(&clp->cl_lock);
+		spin_unlock(&clp->cl_lock);
+	}
+	nfs4_schedule_state_renewal(clp);
+out_exp:
 	nfs_expire_unreferenced_delegations(clp);
 out:
 	dprintk("%s: done\n", __func__);
-- 
1.6.2.5

