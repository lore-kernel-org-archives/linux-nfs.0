Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:34885 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbbGHSZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:25:20 -0400
Received: by labgy5 with SMTP id gy5so78794716lab.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 11:25:18 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4.1: Handle SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED status bit correctly.
Date: Wed,  8 Jul 2015 20:25:09 +0200
Message-Id: <1436379913-3338-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server tells us that only some state has been revoked, then we
need to run the full TEST_STATEID dog and pony show in order to discover
which locks and delegations are still OK. Currently we blow away all
state, which means that we lose all locks!

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 605840dc89cf..f76916169b5f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2191,12 +2191,20 @@ static void nfs41_handle_server_reboot(struct nfs_client *clp)
 	}
 }
 
-static void nfs41_handle_state_revoked(struct nfs_client *clp)
+static void nfs41_handle_all_state_revoked(struct nfs_client *clp)
 {
 	nfs4_reset_all_state(clp);
 	dprintk("%s: state revoked on server %s\n", __func__, clp->cl_hostname);
 }
 
+static void nfs41_handle_some_state_revoked(struct nfs_client *clp)
+{
+	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_nograce);
+	nfs4_schedule_state_manager(clp);
+
+	dprintk("%s: state revoked on server %s\n", __func__, clp->cl_hostname);
+}
+
 static void nfs41_handle_recallable_state_revoked(struct nfs_client *clp)
 {
 	/* This will need to handle layouts too */
@@ -2231,10 +2239,11 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 
 	if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED)
 		nfs41_handle_server_reboot(clp);
-	if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
-			    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
+	if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED))
+		nfs41_handle_all_state_revoked(clp);
+	if (flags & (SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
 			    SEQ4_STATUS_ADMIN_STATE_REVOKED))
-		nfs41_handle_state_revoked(clp);
+		nfs41_handle_some_state_revoked(clp);
 	if (flags & SEQ4_STATUS_LEASE_MOVED)
 		nfs4_schedule_lease_moved_recovery(clp);
 	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
-- 
2.4.3

