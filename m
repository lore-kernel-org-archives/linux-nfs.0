Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26986 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757328Ab1BKQzB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 11:55:01 -0500
Received: from localhost.localdomain (manjua-lxp.hq.netapp.com [10.58.49.248] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p1BGshZ8002533
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 08:54:46 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] wave4: implement pnfs_try_to_write_data
Date: Fri, 11 Feb 2011 11:54:37 -0500
Message-Id: <1297443279-19813-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

split from "pnfs_submit: generic write" and modified

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c              |   24 ++++++++++++++++++++++++
 fs/nfs/pnfs.h              |   11 +++++++++++
 fs/nfs/write.c             |    4 ++++
 include/linux/nfs_iostat.h |    1 +
 include/linux/nfs_xdr.h    |    1 +
 5 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 912b1ff..9d2351a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -892,6 +892,30 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	pnfs_set_pg_test(inode, pgio);
 }
 
+enum pnfs_try_status
+pnfs_try_to_write_data(struct nfs_write_data *wdata,
+			const struct rpc_call_ops *call_ops, int how)
+{
+	struct inode *inode = wdata->inode;
+	enum pnfs_try_status trypnfs;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+
+	wdata->mds_ops = call_ops;
+
+	dprintk("%s: Writing ino:%lu %u@%llu (how %d)\n", __func__,
+		inode->i_ino, wdata->args.count, wdata->args.offset, how);
+
+	trypnfs = nfss->pnfs_curr_ld->write_pagelist(wdata, how);
+	if (trypnfs == PNFS_NOT_ATTEMPTED) {
+		wdata->lseg = NULL;
+		put_lseg(wdata->lseg);
+	} else
+		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
+
+	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
+	return trypnfs;
+}
+
 /*
  * Call the appropriate parallel I/O subsystem read function.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d2d708a..50bcb1f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -81,6 +81,8 @@ struct pnfs_layoutdriver_type {
 	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
 	 */
 	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
+	enum pnfs_try_status
+	(*write_pagelist) (struct nfs_write_data *nfs_data, int how);
 };
 
 struct pnfs_layout_hdr {
@@ -172,6 +174,8 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
+					     const struct rpc_call_ops *, int);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
@@ -250,6 +254,13 @@ pnfs_try_to_read_data(struct nfs_read_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
+static inline enum pnfs_try_status
+pnfs_try_to_write_data(struct nfs_write_data *data,
+		       const struct rpc_call_ops *call_ops, int how)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
 static inline bool
 pnfs_roc(struct inode *ino)
 {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fa92fad..24cc34d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -873,6 +873,10 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
 
+	if (data->lseg &&
+	    (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED))
+		return 0;
+
 	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
 }
 
diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
index 37a1437..8866bb3 100644
--- a/include/linux/nfs_iostat.h
+++ b/include/linux/nfs_iostat.h
@@ -114,6 +114,7 @@ enum nfs_stat_eventcounters {
 	NFSIOS_SHORTWRITE,
 	NFSIOS_DELAY,
 	NFSIOS_PNFS_READ,
+	NFSIOS_PNFS_WRITE,
 	__NFSIOS_COUNTSMAX,
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 23feaf6..9ff26f9 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1040,6 +1040,7 @@ struct nfs_write_data {
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
-- 
1.7.2.1

