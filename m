Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:54936 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755497AbdDGSQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:05 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 16/34] NFS: Clean up nfs42_layoutstat_done()
Date: Fri, 7 Apr 2017 14:15:10 -0400
Message-ID: <20170407181528.2832-17-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 1e486c73ec94..c81c61971625 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -400,8 +400,6 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 	case -EOPNOTSUPP:
 		NFS_SERVER(inode)->caps &= ~NFS_CAP_LAYOUTSTATS;
 	}
-
-	dprintk("%s server returns %d\n", __func__, task->tk_status);
 }
 
 static void
-- 
2.12.2

