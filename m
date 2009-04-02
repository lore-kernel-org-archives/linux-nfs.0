From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 57/67] nfs41: kick start nfs41 session recovery when handling errors
Date: Thu,  2 Apr 2009 16:58:40 +0300
Message-ID: <1238680720-15185-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30916 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756977AbZDBN7b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:31 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Remove checking for any errors that the SEQUENCE operation does not return.
-NFS4ERR_STALE_CLIENTID, NFS4ERR_EXPIRED, NFS4ERR_CB_PATH_DOWN, NFS4ERR_BACK_CHAN_BUSY, NFS4ERR_OP_NOT_IN_SESSION.

SEQUENCE operation error recovery is very primative, we only reset the session.

Remove checking for any errors that are returned by the SEQUENCE operation, but
that resetting the session won't address.
NFS4ERR_RETRY_UNCACHED_REP, NFS4ERR_SEQUENCE_POS,NFS4ERR_TOO_MANY_OPS.

Add error checking for missing SEQUENCE errors that a session reset will
address.
NFS4ERR_BAD_HIGH_SLOT, NFS4ERR_DEADSESSION, NFS4ERR_SEQ_FALSE_RETRY.

A reset of the session is currently our only response to a SEQUENCE operation
error. Don't reset the session on errors where a new session won't help.

Don't reset the session on errors where a new session won't help.

[nfs41: nfs4_async_handle_error update error checking]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: trigger the state manager for session reset]
    Replace session state bit with nfs_client state bit.  Set the
    NFS4CLNT_SESSION_SETUP bit upon a session related error in the sync/async
    error handlers.
[nfs41: _nfs4_async_handle_error fix session reset error list]
Sequence operation errors that session reset could help.
NFS4ERR_BADSESSION
NFS4ERR_BADSLOT
NFS4ERR_BAD_HIGH_SLOT
NFS4ERR_DEADSESSION
NFS4ERR_CONN_NOT_BOUND_TO_SESSION
NFS4ERR_SEQ_FALSE_RETRY
NFS4ERR_SEQ_MISORDERED

Sequence operation errors that a session reset would not help

NFS4ERR_BADXDR
NFS4ERR_DELAY
NFS4ERR_REP_TOO_BIG
NFS4ERR_REP_TOO_BIG_TO_CACHE
NFS4ERR_REQ_TOO_BIG
NFS4ERR_RETRY_UNCACHED_REP
NFS4ERR_SEQUENCE_POS
NFS4ERR_TOO_MANY_OPS

Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41 nfs4_handle_exception fix session reset error list]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[moved nfs41_sequece_call_done code to nfs41: sequence operation]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 984a13a..a9c5b00 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -249,7 +249,25 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			ret = nfs4_wait_clnt_recover(clp);
 			if (ret == 0)
 				exception->retry = 1;
+#if !defined(CONFIG_NFS_V4_1)
 			break;
+#else /* !defined(CONFIG_NFS_V4_1) */
+			if (!nfs4_has_session(server->nfs_client))
+				break;
+			/* FALLTHROUGH */
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BAD_HIGH_SLOT:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_DEADSESSION:
+		case -NFS4ERR_SEQ_FALSE_RETRY:
+		case -NFS4ERR_SEQ_MISORDERED:
+			dprintk("%s ERROR: %d Reset session\n", __func__,
+				errorcode);
+			set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+			exception->retry = 1;
+			/* FALLTHROUGH */
+#endif /* !defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
@@ -3256,6 +3274,20 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
 			task->tk_status = 0;
 			return -EAGAIN;
+#if defined(CONFIG_NFS_V4_1)
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BAD_HIGH_SLOT:
+		case -NFS4ERR_DEADSESSION:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_SEQ_FALSE_RETRY:
+		case -NFS4ERR_SEQ_MISORDERED:
+			dprintk("%s ERROR %d, Reset session\n", __func__,
+				task->tk_status);
+			set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+			task->tk_status = 0;
+			return -EAGAIN;
+#endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
 			if (server)
 				nfs_inc_server_stats(server, NFSIOS_DELAY);
-- 
1.6.2.1

