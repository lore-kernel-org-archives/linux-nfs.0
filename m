Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13760 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752Ab3IFSOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 14:14:08 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 1/1] NFSv4.1 Use MDS auth flavor for data server connection
Date: Fri, 6 Sep 2013 14:14:00 -0400
Message-ID: <1378491240-1848-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
uses the nfs_client cl_rpcclient for all state management operations, and
will use krb5i or auth_sys with no regard to the mount command authflavor
choice.

The MDS, as any NFSv4.1 mount point, uses the nfs_server rpc client for all
non-state management operations with a different nfs_server for each fsid
encountered traversing the mount point, each with a potentially different
auth flavor.

pNFS data servers are not mounted in the normal sense as there is no associated
nfs_server structure. Data servers can also export multiple fsids, each with
a potentially different auth flavor.

Data servers need to use the same authflavor as the MDS server rpc client for
non-state management operations. Populate a list of rpc clients with the MDS
server rpc client auth flavor for the DS to use.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h         |   2 +
 fs/nfs/nfs4client.c       | 116 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4filelayout.c   |  35 ++++++++++----
 include/linux/nfs_fs_sb.h |   1 +
 4 files changed, 146 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2415198..23ec6e8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -186,6 +186,8 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
 					     unsigned int ds_retrans);
+extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
+						struct inode *);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 98c0104..f798925 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -41,9 +41,124 @@ static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 }
 
 #ifdef CONFIG_NFS_V4_1
