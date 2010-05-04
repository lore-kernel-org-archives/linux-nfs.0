From: andros@netapp.com
Subject: [PATCH 1/1] SQUASHME pnfs: restore state recovery in async handler
Date: Tue,  4 May 2010 17:54:06 -0400
Message-ID: <1273010046-9015-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31311 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754465Ab0EDVyh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 17:54:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For some reason, the call to nfs4_schedule_state_recovery was removed from
the pNFS git trees, but is present in the straight 2.6.34-rcX kernels.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4b3bd81..43dab3c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3694,6 +3694,7 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			dprintk("%s ERROR %d, Reset session. Exchangeid "
 				"flags 0x%x\n", __func__, task->tk_status,
 				clp->cl_exchange_flags);
+			nfs4_schedule_state_recovery(clp);
 			task->tk_status = 0;
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.6

