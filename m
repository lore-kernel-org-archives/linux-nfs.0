From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: pnfsd: move kfree of the cb_device rpc_args to release time
Date: Fri, 18 Jun 2010 17:03:38 -0400
Message-ID: <1276895018-29885-1-git-send-email-bhalevy@panasas.com>
References: <4C1BDE45.6020806@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38407 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751899Ab0FRVD3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 17:03:29 -0400
In-Reply-To: <4C1BDE45.6020806@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also, fix a bug in nfsd_device_notify_cb where the nfs4_notify_device
structure was kfreed while the async callback was in progress.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   10 +++++++++-
 fs/nfsd/nfs4pnfsd.c    |    5 +++--
 fs/nfsd/pnfsd.h        |    2 ++
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index cdf9d6d..950e303 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1113,7 +1113,6 @@ static void nfsd4_cb_device_done(struct rpc_task *task, void *calldata)
 	struct nfs4_client *clp = cbnd->nd_client;
 
 	nfsd4_cb_done_sequence(task, clp);
-	kfree(task->tk_msg.rpc_argp);
 
 	dprintk("%s: clp %p cb_client %p: status %d\n",
 	       __func__,
@@ -1128,9 +1127,18 @@ static void nfsd4_cb_device_done(struct rpc_task *task, void *calldata)
 	}
 }
 
+static void nfsd4_cb_device_release(void *calldata)
+{
+	struct nfs4_notify_device *cbnd = calldata;
+	kfree(cbnd->nd_args);
+	cbnd->nd_args = NULL;
+	kfree(cbnd);
+}
+
 static const struct rpc_call_ops nfsd4_cb_device_ops = {
 	.rpc_call_prepare = nfsd4_cb_device_prepare,
 	.rpc_call_done = nfsd4_cb_device_done,
+	.rpc_release = nfsd4_cb_device_release,
 };
 
 /*
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2576848..5043878 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1666,10 +1666,11 @@ int nfsd_device_notify_cb(struct super_block *sb,
 		list_del_init(&cbnd->nd_perclnt);
 		status2 = nfsd4_cb_notify_device(cbnd);
 		pnfs_clear_device_notify(cbnd->nd_client);
-		if (status2)
+		if (status2) {
+			kfree(cbnd);
 			status = status2;
+		}
 		notify_num++;
-		kfree(cbnd);
 	}
 
 	dprintk("NFSD %s: status %d clients %u\n",
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index dd5838f..a181bc3 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -109,6 +109,8 @@ struct nfs4_notify_device {
 	struct nfsd4_pnfs_cb_dev_list  *nd_list;
 	struct nfs4_client	       *nd_client;
 	struct list_head	        nd_perclnt;
+
+	void				*nd_args;	/* nfsd internal */
 };
 
 u64 find_create_sbid(struct super_block *);
-- 
1.6.4.4

