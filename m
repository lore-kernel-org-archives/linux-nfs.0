Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f173.google.com ([209.85.160.173]:34314 "EHLO
	mail-gh0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:48:47 -0400
Received: by mail-gh0-f173.google.com with SMTP id g16so1288647ghb.32
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:48:46 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id n28sm20695730yhn.0.2013.08.09.09.48.45
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:48:45 -0700 (PDT)
Subject: [PATCH v2 07/33] NFS: Enable slot table helpers for NFSv4.0
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:48:44 -0400
Message-ID: <20130809164844.5362.23032.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd like to re-use NFSv4.1's slot table machinery for NFSv4.0
transport blocking.  Re-organize some of nfs4session.c so the slot
table code is built even when NFS_V4_1 is disabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/Makefile      |    4 ++--
 fs/nfs/nfs4session.c |   29 +++++++++++++++++++++--------
 fs/nfs/nfs4session.h |   28 +++++++++++++---------------
 fs/nfs/nfs4state.c   |    9 ---------
 4 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index e0bb048..2839bfe 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -21,10 +21,10 @@ nfsv3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
 obj-$(CONFIG_NFS_V4) += nfsv4.o
 nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
 	  delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
-	  nfs4namespace.o nfs4getroot.o nfs4client.o dns_resolve.o
+	  nfs4namespace.o nfs4getroot.o nfs4client.o dns_resolve.o nfs4session.o
 nfsv4-$(CONFIG_NFS_USE_LEGACY_DNS) += cache_lib.o
 nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
-nfsv4-$(CONFIG_NFS_V4_1)	+= nfs4session.o pnfs.o pnfs_dev.o
+nfsv4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 0161ad2..746675b 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -44,6 +44,17 @@ static void nfs4_shrink_slot_table(struct nfs4_slot_table  *tbl, u32 newsize)
 	}
 }
 
+/**
+ * nfs4_slot_tbl_drain_complete - wake waiters when drain is complete
+ * @tbl - controlling slot table
+ *
+ */
+void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
+{
+	if (nfs4_slot_tbl_draining(tbl))
+		complete(&tbl->complete);
+}
+
 /*
  * nfs4_free_slot - free a slot and efficiently update slot table.
  *
@@ -212,13 +223,6 @@ out:
 	return ret;
 }
 
-/* Destroy the slot table */
-static void nfs4_destroy_slot_tables(struct nfs4_session *session)
-{
-	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
-	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
-}
-
 static bool nfs41_assign_slot(struct rpc_task *task, void *pslot)
 {
 	struct nfs4_sequence_args *args = task->tk_msg.rpc_argp;
@@ -383,6 +387,15 @@ void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
 	spin_unlock(&tbl->slot_tbl_lock);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+/* Destroy the slot table */
+static void nfs4_destroy_slot_tables(struct nfs4_session *session)
+{
+	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
+	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
+}
+
 /*
  * Initialize or reset the forechannel and backchannel tables
  */
@@ -513,4 +526,4 @@ int nfs4_init_ds_session(struct nfs_client *clp, unsigned long lease_time)
 }
 EXPORT_SYMBOL_GPL(nfs4_init_ds_session);
 
-
+#endif	/* defined(CONFIG_NFS_V4_1) */
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 3a153d8..23d26b4 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -72,15 +72,24 @@ enum nfs4_session_state {
 	NFS4_SESSION_INITING,
 };
 
-#if defined(CONFIG_NFS_V4_1)
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
-
-extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
-		u32 target_highest_slotid);
+extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
 extern void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
 		struct nfs4_slot *slot,
 		struct nfs4_sequence_res *res);
+bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
+		struct nfs4_slot *slot);
+void nfs41_wake_slot_table(struct nfs4_slot_table *tbl);
+
+static inline bool nfs4_slot_tbl_draining(struct nfs4_slot_table *tbl)
+{
+	return !!test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
+}
+
+#if defined(CONFIG_NFS_V4_1)
+extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
+		u32 target_highest_slotid);
 
 extern int nfs4_setup_session_slot_tables(struct nfs4_session *ses);
 
@@ -89,17 +98,6 @@ extern void nfs4_destroy_session(struct nfs4_session *session);
 extern int nfs4_init_session(struct nfs_client *clp);
 extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
 
-extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
-
-static inline bool nfs4_slot_tbl_draining(struct nfs4_slot_table *tbl)
-{
-	return !!test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
-}
-
-bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
-		struct nfs4_slot *slot);
-void nfs41_wake_slot_table(struct nfs4_slot_table *tbl);
-
 /*
  * Determine if sessions are in use.
  */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6818964..8826df3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -260,15 +260,6 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	}
 }
 
-/*
- * Signal state manager thread if session fore channel is drained
- */
-void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
-{
-	if (nfs4_slot_tbl_draining(tbl))
-		complete(&tbl->complete);
-}
-
 static int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
 {
 	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);

