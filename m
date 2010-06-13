From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/4] pnfs-submit: filelayout: Stop using pnfs_call_done and friends
Date: Sun, 13 Jun 2010 16:18:39 -0400
Message-ID: <1276460322-13873-2-git-send-email-iisaman@netapp.com>
References: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24319 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656Ab0FMUSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jun 2010 16:18:51 -0400
Received: from localhost.localdomain (kellyv2-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5DKIkfc012997
	for <linux-nfs@vger.kernel.org>; Sun, 13 Jun 2010 13:18:47 -0700 (PDT)
In-Reply-To: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current handling is quite flawed.  The rpc_call_done function
can restart the rpc, so doing anything after the call doesn't work.

In particular:
The current code often ends trying to resend the rpc twice.
The lseg_put should be in the release call, not the done call.
There is no way to distinguish whether a retry should be through the DS or MDS
If rpc_run_task returns an error, rpc_call_done won't even be called.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   30 +++++++++++++++++++++++++++---
 fs/nfs/pnfs.c           |    1 +
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e6d45b8..472b613 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -54,6 +54,7 @@
 #include "nfs4filelayout.h"
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -151,7 +152,17 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 		rdata->args.offset = rdata->fldata.orig_offset;
 	}
 
-	pnfs_callback_ops->nfs_readlist_complete(rdata);
+	/* Note this may cause RPC to be resent */
+	rdata->pdata.call_ops->rpc_call_done(task, data);
+}
+
+static void filelayout_read_release(void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	put_lseg(rdata->pdata.lseg);
+	rdata->pdata.lseg = NULL;
+	rdata->pdata.call_ops->rpc_release(data);
 }
 
 static void filelayout_write_call_done(struct rpc_task *task, void *data)
@@ -164,17 +175,29 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 		wdata->args.offset = wdata->fldata.orig_offset;
 	}
 
-	pnfs_callback_ops->nfs_writelist_complete(wdata);
+	/* Note this may cause RPC to be resent */
+	wdata->pdata.call_ops->rpc_call_done(task, data);
+}
+
+static void filelayout_write_release(void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	put_lseg(wdata->pdata.lseg);
+	wdata->pdata.lseg = NULL;
+	wdata->pdata.call_ops->rpc_release(data);
 }
 
 struct rpc_call_ops filelayout_read_call_ops = {
 	.rpc_call_prepare = nfs_read_prepare,
 	.rpc_call_done = filelayout_read_call_done,
+	.rpc_release = filelayout_read_release,
 };
 
 struct rpc_call_ops filelayout_write_call_ops = {
 	.rpc_call_prepare = nfs_write_prepare,
 	.rpc_call_done = filelayout_write_call_done,
+	.rpc_release = filelayout_write_release,
 };
 
 /* Perform sync or async reads.
@@ -539,12 +562,13 @@ static void filelayout_commit_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
-	pnfs_callback_ops->nfs_commit_complete(wdata);
+	wdata->pdata.call_ops->rpc_call_done(task, data);
 }
 
 static struct rpc_call_ops filelayout_commit_call_ops = {
 	.rpc_call_prepare = nfs_write_prepare,
 	.rpc_call_done = filelayout_commit_call_done,
+	.rpc_release = filelayout_write_release,
 };
 
 /*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7d322c9..a4d1937 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -452,6 +452,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 	if (do_wake_up)
 		wake_up(&nfsi->lo_waitq);
 }
+EXPORT_SYMBOL(put_lseg);
 
 static inline u64
 end_offset(u64 start, u64 len)
-- 
1.6.6.1

