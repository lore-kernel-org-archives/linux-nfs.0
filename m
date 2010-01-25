From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 8/8] NFS: Ensure that we handle NFS4ERR_STALE_STATEID
 correctly
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.16079.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8049 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776Ab0AYWEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:11 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM4B7X014304
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:11 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Even if the server is crazy, we should be able to mark the stateid as being
bad, to ensure it gets recovered.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |   44 +++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4state.c |    2 +-
 3 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ea2f41b..0c6fda3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -278,6 +278,7 @@ extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
+extern int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index afbfe67..375f0fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -249,14 +249,14 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			if (state == NULL)
 				break;
 			nfs4_state_mark_reclaim_nograce(clp, state);
-		case -NFS4ERR_STALE_CLIENTID:
+			goto do_state_recovery;
 		case -NFS4ERR_STALE_STATEID:
+			if (state == NULL)
+				break;
+			nfs4_state_mark_reclaim_reboot(clp, state);
+		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_EXPIRED:
-			nfs4_schedule_state_recovery(clp);
-			ret = nfs4_wait_clnt_recover(clp);
-			if (ret == 0)
-				exception->retry = 1;
-			break;
+			goto do_state_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -289,6 +289,12 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 	}
 	/* We failed to handle the error */
 	return nfs4_map_errors(ret);
+do_state_recovery:
+	nfs4_schedule_state_recovery(clp);
+	ret = nfs4_wait_clnt_recover(clp);
+	if (ret == 0)
+		exception->retry = 1;
+	return ret;
 }
 
 
@@ -3420,15 +3426,14 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			if (state == NULL)
 				break;
 			nfs4_state_mark_reclaim_nograce(clp, state);
-		case -NFS4ERR_STALE_CLIENTID:
+			goto do_state_recovery;
 		case -NFS4ERR_STALE_STATEID:
+			if (state == NULL)
+				break;
+			nfs4_state_mark_reclaim_reboot(clp, state);
+		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_EXPIRED:
-			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
-			nfs4_schedule_state_recovery(clp);
-			if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
-				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto do_state_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -3456,6 +3461,13 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
+do_state_recovery:
+	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
+	nfs4_schedule_state_recovery(clp);
+	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
+		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+	task->tk_status = 0;
+	return -EAGAIN;
 }
 
 static int
@@ -4099,6 +4111,12 @@ static void nfs4_handle_setlk_error(struct nfs_server *server, struct nfs4_lock_
 		   (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
 			nfs4_state_mark_reclaim_nograce(clp, state);
 		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
+		break;
+	case -NFS4ERR_STALE_STATEID:
+		if (new_lock_owner != 0 ||
+		    (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
+			nfs4_state_mark_reclaim_reboot(clp, state);
+		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
 	};
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6d263ed..c1e2733 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -901,7 +901,7 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 	nfs4_schedule_state_manager(clp);
 }
 
-static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
+int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
 
 	set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);

