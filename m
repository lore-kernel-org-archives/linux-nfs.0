Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:33610 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968201Ab3HIQt6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:49:58 -0400
Received: by mail-yh0-f52.google.com with SMTP id f11so1527532yha.39
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:49:58 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id s65sm20681954yhs.14.2013.08.09.09.49.57
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:49:57 -0700 (PDT)
Subject: [PATCH v2 15/33] NFS: Update session draining barriers for NFSv4.0
 transport blocking
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:49:56 -0400
Message-ID: <20130809164956.5362.39856.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4state.c |   61 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 34 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8826df3..d816d93 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -215,32 +215,6 @@ out:
 	return cred;
 }
 
-#if defined(CONFIG_NFS_V4_1)
-
-static int nfs41_setup_state_renewal(struct nfs_client *clp)
-{
-	int status;
-	struct nfs_fsinfo fsinfo;
-
-	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
-		nfs4_schedule_state_renewal(clp);
-		return 0;
-	}
-
-	status = nfs4_proc_get_lease_time(clp, &fsinfo);
-	if (status == 0) {
-		/* Update lease time and schedule renewal */
-		spin_lock(&clp->cl_lock);
-		clp->cl_lease_time = fsinfo.lease_time * HZ;
-		clp->cl_last_renewal = jiffies;
-		spin_unlock(&clp->cl_lock);
-
-		nfs4_schedule_state_renewal(clp);
-	}
-
-	return status;
-}
-
 static void nfs4_end_drain_slot_table(struct nfs4_slot_table *tbl)
 {
 	if (test_and_clear_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
@@ -254,6 +228,11 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
 
+	if (clp->cl_slot_tbl) {
+		nfs4_end_drain_slot_table(clp->cl_slot_tbl);
+		return;
+	}
+
 	if (ses != NULL) {
 		nfs4_end_drain_slot_table(&ses->bc_slot_table);
 		nfs4_end_drain_slot_table(&ses->fc_slot_table);
@@ -278,6 +257,9 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 	struct nfs4_session *ses = clp->cl_session;
 	int ret = 0;
 
+	if (clp->cl_slot_tbl)
+		return nfs4_drain_slot_tbl(clp->cl_slot_tbl);
+
 	/* back channel */
 	ret = nfs4_drain_slot_tbl(&ses->bc_slot_table);
 	if (ret)
@@ -286,6 +268,32 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 	return nfs4_drain_slot_tbl(&ses->fc_slot_table);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+static int nfs41_setup_state_renewal(struct nfs_client *clp)
+{
+	int status;
+	struct nfs_fsinfo fsinfo;
+
+	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
+		nfs4_schedule_state_renewal(clp);
+		return 0;
+	}
+
+	status = nfs4_proc_get_lease_time(clp, &fsinfo);
+	if (status == 0) {
+		/* Update lease time and schedule renewal */
+		spin_lock(&clp->cl_lock);
+		clp->cl_lease_time = fsinfo.lease_time * HZ;
+		clp->cl_last_renewal = jiffies;
+		spin_unlock(&clp->cl_lock);
+
+		nfs4_schedule_state_renewal(clp);
+	}
+
+	return status;
+}
+
 static void nfs41_finish_session_reset(struct nfs_client *clp)
 {
 	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
@@ -2083,7 +2091,6 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 }
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
-static void nfs4_end_drain_session(struct nfs_client *clp) { }
 
 static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 {

