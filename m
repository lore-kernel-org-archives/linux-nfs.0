From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 09/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 2
Date: Thu, 17 Jun 2010 10:49:47 -0400
Message-ID: <1276786187-12514-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34569 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755793Ab0FQOtl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:49:41 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PNFS_NO_RPC.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5948de5..fd2b588 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3279,6 +3279,9 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 			data->pdata.orig_count);
 		data->args.count = data->pdata.orig_count;
 	}
+
+	if (data->pdata.pnfsflags & PNFS_NO_RPC)
+		return 0;
 #endif /* CONFIG_NFS_V4_1 */
 
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
-- 
1.6.4.4

