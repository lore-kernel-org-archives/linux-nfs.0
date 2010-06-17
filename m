From: andros@netapp.com
Subject: [PATCH 2/7] SQUASHNE pnfs-submit: remove cleanup_layoutcommit
Date: Thu, 17 Jun 2010 15:34:51 -0400
Message-ID: <1276803296-9438-3-git-send-email-andros@netapp.com>
References: <1276803296-9438-1-git-send-email-andros@netapp.com>
 <1276803296-9438-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56787 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759849Ab0FQTfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 15:35:32 -0400
In-Reply-To: <1276803296-9438-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Not used by the file layout driver

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |    4 ++--
 fs/nfs/pnfs.c             |   24 ------------------------
 fs/nfs/pnfs.h             |    1 -
 include/linux/nfs4_pnfs.h |    3 ---
 4 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c7d68f5..1269689 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5638,7 +5638,7 @@ static int pnfs4_sync_layoutcommit(struct pnfs_layoutcommit_data *data)
 	} while (exception.retry);
 
 	data->status = err;
-	pnfs_layoutcommit_done(data);
+	put_rpccred(data->cred);
 	pnfs_layoutcommit_free(data);
 	return err;
 }
@@ -5663,7 +5663,7 @@ pnfs_layoutcommit_rpc_done(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(data->args.inode);
 
 	data->status = task->tk_status;
-	pnfs_layoutcommit_done(data);
+	put_rpccred(data->cred);
 
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 96e8b5b..e19e9be 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1554,30 +1554,6 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	return trypnfs;
 }
 
-/* Called on completion of layoutcommit */
-void
-pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
-{
-	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
-	struct nfs_inode *nfsi = NFS_I(data->args.inode);
-
-	dprintk("%s: (status %d)\n", __func__, data->status);
-
-	if (data->status < 0)
-		printk(KERN_ERR "%s, Layoutcommit Failed! = %d\n",
-		       __func__, data->status);
-
-	/* TODO: Maybe we should avoid this by allowing the layout driver
-	 * to directly xdr its layout on the wire.
-	 */
-	if (nfss->pnfs_curr_ld->ld_io_ops->cleanup_layoutcommit)
-		nfss->pnfs_curr_ld->ld_io_ops->cleanup_layoutcommit(
-							&nfsi->layout,
-							&data->args,
-							data->status);
-	put_rpccred(data->cred);
-}
-
 /*
  * Set up the argument/result storage required for the RPC call.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e802cec..07552d5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -47,7 +47,6 @@ enum pnfs_try_status _pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 int pnfs_initialize(void);
 void pnfs_uninitialize(void);
-void pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data);
 void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index b635573..1831308 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -157,9 +157,6 @@ struct layoutdriver_io_operations {
 	void (*encode_layoutcommit) (struct pnfs_layout_type *layoutid,
 				     struct xdr_stream *xdr,
 				     const struct pnfs_layoutcommit_arg *args);
-	void (*cleanup_layoutcommit) (struct pnfs_layout_type *layoutid,
-				      struct pnfs_layoutcommit_arg *args,
-				      int status);
 	void (*encode_layoutreturn) (struct pnfs_layout_type *layoutid,
 				struct xdr_stream *xdr,
 				const struct nfs4_pnfs_layoutreturn_arg *args);
-- 
1.6.6