+/**
+ * Per auth flavor data server rpc clients
+ */
+struct nfs4_ds_server {
+	struct list_head	list;   /* ds_clp->cl_ds_clients */
+	struct rpc_clnt		*rpc_clnt;
+};
+
+/**
+ * Common lookup case for DS I/O
+ */
+static struct nfs4_ds_server *
+nfs4_find_ds_client(struct nfs_client *ds_clp, rpc_authflavor_t flavor)
+{
+	struct nfs4_ds_server *dss;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(dss, &ds_clp->cl_ds_clients, list) {
+		if (dss->rpc_clnt->cl_auth->au_flavor != flavor)
+			continue;
+		goto out;
+	}
+	dss = NULL;
+out:
+	rcu_read_unlock();
+	return dss;
+}
+
+static struct nfs4_ds_server *
+nfs4_add_ds_client(struct nfs_client *ds_clp, rpc_authflavor_t flavor,
+			   struct nfs4_ds_server *new)
+{
+	struct nfs4_ds_server *dss;
+
+	spin_lock(&ds_clp->cl_lock);
+	list_for_each_entry(dss, &ds_clp->cl_ds_clients, list) {
+		if (dss->rpc_clnt->cl_auth->au_flavor != flavor)
+			continue;
+		goto out;
+	}
+	if (new)
+		list_add_rcu(&new->list, &ds_clp->cl_ds_clients);
+	dss = new;
+out:
+	spin_unlock(&ds_clp->cl_lock); /* need some lock to protect list */
+	return dss;
+}
+
+static struct nfs4_ds_server *
+nfs4_alloc_ds_server(struct nfs_client *ds_clp, rpc_authflavor_t flavor)
+{
+	struct nfs4_ds_server *dss;
+
+	dss = kmalloc(sizeof(*dss), GFP_NOFS);
+	if (dss == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	dss->rpc_clnt = rpc_clone_client_set_auth(ds_clp->cl_rpcclient, flavor);
+	if (IS_ERR(dss->rpc_clnt)) {
+		int err = PTR_ERR(dss->rpc_clnt);
+		kfree (dss);
+		return ERR_PTR(err);
+	}
+	INIT_LIST_HEAD(&dss->list);
+
+	return dss;
+}
+
+static void
+nfs4_free_ds_server(struct nfs4_ds_server *dss)
+{
+	rpc_release_client(dss->rpc_clnt);
+	kfree(dss);
+}
+
+/**
+* Find or create a DS rpc client with th MDS server rpc client auth flavor
+* in the nfs_client cl_ds_clients list.
+*/
+struct rpc_clnt *
+nfs4_find_or_create_ds_client(struct nfs_client *ds_clp, struct inode *inode)
+{
+	struct nfs4_ds_server *dss, *new;
+	rpc_authflavor_t flavor = NFS_SERVER(inode)->client->cl_auth->au_flavor;
+
+	dss = nfs4_find_ds_client(ds_clp, flavor);
+	if (dss != NULL)
+		goto out;
+	new = nfs4_alloc_ds_server(ds_clp, flavor);
+	if (IS_ERR(new))
+		return ERR_CAST(new);
+	dss = nfs4_add_ds_client(ds_clp, flavor, new);
+	if (dss != new)
+		nfs4_free_ds_server(new);
+out:
+	return dss->rpc_clnt;
+}
+EXPORT_SYMBOL_GPL(nfs4_find_or_create_ds_client);
+
+static void
+nfs4_shutdown_ds_clients(struct nfs_client *clp)
+{
+	struct nfs4_ds_server *dss;
+	LIST_HEAD(shutdown_list);
+
+	while (!list_empty(&clp->cl_ds_clients)) {
+		dss = list_entry(clp->cl_ds_clients.next,
+					struct nfs4_ds_server, list);
+		list_del(&dss->list);
+		rpc_shutdown_client(dss->rpc_clnt);
+		kfree (dss);
+	}
+}
+
 void nfs41_shutdown_client(struct nfs_client *clp)
 {
 	if (nfs4_has_session(clp)) {
+		nfs4_shutdown_ds_clients(clp);
 		nfs4_destroy_session(clp->cl_session);
 		nfs4_destroy_clientid(clp);
 	}
@@ -77,6 +192,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
+	INIT_LIST_HEAD(&clp->cl_ds_clients);
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index a70cb3a..b86464b 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -528,6 +528,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	struct nfs_pgio_header *hdr = data->header;
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
 	loff_t offset = data->args.offset;
 	u32 j, idx;
 	struct nfs_fh *fh;
@@ -542,6 +543,11 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
+
+	ds_clnt = nfs4_find_or_create_ds_client(ds->ds_clp, hdr->inode);
+	if (IS_ERR(ds_clnt))
+		return PNFS_NOT_ATTEMPTED;
+
 	dprintk("%s USE DS: %s cl_count %d\n", __func__,
 		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
 
@@ -556,7 +562,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
+	nfs_initiate_read(ds_clnt, data,
 				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
 }
@@ -568,6 +574,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	struct nfs_pgio_header *hdr = data->header;
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
 	loff_t offset = data->args.offset;
 	u32 j, idx;
 	struct nfs_fh *fh;
@@ -578,6 +585,11 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds)
 		return PNFS_NOT_ATTEMPTED;
+
+	ds_clnt = nfs4_find_or_create_ds_client(ds->ds_clp, hdr->inode);
+	if (IS_ERR(ds_clnt))
+		return PNFS_NOT_ATTEMPTED;
+
 	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s cl_count %d\n",
 		__func__, hdr->inode->i_ino, sync, (size_t) data->args.count,
 		offset, ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
@@ -595,7 +607,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-	nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
+	nfs_initiate_write(ds_clnt, data,
 				    &filelayout_write_call_ops, sync,
 				    RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
@@ -1105,16 +1117,19 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
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
+	ds_clnt = nfs4_find_or_create_ds_client(ds->ds_clp, data->inode);
+	if (IS_ERR(ds_clnt))
+		goto out_err;
+
 	dprintk("%s ino %lu, how %d cl_count %d\n", __func__,
 		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count));
 	data->commit_done_cb = filelayout_commit_done_cb;
@@ -1123,9 +1138,13 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
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
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e8ff178..b8cedce 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -56,6 +56,7 @@ struct nfs_client {
 	struct rpc_cred		*cl_machine_cred;
 
 #if IS_ENABLED(CONFIG_NFS_V4)
+	struct list_head	cl_ds_clients; /* auth flavor data servers */
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
-- 
1.8.3.1

