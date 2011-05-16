Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25945 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755561Ab1EPO3X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 10:29:23 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: revert useless change in nfs4_write_done_cb
Date: Mon, 16 May 2011 07:29:16 -0700
Message-Id: <1305556156-29923-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DCC71DF.3080701@panasas.com>
References: <4DCC71DF.3080701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index da51abe..ef8cf76 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3210,7 +3210,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 	}
 	if (task->tk_status >= 0) {
 		renew_lease(NFS_SERVER(inode), data->timestamp);
-		nfs_post_op_update_inode_force_wcc(data->inode, data->res.fattr);
+		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
 	}
 	return 0;
 }
-- 
1.7.3.4

