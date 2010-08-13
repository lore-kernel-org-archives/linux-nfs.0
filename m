Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754405Ab0HMVcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:36 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 37/50] pnfs_submit: filelayout read
Date: Fri, 13 Aug 2010 17:31:49 -0400
Message-Id: <1281735122-1496-38-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-37-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
 <1281735122-1496-36-git-send-email-andros@netapp.com>
 <1281735122-1496-37-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   88 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index d1c0d35..c9251ca 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -124,6 +124,93 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 }
 
 /*
+ * Call ops for the async read/write cases
+ * In the case of dense layouts, the offset needs to be reset to its
+ * original value.
+ */
+static void filelayout_read_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	if (rdata->fldata.orig_offset) {
+		dprintk("%s new off %llu orig offset %llu\n", __func__,
+			rdata->args.offset, rdata->fldata.orig_offset);
+		rdata->args.offset = rdata->fldata.orig_offset;
+	}
+
+	/* Note this may cause RPC to be resent */
+	rdata->pdata.call_ops->rpc_call_done(task, data);
+}
+
+static void filelayout_read_release(void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	put_lseg(rdata->pdata.lseg);
+	rdata->pdata.lseg = NULL;
+	rdata->pdata.call_ops->rpc_release(data);
+}
+
+struct rpc_call_ops filelayout_read_call_ops = {
+	.rpc_call_prepare = nfs_read_prepare,
+	.rpc_call_done = filelayout_read_call_done,
+	.rpc_release = filelayout_read_release,
+};
+
+/* Perform sync or async reads.
+ *
+ * An optimization for the NFS file layout driver
+ * allows the original read/write data structs to be passed in the
+ * last argument.
+ *
+ * TODO: join with write_pagelist?
+ */
+static enum pnfs_try_status
+filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
+{
+	struct pnfs_layout_segment *lseg = data->pdata.lseg;
+	struct nfs4_pnfs_ds *ds;
+	loff_t offset = data->args.offset;
+	u32 idx;
+	struct nfs_fh *fh;
+
+	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu\n",
+		__func__, data->inode->i_ino, nr_pages,
+		data->args.pgbase, (size_t)data->args.count, offset);
+
+	/* Retrieve the correct rpc_client for the byte range */
+	idx = nfs4_fl_calc_ds_index(lseg, offset);
+	ds = nfs4_fl_prepare_ds(lseg, idx);
+	if (!ds) {
+		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		return PNFS_NOT_ATTEMPTED;
+	}
+	dprintk("%s USE DS:ip %x %s\n", __func__,
+		htonl(ds->ds_ip_addr), ds->r_addr);
+
+	/* just try the first data server for the index..*/
+	data->fldata.ds_nfs_client = ds->ds_clp;
+	fh = nfs4_fl_select_ds_fh(lseg, offset);
+	if (fh)
+		data->args.fh = fh;
+
+	/*
+	 * Now get the file offset on the dserver
+	 * Set the read offset to this offset, and
+	 * save the original offset in orig_offset
+	 * In the case of aync reads, the offset will be reset in the
+	 * call_ops->rpc_call_done() routine.
+	 */
+	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
+	data->fldata.orig_offset = offset;
+
+	/* Perform an asynchronous read */
+	nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
+			  &filelayout_read_call_ops);
+	return PNFS_ATTEMPTED;
+}
+
+/*
  * Create a filelayout layout structure and return it.  The pNFS client
  * will use the pnfs_layout_type type to refer to the layout for this
  * inode from now on.
@@ -377,6 +464,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 
 struct layoutdriver_io_operations filelayout_io_operations = {
+	.read_pagelist           = filelayout_read_pagelist,
 	.alloc_layout            = filelayout_alloc_layout,
 	.free_layout             = filelayout_free_layout,
 	.alloc_lseg              = filelayout_alloc_lseg,
-- 
1.6.2.5

