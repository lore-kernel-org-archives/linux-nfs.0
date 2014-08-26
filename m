Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35463 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755379AbaHZCqb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2014 22:46:31 -0400
Received: by mail-ie0-f176.google.com with SMTP id tr6so10875588ieb.21
        for <linux-nfs@vger.kernel.org>; Mon, 25 Aug 2014 19:46:30 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Fix problems with close in the presence of a delegation
Date: Mon, 25 Aug 2014 22:46:31 -0400
Message-Id: <1409021192-12706-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the presence of delegations, we can no longer assume that the
state->n_rdwr, state->n_rdonly, state->n_wronly reflect the open
stateid share mode, and so we need to need to calculate the initial
value for calldata->arg.fmode using the state->flags.

Fixes: 88069f77e1ac5 (NFSv41: Fix a potential state leakage when...)
Cc: stable@vger.kernel.org # 2.6.33+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75ae8d22f067..caf838b4edbd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2601,6 +2601,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state *state = calldata->state;
 	struct inode *inode = calldata->inode;
+	bool is_rdonly, is_wronly, is_rdwr;
 	int call_close = 0;
 
 	dprintk("%s: begin!\n", __func__);
@@ -2608,18 +2609,23 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		goto out_wait;
 
 	task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
-	calldata->arg.fmode = FMODE_READ|FMODE_WRITE;
+	calldata->arg.fmode = 0;
 	spin_lock(&state->owner->so_lock);
 	/* Calculate the change in open mode */
+	is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
+	is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
+	is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
+	if (is_rdonly || is_rdwr)
+		calldata->arg.fmode |= FMODE_READ;
+	if (is_wronly || is_rdwr)
+		calldata->arg.fmode |= FMODE_WRITE;
 	if (state->n_rdwr == 0) {
 		if (state->n_rdonly == 0) {
-			call_close |= test_bit(NFS_O_RDONLY_STATE, &state->flags);
-			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
+			call_close |= is_rdonly || is_rdwr;
 			calldata->arg.fmode &= ~FMODE_READ;
 		}
 		if (state->n_wronly == 0) {
-			call_close |= test_bit(NFS_O_WRONLY_STATE, &state->flags);
-			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
+			call_close |= is_wronly || is_rdwr;
 			calldata->arg.fmode &= ~FMODE_WRITE;
 		}
 	}
-- 
1.9.3

