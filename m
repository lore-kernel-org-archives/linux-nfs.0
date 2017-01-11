Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:63691 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752882AbdAKSzH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:07 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/11] NFS: Move nfs4_get_session() into nfs4_session.h
Date: Wed, 11 Jan 2017 13:54:44 -0500
Message-ID: <20170111185454.9315-2-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This puts session related functions together in the same space.  I only
keep one version of this function, since this variable will always be
NULL when using NFS v4.0.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c   |  1 +
 fs/nfs/nfs4_fs.h     | 10 ----------
 fs/nfs/nfs4session.h |  5 +++++
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index d12ff9385f49..b752d85ad8c6 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -12,6 +12,7 @@
 #include "nfs42.h"
 #include "iostat.h"
 #include "pnfs.h"
+#include "nfs4session.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY NFSDBG_PROC
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 665165833660..04ffea093d56 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -273,11 +273,6 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		fmode_t fmode);
 
 #if defined(CONFIG_NFS_V4_1)
-static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
-{
-	return server->nfs_client->cl_session;
-}
-
 extern int nfs41_setup_sequence(struct nfs4_session *session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		struct rpc_task *task);
@@ -357,11 +352,6 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 		hdr->args.stable = NFS_FILE_SYNC;
 }
 #else /* CONFIG_NFS_v4_1 */
-static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
-{
-	return NULL;
-}
-
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
 {
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index dae385500005..22cb55015b2b 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -103,6 +103,11 @@ static inline bool nfs4_test_locked_slot(const struct nfs4_slot_table *tbl,
 	return !!test_bit(slotid, tbl->used_slots);
 }
 
+static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
+{
+	return server->nfs_client->cl_session;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
 		u32 target_highest_slotid);
-- 
2.11.0

