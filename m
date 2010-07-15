From: andros@netapp.com
Subject: [PATCH 3/4] SQUASHME pnfs-submit nfs4filelayout.c cleanup
Date: Thu, 15 Jul 2010 12:33:49 -0400
Message-ID: <1279211630-6039-3-git-send-email-andros@netapp.com>
References: <1279211630-6039-1-git-send-email-andros@netapp.com>
 <1279211630-6039-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2923 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933695Ab0GOQd1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:33:27 -0400
In-Reply-To: <1279211630-6039-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Cleanup comment formatting and lines greater than 80 characters.
Also remove an unecessary forward declaration and #if 0 code.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   66 ++++++++++++++++++++---------------------------
 1 files changed, 28 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index dc3ee0c..9b6ba8d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -66,7 +66,6 @@ MODULE_DESCRIPTION("The NFSv4 file layout driver");
 struct pnfs_client_operations *pnfs_callback_ops;
 
 /* Forward declaration */
-ssize_t filelayout_get_stripesize(struct pnfs_layout_type *);
 struct layoutdriver_io_operations filelayout_io_operations;
 
 int
@@ -84,8 +83,7 @@ filelayout_initialize_mountpoint(struct nfs_client *clp)
 	return 0;
 }
 
-/* Uninitialize a mountpoint by destroying its device list.
- */
+/* Uninitialize a mountpoint by destroying its device list */
 int
 filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
 {
@@ -128,7 +126,8 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 	return 0;
 }
 
-/* Call ops for the async read/write cases
+/*
+ * Call ops for the async read/write cases
  * In the case of dense layouts, the offset needs to be reset to its
  * original value.
  */
@@ -137,8 +136,8 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
 	if (rdata->fldata.orig_offset) {
-		dprintk("%s new off %llu orig offset %llu\n",
-			__func__, rdata->args.offset, rdata->fldata.orig_offset);
+		dprintk("%s new off %llu orig offset %llu\n", __func__,
+			rdata->args.offset, rdata->fldata.orig_offset);
 		rdata->args.offset = rdata->fldata.orig_offset;
 	}
 
@@ -160,8 +159,8 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
 	if (wdata->fldata.orig_offset) {
-		dprintk("%s new off %llu orig offset %llu\n",
-			__func__, wdata->args.offset, wdata->fldata.orig_offset);
+		dprintk("%s new off %llu orig offset %llu\n", __func__,
+			wdata->args.offset, wdata->fldata.orig_offset);
 		wdata->args.offset = wdata->fldata.orig_offset;
 	}
 
@@ -227,7 +226,8 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
 	if (fh)
 		data->args.fh = fh;
 
-	/* Now get the file offset on the dserver
+	/*
+	 * Now get the file offset on the dserver
 	 * Set the read offset to this offset, and
 	 * save the original offset in orig_offset
 	 * In the case of aync reads, the offset will be reset in the
@@ -267,14 +267,15 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	fh = nfs4_fl_select_ds_fh(lseg, offset);
 	if (fh)
 		data->args.fh = fh;
-
-	/* Get the file offset on the dserver. Set the write offset to
+	/*
+	 * Get the file offset on the dserver. Set the write offset to
 	 * this offset and save the original offset.
 	 */
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 	data->fldata.orig_offset = offset;
 
-	/* Perform an asynchronous write The offset will be reset in the
+	/*
+	 * Perform an asynchronous write The offset will be reset in the
 	 * call_ops->rpc_call_done() routine
 	 */
 	nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
@@ -282,7 +283,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	return PNFS_ATTEMPTED;
 }
 
-/* Create a filelayout layout structure and return it.  The pNFS client
+/*
+ * Create a filelayout layout structure and return it.  The pNFS client
  * will use the pnfs_layout_type type to refer to the layout for this
  * inode from now on.
  */
@@ -296,8 +298,7 @@ filelayout_alloc_layout(struct inode *inode)
 	return flp ? &flp->fl_layout : NULL;
 }
 
-/* Free a filelayout layout structure
- */
+/* Free a filelayout layout structure */
 static void
 filelayout_free_layout(struct pnfs_layout_type *lo)
 {
@@ -316,7 +317,7 @@ filelayout_free_layout(struct pnfs_layout_type *lo)
  * 2) pattern_offset is ignored and must == 0 which is wrong;
  * 3) the pattern_offset needs to be a mutliple of the stripe unit.
  * 4) stripe unit is multiple of page size
-*/
+ */
 
 static int
 filelayout_check_layout(struct pnfs_layout_type *lo,
@@ -440,8 +441,7 @@ filelayout_set_layout(struct nfs4_filelayout *flo,
 		if (sizeof(struct nfs_fh) < fl->fh_array[i].size) {
 			printk(KERN_ERR "Too big fh %d received %d\n",
 				i, fl->fh_array[i].size);
-			/* Layout is now invalid, so pretend it does not
-			   exist */
+			/* Layout is now invalid, pretend it doesn't exist */
 			filelayout_free_fh_array(fl);
 			fl->num_fh = 0;
 			break;
@@ -504,9 +504,7 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 	_filelayout_free_lseg(lseg);
 }
 
-/*
- * Allocate a new nfs_write_data struct and initialize
- */
+/* Allocate a new nfs_write_data struct and initialize */
 static struct nfs_write_data *
 filelayout_clone_write_data(struct nfs_write_data *old)
 {
@@ -577,8 +575,8 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 	if (!ds_page_list)
 		goto mem_error;
 	indices_used = (u16 *) (ds_page_list + NFS4_PNFS_MAX_MULTI_CNT + 1);
-
-	/* Sort pages based on which ds to send to.
+	/*
+	 * Sort pages based on which ds to send to.
 	 * MDS is given index equal to NFS4_PNFS_MAX_MULTI_CNT.
 	 * Note we are assuming there is only a single lseg in play.
 	 * When that is not true, we could first sort on lseg, then
@@ -616,7 +614,8 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 			goto mem_error;
 	}
 	clone_list[i] = data;
-	/* Now send off the RPCs to each ds.  Note that it is important
+	/*
+	 * Now send off the RPCs to each ds.  Note that it is important
 	 * that any RPC to the MDS be sent last (or at least after all
 	 * clones have been made.)
 	 */
@@ -675,8 +674,7 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 	return PNFS_ATTEMPTED;
 }
 
-/* Return the stripesize for the specified file.
- */
+/* Return the stripesize for the specified file */
 ssize_t
 filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
 {
@@ -702,18 +700,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
 	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
 
-#if 0
-	dprintk("%s p %llu r %llu \n", __func__, p_stripe, r_stripe);
-#endif
-
 	do_div(p_stripe, pgio->pg_boundary);
 	do_div(r_stripe, pgio->pg_boundary);
 
-#if 0
-	dprintk("%s p %llu r %llu bnd %d bsize %Zu\n", __func__,
-		p_stripe, r_stripe, pgio->pg_boundary, pgio->pg_bsize);
-#endif
-
 	return (p_stripe == r_stripe);
 }
 
@@ -746,9 +735,10 @@ static int __init nfs4filelayout_init(void)
 	printk(KERN_INFO "%s: NFSv4 File Layout Driver Registering...\n",
 	       __func__);
 
-	/* Need to register file_operations struct with global list to indicate
-	* that NFS4 file layout is a possible pNFS I/O module
-	*/
+	/*
+	 * Need to register file_operations struct with global list to indicate
+	 * that NFS4 file layout is a possible pNFS I/O module
+	 */
 	pnfs_callback_ops = pnfs_register_layoutdriver(&filelayout_type);
 
 	return 0;
-- 
1.6.6

