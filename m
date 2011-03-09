Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34211 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab1CIVoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 16:44:05 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4: Fix the setlk error handler
Date: Wed,  9 Mar 2011 16:43:41 -0500
Message-Id: <1299707022-21140-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1299707022-21140-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1299707022-21140-1-git-send-email-Trond.Myklebust@netapp.com>
 <1299707022-21140-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8ae1926..f49b629 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4173,23 +4173,18 @@ static const struct rpc_call_ops nfs4_recover_lock_ops = {
 
 static void nfs4_handle_setlk_error(struct nfs_server *server, struct nfs4_lock_state *lsp, int new_lock_owner, int error)
 {
-	struct nfs_client *clp = server->nfs_client;
-	struct nfs4_state *state = lsp->ls_state;
-
 	switch (error) {
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_BAD_STATEID:
-	case -NFS4ERR_EXPIRED:
+		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
 		if (new_lock_owner != 0 ||
 		   (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
-			nfs4_state_mark_reclaim_nograce(clp, state);
-		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
+			nfs4_schedule_stateid_recovery(server, lsp->ls_state);
 		break;
 	case -NFS4ERR_STALE_STATEID:
-		if (new_lock_owner != 0 ||
-		    (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
-			nfs4_state_mark_reclaim_reboot(clp, state);
 		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
+	case -NFS4ERR_EXPIRED:
+		nfs4_schedule_lease_recovery(server->nfs_client);
 	};
 }
 
-- 
1.7.4

