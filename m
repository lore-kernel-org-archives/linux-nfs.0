Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2824 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab2HHUWK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 16:22:10 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>,
        Fred Isaman <Fred.Isaman@netapp.com>
Subject: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
Date: Wed,  8 Aug 2012 16:21:50 -0400
Message-Id: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ever since commit 0a57cdac3f (NFSv4.1 send layoutreturn to fence
disconnected data server) we've been sending layoutreturn calls
while there is potentially still outstanding I/O to the data
servers. The reason we do this is to avoid races between replayed
writes to the MDS and the original writes to the DS.

When this happens, the BUG_ON() in nfs4_layoutreturn_done can
be triggered because it assumes that we would never call
layoutreturn without knowing that all I/O to the DS is
finished. The fix is to remove the BUG_ON() now that the
assumptions behind the test are obsolete.

Reported-by: Boaz Harrosh <bharrosh@panasas.com>
Reported-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org [>=3.5]
---
 fs/nfs/nfs4proc.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f94f6b3..c77d296 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6359,12 +6359,8 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		return;
 	}
 	spin_lock(&lo->plh_inode->i_lock);
-	if (task->tk_status == 0) {
-		if (lrp->res.lrs_present) {
-			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-		} else
-			BUG_ON(!list_empty(&lo->plh_segs));
-	}
+	if (task->tk_status == 0 && lrp->res.lrs_present)
+		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
 	dprintk("<-- %s\n", __func__);
-- 
1.7.11.2

