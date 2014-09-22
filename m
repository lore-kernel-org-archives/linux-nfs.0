Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33670 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbaIVS3X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2014 14:29:23 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XW8MV-0007Ps-Ex
	for linux-nfs@vger.kernel.org; Mon, 22 Sep 2014 18:29:23 +0000
Date: Mon, 22 Sep 2014 11:29:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH, RFC] nfsd: fix nfsd4_cb_recall_done error handling
Message-ID: <20140922182923.GA18904@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The error handling for CB_RECALL seems fairly broken to me.

What looks good:

 - for EBADHANDLE and NFS4ERR_BAD_STATEID retry until dl_retries
   hits zero, then mark the connection down and set cb_done

What looks wrong:

 - for everything else we first mark the connection down, then
   retry until dl_retries hits zero, then mark the connection down
   again  and set cb_done.

>From all I can see what we want is:

 - keep the behavior for EBADHANDLE and NFS4ERR_BAD_STATEID,
   otherwise jump straight to making the connection down
   and setting cb_done

But maybe I'm missing something?


diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 17d5441..ed25c58 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -971,24 +971,21 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		return;
 	switch (task->tk_status) {
 	case 0:
-		cb->cb_done = true;
-		return;
+		break;
 	case -EBADHANDLE:
 	case -NFS4ERR_BAD_STATEID:
 		/* Race: client probably got cb_recall
 		 * before open reply granting delegation */
-		break;
+		if (dp->dl_retries--) {
+			rpc_delay(task, 2*HZ);
+			task->tk_status = 0;
+			rpc_restart_call_prepare(task);
+			return;
+		}
 	default:
 		/* Network partition? */
 		nfsd4_mark_cb_down(clp, task->tk_status);
 	}
-	if (dp->dl_retries--) {
-		rpc_delay(task, 2*HZ);
-		task->tk_status = 0;
-		rpc_restart_call_prepare(task);
-		return;
-	}
-	nfsd4_mark_cb_down(clp, task->tk_status);
 	cb->cb_done = true;
 }
 
-- 
1.9.1

