From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 6/6] nfsd4: fix delegation recall race use-after-free
Date: Thu, 24 Jun 2010 12:29:10 -0400
Message-ID: <1277396950-18298-7-git-send-email-bfields@citi.umich.edu>
References: <1277396950-18298-1-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-2-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-3-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-4-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-5-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-6-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52623 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756054Ab0FXQ3L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jun 2010 12:29:11 -0400
In-Reply-To: <1277396950-18298-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the rarely-used callback-connection-changing setclientid occurs
simultaneously with a delegation recall, we rerun the recall by
requeueing it on a workqueue.  But we also need to take a reference on
the delegation in that case, since the delegation held by the rpc itself
will be released by the rpc_release callback.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a468632..1e6497e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -689,6 +689,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		warn_no_callback_path(clp, task->tk_status);
 		if (current_rpc_client != task->tk_client) {
 			/* queue a callback on the new connection: */
+			atomic_inc(&dp->dl_count);
 			nfsd4_cb_recall(dp);
 			return;
 		}
-- 
1.7.0.4

