From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] pnfsd: reset status on NFS4ERR_NOMATCHING_LAYOUT
Date: Fri, 18 Jun 2010 17:03:44 -0400
Message-ID: <1276895024-29925-1-git-send-email-bhalevy@panasas.com>
References: <4C1BDE45.6020806@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18281 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752299Ab0FRVDf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 17:03:35 -0400
In-Reply-To: <4C1BDE45.6020806@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Although it's encoded as an error on the protocol level
it's actualy a success, just short circuited.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 950e303..f3b5015 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1049,6 +1049,7 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
 		rpc_restart_call(task);
 		break;
 	case -NFS4ERR_NOMATCHING_LAYOUT:
+		task->tk_status = 0;
 		nomatching_layout(clr);
 	}
 }
-- 
1.6.4.4

