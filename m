From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 3/5] nfs41: Retry delegation return if it failed with session error
Date: Mon,  7 Dec 2009 00:21:49 -0800
Message-ID: <1260174111-23160-4-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260174111-23160-3-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759111AbZLGI1o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:27:44 -0500
In-Reply-To: <1260174111-23160-3-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update nfs4_delegreturn_done() to retry the operation after setting the
NFS4CLNT_SESSION_SETUP bit to indicate the need to reset the session.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4proc.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a8861c..53b0a7d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3490,9 +3490,20 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 	nfs4_sequence_done(data->res.server, &data->res.seq_res,
 			task->tk_status);
 
-	data->rpc_status = task->tk_status;
-	if (data->rpc_status == 0)
+	switch (task->tk_status) {
+	case -NFS4ERR_STALE_STATEID:
+	case -NFS4ERR_EXPIRED:
+	case 0:
 		renew_lease(data->res.server, data->timestamp);
+		break;
+	default:
+		if (nfs4_async_handle_error(task, data->res.server, NULL) ==
+				-EAGAIN) {
+			nfs4_restart_rpc(task, data->res.server->nfs_client);
+			return;
+		}
+	}
+	data->rpc_status = task->tk_status;
 }
 
 static void nfs4_delegreturn_release(void *calldata)
-- 
1.5.4.3

