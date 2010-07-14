From: andros@netapp.com
Subject: [PATCH 1/5] SQUASHME pnfs-submit: pnfs_try_to_commit can release nfs_write_data
Date: Wed, 14 Jul 2010 15:43:54 -0400
Message-ID: <1279136638-3097-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236Ab0GNTn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 15:43:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

So don't reference nfs_write_data.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3018ed6..56c3af4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1373,7 +1373,7 @@ enum pnfs_try_status
 pnfs_try_to_commit(struct nfs_write_data *data,
 		    const struct rpc_call_ops *call_ops, int sync)
 {
-	struct nfs_inode *nfsi = NFS_I(data->inode);
+	struct inode *inode = data->inode;
 	struct nfs_server *nfss = NFS_SERVER(data->inode);
 	enum pnfs_try_status trypnfs;
 
@@ -1389,12 +1389,12 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	data->pdata.call_ops = call_ops;
 	data->pdata.how = sync;
 	data->pdata.lseg = NULL;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(nfsi->layout,
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(NFS_I(inode)->layout,
 							sync, data);
 	if (trypnfs == PNFS_NOT_ATTEMPTED)
 		_pnfs_clear_lseg_from_pages(&data->pages);
 	else
-		nfs_inc_stats(data->inode, NFSIOS_PNFS_COMMIT);
+		nfs_inc_stats(inode, NFSIOS_PNFS_COMMIT);
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
-- 
1.6.6

