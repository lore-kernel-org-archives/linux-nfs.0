Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f178.google.com ([209.85.160.178]:48607 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQtE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:49:04 -0400
Received: by mail-gh0-f178.google.com with SMTP id g15so1280269ghb.37
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:49:03 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id a42sm18474634yhb.19.2013.08.09.09.49.03
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:49:03 -0700 (PDT)
Subject: [PATCH v2 09/33] NFS: Add global helper for releasing slot table
 resources
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:49:02 -0400
Message-ID: <20130809164902.5362.75813.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs4_destroy_slot_tables() function is renamed to avoid
confusion with the new helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4session.c |   21 +++++++++++++++------
 fs/nfs/nfs4session.h |    1 +
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index be273c5..e0bf666 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -232,6 +232,16 @@ out:
 }
 
 /**
+ * nfs4_release_slot_table - release resources attached to a slot table
+ * @tbl: slot table to shut down
+ *
+ */
+void nfs4_release_slot_table(struct nfs4_slot_table *tbl)
+{
+	nfs4_shrink_slot_table(tbl, 0);
+}
+
+/**
  * nfs4_setup_slot_table - prepare a stand-alone slot table for use
  * @tbl: slot table to set up
  * @max_reqs: maximum number of requests allowed
@@ -412,11 +422,10 @@ void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
 
 #if defined(CONFIG_NFS_V4_1)
 
-/* Destroy the slot table */
-static void nfs4_destroy_slot_tables(struct nfs4_session *session)
+static void nfs4_destroy_session_slot_tables(struct nfs4_session *session)
 {
-	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
-	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
+	nfs4_release_slot_table(&session->fc_slot_table);
+	nfs4_release_slot_table(&session->bc_slot_table);
 }
 
 /*
@@ -441,7 +450,7 @@ int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	if (status && tbl->slots == NULL)
 		/* Fore and back channel share a connection so get
 		 * both slot tables or neither */
-		nfs4_destroy_slot_tables(ses);
+		nfs4_destroy_session_slot_tables(ses);
 	return status;
 }
 
@@ -477,7 +486,7 @@ void nfs4_destroy_session(struct nfs4_session *session)
 	dprintk("%s Destroy backchannel for xprt %p\n",
 		__func__, xprt);
 	xprt_destroy_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
-	nfs4_destroy_slot_tables(session);
+	nfs4_destroy_session_slot_tables(session);
 	kfree(session);
 }
 
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 7781838..92c27f4 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -74,6 +74,7 @@ enum nfs4_session_state {
 
 extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
 		unsigned int max_reqs, const char *queue);
+extern void nfs4_release_slot_table(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);

