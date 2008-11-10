From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 30/85] nfs41: nfs41_call_sync_done
Date: Mon, 10 Nov 2008 22:23:27 +0200
Message-ID: <1226348607-8220-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48788 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbYKJUXe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:23:34 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement nfs4.1 synchronous rpc_call_done method
that essentially just calls nfs4_sequence_done, that turns
around and calls nfs41_sequence_done for minorversion1 rpcs.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 217f891..5d9ca20 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -489,8 +489,17 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
+static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs41_call_sync_data *data = calldata;
+	struct nfs_server *server = data->server;
+
+	nfs41_sequence_done(server->nfs_client, data->seq_res, task->tk_status);
+}
+
 struct rpc_call_ops nfs41_call_sync_ops = {
 	.rpc_call_prepare = nfs41_call_sync_prepare,
+	.rpc_call_done = nfs41_call_sync_done,
 };
 
 #endif /* CONFIG_NFS_V4_1 */
@@ -537,6 +546,15 @@ static int _nfs4_call_sync(struct nfs_server *server,
        _nfs4_call_sync((server), (msg), &(args)->seq_args, \
                        &(res)->seq_res, (cache_reply))
 
+static void nfs4_sequence_done(const struct nfs_server *server,
+			       struct nfs41_sequence_res *res, int rpc_status)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (server->nfs_client->cl_minorversion)
+		nfs41_sequence_done(server->nfs_client, res, rpc_status);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
-- 
1.6.0.2

