Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43653 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603Ab1BURtn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Feb 2011 12:49:43 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/7] NFSv4.1: implement generic pnfs layer write switch
Date: Mon, 21 Feb 2011 12:49:34 -0500
Message-Id: <1298310576-13523-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
References: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

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
 fs/nfs/nfs4filelayout.c    |    7 +++++++
 fs/nfs/pnfs.c              |   24 ++++++++++++++++++++++++
 fs/nfs/pnfs.h              |   11 +++++++++++
 fs/nfs/write.c             |    4 ++++
 include/linux/nfs_iostat.h |    1 +
 include/linux/nfs_xdr.h    |    1 +
 6 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b9f8044..553adea 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -236,6 +236,12 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	return PNFS_ATTEMPTED;
 }
 
+static enum pnfs_try_status
+filelayout_write_pagelist(struct nfs_write_data *data, int sync)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
 /*
  * filelayout_check_layout()
  *
@@ -453,6 +459,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.free_lseg		= filelayout_free_lseg,
 	.pg_test                = filelayout_pg_test,
 	.read_pagelist          = filelayout_read_pagelist,
+	.write_pagelist         = filelayout_write_pagelist,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0ed3948d..e8e7bab 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -901,6 +901,30 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
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
index 1d4e631..3766afea 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -79,6 +79,8 @@ struct pnfs_layoutdriver_type {
 	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
 	 */
 	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
+	enum pnfs_try_status
+	(*write_pagelist) (struct nfs_write_data *nfs_data, int how);
 };
 
 struct pnfs_layout_hdr {
@@ -120,6 +122,8 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
+					     const struct rpc_call_ops *, int);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
@@ -200,6 +204,13 @@ pnfs_try_to_read_data(struct nfs_read_data *data,
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
index 6cf5de6..b6b683d 100644
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
index 09d9681..c82ad33 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1039,6 +1039,7 @@ struct nfs_write_data {
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
+	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
-- 
1.7.2.1

