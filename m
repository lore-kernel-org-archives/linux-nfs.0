From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 22/24] pnfs_submit: remove unecessary pnfs_fl_call_data field pnfs_client
Date: Tue,  8 Jun 2010 00:19:19 -0400
Message-ID: <1275970761-31806-23-git-send-email-iisaman@netapp.com>
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
 <1275970761-31806-19-git-send-email-iisaman@netapp.com>
 <1275970761-31806-20-git-send-email-iisaman@netapp.com>
 <1275970761-31806-21-git-send-email-iisaman@netapp.com>
 <1275970761-31806-22-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4879 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab0FHETt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:49 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQD014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:40 -0700 (PDT)
In-Reply-To: <1275970761-31806-22-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    9 +++------
 include/linux/nfs_xdr.h |    1 -
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 756cb64..b82e4ff 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -216,7 +216,6 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 
 	/* just try the first data server for the index..*/
 	data->fldata.ds_nfs_client = ds->ds_clp;
-	data->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
 	data->args.fh = nfs4_fl_select_ds_fh(flseg, idx);
 
 	/* Now get the file offset on the dserver
@@ -230,7 +229,7 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
 	data->fldata.orig_offset = offset;
 
 	/* Perform an asynchronous read */
-	nfs_initiate_read(data, data->fldata.pnfs_client,
+	nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
 			  &filelayout_read_call_ops);
 
 	data->pdata.pnfs_error = 0;
@@ -269,7 +268,6 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
 		htonl(ds->ds_ip_addr), ntohs(ds->ds_port), ds->r_addr);
 
 	data->fldata.ds_nfs_client = ds->ds_clp;
-	data->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
 	data->args.fh = nfs4_fl_select_ds_fh(flseg, idx);
 
 	/* Get the file offset on the dserver. Set the write offset to
@@ -281,7 +279,7 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
 	/* Perform an asynchronous write The offset will be reset in the
 	 * call_ops->rpc_call_done() routine
 	 */
-	nfs_initiate_write(data, data->fldata.pnfs_client,
+	nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
 			   &filelayout_write_call_ops, sync);
 
 	data->pdata.pnfs_error = 0;
@@ -572,7 +570,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	struct nfs4_pnfs_ds *ds;
 
 	dprintk("%s data %p pnfs_client %p sync %d\n",
-		__func__, data, data->fldata.pnfs_client, sync);
+		__func__, data, data->fldata.ds_nfs_client->cl_rpcclient, sync);
 
 	/* Alloc room for both in one go */
 	ds_page_list = kzalloc((NFS4_PNFS_MAX_MULTI_CNT + 1) *
@@ -643,7 +641,6 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 				continue;
 			}
 			clnt = ds->ds_clp->cl_rpcclient;
-			dsdata->fldata.pnfs_client = clnt;
 			dsdata->fldata.ds_nfs_client = ds->ds_clp;
 			dsdata->args.fh = \
 				nfs4_fl_select_ds_fh(LSEG_LD_DATA(req->wb_lseg),
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 07d6dd2..183a9c3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -980,7 +980,6 @@ struct pnfs_call_data {
 
 /* files layout-type specific data for read, write, and commit */
 struct pnfs_fl_call_data {
-	struct rpc_clnt		*pnfs_client;	/* Holds pNFS device across async calls */
 	struct nfs_client	*ds_nfs_client;
 	__u64			orig_offset;
 	int			commit_through_mds;
-- 
1.6.6.1

