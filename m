From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFSv41: Fix a potential state leakage when restarting
 nfs4_close_prepare
Date: Mon, 07 Dec 2009 16:47:44 -0500
Message-ID: <1260222464.2934.7.camel@localhost>
References: <1260211012.32136.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48615 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965072AbZLGVri convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 16:47:38 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB7LljEB014113
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 13:47:45 -0800 (PST)
In-Reply-To: <1260211012.32136.48.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Currently, if the call to nfs4_setup_sequence() in nfs4_close_prepare
fails, any later retries will fail to launch an RPC call, due to the fact
that the &state->flags will have been cleared.
Ditto if nfs4_close_done() triggers a call to the NFSv4.1 version of
nfs_restart_rpc().

We therefore move the actual clearing of the state->flags to
nfs4_close_done(), when we know that the RPC call was successful.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |   49 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 32 insertions(+), 17 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cdf17d6..4700898 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -761,13 +761,13 @@ static int can_open_cached(struct nfs4_state *state, fmode_t mode, int open_mode
 		goto out;
 	switch (mode & (FMODE_READ|FMODE_WRITE)) {
 		case FMODE_READ:
-			ret |= test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0;
+			ret |= state->n_rdonly != 0;
 			break;
 		case FMODE_WRITE:
-			ret |= test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0;
+			ret |= state->n_wronly != 0;
 			break;
 		case FMODE_READ|FMODE_WRITE:
-			ret |= test_bit(NFS_O_RDWR_STATE, &state->flags) != 0;
+			ret |= state->n_rdwr != 0;
 	}
 out:
 	return ret;
@@ -1711,6 +1711,18 @@ static void nfs4_free_closedata(void *data)
 	kfree(calldata);
 }
 
+static void nfs4_close_clear_stateid_flags(struct nfs4_state *state,
+		fmode_t fmode)
+{
+	spin_lock(&state->owner->so_lock);
+	if (!(fmode & FMODE_READ))
+		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
+	if (!(fmode & FMODE_WRITE))
+		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+	clear_bit(NFS_O_RDWR_STATE, &state->flags);
+	spin_unlock(&state->owner->so_lock);
+}
+
 static void nfs4_close_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_closedata *calldata = data;
@@ -1727,6 +1739,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 		case 0:
 			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
+			nfs4_close_clear_stateid_flags(state,
+					calldata->arg.fmode);
 			break;
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_OLD_STATEID:
@@ -1747,38 +1761,39 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state *state = calldata->state;
-	int clear_rd, clear_wr, clear_rdwr;
+	int call_close = 0;
 
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		return;
 
-	clear_rd = clear_wr = clear_rdwr = 0;
+	task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
+	calldata->arg.fmode = FMODE_READ|FMODE_WRITE;
 	spin_lock(&state->owner->so_lock);
 	/* Calculate the change in open mode */
 	if (state->n_rdwr == 0) {
 		if (state->n_rdonly == 0) {
-			clear_rd |= test_and_clear_bit(NFS_O_RDONLY_STATE, &state->flags);
-			clear_rdwr |= test_and_clear_bit(NFS_O_RDWR_STATE, &state->flags);
+			call_close |= test_bit(NFS_O_RDONLY_STATE, &state->flags);
+			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
+			calldata->arg.fmode &= ~FMODE_READ;
 		}
 		if (state->n_wronly == 0) {
-			clear_wr |= test_and_clear_bit(NFS_O_WRONLY_STATE, &state->flags);
-			clear_rdwr |= test_and_clear_bit(NFS_O_RDWR_STATE, &state->flags);
+			call_close |= test_bit(NFS_O_WRONLY_STATE, &state->flags);
+			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
+			calldata->arg.fmode &= ~FMODE_WRITE;
 		}
 	}
 	spin_unlock(&state->owner->so_lock);
-	if (!clear_rd && !clear_wr && !clear_rdwr) {
+
+	if (!call_close) {
 		/* Note: exit _without_ calling nfs4_close_done */
 		task->tk_action = NULL;
 		return;
 	}
+
+	if (calldata->arg.fmode == 0)
+		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
+
 	nfs_fattr_init(calldata->res.fattr);
-	if (test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0) {
-		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
-		calldata->arg.fmode = FMODE_READ;
-	} else if (test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0) {
-		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
-		calldata->arg.fmode = FMODE_WRITE;
-	}
 	calldata->timestamp = jiffies;
 	if (nfs4_setup_sequence((NFS_SERVER(calldata->inode))->nfs_client,
 				&calldata->arg.seq_args, &calldata->res.seq_res,

