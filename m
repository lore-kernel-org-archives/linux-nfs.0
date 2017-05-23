Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35725 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968302AbdEWOyp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:54:45 -0400
Subject: [PATCH v1 08/12] NFSv4.1: Handle EXCHGID4_FLAG_CONFIRMED_R during
 NFSv4.1 migration
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 May 2017 10:54:43 -0400
Message-ID: <20170523145442.961.53875.stgit@manet.1015granger.net>
In-Reply-To: <20170523142629.961.81233.stgit@manet.1015granger.net>
References: <20170523142629.961.81233.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Transparent State Migration copies a client's lease state from the
server where a filesystem used to reside to the server where it now
resides. When an NFSv4.1 client first contacts that destination
server, it uses EXCHANGE_ID to detect trunking relationships.

The lease that was copied there is returned to that client, but the
destination server sets EXCHGID4_FLAG_CONFIRMED_R when replying to
the client. This is because the lease was confirmed on the source
server (before it was copied).

Normally, when CONFIRMED_R is set, a client purges the lease and
creates a new one. However, that throws away the entire benefit of
Transparent State Migration.

Therefore, the client must not purge that lease, and it must use the
contrived slot sequence value returned by the destination for its
first CREATE_SESSION operation.

Reported-by: Xuan Qi <xuan.qi@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c  |    2 +-
 fs/nfs/nfs4state.c |   11 +++++++++--
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c08c46a..54e561a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7375,11 +7375,11 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
 	if (status == 0) {
 		clp->cl_clientid = cdata->res.clientid;
 		clp->cl_exchange_flags = cdata->res.flags;
+		clp->cl_seqid = cdata->res.seqid;
 		/* Client ID is not confirmed */
 		if (!(cdata->res.flags & EXCHGID4_FLAG_CONFIRMED_R)) {
 			clear_bit(NFS4_SESSION_ESTABLISHED,
 			&clp->cl_session->session_state);
-			clp->cl_seqid = cdata->res.seqid;
 		}
 
 		kfree(clp->cl_serverowner);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b34de03..1b8a848 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -341,6 +341,7 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 				   struct rpc_cred *cred)
 {
 	int status;
+	bool tsm;
 
 	status = nfs4_proc_exchange_id(clp, cred);
 	if (status != NFS4_OK)
@@ -352,8 +353,14 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 	if (clp != *result)
 		return 0;
 
-	/* Purge state if the client id was established in a prior instance */
-	if (clp->cl_exchange_flags & EXCHGID4_FLAG_CONFIRMED_R)
+	/*
+	 * Purge state if the client id was established in a prior
+	 * instance and the client id could not have arrived on the
+	 * server via Transparent State Migration.
+	 */
+	tsm = test_bit(NFS4CLNT_MOVED, &clp->cl_state) ||
+	      test_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state);
+	if (clp->cl_exchange_flags & EXCHGID4_FLAG_CONFIRMED_R && !tsm)
 		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
 	else
 		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);

