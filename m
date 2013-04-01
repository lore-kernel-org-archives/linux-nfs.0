Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6770 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759681Ab3DAUBl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 16:01:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4: Clean up nfs4_open_delegation_recall
Date: Mon,  1 Apr 2013 16:01:32 -0400
Message-Id: <1364846493-11145-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1364846493-11145-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1364846493-11145-1-git-send-email-Trond.Myklebust@netapp.com>
 <1364846493-11145-2-git-send-email-Trond.Myklebust@netapp.com>
 <1364846493-11145-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it symmetric with nfs4_lock_delegation_recall

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 96 ++++++++++++++++++++++++-------------------------------
 1 file changed, 41 insertions(+), 55 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e28a726..b5ebf8c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1379,70 +1379,56 @@ static int nfs4_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *sta
 	return ret;
 }
 
-static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
+int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
 {
+	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_opendata *opendata;
-	int ret;
+	int err;
 
 	opendata = nfs4_open_recoverdata_alloc(ctx, state,
 			NFS4_OPEN_CLAIM_DELEG_CUR_FH);
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
-	ret = nfs4_open_recover(opendata, state);
+	err = nfs4_open_recover(opendata, state);
 	nfs4_opendata_put(opendata);
-	return ret;
-}
-
-int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
-{
-	struct nfs4_exception exception = { };
-	struct nfs_server *server = NFS_SERVER(state->inode);
-	int err;
-	do {
-		err = _nfs4_open_delegation_recall(ctx, state, stateid);
-		switch (err) {
-			case 0:
-			case -ENOENT:
-			case -ESTALE:
-				goto out;
-			case -NFS4ERR_BADSESSION:
-			case -NFS4ERR_BADSLOT:
-			case -NFS4ERR_BAD_HIGH_SLOT:
-			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
-			case -NFS4ERR_DEADSESSION:
-				set_bit(NFS_DELEGATED_STATE, &state->flags);
-				nfs4_schedule_session_recovery(server->nfs_client->cl_session, err);
-				err = -EAGAIN;
-				goto out;
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_STALE_STATEID:
-				set_bit(NFS_DELEGATED_STATE, &state->flags);
-			case -NFS4ERR_EXPIRED:
-				/* Don't recall a delegation if it was lost */
-				nfs4_schedule_lease_recovery(server->nfs_client);
-				err = -EAGAIN;
-				goto out;
-			case -NFS4ERR_DELEG_REVOKED:
-			case -NFS4ERR_ADMIN_REVOKED:
-			case -NFS4ERR_BAD_STATEID:
-				nfs_inode_find_state_and_recover(state->inode,
-						stateid);
-				nfs4_schedule_stateid_recovery(server, state);
-			case -ENOMEM:
-				err = 0;
-				goto out;
-			case -NFS4ERR_DELAY:
-			case -NFS4ERR_GRACE:
-				set_bit(NFS_DELEGATED_STATE, &state->flags);
-				ssleep(1);
-				err = -EAGAIN;
-				goto out;
-		}
-		set_bit(NFS_DELEGATED_STATE, &state->flags);
-		err = nfs4_handle_exception(server, err, &exception);
-	} while (exception.retry);
-out:
+	switch (err) {
+		default:
+			printk(KERN_ERR "NFS: %s: unhandled error "
+					"%d.\n", __func__, err);
+		case 0:
+		case -ENOENT:
+		case -ESTALE:
+			break;
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BAD_HIGH_SLOT:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_DEADSESSION:
+			set_bit(NFS_DELEGATED_STATE, &state->flags);
+			nfs4_schedule_session_recovery(server->nfs_client->cl_session, err);
+			return -EAGAIN;
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_STALE_STATEID:
+			set_bit(NFS_DELEGATED_STATE, &state->flags);
+		case -NFS4ERR_EXPIRED:
+			/* Don't recall a delegation if it was lost */
+			nfs4_schedule_lease_recovery(server->nfs_client);
+			return -EAGAIN;
+		case -NFS4ERR_DELEG_REVOKED:
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_BAD_STATEID:
+			nfs_inode_find_state_and_recover(state->inode,
+					stateid);
+			nfs4_schedule_stateid_recovery(server, state);
+		case -ENOMEM:
+			return 0;
+		case -NFS4ERR_DELAY:
+		case -NFS4ERR_GRACE:
+			set_bit(NFS_DELEGATED_STATE, &state->flags);
+			ssleep(1);
+			return -EAGAIN;
+	}
 	return err;
 }
 
-- 
1.8.1.4

