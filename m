Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33068 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756060AbcH1WZF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2016 18:25:05 -0400
Received: by mail-it0-f65.google.com with SMTP id d65so5046826ith.0
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2016 15:25:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4.1: Delay callback processing when there are referring triples
Date: Sun, 28 Aug 2016 18:21:02 -0400
Message-Id: <1472422865-28698-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472422865-28698-2-git-send-email-trond.myklebust@primarydata.com>
References: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If CB_SEQUENCE tells us that the processing of this request depends on
the completion of one or more referring triples (see RFC 5661 Section
2.10.6.3), delay the callback processing until after the RPC requests
being referred to have completed.
If we end up delaying for more than 1/2 second, then fall back to
returning NFS4ERR_DELAY in reply to the callback.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c |  4 ++--
 fs/nfs/nfs4proc.c      |  2 ++
 fs/nfs/nfs4session.c   | 22 +++++++++++++++++++++-
 fs/nfs/nfs4session.h   |  5 ++++-
 4 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a4cf6d2c14a4..c35932967722 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -454,8 +454,8 @@ static bool referring_call_exists(struct nfs_client *clp,
 				((u32 *)&rclist->rcl_sessionid.data)[3],
 				ref->rc_sequenceid, ref->rc_slotid);
 
-			status = nfs4_slot_seqid_in_use(tbl, ref->rc_slotid,
-					ref->rc_sequenceid);
+			status = nfs4_slot_wait_on_seqid(tbl, ref->rc_slotid,
+					ref->rc_sequenceid, HZ >> 1) < 0;
 			if (status)
 				goto out;
 		}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1949bbd806eb..0cc0c319cfdd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -686,6 +686,8 @@ out_unlock:
 	res->sr_slot = NULL;
 	if (send_new_highest_used_slotid)
 		nfs41_notify_server(session->clp);
+	if (waitqueue_active(&tbl->slot_waitq))
+		wake_up_all(&tbl->slot_waitq);
 }
 
 int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index c1f4c208f38a..b62973045a3e 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -28,6 +28,7 @@ static void nfs4_init_slot_table(struct nfs4_slot_table *tbl, const char *queue)
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
 	spin_lock_init(&tbl->slot_tbl_lock);
 	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, queue);
+	init_waitqueue_head(&tbl->slot_waitq);
 	init_completion(&tbl->complete);
 }
 
@@ -192,7 +193,8 @@ static int nfs4_slot_get_seqid(struct nfs4_slot_table  *tbl, u32 slotid,
  * RPC call in question is still in flight. This function is mainly
  * intended for use by the callback channel.
  */
-bool nfs4_slot_seqid_in_use(struct nfs4_slot_table *tbl, u32 slotid, u32 seq_nr)
+static bool nfs4_slot_seqid_in_use(struct nfs4_slot_table *tbl,
+		u32 slotid, u32 seq_nr)
 {
 	u32 cur_seq;
 	bool ret = false;
@@ -206,6 +208,24 @@ bool nfs4_slot_seqid_in_use(struct nfs4_slot_table *tbl, u32 slotid, u32 seq_nr)
 }
 
 /*
+ * nfs4_slot_wait_on_seqid - wait until a slot sequence id is complete
+ *
+ * Given a slot table, slot id and sequence number, wait until the
+ * corresponding RPC call completes. This function is mainly
+ * intended for use by the callback channel.
+ */
+int nfs4_slot_wait_on_seqid(struct nfs4_slot_table *tbl,
+		u32 slotid, u32 seq_nr,
+		unsigned long timeout)
+{
+	if (wait_event_timeout(tbl->slot_waitq,
+			!nfs4_slot_seqid_in_use(tbl, slotid, seq_nr),
+			timeout) == 0)
+		return -ETIMEDOUT;
+	return 0;
+}
+
+/*
  * nfs4_alloc_slot - efficiently look for a free slot
  *
  * nfs4_alloc_slot looks for an unset bit in the used_slots bitmap.
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 33cace62b50b..fa75d7db3db3 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -36,6 +36,7 @@ struct nfs4_slot_table {
 	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
 	spinlock_t	slot_tbl_lock;
 	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
+	wait_queue_head_t	slot_waitq;	/* Completion wait on slot */
 	u32		max_slots;		/* # slots in table */
 	u32		max_slotid;		/* Max allowed slotid value */
 	u32		highest_used_slotid;	/* sent to server on each SEQ.
@@ -78,7 +79,9 @@ extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
 extern void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_lookup_slot(struct nfs4_slot_table *tbl, u32 slotid);
-extern bool nfs4_slot_seqid_in_use(struct nfs4_slot_table  *tbl, u32 slotid, u32 seq_nr);
+extern int nfs4_slot_wait_on_seqid(struct nfs4_slot_table *tbl,
+		u32 slotid, u32 seq_nr,
+		unsigned long timeout);
 extern bool nfs4_try_to_lock_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
-- 
2.7.4

