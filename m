Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:58823 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbaIWG42 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 02:56:28 -0400
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 1/2] nfsd: fix nfsd4_cb_recall_done error handling
Date: Tue, 23 Sep 2014 08:58:48 +0200
Message-Id: <1411455529-11556-2-git-send-email-hch@lst.de>
In-Reply-To: <1411455529-11556-1-git-send-email-hch@lst.de>
References: <1411455529-11556-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For any error that is not EBADHANDLE or NFS4ERR_BAD_STATEID,
nfsd4_cb_recall_done first marks the connection down, then
retries until dl_retries hits zero, then marks the connection down
again and sets cb_done.  This changes the code to only retry
for EBADHANDLE or NFS4ERR_BAD_STATEID, and factors setting
cb_done into a single point in the function.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index e0be57b..795e218 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -874,24 +874,21 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
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

