Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066Ab1BDVea (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:30 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>, Fred Isaman <iisaman@netapp.com>,
        Mingyang Guo <guomingyang@nrchpc.ac.cn>,
        Oleg Drokin <green@linuxhacker.ru>,
        Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 10/40] pnfs_submit: filelayout read
Date: Fri,  4 Feb 2011 16:33:32 -0500
Message-Id: <1296855242-2592-11-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-10-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Tested-by: Guo Mingyang <guomingyang@nrchpc.ac.cn>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c |   88 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 6ec9957..3daf351 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -99,6 +99,93 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
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
+	dprintk("%s USE DS:ip %x %hu\n", __func__,
+		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
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
  * filelayout_check_layout()
  *
  * Make sure layout segment parameters are sane WRT the device.
@@ -320,6 +407,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.alloc_lseg              = filelayout_alloc_lseg,
 	.free_lseg               = filelayout_free_lseg,
 	.pg_test                 = filelayout_pg_test,
+	.read_pagelist           = filelayout_read_pagelist,
 };
 
 static int __init nfs4filelayout_init(void)
-- 
1.6.6

