From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/15] NFSv41: Further cleanup for nfs4_sequence_done
Date: Mon, 14 Jun 2010 17:51:31 -0400
Message-ID: <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34599 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726Ab0FNVvo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:44 -0400
In-Reply-To: <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of testing if the nfs_client has a session, we should be testing if
the struct nfs4_sequence_res was set up with one.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 94377a5..60ea066 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -430,6 +430,13 @@ out:
 	nfs41_sequence_free_slot(res);
 }
 
+static void nfs4_sequence_done(const struct nfs_server *server,
+			       struct nfs4_sequence_res *res, int rpc_status)
+{
+	if (res->sr_session != NULL)
+		nfs41_sequence_done(res);
+}
+
 /*
  * nfs4_find_slot - efficiently look for a free slot
  *
@@ -642,6 +649,11 @@ int _nfs4_call_sync_session(struct nfs_server *server,
 	return nfs4_call_sync_sequence(server, msg, args, res, cache_reply, 0);
 }
 
+#else
+static void nfs4_sequence_done(const struct nfs_server *server,
+			       struct nfs4_sequence_res *res, int rpc_status)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 int _nfs4_call_sync(struct nfs_server *server,
@@ -658,15 +670,6 @@ int _nfs4_call_sync(struct nfs_server *server,
 	(server)->nfs_client->cl_call_sync((server), (msg), &(args)->seq_args, \
 			&(res)->seq_res, (cache_reply))
 
-static void nfs4_sequence_done(const struct nfs_server *server,
-			       struct nfs4_sequence_res *res, int rpc_status)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(server->nfs_client))
-		nfs41_sequence_done(res);
-#endif /* CONFIG_NFS_V4_1 */
-}
-
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
-- 
1.7.0.1

