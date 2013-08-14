Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26746 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933211Ab3HNXZU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 19:25:20 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 13/13] NFSv4.1: Add tracepoints for debugging slot table operations
Date: Wed, 14 Aug 2013 19:24:58 -0400
Message-ID: <1376522698-44596-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376522698-44596-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1376522698-44596-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-2-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-3-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-4-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-5-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-6-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-7-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-8-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-9-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-10-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-11-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-12-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-13-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints to nfs41_setup_sequence and nfs41_sequence_done
to track session and slot table state changes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |   1 +
 fs/nfs/nfs4proc.c      |   2 +
 fs/nfs/nfs4session.h   |  10 ++++
 fs/nfs/nfs4trace.c     |   2 +
 fs/nfs/nfs4trace.h     | 130 +++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 145 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c074930..c44204d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -464,6 +464,7 @@ out:
 	} else
 		res->csr_status = status;
 
+	trace_nfs4_cb_sequence(args, res, htonl(status));
 	dprintk("%s: exit with status = %d res->csr_status %d\n", __func__,
 		ntohl(status), ntohl(res->csr_status));
 	return status;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 70f884e..6276ffd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -508,6 +508,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		interrupted = true;
 	}
 
+	trace_nfs4_sequence_done(session, res);
 	/* Check the SEQUENCE operation status */
 	switch (res->sr_status) {
 	case 0:
@@ -660,6 +661,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	 * set to 1 if an rpc level failure occurs.
 	 */
 	res->sr_status = 1;
+	trace_nfs4_setup_sequence(session, args);
 out_success:
 	rpc_call_start(task);
 	return 0;
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 86a0669..e3e6ce3 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -117,6 +117,16 @@ static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
 	return 0;
 }
 
