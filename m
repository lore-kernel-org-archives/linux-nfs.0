From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 15/19] SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 3
Date: Thu, 17 Jun 2010 10:50:53 -0400
Message-ID: <1276786253-12990-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11182 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932876Ab0FQOur (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:50:47 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_refresh_inode only for MDS commits.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2782900..95de256 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3298,7 +3298,8 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
-	nfs_refresh_inode(inode, data->res.fattr);
+	if (client == server->nfs_client)
+		nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
 
-- 
1.6.4.4

