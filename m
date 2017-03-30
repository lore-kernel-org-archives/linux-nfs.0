Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:57945 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933107AbdC3OKz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Mar 2017 10:10:55 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] PNFS fix fallback to MDS if got error on commit to DS
Date: Thu, 30 Mar 2017 10:10:55 -0400
Message-ID: <20170330141055.61977-1-kolga@netapp.com>
In-Reply-To: <CAN-5tyG5s1B25WShf5HJ0DkYLpM7oQ1OiZO+zvg892yZ=68NoQ@mail.gmail.com>
References: <CAN-5tyG5s1B25WShf5HJ0DkYLpM7oQ1OiZO+zvg892yZ=68NoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upong receiving some errors (EACCES) on commit to the DS the code
doesn't fallback to MDS and intead retrieds to the same DS again.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index a3fc48b..59e1efa 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -202,10 +202,10 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 			task->tk_status);
 		nfs4_mark_deviceid_unavailable(devid);
 		pnfs_error_mark_layout_for_return(inode, lseg);
-		pnfs_set_lo_fail(lseg);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
+		pnfs_set_lo_fail(lseg);
 reset:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
-- 
1.8.3.1

