Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:44339 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759711Ab3DAUCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 16:02:47 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix another reboot recovery race
Date: Mon,  1 Apr 2013 16:02:44 -0400
Message-Id: <1364846564-11330-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the open_context for the file is not yet fully initialised,
then open recovery cannot succeed, and since nfs4_state_find_open_context
returns an ENOENT, we end up treating the file as being irrecoverable.

What we really want to do, is just defer the recovery until later.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  | 8 +++-----
 fs/nfs/nfs4state.c | 2 ++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e7d42f..8134394 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1373,7 +1373,7 @@ static int nfs4_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *sta
 
 	ctx = nfs4_state_find_open_context(state);
 	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
+		return -EAGAIN;
 	ret = nfs4_do_open_reclaim(ctx, state);
 	put_nfs_open_context(ctx);
 	return ret;
@@ -1814,7 +1814,7 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 
 	ctx = nfs4_state_find_open_context(state);
 	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
+		return -EAGAIN;
 	ret = nfs4_do_open_expired(ctx, state);
 	put_nfs_open_context(ctx);
 	return ret;
@@ -1936,10 +1936,8 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	if (ret != 0)
 		goto out;
 
-	if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq)) {
+	if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 		nfs4_schedule_stateid_recovery(server, state);
-		nfs4_wait_clnt_recover(server->nfs_client);
-	}
 	*res = state;
 out:
 	return ret;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 685b1e9..b924bdd 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1476,6 +1476,8 @@ restart:
 				 */
 				nfs4_state_mark_recovery_failed(state, status);
 				break;
+			case -EAGAIN:
+				ssleep(1);
 			case -NFS4ERR_ADMIN_REVOKED:
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_BAD_STATEID:
-- 
1.8.1.4

