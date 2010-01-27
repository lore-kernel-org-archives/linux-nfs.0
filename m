From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 3/4] nfs41: fix race between umount and renewd sequence operations
Date: Tue, 26 Jan 2010 18:43:54 -0800
Message-ID: <1264560235-2478-3-git-send-email-batsakis@netapp.com>
References: <1264560235-2478-1-git-send-email-batsakis@netapp.com>
 <1264560235-2478-2-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28703 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754809Ab0A0Cne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 21:43:34 -0500
In-Reply-To: <1264560235-2478-2-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9fc99e9..cd523df 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5041,6 +5041,8 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 
 	if (task->tk_status < 0) {
 		dprintk("%s ERROR %d\n", __func__, task->tk_status);
+		if (atomic_read(&clp->cl_count) == 1)
+			return;
 
 		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
 								== -EAGAIN) {
@@ -5050,7 +5052,8 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	}
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
-	nfs4_schedule_state_renewal(clp);
+	if (atomic_read(&clp->cl_count) > 1)
+		nfs4_schedule_state_renewal(clp);
 
 	kfree(task->tk_msg.rpc_argp);
 	kfree(task->tk_msg.rpc_resp);
@@ -5073,9 +5076,15 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 	rpc_call_start(task);
 }
 
+static void nfs41_sequence_release(void *calldata)
+{
+	nfs_put_client((struct nfs_client *) calldata);
+}
+
 static const struct rpc_call_ops nfs41_sequence_ops = {
 	.rpc_call_done = nfs41_sequence_call_done,
 	.rpc_call_prepare = nfs41_sequence_prepare,
+	.rpc_release = nfs41_sequence_release,
 };
 
 static int nfs41_proc_async_sequence(struct nfs_client *clp,
@@ -5088,11 +5097,16 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp,
 		.rpc_cred = cred,
 	};
 
+	if (!atomic_inc_not_zero(&clp->cl_count))
+		return -EIO;
 	args = kzalloc(sizeof(*args), GFP_KERNEL);
-	if (!args)
+	if (!args) {
+		nfs_put_client(clp);
 		return -ENOMEM;
+	}
 	res = kzalloc(sizeof(*res), GFP_KERNEL);
 	if (!res) {
+		nfs_put_client(clp);
 		kfree(args);
 		return -ENOMEM;
 	}
-- 
1.6.2.5

