Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45198 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab2LOUoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2012 15:44:32 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4.1: Try to deal with NFS4ERR_SEQ_MISORDERED.
Date: Sat, 15 Dec 2012 15:44:24 -0500
Message-Id: <1355604266-21183-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server returns NFS4ERR_SEQ_MISORDERED, it could be a sign
that the slot was retired at some point. Retry the attempt after
reinitialising the slot sequence number to 1.

Also add a handler for NFS4ERR_SEQ_FALSE_RETRY. Just bump the slot
sequence number and retry...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b0963ae..9003b8f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -467,11 +467,19 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * The slot id we used was probably retired. Try again
 		 * using a different slot id.
 		 */
-		if (rpc_restart_call_prepare(task)) {
-			task->tk_status = 0;
-			ret = 0;
-		}
-		break;
+		goto retry_nowait;
+	case -NFS4ERR_SEQ_MISORDERED:
+		/*
+		 * Could this slot have been previously retired?
+		 * If so, then the server may be expecting seq_nr = 1!
+		 */
+		if (slot->seq_nr == 1)
+			break;
+		slot->seq_nr = 1;
+		goto retry_nowait;
+	case -NFS4ERR_SEQ_FALSE_RETRY:
+		++slot->seq_nr;
+		goto retry_nowait;
 	default:
 		/* Just update the slot sequence no. */
 		++slot->seq_nr;
@@ -481,6 +489,12 @@ out:
 	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
 	nfs41_sequence_free_slot(res);
 	return ret;
+retry_nowait:
+	if (rpc_restart_call_prepare(task)) {
+		task->tk_status = 0;
+		ret = 0;
+	}
+	goto out;
 out_retry:
 	if (!rpc_restart_call(task))
 		goto out;
-- 
1.7.11.7

