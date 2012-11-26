Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9745 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756016Ab2KZURP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:15 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 27/28] NFSv4.1: Move slot table and session struct definitions to nfs4session.h
Date: Mon, 26 Nov 2012 15:16:44 -0500
Message-Id: <1353961005-63874-28-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-27-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-19-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-20-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-21-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-22-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-23-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-24-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-25-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-26-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-27-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. Gather NFSv4.1 slot definitions in fs/nfs/nfs4session.h.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_xdr.c     |   1 +
 fs/nfs/internal.h         |  21 ----------
 fs/nfs/nfs4_fs.h          |  12 ------
 fs/nfs/nfs4filelayout.c   |   1 +
 fs/nfs/nfs4session.h      | 101 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4state.c        |   1 +
 fs/nfs/nfs4xdr.c          |   1 +
 fs/nfs/super.c            |   1 +
 include/linux/nfs_fs_sb.h |  49 ----------------------
 include/linux/nfs_xdr.h   |  11 +----
 10 files changed, 107 insertions(+), 92 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index ea6a7b1..59461c9 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -16,6 +16,7 @@
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "internal.h"
+#include "nfs4session.h"
 
 #define CB_OP_TAGLEN_MAXSZ	(512)
 #define CB_OP_HDR_RES_MAXSZ	(2 + CB_OP_TAGLEN_MAXSZ)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8965a99..9bdbfc3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -18,27 +18,6 @@ struct nfs_string;
  */
 #define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
 
