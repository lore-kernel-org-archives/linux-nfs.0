Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36842 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622Ab2D0Vpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:34 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 07/13] NFSv4.1 remove nfs4_reset_write and nfs4_reset_read
Date: Fri, 27 Apr 2012 17:53:47 -0400
Message-Id: <1335563633-7191-8-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replaced by filelayout_reset_write and filelayout_reset_read

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h |    2 --
 fs/nfs/nfs4proc.c |   35 -----------------------------------
 2 files changed, 0 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f38e099..0397d2f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -383,13 +383,11 @@ void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
-extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
 extern int nfs4_init_client(struct nfs_client *clp,
 			    const struct rpc_timeout *timeparms,
 			    const char *ip_addr,
 			    rpc_authflavor_t authflavour,
 			    int noresvport);
-extern void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data);
 extern int _nfs4_call_sync(struct rpc_clnt *clnt,
 			   struct nfs_server *server,
 			   struct rpc_message *msg,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6365b02..bc9c2c9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3329,23 +3329,6 @@ static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_da
 	rpc_call_start(task);
 }
 
-/* Reset the the nfs_read_data to send the read to the MDS. */
-void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
-{
-	struct nfs_pgio_header *hdr = data->header;
-	struct inode *inode = hdr->inode;
-
-	dprintk("%s Reset task for i/o through\n", __func__);
-	data->ds_clp = NULL;
-	/* offsets will differ in the dense stripe case */
-	data->args.offset = data->mds_offset;
-	data->args.fh     = NFS_FH(inode);
-	data->read_done_cb = nfs4_read_done_cb;
-	task->tk_ops = hdr->mds_ops;
-	rpc_task_reset_client(task, NFS_CLIENT(inode));
-}
-EXPORT_SYMBOL_GPL(nfs4_reset_read);
-
 static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->header->inode;
@@ -3369,24 +3352,6 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 		nfs4_write_done_cb(task, data);
 }
 
-/* Reset the the nfs_write_data to send the write to the MDS. */
-void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data)
-{
-	struct nfs_pgio_header *hdr = data->header;
-	struct inode *inode = hdr->inode;
-
-	dprintk("%s Reset task for i/o through\n", __func__);
-	data->ds_clp     = NULL;
-	data->write_done_cb = nfs4_write_done_cb;
-	data->args.fh       = NFS_FH(inode);
-	data->args.bitmask  = data->res.server->cache_consistency_bitmask;
-	data->args.offset   = data->mds_offset;
-	data->res.fattr     = &data->fattr;
-	task->tk_ops        = hdr->mds_ops;
-	rpc_task_reset_client(task, NFS_CLIENT(inode));
-}
-EXPORT_SYMBOL_GPL(nfs4_reset_write);
-
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->header->inode);
-- 
1.7.6.4

