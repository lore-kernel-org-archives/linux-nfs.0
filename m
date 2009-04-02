From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 34/67] nfs41: nfs41_call_sync_done
Date: Thu,  2 Apr 2009 16:55:19 +0300
Message-ID: <1238680519-14465-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27255 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758342AbZDBNzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:55:25 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement nfs4.1 synchronous rpc_call_done method
that essentially just calls nfs4_sequence_done, that turns
around and calls nfs41_sequence_done for minorversion1 rpcs.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: check for session not minorversion]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[move adding nfs4_sequence_free_slot from nfs41-separate-free-slot-from-sequence-done]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs41_call_sync_data use nfs_client not nfs_server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dbc701b..2b481db 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -492,8 +492,17 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
+static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs41_call_sync_data *data = calldata;
+
+	nfs41_sequence_done(data->clp, data->seq_res, task->tk_status);
+	nfs41_sequence_free_slot(data->clp, data->seq_res);
+}
+
 struct rpc_call_ops nfs41_call_sync_ops = {
 	.rpc_call_prepare = nfs41_call_sync_prepare,
+	.rpc_call_done = nfs41_call_sync_done,
 };
 
 static int nfs4_call_sync_sequence(struct nfs_client *clp,
-- 
1.6.2.1

