Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab1BDVeu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:50 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 31/40] pnfs_submit wave3 remove struct pnfs_fl_call_data
Date: Fri,  4 Feb 2011 16:33:53 -0500
Message-Id: <1296855242-2592-32-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-31-git-send-email-andros@netapp.com>
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
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
 <1296855242-2592-30-git-send-email-andros@netapp.com>
 <1296855242-2592-31-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   13 +++++++------
 fs/nfs/nfs4proc.c       |    8 ++++----
 fs/nfs/read.c           |    9 +--------
 include/linux/nfs_xdr.h |   13 ++++---------
 4 files changed, 16 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c7ba5bc..fa718e1 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -104,10 +104,11 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
-	if (rdata->fldata.orig_offset) {
+	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
+	if (rdata->orig_offset) {
 		dprintk("%s new off %llu orig offset %llu\n", __func__,
-			rdata->args.offset, rdata->fldata.orig_offset);
-		rdata->args.offset = rdata->fldata.orig_offset;
+			rdata->args.offset, rdata->orig_offset);
+		rdata->args.offset = rdata->orig_offset;
 	}
 
 	/* Note this may cause RPC to be resent */
@@ -152,14 +153,14 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	dprintk("%s USE DS:ip %x %hu\n", __func__,
 		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
 
-	/* just try the first data server for the index..*/
-	data->fldata.ds_nfs_client = ds->ds_clp;
+	/* No multipath support. Use first DS */
+	data->ds_clp = ds->ds_clp;
 	fh = nfs4_fl_select_ds_fh(lseg, offset);
 	if (fh)
 		data->args.fh = fh;
 
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
-	data->fldata.orig_offset = offset;
+	data->orig_offset = offset;
 
 	/* Perform an asynchronous read to ds */
 	nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1da0ebf..213e3f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3077,15 +3077,15 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
-	struct nfs_client *client = server->nfs_client;
+	struct nfs_client *clp = server->nfs_client;
 
 	dprintk("--> %s\n", __func__);
 
 #ifdef CONFIG_NFS_V4_1
 	/* Is this a DS session */
-	if (data->fldata.ds_nfs_client) {
+	if (data->ds_clp) {
 		dprintk("%s DS read\n", __func__);
-		client = data->fldata.ds_nfs_client;
+		clp = data->ds_clp;
 	}
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -3098,7 +3098,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	}
 
 	nfs_invalidate_atime(data->inode);
-	if (task->tk_status > 0 && client == server->nfs_client)
+	if (task->tk_status > 0 && !data->ds_clp)
 		renew_lease(server, data->timestamp);
 	return 0;
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 0db6203..9af3048 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -382,14 +382,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 {
 	struct nfs_readargs *argp = &data->args;
 	struct nfs_readres *resp = &data->res;
-	struct nfs_client *clp = NFS_SERVER(data->inode)->nfs_client;
 
-#ifdef CONFIG_NFS_V4_1
-	if (data->fldata.ds_nfs_client) {
-		dprintk("%s DS read\n", __func__);
-		clp = data->fldata.ds_nfs_client;
-	}
-#endif /* CONFIG_NFS_V4_1 */
 	if (resp->eof || resp->count == argp->count)
 		return;
 
@@ -403,7 +396,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-	nfs_restart_rpc(task, clp);
+	nfs_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
 }
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 887aff3..4cf522e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1009,14 +1009,8 @@ struct nfs_page;
 /* pnfs-specific data needed for read, write, and commit calls */
 struct pnfs_call_data {
 	const struct rpc_call_ops *call_ops;
-	u32			orig_count;	/* for retry via MDS */
-	u8			how;		/* for FLUSH_STABLE */
-};
-
-/* files layout-type specific data for read, write, and commit */
-struct pnfs_fl_call_data {
-	struct nfs_client	*ds_nfs_client;
-	__u64			orig_offset;
+	u32			orig_count;     /* for retry via MDS */
+	u8			how;            /* for FLUSH_STABLE */
 };
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -1033,12 +1027,13 @@ struct nfs_read_data {
 	struct nfs_readargs args;
 	struct nfs_readres  res;
 	struct pnfs_layout_segment *lseg;
+	struct nfs_client	*ds_clp;   /* pNFS data server */
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
 #if defined(CONFIG_NFS_V4_1)
 	struct pnfs_call_data	pdata;
-	struct pnfs_fl_call_data fldata;
+	__u64			orig_offset; /* For filelayout dense stripe */
 #endif /* CONFIG_NFS_V4_1 */
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
-- 
1.6.6

