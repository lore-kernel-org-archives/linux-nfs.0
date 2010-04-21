From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/9] NFS: Calldata for nfs4_renew_done()
Date: Wed, 21 Apr 2010 13:43:52 -0400
Message-ID: <20100421174351.2037.67388.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:57134 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049Ab0DURte (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:49:34 -0400
Received: by pwj9 with SMTP id 9so5328595pwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:49:33 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm about to change task->tk_start from a jiffies value to a ktime_t
value in order to make RPC RTT reporting more precise.

Recently (commit dc96aef9) nfs4_renew_done() started to reference
task->tk_start so that a jiffies value no longer had to be passed
from nfs4_proc_async_renew().  This allowed the calldata to point to
an nfs_client instead.

Changing task->tk_start to a ktime_t value makes it effectively
useless for renew timestamps, so we need to restore the pre-dc96aef9
logic that provided a jiffies "start" timestamp to nfs4_renew_done().

Both an nfs_client pointer and a timestamp need to be passed to
nfs4_renew_done(), so create a new nfs_renewdata structure that
contains both, resembling what is already done for delegreturn,
lock, and unlock.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6380670..9a16431 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3146,23 +3146,31 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 }
 
+struct nfs4_renewdata {
+	struct nfs_client	*client;
+	unsigned long		timestamp;
+};
+
 /*
  * nfs4_proc_async_renew(): This is not one of the nfs_rpc_ops; it is a special
  * standalone procedure for queueing an asynchronous RENEW.
  */
-static void nfs4_renew_release(void *data)
+static void nfs4_renew_release(void *calldata)
 {
-	struct nfs_client *clp = data;
+	struct nfs4_renewdata *data = calldata;
+	struct nfs_client *clp = data->client;
 
 	if (atomic_read(&clp->cl_count) > 1)
 		nfs4_schedule_state_renewal(clp);
 	nfs_put_client(clp);
+	kfree(data);
 }
 
-static void nfs4_renew_done(struct rpc_task *task, void *data)
+static void nfs4_renew_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs_client *clp = data;
-	unsigned long timestamp = task->tk_start;
+	struct nfs4_renewdata *data = calldata;
+	struct nfs_client *clp = data->client;
+	unsigned long timestamp = data->timestamp;
 
 	if (task->tk_status < 0) {
 		/* Unless we're shutting down, schedule state recovery! */
@@ -3188,11 +3196,17 @@ int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 		.rpc_argp	= clp,
 		.rpc_cred	= cred,
 	};
+	struct nfs4_renewdata *data;
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
 		return -EIO;
+	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	if (data == NULL)
+		return -ENOMEM;
+	data->client = clp;
+	data->timestamp = jiffies;
 	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_SOFT,
-			&nfs4_renew_ops, clp);
+			&nfs4_renew_ops, (void *)data);
 }
 
 int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)