-/*
- * Determine if sessions are in use.
- */
-static inline int nfs4_has_session(const struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (clp->cl_session)
-		return 1;
-#endif /* CONFIG_NFS_V4_1 */
-	return 0;
-}
-
-static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(clp))
-		return (clp->cl_session->flags & SESSION4_PERSIST);
-#endif /* CONFIG_NFS_V4_1 */
-	return 0;
-}
-
 static inline void nfs_attr_check_mountpoint(struct super_block *parent, struct nfs_fattr *fattr)
 {
 	if (!nfs_fsid_equal(&NFS_SB(parent)->fsid, &fattr->fsid))
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cd3e309..322bd01 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -29,11 +29,6 @@ enum nfs4_client_state {
 	NFS4CLNT_BIND_CONN_TO_SESSION,
 };
 
-enum nfs4_session_state {
-	NFS4_SESSION_INITING,
-	NFS4_SESSION_DRAINING,
-};
-
 #define NFS4_RENEW_TIMEOUT		0x01
 #define NFS4_RENEW_DELEGATION_CB	0x02
 
@@ -327,13 +322,6 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
 extern void nfs41_server_notify_target_slotid_update(struct nfs_client *clp);
 
-extern void nfs4_session_drain_complete(struct nfs4_session *session,
-		struct nfs4_slot_table *tbl);
-
-static inline bool nfs4_session_draining(struct nfs4_session *session)
-{
-	return !!test_bit(NFS4_SESSION_DRAINING, &session->session_state);
-}
 #else
 static inline void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 {
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index bfb28fa..591a1a7 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -35,6 +35,7 @@
 
 #include <linux/sunrpc/metrics.h>
 
+#include "nfs4session.h"
 #include "internal.h"
 #include "delegation.h"
 #include "nfs4filelayout.h"
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index cb47b1e..e96323f 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -7,6 +7,68 @@
 #ifndef __LINUX_FS_NFS_NFS4SESSION_H
 #define __LINUX_FS_NFS_NFS4SESSION_H
 
+/* maximum number of slots to use */
+#define NFS4_DEF_SLOT_TABLE_SIZE (16U)
+#define NFS4_MAX_SLOT_TABLE (256U)
+#define NFS4_NO_SLOT ((u32)-1)
+
+#if IS_ENABLED(CONFIG_NFS_V4)
+
+/* Sessions slot seqid */
+struct nfs4_slot {
+	struct nfs4_slot_table	*table;
+	struct nfs4_slot	*next;
+	unsigned long		generation;
+	unsigned long		renewal_time;
+	u32			slot_nr;
+	u32		 	seq_nr;
+};
+
+/* Sessions */
+#define SLOT_TABLE_SZ DIV_ROUND_UP(NFS4_MAX_SLOT_TABLE, 8*sizeof(long))
+struct nfs4_slot_table {
+	struct nfs4_session *session;		/* Parent session */
+	struct nfs4_slot *slots;		/* seqid per slot */
+	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
+	spinlock_t	slot_tbl_lock;
+	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
+	u32		max_slots;		/* # slots in table */
+	u32		max_slotid;		/* Max allowed slotid value */
+	u32		highest_used_slotid;	/* sent to server on each SEQ.
+						 * op for dynamic resizing */
+	u32		target_highest_slotid;	/* Server max_slot target */
+	u32		server_highest_slotid;	/* Server highest slotid */
+	unsigned long	generation;		/* Generation counter for
+						   target_highest_slotid */
+	struct completion complete;
+};
+
+/*
+ * Session related parameters
+ */
+struct nfs4_session {
+	struct nfs4_sessionid		sess_id;
+	u32				flags;
+	unsigned long			session_state;
+	u32				hash_alg;
+	u32				ssv_len;
+
+	/* The fore and back channel */
+	struct nfs4_channel_attrs	fc_attrs;
+	struct nfs4_slot_table		fc_slot_table;
+	struct nfs4_channel_attrs	bc_attrs;
+	struct nfs4_slot_table		bc_slot_table;
+	struct nfs_client		*clp;
+	/* Create session arguments */
+	unsigned int			fc_target_max_rqst_sz;
+	unsigned int			fc_target_max_resp_sz;
+};
+
+enum nfs4_session_state {
+	NFS4_SESSION_INITING,
+	NFS4_SESSION_DRAINING,
+};
+
 #if defined(CONFIG_NFS_V4_1)
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
@@ -24,6 +86,31 @@ extern void nfs4_destroy_session(struct nfs4_session *session);
 extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
 
+extern void nfs4_session_drain_complete(struct nfs4_session *session,
+		struct nfs4_slot_table *tbl);
+
+static inline bool nfs4_session_draining(struct nfs4_session *session)
+{
+	return !!test_bit(NFS4_SESSION_DRAINING, &session->session_state);
+}
+
+/*
+ * Determine if sessions are in use.
+ */
+static inline int nfs4_has_session(const struct nfs_client *clp)
+{
+	if (clp->cl_session)
+		return 1;
+	return 0;
+}
+
+static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
+{
+	if (nfs4_has_session(clp))
+		return (clp->cl_session->flags & SESSION4_PERSIST);
+	return 0;
+}
+
 #else /* defined(CONFIG_NFS_V4_1) */
 
 static inline int nfs4_init_session(struct nfs_server *server)
@@ -31,5 +118,19 @@ static inline int nfs4_init_session(struct nfs_server *server)
 	return 0;
 }
 
+/*
+ * Determine if sessions are in use.
+ */
+static inline int nfs4_has_session(const struct nfs_client *clp)
+{
+	return 0;
+}
+
+static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
+{
+	return 0;
+}
+
 #endif /* defined(CONFIG_NFS_V4_1) */
+#endif /* IS_ENABLED(CONFIG_NFS_V4) */
 #endif /* __LINUX_FS_NFS_NFS4SESSION_H */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1d38c8b..9afcdd3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -57,6 +57,7 @@
 #include "callback.h"
 #include "delegation.h"
 #include "internal.h"
+#include "nfs4session.h"
 #include "pnfs.h"
 #include "netns.h"
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a67040f..e786dc7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -56,6 +56,7 @@
 
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "nfs4session.h"
 #include "pnfs.h"
 #include "netns.h"
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 652d3f7..e12cea4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -64,6 +64,7 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "nfs4session.h"
 #include "pnfs.h"
 #include "nfs.h"
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e707c1b..6c6ed15 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -198,53 +198,4 @@ struct nfs_server {
 #define NFS_CAP_POSIX_LOCK	(1U << 14)
 #define NFS_CAP_UIDGID_NOMAP	(1U << 15)
 
-
-/* maximum number of slots to use */
-#define NFS4_DEF_SLOT_TABLE_SIZE (16U)
-#define NFS4_MAX_SLOT_TABLE (256U)
-#define NFS4_NO_SLOT ((u32)-1)
-
-#if IS_ENABLED(CONFIG_NFS_V4)
-
-/* Sessions */
-#define SLOT_TABLE_SZ DIV_ROUND_UP(NFS4_MAX_SLOT_TABLE, 8*sizeof(long))
-struct nfs4_slot_table {
-	struct nfs4_session *session;		/* Parent session */
-	struct nfs4_slot *slots;		/* seqid per slot */
-	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
-	spinlock_t	slot_tbl_lock;
-	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
-	u32		max_slots;		/* # slots in table */
-	u32		max_slotid;		/* Max allowed slotid value */
-	u32		highest_used_slotid;	/* sent to server on each SEQ.
-						 * op for dynamic resizing */
-	u32		target_highest_slotid;	/* Server max_slot target */
-	u32		server_highest_slotid;	/* Server highest slotid */
-	unsigned long	generation;		/* Generation counter for
-						   target_highest_slotid */
-	struct completion complete;
-};
-
-/*
- * Session related parameters
- */
-struct nfs4_session {
-	struct nfs4_sessionid		sess_id;
-	u32				flags;
-	unsigned long			session_state;
-	u32				hash_alg;
-	u32				ssv_len;
-
-	/* The fore and back channel */
-	struct nfs4_channel_attrs	fc_attrs;
-	struct nfs4_slot_table		fc_slot_table;
-	struct nfs4_channel_attrs	bc_attrs;
-	struct nfs4_slot_table		bc_slot_table;
-	struct nfs_client		*clp;
-	/* Create session arguments */
-	unsigned int			fc_target_max_rqst_sz;
-	unsigned int			fc_target_max_resp_sz;
-};
-
-#endif /* CONFIG_NFS_V4 */
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 44d256f..2076149 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -185,16 +185,7 @@ struct nfs4_channel_attrs {
 	u32			max_reqs;
 };
 
-/* nfs41 sessions slot seqid */
-struct nfs4_slot {
-	struct nfs4_slot_table	*table;
-	struct nfs4_slot	*next;
-	unsigned long		generation;
-	unsigned long		renewal_time;
-	u32			slot_nr;
-	u32		 	seq_nr;
-};
-
+struct nfs4_slot;
 struct nfs4_sequence_args {
 	struct nfs4_slot	*sa_slot;
 	u8			sa_cache_this;
-- 
1.7.11.7

