Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757749Ab1BKSAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:43 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 03/17] SQUASHME rename orig_offset to mds_offset
Date: Thu, 10 Feb 2011 20:52:36 -0500
Message-Id: <1297389170-26702-4-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-3-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: filelayout read

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    8 ++++----
 include/linux/nfs_xdr.h |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 05fcc6a..61f21b6 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -201,10 +201,10 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
-	if (rdata->orig_offset) {
+	if (rdata->mds_offset) {
 		dprintk("%s new off %llu orig offset %llu\n", __func__,
-			rdata->args.offset, rdata->orig_offset);
-		rdata->args.offset = rdata->orig_offset;
+			rdata->args.offset, rdata->mds_offset);
+		rdata->args.offset = rdata->mds_offset;
 	}
 
 	/* Note this may cause RPC to be resent */
@@ -256,7 +256,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 		data->args.fh = fh;
 
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
-	data->orig_offset = offset;
+	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
 	nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c91f468..935d8ff 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1021,7 +1021,7 @@ struct nfs_read_data {
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	const struct rpc_call_ops *call_ops;	/* For pNFS recovery to MDS */
 	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
-	__u64			orig_offset;	/* Filelayout dense stripe */
+	__u64			mds_offset;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.6.6

