Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36837 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200AbaBAU4v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Feb 2014 15:56:51 -0500
Received: by mail-ie0-f176.google.com with SMTP id tp5so5224172ieb.7
        for <linux-nfs@vger.kernel.org>; Sat, 01 Feb 2014 12:56:51 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 2/2] NFSv4.1: nfs4_destroy_session must call rpc_destroy_waitqueue
Date: Sat,  1 Feb 2014 15:56:48 -0500
Message-Id: <1391288208-23750-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1391288208-23750-1-git-send-email-trond.myklebust@primarydata.com>
References: <1391288208-23750-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There may still be timers active on the session waitqueues. Make sure
that we kill them before freeing the memory.

Cc: stable@vger.kernel.org # 3.12+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c  |  2 +-
 fs/nfs/nfs4session.c | 25 ++++++++++++++++++++-----
 fs/nfs/nfs4session.h |  2 +-
 3 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index dbb3e1f30c68..860ad26a5590 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -170,7 +170,7 @@ void nfs41_shutdown_client(struct nfs_client *clp)
 void nfs40_shutdown_client(struct nfs_client *clp)
 {
 	if (clp->cl_slot_tbl) {
-		nfs4_release_slot_table(clp->cl_slot_tbl);
+		nfs4_shutdown_slot_table(clp->cl_slot_tbl);
 		kfree(clp->cl_slot_tbl);
 	}
 }
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index cf883c7ae053..e799dc3c3b1d 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -231,14 +231,23 @@ out:
 	return ret;
 }
 
+/*
+ * nfs4_release_slot_table - release all slot table entries
+ */
+static void nfs4_release_slot_table(struct nfs4_slot_table *tbl)
+{
+	nfs4_shrink_slot_table(tbl, 0);
+}
+
 /**
- * nfs4_release_slot_table - release resources attached to a slot table
+ * nfs4_shutdown_slot_table - release resources attached to a slot table
  * @tbl: slot table to shut down
  *
  */
-void nfs4_release_slot_table(struct nfs4_slot_table *tbl)
+void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl)
 {
-	nfs4_shrink_slot_table(tbl, 0);
+	nfs4_release_slot_table(tbl);
+	rpc_destroy_wait_queue(&tbl->slot_tbl_waitq);
 }
 
 /**
@@ -422,7 +431,7 @@ void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
 	spin_unlock(&tbl->slot_tbl_lock);
 }
 
-static void nfs4_destroy_session_slot_tables(struct nfs4_session *session)
+static void nfs4_release_session_slot_tables(struct nfs4_session *session)
 {
 	nfs4_release_slot_table(&session->fc_slot_table);
 	nfs4_release_slot_table(&session->bc_slot_table);
@@ -450,7 +459,7 @@ int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	if (status && tbl->slots == NULL)
 		/* Fore and back channel share a connection so get
 		 * both slot tables or neither */
-		nfs4_destroy_session_slot_tables(ses);
+		nfs4_release_session_slot_tables(ses);
 	return status;
 }
 
@@ -470,6 +479,12 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	return session;
 }
 
+static void nfs4_destroy_session_slot_tables(struct nfs4_session *session)
+{
+	nfs4_shutdown_slot_table(&session->fc_slot_table);
+	nfs4_shutdown_slot_table(&session->bc_slot_table);
+}
+
 void nfs4_destroy_session(struct nfs4_session *session)
 {
 	struct rpc_xprt *xprt;
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 232306100651..b34ada9bc6a2 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -74,7 +74,7 @@ enum nfs4_session_state {
 
 extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
 		unsigned int max_reqs, const char *queue);
-extern void nfs4_release_slot_table(struct nfs4_slot_table *tbl);
+extern void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
-- 
1.8.5.3

