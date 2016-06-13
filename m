Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:40072 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422983AbcFMSwG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 14:52:06 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 4746628014E
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 20:52:04 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 2C08513E83
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 20:52:04 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4: flexfiles: respect noresvport when establishing connections to DSes
Date: Mon, 13 Jun 2016 20:52:00 +0200
Message-Id: <1465843920-2785-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/internal.h   | 2 +-
 fs/nfs/nfs3client.c | 9 ++++++---
 fs/nfs/pnfs_nfs.c   | 4 ++--
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 67b9345..8c1e4d7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -193,7 +193,7 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 					     rpc_authflavor_t au_flavor);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
 						struct inode *);
-extern struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
+extern struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 			const struct sockaddr *ds_addr, int ds_addrlen,
 			int ds_proto, unsigned int ds_timeo,
 			unsigned int ds_retrans, rpc_authflavor_t au_flavor);
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 9e9fa34..e0c9678 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -76,7 +76,7 @@ struct nfs_server *nfs3_clone_server(struct nfs_server *source,
  * low timeout interval so that if a connection is lost, we retry through
  * the MDS.
  */
-struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
+struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		const struct sockaddr *ds_addr, int ds_addrlen,
 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
 		rpc_authflavor_t au_flavor)
@@ -86,7 +86,7 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
 		.addrlen = ds_addrlen,
 		.nfs_mod = &nfs_v3,
 		.proto = ds_proto,
-		.net = mds_clp->cl_net,
+		.net = mds_srv->nfs_client->cl_net,
 	};
 	struct rpc_timeout ds_timeout;
 	struct nfs_client *clp;
@@ -97,9 +97,12 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
 		return ERR_PTR(-EINVAL);
 	cl_init.hostname = buf;
 
+	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
+		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+
 	/* Use the MDS nfs_client cl_ipaddr. */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
-	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
+	clp = nfs_get_client(&cl_init, &ds_timeout, mds_srv->nfs_client->cl_ipaddr,
 			     au_flavor);
 
 	return clp;
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index a3e3157..7b7244f 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -587,7 +587,7 @@ static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
 }
 
 static struct nfs_client *(*get_v3_ds_connect)(
-			struct nfs_client *mds_clp,
+			struct nfs_server *mds_srv,
 			const struct sockaddr *ds_addr,
 			int ds_addrlen,
 			int ds_proto,
@@ -646,7 +646,7 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 			rpc_clnt_add_xprt(clp->cl_rpcclient, &xprt_args,
 					rpc_clnt_test_and_add_xprt, NULL);
 		} else
-			clp = get_v3_ds_connect(mds_srv->nfs_client,
+			clp = get_v3_ds_connect(mds_srv,
 					(struct sockaddr *)&da->da_addr,
 					da->da_addrlen, IPPROTO_TCP,
 					timeo, retrans, au_flavor);
-- 
2.5.5

