Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14172 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:17 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/13] NFSv4.1: Remove assertion BUG_ON()s from the files and generic layout code
Date: Mon, 15 Oct 2012 17:30:59 -0400
Message-Id: <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c    | 13 ++++---------
 fs/nfs/nfs4filelayoutdev.c |  2 --
 fs/nfs/pnfs.c              |  6 ++----
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2e45fd9..bfb28fa 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -512,7 +512,6 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	loff_t offset = data->args.offset;
 	u32 j, idx;
 	struct nfs_fh *fh;
-	int status;
 
 	dprintk("--> %s ino %lu pgbase %u req %Zu@%llu\n",
 		__func__, hdr->inode->i_ino,
@@ -538,9 +537,8 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	status = nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
+	nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
 				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
-	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
 }
 
@@ -554,7 +552,6 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	loff_t offset = data->args.offset;
 	u32 j, idx;
 	struct nfs_fh *fh;
-	int status;
 
 	/* Retrieve the correct rpc_client for the byte range */
 	j = nfs4_fl_calc_j_index(lseg, offset);
@@ -579,10 +576,9 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-	status = nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
+	nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
 				    &filelayout_write_call_ops, sync,
 				    RPC_TASK_SOFTCONN);
-	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
 }
 
@@ -909,7 +905,7 @@ static void
 filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
-	BUG_ON(pgio->pg_lseg != NULL);
+	WARN_ON_ONCE(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase) {
 		/*
@@ -939,7 +935,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	struct nfs_commit_info cinfo;
 	int status;
 
-	BUG_ON(pgio->pg_lseg != NULL);
+	WARN_ON_ONCE(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase)
 		goto out_mds;
@@ -1187,7 +1183,6 @@ static void filelayout_recover_commit_reqs(struct list_head *dst,
 	 */
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
 		if (transfer_commit_list(&b->written, dst, cinfo, 0)) {
-			BUG_ON(!list_empty(&b->written));
 			pnfs_put_lseg(b->wlseg);
 			b->wlseg = NULL;
 		}
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index a8eaa9b..93e2530 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -162,8 +162,6 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
 		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
 
-	BUG_ON(list_empty(&ds->ds_addrs));
-
 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
 		dprintk("%s: DS %s: trying address %s\n",
 			__func__, ds->ds_remotestr, da->da_remotestr);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 43e4ad8..778c7fa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -634,7 +634,6 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 
-	BUG_ON(ctx == NULL);
 	lgp = kzalloc(sizeof(*lgp), gfp_flags);
 	if (lgp == NULL)
 		return NULL;
@@ -1115,7 +1114,6 @@ pnfs_update_layout(struct inode *ino,
 		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
 		 */
 		spin_lock(&clp->cl_lock);
-		BUG_ON(!list_empty(&lo->plh_layouts));
 		list_add_tail(&lo->plh_layouts, &server->layouts);
 		spin_unlock(&clp->cl_lock);
 	}
@@ -1211,7 +1209,7 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 {
 	u64 rd_size = req->wb_bytes;
 
-	BUG_ON(pgio->pg_lseg != NULL);
+	WARN_ON_ONCE(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase) {
 		nfs_pageio_reset_read_mds(pgio);
@@ -1240,7 +1238,7 @@ void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
 {
-	BUG_ON(pgio->pg_lseg != NULL);
+	WARN_ON_ONCE(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase) {
 		nfs_pageio_reset_write_mds(pgio);
-- 
1.7.11.7

