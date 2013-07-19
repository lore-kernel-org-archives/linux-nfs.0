Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26225 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939Ab3GSVGo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 17:06:44 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 2/2] NFSv4.1 Use the MDS nfs_server authflavor for pNFS data server connections
Date: Fri, 19 Jul 2013 17:06:37 -0400
Message-ID: <1374267997-4305-2-git-send-email-andros@netapp.com>
In-Reply-To: <1374267997-4305-1-git-send-email-andros@netapp.com>
References: <1374267997-4305-1-git-send-email-andros@netapp.com>
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

Data servers also need to use the same authflavor as the MDS mount for
non-state management operations. Add a strut rpc_clnt to struct nfs_client for
data server connections.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            | 16 +++++++++++++---
 fs/nfs/nfs4filelayout.c    |  6 +++---
 fs/nfs/nfs4filelayoutdev.c | 16 +++++++++++++++-
 include/linux/nfs_fs_sb.h  |  1 +
 4 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2dceee4..b803bad 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -177,6 +177,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 
 	INIT_LIST_HEAD(&clp->cl_superblocks);
 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
+	clp->cl_dsrpcclient = ERR_PTR(-EINVAL);
 
 	clp->cl_proto = cl_init->proto;
 	clp->cl_net = get_net(cl_init->net);
@@ -595,8 +596,13 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 	if (test_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags))
 		args.flags |= RPC_CLNT_CREATE_INFINITE_SLOTS;
 
-	if (!IS_ERR(clp->cl_rpcclient))
-		return 0;
+	if (is_ds_client(clp)) {
+		if (IS_ERR(clp->cl_rpcclient) || !IS_ERR(clp->cl_dsrpcclient))
+			return 0;
+	} else {
+		if (!IS_ERR(clp->cl_rpcclient))
+			return 0;
+	}
 
 	clnt = rpc_create(&args);
 	if (IS_ERR(clnt)) {
@@ -605,7 +611,11 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		return PTR_ERR(clnt);
 	}
 
-	clp->cl_rpcclient = clnt;
+	if (is_ds_client(clp))
+		clp->cl_dsrpcclient = clnt;
+	else
+		clp->cl_rpcclient = clnt;
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 17ed87e..3fe1491 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -552,7 +552,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
+	nfs_initiate_read(ds->ds_clp->cl_dsrpcclient, data,
 				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
 }
@@ -591,7 +591,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-	nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
+	nfs_initiate_write(ds->ds_clp->cl_dsrpcclient, data,
 				    &filelayout_write_call_ops, sync,
 				    RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
@@ -1119,7 +1119,7 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
 		data->args.fh = fh;
-	return nfs_initiate_commit(ds->ds_clp->cl_rpcclient, data,
+	return nfs_initiate_commit(ds->ds_clp->cl_dsrpcclient, data,
 				   &filelayout_commit_call_ops, how,
 				   RPC_TASK_SOFTCONN);
 }
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 95604f6..46f1b13 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -159,10 +159,11 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs4_pnfs_ds_addr *da;
+	struct rpc_timeout ds_timeout;
 	int status = 0;
 
 	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
-		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
+		mds_srv->client->cl_auth->au_flavor);
 
 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
 		dprintk("%s: DS %s: trying address %s\n",
@@ -185,7 +186,20 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	if (status)
 		goto out_put;
 
+	nfs_init_timeout_values(&ds_timeout, IPPROTO_TCP, dataserver_timeo,
+				dataserver_retrans);
+	spin_lock(&clp->cl_lock);
+	status = nfs_create_rpc_client(clp, &ds_timeout,
+					mds_srv->client->cl_auth->au_flavor);
+	spin_unlock(&clp->cl_lock);
+
+	if (IS_ERR(clp->cl_dsrpcclient))
+		status = PTR_ERR(clp->cl_dsrpcclient);
+	if (status < 0)
+		goto out_put;
+
 	ds->ds_clp = clp;
+
 	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
 out:
 	return status;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d221243..81c99a5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -56,6 +56,7 @@ struct nfs_client {
 	struct rpc_cred		*cl_machine_cred;
 
 #if IS_ENABLED(CONFIG_NFS_V4)
+	struct rpc_clnt *	cl_dsrpcclient; /* pNFS Data Server */
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
-- 
1.8.3.1

