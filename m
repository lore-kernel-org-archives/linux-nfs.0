From: andros@netapp.com
Subject: [PATCH 03/11] nfs41: nfs4_get_lease_time will never session reset
Date: Fri,  4 Dec 2009 15:25:38 -0500
Message-ID: <1259958347-9031-4-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757170AbZLDUZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:54 -0500
In-Reply-To: <1259958347-9031-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Make this clear by calling rpc_restart-call.
Prepare for nfs4_restart_rpc() to free slots.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e13d53..979d2e3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4389,7 +4389,7 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 		dprintk("%s Retry: tk_status %d\n", __func__, task->tk_status);
 		rpc_delay(task, NFS4_POLL_RETRY_MIN);
 		task->tk_status = 0;
-		nfs4_restart_rpc(task, data->clp);
+		rpc_restart_call(task);
 		return;
 	}
 	nfs41_sequence_free_slot(data->clp, &data->res->lr_seq_res);
-- 
1.6.0.6

