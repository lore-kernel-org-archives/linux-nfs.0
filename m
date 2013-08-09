Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f53.google.com ([209.85.213.53]:37415 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQsz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:48:55 -0400
Received: by mail-yh0-f53.google.com with SMTP id v1so1521438yhn.40
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:48:54 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id g66sm20678449yhd.11.2013.08.09.09.48.54
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:48:54 -0700 (PDT)
Subject: [PATCH v2 08/33] NFS: Add global helper to set up a stand-along
 nfs4_slot_table
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:48:53 -0400
Message-ID: <20130809164853.5362.83625.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4session.c |   38 +++++++++++++++++++++++++-------------
 fs/nfs/nfs4session.h |    2 ++
 2 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 746675b..be273c5 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -23,6 +23,14 @@
 
 #define NFSDBG_FACILITY		NFSDBG_STATE
 
+static void nfs4_init_slot_table(struct nfs4_slot_table *tbl, const char *queue)
+{
+	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	spin_lock_init(&tbl->slot_tbl_lock);
+	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, queue);
+	init_completion(&tbl->complete);
+}
+
 /*
  * nfs4_shrink_slot_table - free retired slots from the slot table
  */
@@ -223,6 +231,21 @@ out:
 	return ret;
 }
 
+/**
+ * nfs4_setup_slot_table - prepare a stand-alone slot table for use
+ * @tbl: slot table to set up
+ * @max_reqs: maximum number of requests allowed
+ * @queue: name to give RPC wait queue
+ *
+ * Returns zero on success, or a negative errno.
+ */
+int nfs4_setup_slot_table(struct nfs4_slot_table *tbl, unsigned int max_reqs,
+		const char *queue)
+{
+	nfs4_init_slot_table(tbl, queue);
+	return nfs4_realloc_slot_table(tbl, max_reqs, 0);
+}
+
 static bool nfs41_assign_slot(struct rpc_task *task, void *pslot)
 {
 	struct nfs4_sequence_args *args = task->tk_msg.rpc_argp;
@@ -425,24 +448,13 @@ int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 {
 	struct nfs4_session *session;
-	struct nfs4_slot_table *tbl;
 
 	session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
 	if (!session)
 		return NULL;
 
-	tbl = &session->fc_slot_table;
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	spin_lock_init(&tbl->slot_tbl_lock);
-	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
-	init_completion(&tbl->complete);
-
-	tbl = &session->bc_slot_table;
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	spin_lock_init(&tbl->slot_tbl_lock);
-	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
-	init_completion(&tbl->complete);
-
+	nfs4_init_slot_table(&session->fc_slot_table, "ForeChannel Slot table");
+	nfs4_init_slot_table(&session->bc_slot_table, "BackChannel Slot table");
 	session->session_state = 1<<NFS4_SESSION_INITING;
 
 	session->clp = clp;
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 23d26b4..7781838 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -72,6 +72,8 @@ enum nfs4_session_state {
 	NFS4_SESSION_INITING,
 };
 
+extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
+		unsigned int max_reqs, const char *queue);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);

