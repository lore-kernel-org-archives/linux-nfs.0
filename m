Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51972 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856Ab1BNTS7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:18:59 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>, Fred Isaman <iisaman@netapp.com>,
        Mingyang Guo <guomingyang@nrchpc.ac.cn>,
        Oleg Drokin <green@linuxhacker.ru>,
        Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 14/16] pnfs: wave 3: filelayout read
Date: Mon, 14 Feb 2011 14:18:34 -0500
Message-Id: <1297711116-3139-15-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Attempt a pNFS file layout read by setting up the nfs_read_data struct and
calling nfs_initiate_read with the data server rpc client and the
filelayout rpc call ops.

Error handling is implemented in a subsequent patch.

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
 fs/nfs/nfs4_fs.h        |    3 ++
 fs/nfs/nfs4filelayout.c |   80 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c       |    3 +-
 include/linux/nfs_xdr.h |    1 +
 4 files changed, 86 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5dc378e..457b1fe 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -252,6 +252,9 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 extern int nfs4_setup_sequence(const struct nfs_server *server,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		int cache_reply, struct rpc_task *task);
+extern int nfs41_setup_sequence(struct nfs4_session *session,
+		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
+		int cache_reply, struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 1c34809..a352674 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -96,6 +96,85 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 }
 
 /*
+ * Call ops for the async read/write cases
+ * In the case of dense layouts, the offset needs to be reset to its
+ * original value.
+ */
+static void filelayout_read_prepare(struct rpc_task *task, void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
+				&rdata->args.seq_args, &rdata->res.seq_res,
+				0, task))
+		return;
+
+	rpc_call_start(task);
+}
+
+static void filelayout_read_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
+
+	/* Note this may cause RPC to be resent */
+	rdata->mds_ops->rpc_call_done(task, data);
+}
+
+static void filelayout_read_release(void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	rdata->mds_ops->rpc_release(data);
+}
+
+struct rpc_call_ops filelayout_read_call_ops = {
+	.rpc_call_prepare = filelayout_read_prepare,
+	.rpc_call_done = filelayout_read_call_done,
+	.rpc_release = filelayout_read_release,
+};
+
+static enum pnfs_try_status
+filelayout_read_pagelist(struct nfs_read_data *data)
+{
+	struct pnfs_layout_segment *lseg = data->lseg;
+	struct nfs4_pnfs_ds *ds;
+	loff_t offset = data->args.offset;
+	u32 j, idx;
+	struct nfs_fh *fh;
+
+	dprintk("--> %s ino %lu pgbase %u req %Zu@%llu\n",
+		__func__, data->inode->i_ino,
+		data->args.pgbase, (size_t)data->args.count, offset);
+
+	/* Retrieve the correct rpc_client for the byte range */
+	j = nfs4_fl_calc_j_index(lseg, offset);
+	idx = nfs4_fl_calc_ds_index(lseg, j);
+	ds = nfs4_fl_prepare_ds(lseg, idx);
+	if (!ds) {
+		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		return PNFS_NOT_ATTEMPTED;
+	}
+	dprintk("%s USE DS:ip %x %hu\n", __func__,
+		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
+
+	/* No multipath support. Use first DS */
+	data->ds_clp = ds->ds_clp;
+	fh = nfs4_fl_select_ds_fh(lseg, j);
+	if (fh)
+		data->args.fh = fh;
+
+	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
+	data->mds_offset = offset;
+
+	/* Perform an asynchronous read to ds */
+	nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
+			  &filelayout_read_call_ops);
+	return PNFS_ATTEMPTED;
+}
+
+/*
  * filelayout_check_layout()
  *
  * Make sure layout segment parameters are sane WRT the device.
@@ -315,6 +394,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.alloc_lseg              = filelayout_alloc_lseg,
 	.free_lseg               = filelayout_free_lseg,
 	.pg_test                 = filelayout_pg_test,
+	.read_pagelist           = filelayout_read_pagelist,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fe75ebd..bdf6fa6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -505,7 +505,7 @@ out:
 	return ret_id;
 }
 
-static int nfs41_setup_sequence(struct nfs4_session *session,
+int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
 				int cache_reply,
@@ -571,6 +571,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	res->sr_status = 1;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs41_setup_sequence);
 
 int nfs4_setup_sequence(const struct nfs_server *server,
 			struct nfs4_sequence_args *args,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a607c65..3c74807 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1020,6 +1020,7 @@ struct nfs_read_data {
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	const struct rpc_call_ops *mds_ops;
+	__u64			mds_offset;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.7.2.3

