Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293Ab0HMVdT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:19 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 40/50] pnfs_submit: filelayout write
Date: Fri, 13 Aug 2010 17:31:52 -0400
Message-Id: <1281735122-1496-41-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-40-git-send-email-andros@netapp.com>
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
 <1281735122-1496-38-git-send-email-andros@netapp.com>
 <1281735122-1496-39-git-send-email-andros@netapp.com>
 <1281735122-1496-40-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c9251ca..8c5702b 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -151,12 +151,41 @@ static void filelayout_read_release(void *data)
 	rdata->pdata.call_ops->rpc_release(data);
 }
 
+static void filelayout_write_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	if (wdata->fldata.orig_offset) {
+		dprintk("%s new off %llu orig offset %llu\n", __func__,
+			wdata->args.offset, wdata->fldata.orig_offset);
+		wdata->args.offset = wdata->fldata.orig_offset;
+	}
+
+	/* Note this may cause RPC to be resent */
+	wdata->pdata.call_ops->rpc_call_done(task, data);
+}
+
+static void filelayout_write_release(void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	put_lseg(wdata->pdata.lseg);
+	wdata->pdata.lseg = NULL;
+	wdata->pdata.call_ops->rpc_release(data);
+}
+
 struct rpc_call_ops filelayout_read_call_ops = {
 	.rpc_call_prepare = nfs_read_prepare,
 	.rpc_call_done = filelayout_read_call_done,
 	.rpc_release = filelayout_read_release,
 };
 
+struct rpc_call_ops filelayout_write_call_ops = {
+	.rpc_call_prepare = nfs_write_prepare,
+	.rpc_call_done = filelayout_write_call_done,
+	.rpc_release = filelayout_write_release,
+};
+
 /* Perform sync or async reads.
  *
  * An optimization for the NFS file layout driver
@@ -210,6 +239,47 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
 	return PNFS_ATTEMPTED;
 }
 
+/* Perform async writes. */
+static enum pnfs_try_status
+filelayout_write_pagelist(struct nfs_write_data *data, unsigned nr_pages, int sync)
+{
+	struct pnfs_layout_segment *lseg = data->pdata.lseg;
+	struct nfs4_pnfs_ds *ds;
+	loff_t offset = data->args.offset;
+	u32 idx;
+	struct nfs_fh *fh;
+
+	/* Retrieve the correct rpc_client for the byte range */
+	idx = nfs4_fl_calc_ds_index(lseg, offset);
+	ds = nfs4_fl_prepare_ds(lseg, idx);
+	if (!ds) {
+		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		return PNFS_NOT_ATTEMPTED;
+	}
+	dprintk("%s ino %lu sync %d req %Zu@%llu DS:%x:%hu %s\n", __func__,
+		data->inode->i_ino, sync, (size_t) data->args.count, offset,
+		htonl(ds->ds_ip_addr), ntohs(ds->ds_port), ds->r_addr);
+
+	data->fldata.ds_nfs_client = ds->ds_clp;
+	fh = nfs4_fl_select_ds_fh(lseg, offset);
+	if (fh)
+		data->args.fh = fh;
+	/*
+	 * Get the file offset on the dserver. Set the write offset to
+	 * this offset and save the original offset.
+	 */
+	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
+	data->fldata.orig_offset = offset;
+
+	/*
+	 * Perform an asynchronous write The offset will be reset in the
+	 * call_ops->rpc_call_done() routine
+	 */
+	nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
+			   &filelayout_write_call_ops, sync);
+	return PNFS_ATTEMPTED;
+}
+
 /*
  * Create a filelayout layout structure and return it.  The pNFS client
  * will use the pnfs_layout_type type to refer to the layout for this
@@ -465,6 +535,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 
 struct layoutdriver_io_operations filelayout_io_operations = {
 	.read_pagelist           = filelayout_read_pagelist,
+	.write_pagelist          = filelayout_write_pagelist,
 	.alloc_layout            = filelayout_alloc_layout,
 	.free_layout             = filelayout_free_layout,
 	.alloc_lseg              = filelayout_alloc_lseg,
-- 
1.6.2.5

