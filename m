Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:61110 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434AbaA2Qen (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jan 2014 11:34:43 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/1] NFSv4.1 free slot before resending I/O to MDS
Date: Wed, 29 Jan 2014 11:34:38 -0500
Message-ID: <1391013278-13517-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Fix a dynamic session slot leak where a slot is preallocated and I/O is
resent through the MDS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h        |  1 +
 fs/nfs/nfs4filelayout.c | 10 ++++++++--
 fs/nfs/nfs4proc.c       |  3 ++-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5609edc..a5b27c2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -270,6 +270,7 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 extern int nfs41_setup_sequence(struct nfs4_session *session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		struct rpc_task *task);
+extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res *);
 extern int nfs4_proc_create_session(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_destroy_session(struct nfs4_session *, struct rpc_cred *);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 03fd8be..20a56fa 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -335,8 +335,11 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
 	if (test_bit(NFS_IOHDR_REDO, &rdata->header->flags) &&
-	    task->tk_status == 0)
+	    task->tk_status == 0) {
+		if (rdata->res.seq_res.sr_slot != NULL)
+			nfs41_sequence_done(task, &rdata->res.seq_res);
 		return;
+	}
 
 	/* Note this may cause RPC to be resent */
 	rdata->header->mds_ops->rpc_call_done(task, data);
@@ -442,8 +445,11 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 	struct nfs_write_data *wdata = data;
 
 	if (test_bit(NFS_IOHDR_REDO, &wdata->header->flags) &&
-	    task->tk_status == 0)
+	    task->tk_status == 0) {
+		if (wdata->res.seq_res.sr_slot != NULL)
+			nfs41_sequence_done(task, &wdata->res.seq_res);
 		return;
+	}
 
 	/* Note this may cause RPC to be resent */
 	wdata->header->mds_ops->rpc_call_done(task, data);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed10d0d..ae00c3e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -592,7 +592,7 @@ out_unlock:
 		nfs41_server_notify_highest_slotid_update(session->clp);
 }
 
-static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
+int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
 	struct nfs4_slot *slot;
@@ -692,6 +692,7 @@ out_retry:
 	rpc_delay(task, NFS4_POLL_RETRY_MAX);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs41_sequence_done);
 
 static int nfs4_sequence_done(struct rpc_task *task,
 			       struct nfs4_sequence_res *res)
-- 
1.8.3.1

