From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 36/67] nfs41: open sequence setup/done support
Date: Thu,  2 Apr 2009 16:55:29 +0300
Message-ID: <1238680529-14528-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32833 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754186AbZDBNzs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:55:48 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate nfs4_open calls from nfs41: sequence setup/done support
Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
[use nfs4_sequence_done_free_slot]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 638dea9..8654a96 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1241,6 +1241,10 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
+	if (nfs4_setup_sequence(data->o_arg.server->nfs_client,
+				&data->o_arg.seq_args,
+				&data->o_res.seq_res, 1, task))
+		return;
 	rpc_call_start(task);
 	return;
 out_no_action:
@@ -1253,6 +1257,10 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 	struct nfs4_opendata *data = calldata;
 
 	data->rpc_status = task->tk_status;
+
+	nfs4_sequence_done_free_slot(data->o_arg.server, &data->o_res.seq_res,
+				     task->tk_status);
+
 	if (RPC_ASSASSINATED(task))
 		return;
 	if (task->tk_status == 0) {
-- 
1.6.2.1

