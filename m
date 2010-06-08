From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 18/24] pnfs_submit: remove pnfs_writepages LAYOUTGET invocation
Date: Tue,  8 Jun 2010 00:19:15 -0400
Message-ID: <1275970761-31806-19-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
 <1275970761-31806-11-git-send-email-iisaman@netapp.com>
 <1275970761-31806-12-git-send-email-iisaman@netapp.com>
 <1275970761-31806-13-git-send-email-iisaman@netapp.com>
 <1275970761-31806-14-git-send-email-iisaman@netapp.com>
 <1275970761-31806-15-git-send-email-iisaman@netapp.com>
 <1275970761-31806-16-git-send-email-iisaman@netapp.com>
 <1275970761-31806-17-git-send-email-iisaman@netapp.com>
 <1275970761-31806-18-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab0FHETs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:48 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQ9014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:37 -0700 (PDT)
In-Reply-To: <1275970761-31806-18-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   37 +++++++------------------------------
 fs/nfs/pnfs.h |   15 ++++++---------
 2 files changed, 13 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3d5c17b..4907e3a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1514,7 +1514,7 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 {
 	struct nfs_writeargs *args = &wdata->args;
 	struct inode *inode = wdata->inode;
-	int numpages, status;
+	int numpages;
 	enum pnfs_try_status trypnfs;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1526,19 +1526,8 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		args->count,
 		args->offset);
 
-	/* Retrieve and set layout if not allready cached */
-	status = _pnfs_update_layout(inode,
-				    args->context,
-				    args->count,
-				    args->offset,
-				    IOMODE_RW,
-				    &lseg);
-	if (status) {
-		dprintk("%s: Updating layout failed (%d), retry with NFS \n",
-			__func__, status);
-		trypnfs = PNFS_NOT_ATTEMPTED;	/* retry with nfs I/O */
-		goto out;
-	}
+	lseg = wdata->req->wb_lseg;
+	get_lseg(lseg);
 
 	/* Determine number of pages
 	 */
@@ -1566,7 +1555,6 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		wdata->pdata.lseg = NULL;
 		put_lseg(lseg);
 	}
-out:
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
@@ -1673,22 +1661,11 @@ enum pnfs_try_status
 _pnfs_try_to_write_data(struct nfs_write_data *data,
 			const struct rpc_call_ops *call_ops, int how)
 {
-	struct inode *ino = data->inode;
-	struct nfs_server *nfss = NFS_SERVER(ino);
-
 	dprintk("--> %s\n", __func__);
-	/* Only create an rpc request if utilizing NFSv4 I/O */
-	if (!pnfs_enabled_sb(nfss) ||
-	    !nfss->pnfs_curr_ld->ld_io_ops->write_pagelist) {
-		dprintk("<-- %s: not using pnfs\n", __func__);
-		return PNFS_NOT_ATTEMPTED;
-	} else {
-		dprintk("%s: Utilizing pNFS I/O\n", __func__);
-		data->pdata.call_ops = call_ops;
-		data->pdata.pnfs_error = 0;
-		data->pdata.how = how;
-		return pnfs_writepages(data, how);
-	}
+	data->pdata.call_ops = call_ops;
+	data->pdata.pnfs_error = 0;
+	data->pdata.how = how;
+	return pnfs_writepages(data, how);
 }
 
 enum pnfs_try_status
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 339485d..ea54210 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -123,18 +123,15 @@ pnfs_try_to_write_data(struct nfs_write_data *data,
 		       const struct rpc_call_ops *call_ops,
 		       int how)
 {
-	struct inode *inode = data->inode;
-	struct nfs_server *nfss = NFS_SERVER(inode);
 	enum pnfs_try_status ret;
 
-	/* FIXME: write_pagelist should probably be mandated */
-	if (PNFS_EXISTS_LDIO_OP(nfss, write_pagelist))
-		ret = _pnfs_try_to_write_data(data, call_ops, how);
-	else
-		ret = PNFS_NOT_ATTEMPTED;
-
+	if (!data->req->wb_lseg)
+		return PNFS_NOT_ATTEMPTED;
+	ret = _pnfs_try_to_write_data(data, call_ops, how);
 	if (ret == PNFS_ATTEMPTED)
-		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
+		nfs_inc_stats(data->inode, NFSIOS_PNFS_WRITE);
+	else
+		_pnfs_clear_lseg_from_pages(&data->pages);
 	return ret;
 }
 
-- 
1.6.6.1

