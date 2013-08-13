Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54104 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757703Ab3HMVsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 17:48:00 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 3/3] NFSv4.1 Use the shared nfs_client rpc_clnts for pNFS data server connections
Date: Tue, 13 Aug 2013 17:47:49 -0400
Message-ID: <1376430469-3773-4-git-send-email-andros@netapp.com>
In-Reply-To: <1376430469-3773-1-git-send-email-andros@netapp.com>
References: <1376430469-3773-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

pNFS data servers are not mounted in the normal sense as there is no associated
nfs_server structure.

Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
uses the nfs_client cl_rpcclient for all state management operations, and
will use krb5i or auth_sys with no regard to the mount command authflavor
choice.  For normal mounted servers, the nfs_server client authflavor is used
for all non-state management operations

Data servers use the same authflavor as the MDS mount for non-state management
operations. Note that the MDS has performed any sub-mounts and created an
nfs_server rpc client. Use the array of struct rpc_clnt in struct
nfs_client, one for each possible auth flavor for data server RPC connections.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    | 69 ++++++++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs4filelayout.h    |  3 ++
 fs/nfs/nfs4filelayoutdev.c |  4 ++-
 3 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 17ed87e..f8faad7 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -83,6 +83,35 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 	BUG();
 }
 
+/* Use the au_flavor of the MDS nfs_server RPC client to find or clone the
+ * correct data server RPC client.
+ *
+ * Note that the MDS has already performed any sub-mounts and negotiated
+ * a security flavor.
+ */
+static struct rpc_clnt *
+filelayout_rpc_clnt(struct inode *inode, struct nfs_client *clp)
+{
+	rpc_authflavor_t flav = NFS_SERVER(inode)->client->cl_auth->au_flavor;
+
+	return nfs_get_auth_rpc_client(clp, flav);
+}
+
+void
+filelayout_shutdown_rpc_clnt(struct nfs_client *clp)
+{
+	int i;
+
+	/* The three Kerberos pseudoflavors plus RPC_AUTH_UNIX */
+	for (i = 0; i < RPC_AUTH_MAX_PSEUDO_FLAVOR + 1; i++) {
+		if (!IS_ERR(clp->cl_rpc_clnt[i])) {
+			dprintk("%s shutdown data server client %p index %d\n",
+				__func__, clp->cl_rpc_clnt[i], i);
+			nfs_shutdown_rpc_client(clp, clp->cl_rpc_clnt[i]);
+		}
+	}
+}
+
 static void filelayout_reset_write(struct nfs_write_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
@@ -524,6 +553,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	struct nfs_pgio_header *hdr = data->header;
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
 	loff_t offset = data->args.offset;
 	u32 j, idx;
 	struct nfs_fh *fh;
@@ -538,6 +568,11 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
+
+	ds_clnt = filelayout_rpc_clnt(hdr->inode, ds->ds_clp);
+	if (IS_ERR(ds_clnt))
+		return PNFS_NOT_ATTEMPTED;
+
 	dprintk("%s USE DS: %s cl_count %d\n", __func__,
 		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
 
@@ -552,8 +587,8 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
-				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
+	nfs_initiate_read(ds_clnt, data, &filelayout_read_call_ops,
+			RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
 }
 
@@ -564,6 +599,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	struct nfs_pgio_header *hdr = data->header;
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
 	loff_t offset = data->args.offset;
 	u32 j, idx;
 	struct nfs_fh *fh;
@@ -574,6 +610,11 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
+
+	ds_clnt = filelayout_rpc_clnt(hdr->inode, ds->ds_clp);
+	if (IS_ERR(ds_clnt))
+		return PNFS_NOT_ATTEMPTED;
+
 	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s cl_count %d\n",
 		__func__, hdr->inode->i_ino, sync, (size_t) data->args.count,
 		offset, ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
@@ -591,9 +632,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-	nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
-				    &filelayout_write_call_ops, sync,
-				    RPC_TASK_SOFTCONN);
+	nfs_initiate_write(ds_clnt, data, &filelayout_write_call_ops, sync,
+				RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
 }
 
@@ -1101,16 +1141,19 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 {
 	struct pnfs_layout_segment *lseg = data->lseg;
 	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
 	u32 idx;
 	struct nfs_fh *fh;
 
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
-	if (!ds) {
-		prepare_to_resend_writes(data);
-		filelayout_commit_release(data);
-		return -EAGAIN;
-	}
+	if (!ds)
+		goto out_err;
+
+	ds_clnt = filelayout_rpc_clnt(data->inode, ds->ds_clp);
+	if (IS_ERR(ds_clnt))
+		goto out_err;
+
 	dprintk("%s ino %lu, how %d cl_count %d\n", __func__,
 		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count));
 	data->commit_done_cb = filelayout_commit_done_cb;
@@ -1119,9 +1162,13 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
 		data->args.fh = fh;
-	return nfs_initiate_commit(ds->ds_clp->cl_rpcclient, data,
+	return nfs_initiate_commit(ds_clnt, data,
 				   &filelayout_commit_call_ops, how,
 				   RPC_TASK_SOFTCONN);
+out_err:
+	prepare_to_resend_writes(data);
+	filelayout_commit_release(data);
+	return -EAGAIN;
 }
 
 static int
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index cebd20e..64a2528 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -139,6 +139,9 @@ filelayout_test_devid_invalid(struct nfs4_deviceid_node *node)
 extern bool
 filelayout_test_devid_unavailable(struct nfs4_deviceid_node *node);
 
+extern void
+filelayout_shutdown_rpc_clnt(struct nfs_client *clp);
+
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 95604f6..cc10fd3 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -162,7 +162,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	int status = 0;
 
 	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
-		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
+		mds_srv->client->cl_auth->au_flavor);
 
 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
 		dprintk("%s: DS %s: trying address %s\n",
@@ -203,6 +203,8 @@ destroy_ds(struct nfs4_pnfs_ds *ds)
 	ifdebug(FACILITY)
 		print_ds(ds);
 
+	filelayout_shutdown_rpc_clnt(ds->ds_clp);
+
 	if (ds->ds_clp)
 		nfs_put_client(ds->ds_clp);
 
-- 
1.8.3.1

