From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 13/19] SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 1
Date: Thu, 17 Jun 2010 10:50:31 -0400
Message-ID: <1276786231-12738-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9529 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932833Ab0FQOuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:50:25 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PNFS_NO_RPC

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5c1e680..8b88cf2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3279,6 +3279,11 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
+#ifdef CONFIG_NFS_V4_1
+	if (data->pdata.pnfsflags & PNFS_NO_RPC)
+		return 0;
+#endif /* CONFIG_NFS_V4_1 */
+
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL, NULL) == -EAGAIN) {
-- 
1.6.4.4

