From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 04/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 1
Date: Thu, 17 Jun 2010 10:48:53 -0400
Message-ID: <1276786133-11891-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22045 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760144Ab0FQOsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:48:47 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

deviding into several patches to assist review

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c4f707f..a6bebbf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3144,6 +3144,11 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	dprintk("--> %s\n", __func__);
 
+#ifdef CONFIG_NFS_V4_1
+	if (data->pdata.pnfsflags & PNFS_NO_RPC)
+		return 0;
+#endif /* CONFIG_NFS_V4_1 */
+
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
 	if (nfs4_async_handle_error(task, server, data->args.context->state, NULL) == -EAGAIN) {
-- 
1.6.4.4

