From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 4/4] pnfs-submit: Remove pnfs_error
Date: Sun, 13 Jun 2010 16:18:42 -0400
Message-ID: <1276460322-13873-5-git-send-email-iisaman@netapp.com>
References: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
 <1276460322-13873-2-git-send-email-iisaman@netapp.com>
 <1276460322-13873-3-git-send-email-iisaman@netapp.com>
 <1276460322-13873-4-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27832 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754378Ab0FMUSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jun 2010 16:18:52 -0400
Received: from localhost.localdomain (kellyv2-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5DKIkff012997
	for <linux-nfs@vger.kernel.org>; Sun, 13 Jun 2010 13:18:49 -0700 (PDT)
In-Reply-To: <1276460322-13873-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was only being used to signal EAGAIN to the no longer existing
pnfs_call_done functions.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 ------
 fs/nfs/pnfs.c           |    3 ---
 fs/nfs/pnfs.h           |   10 ----------
 fs/nfs/read.c           |    6 +-----
 fs/nfs/write.c          |    9 ++-------
 include/linux/nfs_xdr.h |    1 -
 6 files changed, 3 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9a3ea49..8a83c0d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -254,9 +254,6 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 	/* Perform an asynchronous read */
 	nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
 			  &filelayout_read_call_ops);
-
-	data->pdata.pnfs_error = 0;
-
 	return PNFS_ATTEMPTED;
 }
 
@@ -304,8 +301,6 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
 	 */
 	nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
 			   &filelayout_write_call_ops, sync);
-
-	data->pdata.pnfs_error = 0;
 	return PNFS_ATTEMPTED;
 }
 
@@ -678,7 +673,6 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	}
 	kfree(clone_list);
 	kfree(ds_page_list);
-	data->pdata.pnfs_error = 0;
 	return PNFS_ATTEMPTED;
 
  mem_error:
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7795e3e..3f7f50a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1513,7 +1513,6 @@ _pnfs_try_to_read_data(struct nfs_read_data *data,
 {
 	dprintk("%s: Utilizing pNFS I/O\n", __func__);
 	data->pdata.call_ops = call_ops;
-	data->pdata.pnfs_error = 0;
 	return pnfs_readpages(data);
 }
 
@@ -1523,7 +1522,6 @@ _pnfs_try_to_write_data(struct nfs_write_data *data,
 {
 	dprintk("--> %s\n", __func__);
 	data->pdata.call_ops = call_ops;
-	data->pdata.pnfs_error = 0;
 	data->pdata.how = how;
 	return pnfs_writepages(data, how);
 }
@@ -1534,7 +1532,6 @@ _pnfs_try_to_commit(struct nfs_write_data *data,
 {
 	dprintk("%s: Utilizing pNFS I/O\n", __func__);
 	data->pdata.call_ops = call_ops;
-	data->pdata.pnfs_error = 0;
 	data->pdata.how = how;
 	return pnfs_commit(data, how);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 60bddc1..e802cec 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -185,16 +185,6 @@ static inline void pnfs_update_layout(struct inode *ino,
 	}
 }
 
-static inline int pnfs_get_write_status(struct nfs_write_data *data)
-{
-	return data->pdata.pnfs_error;
-}
-
-static inline int pnfs_get_read_status(struct nfs_read_data *data)
-{
-	return data->pdata.pnfs_error;
-}
-
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 9cabf88..6a18b9c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -205,8 +205,7 @@ int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 		       const struct rpc_call_ops *call_ops)
 {
 	if (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED)
-		return pnfs_get_read_status(data);
-
+		return 0;
 	return nfs_initiate_read(data, clnt, call_ops);
 }
 
@@ -400,9 +399,6 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-#ifdef CONFIG_NFS_V4_1
-	data->pdata.pnfs_error = -EAGAIN;
-#endif /* CONFIG_NFS_V4_1 */
 	nfs_restart_rpc(task, clp);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 65e2c62..2f80b20 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -851,8 +851,7 @@ int pnfs_initiate_write(struct nfs_write_data *data,
 			int how)
 {
 	if (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED)
-		return pnfs_get_write_status(data);
-
+		return 0;
 	return nfs_initiate_write(data, clnt, call_ops, how);
 }
 
@@ -1258,9 +1257,6 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 				 */
 				argp->stable = NFS_FILE_SYNC;
 			}
-#ifdef CONFIG_NFS_V4_1
-			data->pdata.pnfs_error = -EAGAIN;
-#endif /* CONFIG_NFS_V4_1 */
 			nfs_restart_rpc(task, clp);
 			return -EAGAIN;
 		}
@@ -1350,8 +1346,7 @@ int pnfs_initiate_commit(struct nfs_write_data *data,
 {
 	if (pnfs &&
 	    (pnfs_try_to_commit(data, &nfs_commit_ops, how) == PNFS_ATTEMPTED))
-		return pnfs_get_write_status(data);
-
+		return 0;
 	return nfs_initiate_commit(data, clnt, &nfs_commit_ops, how);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index aa41a3c..01d45ce 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -973,7 +973,6 @@ struct pnfs_call_data {
 	struct pnfs_layout_segment *lseg;
 	const struct rpc_call_ops *call_ops;
 	u32			orig_count;	/* for retry via MDS */
-	int			pnfs_error;
 	u8			how;		/* for FLUSH_STABLE */
 };
 
-- 
1.6.6.1

