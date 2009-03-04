From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 37/46] nfs41: nfs41_call_sync_done
Date: Wed,  4 Mar 2009 02:00:36 +0200
Message-ID: <1236124836-3994-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17818
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751726AbZCDAAt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:00:49 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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

move adding nfs4_sequence_free_slot from nfs41-separate-free-slot-from-sequence-done

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9179508..f2fc8fe 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -535,8 +535,18 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
+static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs41_call_sync_data *data = calldata;
+	struct nfs_server *server = data->server;
+
+	nfs41_sequence_done(server->nfs_client, data->seq_res, task->tk_status);
+	nfs41_sequence_free_slot(server->nfs_client, data->seq_res);
+}
+
 struct rpc_call_ops nfs41_call_sync_ops = {
 	.rpc_call_prepare = nfs41_call_sync_prepare,
+	.rpc_call_done = nfs41_call_sync_done,
 };
 
 int _nfs4_call_sync_session(struct nfs_server *server,
-- 
1.6.1.3

