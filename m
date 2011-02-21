Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43653 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752497Ab1BURtm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Feb 2011 12:49:42 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/7] NFSv4.1: add callback to nfs4_write_done
Date: Mon, 21 Feb 2011 12:49:31 -0500
Message-Id: <1298310576-13523-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
References: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add callback that pnfs layout driver can use to do its own handling
of data server WRITE response.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |   14 ++++++++++----
 include/linux/nfs_xdr.h |    1 +
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f91e259..bfdd36a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3122,13 +3122,10 @@ void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 }
 EXPORT_SYMBOL_GPL(nfs4_reset_read);
 
-static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
+static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
-		return -EAGAIN;
-
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
@@ -3140,11 +3137,20 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
+static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
+{
+	if (!nfs4_sequence_done(task, &data->res.seq_res))
+		return -EAGAIN;
+	return data->write_done_cb(task, data);
+}
+
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
 	data->args.bitmask = server->cache_consistency_bitmask;
+	if (!data->write_done_cb)
+		data->write_done_cb = nfs4_write_done_cb;
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index eb0e870..21cd41d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1038,6 +1038,7 @@ struct nfs_write_data {
 	unsigned int		npages;		/* Max length of pagevec */
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
+	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
-- 
1.7.2.1

