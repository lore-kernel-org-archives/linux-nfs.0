Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:53862 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab2A3TaW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:22 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:21 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A6EFD3E40047
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:19 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTxn2108354
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:59 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTwHU003967
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:59 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTvpn003891
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/13] NFS: Add replication capability to state manager thread.
Date: Mon, 30 Jan 2012 13:29:53 -0600
Message-Id: <1327951795-16400-12-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

State manager now handles replication. It will replce the failed
server with new replicated server.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs4_fs.h          |    2 ++
 fs/nfs/nfs4state.c        |   14 ++++++++++++++
 include/linux/nfs_fs_sb.h |    3 +++
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b2a973b..afc19cc 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -25,6 +25,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
+	NFS4CLNT_REPLICATE,
 };
 
 enum nfs4_session_state {
@@ -332,6 +333,7 @@ extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
 int nfs4_replace_transport(struct nfs_server *server);
+void nfs4_schedule_replication_recovery(const struct nfs_server *server);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c97bbc7..3214376 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1709,6 +1709,15 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
 	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 }
 
+void nfs4_schedule_replication_recovery(const struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+	if (test_and_set_bit(NFS4CLNT_REPLICATE, &clp->cl_state) == 0) {
+		clp->cl_failed_server = (struct nfs_server *)server;
+		nfs4_schedule_state_manager(clp);
+	}
+}
+
 static void nfs4_state_manager(struct nfs_client *clp)
 {
 	int status = 0;
@@ -1758,6 +1767,11 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_REPLICATE, &clp->cl_state)) {
+			BUG_ON(clp->cl_failed_server == 0);
+			nfs4_replace_transport(clp->cl_failed_server);
+		}
+
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			status = nfs4_do_reclaim(clp,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index f5fd4bb..8c16ec5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -78,6 +78,9 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
+
+	/* Valid only under replicate state */
+	struct nfs_server	*cl_failed_server;
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.8.3