+#ifdef CONFIG_CRC32
+/*
+ * nfs_session_id_hash - calculate the crc32 hash for the session id
+ * @session - pointer to session
+ */
+#define nfs_session_id_hash(sess_id) \
+	(~crc32_le(0xFFFFFFFF, &(sess_id)->data[0], sizeof((sess_id)->data)))
+#else
+#define nfs_session_id_hash(session) (0)
+#endif
 #else /* defined(CONFIG_NFS_V4_1) */
 
 static inline int nfs4_init_session(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4trace.c b/fs/nfs/nfs4trace.c
index f840974..d774335 100644
--- a/fs/nfs/nfs4trace.c
+++ b/fs/nfs/nfs4trace.c
@@ -4,6 +4,8 @@
 #include <linux/nfs_fs.h>
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "nfs4session.h"
+#include "callback.h"
 
 #define CREATE_TRACE_POINTS
 #include "nfs4trace.h"
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b068396..620b72d 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -231,6 +231,136 @@ DEFINE_NFS4_CLIENTID_EVENT(nfs4_destroy_clientid);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_bind_conn_to_session);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_sequence);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_reclaim_complete);
+
+TRACE_EVENT(nfs4_setup_sequence,
+		TP_PROTO(const struct nfs4_session *session,
+			const struct nfs4_sequence_args *args),
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
+			struct nfs4_slot *sa_slot = args->sa_slot;
+			__entry->session = nfs_session_id_hash(&session->sess_id);
+			__entry->slot_nr = sa_slot->slot_nr;
+			__entry->seq_nr = sa_slot->seq_nr;
+			__entry->highest_used_slotid =
+					sa_slot->table->highest_used_slotid;
+		),
+		TP_printk(
+			"session=%0x08x slot_nr=%u seq_nr=%u "
+			"highest_used_slotid=%u",
+			__entry->session,
+			__entry->slot_nr,
+			__entry->seq_nr,
+			__entry->highest_used_slotid
+		)
+);
+
+#define show_nfs4_sequence_status_flags(status)				\
+	__print_flags((unsigned long)status, "|",			\
+		{ SEQ4_STATUS_CB_PATH_DOWN, "CB_PATH_DOWN" },		\
+		{ SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING,			\
+			"CB_GSS_CONTEXTS_EXPIRING" },			\
+		{ SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED,			\
+			"CB_GSS_CONTEXTS_EXPIRED" },			\
+		{ SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,		\
+			"EXPIRED_ALL_STATE_REVOKED" },			\
+		{ SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,		\
+			"EXPIRED_SOME_STATE_REVOKED" },			\
+		{ SEQ4_STATUS_ADMIN_STATE_REVOKED,			\
+			"ADMIN_STATE_REVOKED" },			\
+		{ SEQ4_STATUS_RECALLABLE_STATE_REVOKED,			\
+			"RECALLABLE_STATE_REVOKED" },			\
+		{ SEQ4_STATUS_LEASE_MOVED, "LEASE_MOVED" },		\
+		{ SEQ4_STATUS_RESTART_RECLAIM_NEEDED,			\
+			"RESTART_RECLAIM_NEEDED" },			\
+		{ SEQ4_STATUS_CB_PATH_DOWN_SESSION,			\
+			"CB_PATH_DOWN_SESSION" },			\
+		{ SEQ4_STATUS_BACKCHANNEL_FAULT,			\
+			"BACKCHANNEL_FAULT" })
+
+TRACE_EVENT(nfs4_sequence_done,
+		TP_PROTO(const struct nfs4_session *session,
+			const struct nfs4_sequence_res *res),
+		TP_ARGS(session, res),
+
+		TP_STRUCT__entry(
+			__field(unsigned int, session)
+			__field(unsigned int, slot_nr)
+			__field(unsigned int, seq_nr)
+			__field(unsigned int, highest_slotid)
+			__field(unsigned int, target_highest_slotid)
+			__field(unsigned int, status_flags)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			struct nfs4_slot *sr_slot = res->sr_slot;
+			__entry->session = nfs_session_id_hash(&session->sess_id);
+			__entry->slot_nr = sr_slot->slot_nr;
+			__entry->seq_nr = sr_slot->seq_nr;
+			__entry->highest_slotid = res->sr_highest_slotid;
+			__entry->target_highest_slotid =
+					res->sr_target_highest_slotid;
+			__entry->error = res->sr_status;
+		),
+		TP_printk(
+			"error=%d (%s) session=%0x08x slot_nr=%u seq_nr=%u "
+			"highest_slotid=%u target_highest_slotid=%u"
+			"status_flags=%u (%s)",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			__entry->session,
+			__entry->slot_nr,
+			__entry->seq_nr,
+			__entry->highest_slotid,
+			__entry->target_highest_slotid,
+			__entry->status_flags,
+			show_nfs4_sequence_status_flags(__entry->status_flags)
+		)
+);
+
+TRACE_EVENT(nfs4_cb_sequence,
+		TP_PROTO(const struct cb_sequenceargs *args,
+			const struct cb_sequenceres *res,
+			__be32 status),
+		TP_ARGS(args, res, status),
+
+		TP_STRUCT__entry(
+			__field(unsigned int, session)
+			__field(unsigned int, slot_nr)
+			__field(unsigned int, seq_nr)
+			__field(unsigned int, highest_slotid)
+			__field(unsigned int, cachethis)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			__entry->session = nfs_session_id_hash(&args->csa_sessionid);
+			__entry->slot_nr = args->csa_slotid;
+			__entry->seq_nr = args->csa_sequenceid;
+			__entry->highest_slotid = args->csa_highestslotid;
+			__entry->cachethis = args->csa_cachethis;
+			__entry->error = -be32_to_cpu(status);
+		),
+
+		TP_printk(
+			"error=%d (%s) session=%0x08x slot_nr=%u seq_nr=%u "
+			"highest_slotid=%u",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			__entry->session,
+			__entry->slot_nr,
+			__entry->seq_nr,
+			__entry->highest_slotid
+		)
+);
 #endif /* CONFIG_NFS_V4_1 */
 
 DECLARE_EVENT_CLASS(nfs4_open_event,
-- 
1.8.3.1

