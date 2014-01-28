Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43757 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932115AbaA1XBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jan 2014 18:01:21 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 free slot before resending I/O to MDS
Date: Tue, 28 Jan 2014 18:01:14 -0500
Message-ID: <1390950074-7245-2-git-send-email-andros@netapp.com>
In-Reply-To: <1390950074-7245-1-git-send-email-andros@netapp.com>
References: <1390950074-7245-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Free an allocated slot from nfs41_wake_and_assign_slot prior to rpc_exit.
Prevents a state_manager hang when draining a data server session.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 6 ++++++
 fs/nfs/nfs4session.c    | 1 +
 2 files changed, 7 insertions(+)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 03fd8be..9611999 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -314,6 +314,9 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 	if (filelayout_reset_to_mds(rdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_read(rdata);
+		if (rdata->res.seq_res.sr_slot != NULL)
+			nfs4_free_slot(&rdata->ds_clp->cl_session->fc_slot_table,
+					rdata->res.seq_res.sr_slot);
 		rpc_exit(task, 0);
 		return;
 	}
@@ -425,6 +428,9 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 	if (filelayout_reset_to_mds(wdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_write(wdata);
+		if (wdata->res.seq_res.sr_slot != NULL)
+			nfs4_free_slot(&wdata->ds_clp->cl_session->fc_slot_table,
+					wdata->res.seq_res.sr_slot);
 		rpc_exit(task, 0);
 		return;
 	}
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index cf883c7..5226846 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -98,6 +98,7 @@ void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 	dprintk("%s: slotid %u highest_used_slotid %u\n", __func__,
 		slotid, tbl->highest_used_slotid);
 }
+EXPORT_SYMBOL_GPL(nfs4_free_slot);
 
 static struct nfs4_slot *nfs4_new_slot(struct nfs4_slot_table  *tbl,
 		u32 slotid, u32 seq_init, gfp_t gfp_mask)
-- 
1.8.3.1

