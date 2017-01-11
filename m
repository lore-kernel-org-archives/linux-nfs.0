Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:47054 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754099AbdAKSz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:27 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/11] NFS: Make trace_nfs4_setup_sequence() available to NFS v4.0
Date: Wed, 11 Jan 2017 13:54:54 -0500
Message-ID: <20170111185454.9315-12-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This tracepoint displays information about the slot that was chosen for
the RPC, in addition to session information.  This could be useful
information for debugging, and we can set the session id hash to 0 to
indicate that there is no session.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c    |  4 +---
 fs/nfs/nfs4session.h |  2 ++
 fs/nfs/nfs4trace.h   | 64 ++++++++++++++++++++++++++--------------------------
 3 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 31edcf07ac93..94fdf26f9bf4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -925,11 +925,9 @@ int nfs4_setup_sequence(const struct nfs_client *client,
 		res->sr_timestamp = jiffies;
 		res->sr_status_flags = 0;
 		res->sr_status = 1;
-#ifdef CONFIG_NFS_V4_1
-		trace_nfs4_setup_sequence(session, args);
-#endif /* CONFIG_NFS_V4_1 */
 	}
 
+	trace_nfs4_setup_sequence(session, args);
 out_start:
 	rpc_call_start(task);
 	return 0;
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index f6378d95b1b5..dfae4880eacb 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -175,6 +175,8 @@ static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
 	return 0;
 }
 
+#define nfs_session_id_hash(session) (0)
+
 #endif /* defined(CONFIG_NFS_V4_1) */
 #endif /* IS_ENABLED(CONFIG_NFS_V4) */
 #endif /* __LINUX_FS_NFS_NFS4SESSION_H */
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index cfb8f7ce5cf6..845d0eadefc9 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -241,38 +241,6 @@ DEFINE_NFS4_CLIENTID_EVENT(nfs4_bind_conn_to_session);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_sequence);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_reclaim_complete);
 
-TRACE_EVENT(nfs4_setup_sequence,
-		TP_PROTO(
-			const struct nfs4_session *session,
-			const struct nfs4_sequence_args *args
-		),
-		TP_ARGS(session, args),
-
-		TP_STRUCT__entry(
-			__field(unsigned int, session)
-			__field(unsigned int, slot_nr)
-			__field(unsigned int, seq_nr)
-			__field(unsigned int, highest_used_slotid)
-		),
-
-		TP_fast_assign(
-			const struct nfs4_slot *sa_slot = args->sa_slot;
-			__entry->session = nfs_session_id_hash(&session->sess_id);
-			__entry->slot_nr = sa_slot->slot_nr;
-			__entry->seq_nr = sa_slot->seq_nr;
-			__entry->highest_used_slotid =
-					sa_slot->table->highest_used_slotid;
-		),
-		TP_printk(
-			"session=0x%08x slot_nr=%u seq_nr=%u "
-			"highest_used_slotid=%u",
-			__entry->session,
-			__entry->slot_nr,
-			__entry->seq_nr,
-			__entry->highest_used_slotid
-		)
-);
-
 #define show_nfs4_sequence_status_flags(status) \
 	__print_flags((unsigned long)status, "|", \
 		{ SEQ4_STATUS_CB_PATH_DOWN, "CB_PATH_DOWN" }, \
@@ -382,6 +350,38 @@ TRACE_EVENT(nfs4_cb_sequence,
 );
 #endif /* CONFIG_NFS_V4_1 */
 
+TRACE_EVENT(nfs4_setup_sequence,
+		TP_PROTO(
+			const struct nfs4_session *session,
+			const struct nfs4_sequence_args *args
+		),
+		TP_ARGS(session, args),
+
+		TP_STRUCT__entry(
+			__field(unsigned int, session)
+			__field(unsigned int, slot_nr)
+			__field(unsigned int, seq_nr)
+			__field(unsigned int, highest_used_slotid)
+		),
+
+		TP_fast_assign(
+			const struct nfs4_slot *sa_slot = args->sa_slot;
+			__entry->session = session ? nfs_session_id_hash(&session->sess_id) : 0;
+			__entry->slot_nr = sa_slot->slot_nr;
+			__entry->seq_nr = sa_slot->seq_nr;
+			__entry->highest_used_slotid =
+					sa_slot->table->highest_used_slotid;
+		),
+		TP_printk(
+			"session=0x%08x slot_nr=%u seq_nr=%u "
+			"highest_used_slotid=%u",
+			__entry->session,
+			__entry->slot_nr,
+			__entry->seq_nr,
+			__entry->highest_used_slotid
+		)
+);
+
 DECLARE_EVENT_CLASS(nfs4_open_event,
 		TP_PROTO(
 			const struct nfs_open_context *ctx,
-- 
2.11.0

