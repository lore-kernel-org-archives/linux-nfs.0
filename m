Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755865Ab2KZUQz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:16:55 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/28] NFSv4.1: Don't confuse CREATE_SESSION arguments and results
Date: Mon, 26 Nov 2012 15:16:19 -0500
Message-Id: <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't store the target request and response sizes in the same
variables used to store the server's replies to those targets.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c         | 30 +++++++++++++++++-------------
 include/linux/nfs_fs_sb.h |  3 +++
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a32d953..3e572dc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5807,8 +5807,8 @@ void nfs4_destroy_session(struct nfs4_session *session)
 static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 {
 	struct nfs4_session *session = args->client->cl_session;
-	unsigned int mxrqst_sz = session->fc_attrs.max_rqst_sz,
-		     mxresp_sz = session->fc_attrs.max_resp_sz;
+	unsigned int mxrqst_sz = session->fc_target_max_rqst_sz,
+		     mxresp_sz = session->fc_target_max_resp_sz;
 
 	if (mxrqst_sz == 0)
 		mxrqst_sz = NFS_MAX_FILE_IO_SIZE;
@@ -6015,24 +6015,28 @@ int nfs4_init_session(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_session *session;
-	unsigned int rsize, wsize;
+	unsigned int target_max_rqst_sz = NFS_MAX_FILE_IO_SIZE;
+	unsigned int target_max_resp_sz = NFS_MAX_FILE_IO_SIZE;
 
 	if (!nfs4_has_session(clp))
 		return 0;
 
+	if (server->rsize != 0)
+		target_max_resp_sz = server->rsize;
+	target_max_resp_sz += nfs41_maxread_overhead;
+
+	if (server->wsize != 0)
+		target_max_rqst_sz = server->wsize;
+	target_max_rqst_sz += nfs41_maxwrite_overhead;
+
 	session = clp->cl_session;
 	spin_lock(&clp->cl_lock);
 	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
-
-		rsize = server->rsize;
-		if (rsize == 0)
-			rsize = NFS_MAX_FILE_IO_SIZE;
-		wsize = server->wsize;
-		if (wsize == 0)
-			wsize = NFS_MAX_FILE_IO_SIZE;
-
-		session->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
-		session->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
+		/* Initialise targets and channel attributes */
+		session->fc_target_max_rqst_sz = target_max_rqst_sz;
+		session->fc_attrs.max_rqst_sz = target_max_rqst_sz;
+		session->fc_target_max_resp_sz = target_max_resp_sz;
+		session->fc_attrs.max_resp_sz = target_max_resp_sz;
 	}
 	spin_unlock(&clp->cl_lock);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a9e76ee..97c8f91 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -242,6 +242,9 @@ struct nfs4_session {
 	struct nfs4_channel_attrs	bc_attrs;
 	struct nfs4_slot_table		bc_slot_table;
 	struct nfs_client		*clp;
+	/* Create session arguments */
+	unsigned int			fc_target_max_rqst_sz;
+	unsigned int			fc_target_max_resp_sz;
 };
 
 #endif /* CONFIG_NFS_V4 */
-- 
1.7.11.7

