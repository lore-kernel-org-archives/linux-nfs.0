Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:30032 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759679Ab3DAUBl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 16:01:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: Clean up nfs4_lock_delegation_recall
Date: Mon,  1 Apr 2013 16:01:31 -0400
Message-Id: <1364846493-11145-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1364846493-11145-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1364846493-11145-1-git-send-email-Trond.Myklebust@netapp.com>
 <1364846493-11145-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All error cases are handled by the switch() statement, meaning that the
call to nfs4_handle_exception() is unreachable.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 86 ++++++++++++++++++++++++-------------------------------
 1 file changed, 38 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a549ffe..e28a726 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5164,59 +5164,49 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
 	int err;
 
 	err = nfs4_set_lock_state(state, fl);
 	if (err != 0)
 		goto out;
-	do {
-		err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
-		switch (err) {
-			default:
-				printk(KERN_ERR "NFS: %s: unhandled error "
-					"%d.\n", __func__, err);
-			case 0:
-			case -ESTALE:
-				goto out;
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_STALE_STATEID:
-				set_bit(NFS_DELEGATED_STATE, &state->flags);
-			case -NFS4ERR_EXPIRED:
-				nfs4_schedule_lease_recovery(server->nfs_client);
-				err = -EAGAIN;
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
-			case -NFS4ERR_DELEG_REVOKED:
-			case -NFS4ERR_ADMIN_REVOKED:
-			case -NFS4ERR_BAD_STATEID:
-			case -NFS4ERR_OPENMODE:
-				nfs4_schedule_stateid_recovery(server, state);
-				err = 0;
-				goto out;
-			case -NFS4ERR_DELAY:
-			case -NFS4ERR_GRACE:
-				set_bit(NFS_DELEGATED_STATE, &state->flags);
-				ssleep(1);
-				err = -EAGAIN;
-				goto out;
-			case -ENOMEM:
-			case -NFS4ERR_DENIED:
-				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
-				err = 0;
-				goto out;
-		}
-		set_bit(NFS_DELEGATED_STATE, &state->flags);
-		err = nfs4_handle_exception(server, err, &exception);
-	} while (exception.retry);
+	err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
+	switch (err) {
+		default:
+			printk(KERN_ERR "NFS: %s: unhandled error "
+				"%d.\n", __func__, err);
+		case 0:
+		case -ESTALE:
+			goto out;
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_STALE_STATEID:
+			set_bit(NFS_DELEGATED_STATE, &state->flags);
+		case -NFS4ERR_EXPIRED:
+			nfs4_schedule_lease_recovery(server->nfs_client);
+			return -EAGAIN;
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BAD_HIGH_SLOT:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_DEADSESSION:
+			set_bit(NFS_DELEGATED_STATE, &state->flags);
+			nfs4_schedule_session_recovery(server->nfs_client->cl_session, err);
+			return -EAGAIN;
+		case -NFS4ERR_DELEG_REVOKED:
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_OPENMODE:
+			nfs4_schedule_stateid_recovery(server, state);
+			return 0;
+		case -NFS4ERR_DELAY:
+		case -NFS4ERR_GRACE:
+			set_bit(NFS_DELEGATED_STATE, &state->flags);
+			ssleep(1);
+			return -EAGAIN;
+		case -ENOMEM:
+		case -NFS4ERR_DENIED:
+			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
+			return 0;
+	}
 out:
 	return err;
 }
-- 
1.8.1.4

