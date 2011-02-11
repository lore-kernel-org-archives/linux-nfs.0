Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17119 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757673Ab1BKQzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 11:55:00 -0500
Received: from localhost.localdomain (manjua-lxp.hq.netapp.com [10.58.49.248] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p1BGshZ7002533
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 08:54:46 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] wave4: nfs: rearrange nfs4_write_done
Date: Fri, 11 Feb 2011 11:54:36 -0500
Message-Id: <1297443279-19813-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add hook that layout driver can use to take control here.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |   14 ++++++++++----
 include/linux/nfs_xdr.h |    1 +
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a40a281..3952f7c 100644
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
@@ -3140,6 +3137,13 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
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
@@ -3149,6 +3153,8 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 		data->res.fattr = NULL;
 	} else
 		data->args.bitmask = server->cache_consistency_bitmask;
+	if (!data->write_done_cb)
+		data->write_done_cb = nfs4_write_done_cb;
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 726ec2a..23feaf6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1040,6 +1040,7 @@ struct nfs_write_data {
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
-- 
1.7.2.1

