Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32833 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758986Ab3BKTaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 14:30:35 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] NFSv4: Fix up the return values of nfs4_open_delegation_recall
Date: Mon, 11 Feb 2013 14:29:24 -0500
Message-Id: <1360610966-15398-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1360610966-15398-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-2-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-3-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjust the return values so that they return EAGAIN to the caller in
cases where we might want to retry the delegation recall after
the state recovery has run.
Note that we can't wait and retry in this routine, because the caller
may be the state manager thread.

If delegation recall fails due to a session or reboot related issue,
also ensure that we mark the stateid as delegated so that
nfs_delegation_claim_opens can find it again later.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a1e89e2..f7e05ad 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1355,19 +1355,18 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 			case -NFS4ERR_BAD_HIGH_SLOT:
 			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 			case -NFS4ERR_DEADSESSION:
+				set_bit(NFS_DELEGATED_STATE, &state->flags);
 				nfs4_schedule_session_recovery(server->nfs_client->cl_session, err);
+				err = -EAGAIN;
 				goto out;
 			case -NFS4ERR_STALE_CLIENTID:
 			case -NFS4ERR_STALE_STATEID:
+				set_bit(NFS_DELEGATED_STATE, &state->flags);
 			case -NFS4ERR_EXPIRED:
 				/* Don't recall a delegation if it was lost */
 				nfs4_schedule_lease_recovery(server->nfs_client);
+				err = -EAGAIN;
 				goto out;
-			case -ERESTARTSYS:
-				/*
-				 * The show must go on: exit, but mark the
-				 * stateid as needing recovery.
-				 */
 			case -NFS4ERR_DELEG_REVOKED:
 			case -NFS4ERR_ADMIN_REVOKED:
 			case -NFS4ERR_BAD_STATEID:
@@ -1378,6 +1377,7 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 				err = 0;
 				goto out;
 		}
+		set_bit(NFS_DELEGATED_STATE, &state->flags);
 		err = nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
 out:
@@ -4957,24 +4957,22 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 			case 0:
 			case -ESTALE:
 				goto out;
-			case -NFS4ERR_EXPIRED:
-				nfs4_schedule_stateid_recovery(server, state);
 			case -NFS4ERR_STALE_CLIENTID:
 			case -NFS4ERR_STALE_STATEID:
+				set_bit(NFS_DELEGATED_STATE, &state->flags);
+			case -NFS4ERR_EXPIRED:
 				nfs4_schedule_lease_recovery(server->nfs_client);
+				err = -EAGAIN;
 				goto out;
 			case -NFS4ERR_BADSESSION:
 			case -NFS4ERR_BADSLOT:
 			case -NFS4ERR_BAD_HIGH_SLOT:
 			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 			case -NFS4ERR_DEADSESSION:
+				set_bit(NFS_DELEGATED_STATE, &state->flags);
 				nfs4_schedule_session_recovery(server->nfs_client->cl_session, err);
+				err = -EAGAIN;
 				goto out;
-			case -ERESTARTSYS:
-				/*
-				 * The show must go on: exit, but mark the
-				 * stateid as needing recovery.
-				 */
 			case -NFS4ERR_DELEG_REVOKED:
 			case -NFS4ERR_ADMIN_REVOKED:
 			case -NFS4ERR_BAD_STATEID:
@@ -4987,9 +4985,8 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
 				err = 0;
 				goto out;
-			case -NFS4ERR_DELAY:
-				break;
 		}
+		set_bit(NFS_DELEGATED_STATE, &state->flags);
 		err = nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
 out:
-- 
1.8.1.2

