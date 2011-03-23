Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20886 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445Ab1CWMai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 08:30:38 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/11] NFSv4.1: add callback to nfs4_commit_done
Date: Wed, 23 Mar 2011 08:30:04 -0400
Message-Id: <1300883412-32296-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
References: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add a callback that the pnfs layout driver can use to do its own
error handling of the data server's COMMIT response.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1d84e70..bcc29bd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3195,12 +3195,9 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
 }
 
-static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
+static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
-	
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
-		return -EAGAIN;
 
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
@@ -3210,11 +3207,20 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
+static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
+{
+	if (!nfs4_sequence_done(task, &data->res.seq_res))
+		return -EAGAIN;
+	return data->write_done_cb(task, data);
+}
+
 static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 	
 	data->args.bitmask = server->cache_consistency_bitmask;
+	if (!data->write_done_cb)
+		data->write_done_cb = nfs4_commit_done_cb;
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 }
-- 
1.7.2.1

