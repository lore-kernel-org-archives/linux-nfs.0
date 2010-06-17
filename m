From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 08/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 1
Date: Thu, 17 Jun 2010 10:49:37 -0400
Message-ID: <1276786177-12470-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18074 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756240Ab0FQOtb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:49:31 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

restore original count after retry.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a0ab6c..5948de5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3271,7 +3271,16 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
-	
+
+#ifdef CONFIG_NFS_V4_1
+	/* restore original count after retry? */
+	if (data->pdata.orig_count) {
+		dprintk("%s: restoring original count %u\n", __func__,
+			data->pdata.orig_count);
+		data->args.count = data->pdata.orig_count;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
 
-- 
1.6.4.4

