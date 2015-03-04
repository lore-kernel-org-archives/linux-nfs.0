Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:44329 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756076AbbCDCyI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 21:54:08 -0500
Received: by igdh15 with SMTP id h15so33565570igd.3
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 18:54:07 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Jorge Mora <Jorge.Mora@netapp.com>
Subject: [PATCH 2/2] NFSv4.1: Clear the old state by our client id before establishing a new lease
Date: Tue,  3 Mar 2015 21:54:03 -0500
Message-Id: <1425437643-76439-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1425437643-76439-1-git-send-email-trond.myklebust@primarydata.com>
References: <1425437643-76439-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the call to exchange-id returns with the EXCHGID4_FLAG_CONFIRMED_R flag
set, then that means our lease was established by a previous mount instance.
Ensure that we detect this situation, and that we clear the state held by
that mount.

Reported-by: Jorge Mora <Jorge.Mora@netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c    | 15 +++++++++++----
 fs/nfs/nfs4session.h |  1 +
 fs/nfs/nfs4state.c   |  6 +++++-
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 732526e04cd5..627f37c44456 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6897,9 +6897,13 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 
 	if (status == 0) {
 		clp->cl_clientid = res.clientid;
-		clp->cl_exchange_flags = (res.flags & ~EXCHGID4_FLAG_CONFIRMED_R);
-		if (!(res.flags & EXCHGID4_FLAG_CONFIRMED_R))
+		clp->cl_exchange_flags = res.flags;
+		/* Client ID is not confirmed */
+		if (!(res.flags & EXCHGID4_FLAG_CONFIRMED_R)) {
+			clear_bit(NFS4_SESSION_ESTABLISHED,
+					&clp->cl_session->session_state);
 			clp->cl_seqid = res.seqid;
+		}
 
 		kfree(clp->cl_serverowner);
 		clp->cl_serverowner = res.server_owner;
@@ -7231,6 +7235,9 @@ static void nfs4_update_session(struct nfs4_session *session,
 		struct nfs41_create_session_res *res)
 {
 	nfs4_copy_sessionid(&session->sess_id, &res->sessionid);
+	/* Mark client id and session as being confirmed */
+	session->clp->cl_exchange_flags |= EXCHGID4_FLAG_CONFIRMED_R;
+	set_bit(NFS4_SESSION_ESTABLISHED, &session->session_state);
 	session->flags = res->flags;
 	memcpy(&session->fc_attrs, &res->fc_attrs, sizeof(session->fc_attrs));
 	if (res->flags & SESSION4_BACK_CHAN)
@@ -7326,8 +7333,8 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
 	dprintk("--> nfs4_proc_destroy_session\n");
 
 	/* session is still being setup */
-	if (session->clp->cl_cons_state != NFS_CS_READY)
-		return status;
+	if (!test_and_clear_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
+		return 0;
 
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	trace_nfs4_destroy_session(session->clp, status);
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index fc46c7455898..e3ea2c5324d6 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -70,6 +70,7 @@ struct nfs4_session {
 
 enum nfs4_session_state {
 	NFS4_SESSION_INITING,
+	NFS4_SESSION_ESTABLISHED,
 };
 
 extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d8b43f0e08fc..f95e3b58bbc3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -353,7 +353,11 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 	if (clp != *result)
 		return 0;
 
-	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+	/* Purge state if the client id was established in a prior instance */
+	if (clp->cl_exchange_flags & EXCHGID4_FLAG_CONFIRMED_R)
+		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
+	else
+		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 	nfs4_schedule_state_manager(clp);
 	status = nfs_wait_client_init_complete(clp);
 	if (status < 0)
-- 
2.1.0

