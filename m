From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 06/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 3
Date: Thu, 17 Jun 2010 10:49:15 -0400
Message-ID: <1276786155-12371-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:55964 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760144Ab0FQOtJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:49:09 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do not renew the data server lease.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 77b7182..e8b0f33 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3164,7 +3164,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	}
 
 	nfs_invalidate_atime(data->inode);
-	if (task->tk_status > 0)
+	if (task->tk_status > 0 && client == server->nfs_client)
 		renew_lease(server, data->timestamp);
 	return 0;
 }
-- 
1.6.4.4

