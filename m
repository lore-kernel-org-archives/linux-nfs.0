Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:53593 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754725AbdKJWhi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 17:37:38 -0500
Received: by mail-it0-f66.google.com with SMTP id m191so3393145itg.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2017 14:37:37 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v2 6/7] NFS: Propagate NFS_MOUNT_UNSHARED to clients
Date: Fri, 10 Nov 2017 16:37:06 -0600
Message-Id: <20171110223707.17098-7-JPEWhacker@gmail.com>
In-Reply-To: <20171110223707.17098-1-JPEWhacker@gmail.com>
References: <20171110223707.17098-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Propagating the flag allows operations to be performed on the client
without affecting other mounts to the same client, much like operations
on the superblock will not affect other superblocks.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/client.c           | 9 +++++++--
 fs/nfs/nfs3client.c       | 2 ++
 fs/nfs/nfs4client.c       | 4 ++++
 include/linux/nfs_fs_sb.h | 1 +
 4 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 22880ef6d8dd..c5872286f322 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -297,6 +297,10 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		if (clp->cl_cons_state < 0)
 			continue;
 
+		/* Don't match clients that don't want to be shared */
+		if (test_bit(NFS_CS_UNSHARED, &clp->cl_flags))
+			continue;
+
 		/* Different NFS versions cannot share the same nfs_client */
 		if (clp->rpc_ops != data->nfs_mod->rpc_ops)
 			continue;
@@ -386,7 +390,7 @@ nfs_found_client(const struct nfs_client_initdata *cl_init,
  */
 struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 {
-	struct nfs_client *clp, *new = NULL;
+	struct nfs_client *clp = NULL, *new = NULL;
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
 	const struct nfs_rpc_ops *rpc_ops = cl_init->nfs_mod->rpc_ops;
 
@@ -399,7 +403,8 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 	do {
 		spin_lock(&nn->nfs_client_lock);
 
-		clp = nfs_match_client(cl_init);
+		if (!test_bit(NFS_CS_UNSHARED, &cl_init->init_flags))
+			clp = nfs_match_client(cl_init);
 		if (clp) {
 			spin_unlock(&nn->nfs_client_lock);
 			if (new)
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 7879f2a0fcfd..b62bed41053f 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -102,6 +102,8 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 
 	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+	if (mds_srv->flags & NFS_MOUNT_UNSHARED)
+		__set_bit(NFS_CS_UNSHARED, &cl_init.init_flags);
 
 	/* Use the MDS nfs_client cl_ipaddr. */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index e9bea90dc017..e51467f5b3bc 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -852,6 +852,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
 	if (test_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status))
 		set_bit(NFS_CS_TSM_POSSIBLE, &cl_init.init_flags);
+	if (server->flags & NFS_MOUNT_UNSHARED)
+		__set_bit(NFS_CS_UNSHARED, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init);
@@ -910,6 +912,8 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 
 	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
 		__set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+	if (mds_srv->flags & NFS_MOUNT_UNSHARED)
+		__set_bit(NFS_CS_UNSHARED, &cl_init.init_flags);
 
 	/*
 	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 286b71c418b4..8761f729921a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -44,6 +44,7 @@ struct nfs_client {
 #define NFS_CS_INFINITE_SLOTS	3		/* - don't limit TCP slots */
 #define NFS_CS_NO_RETRANS_TIMEOUT	4	/* - Disable retransmit timeouts */
 #define NFS_CS_TSM_POSSIBLE	5		/* - Maybe state migration */
+#define NFS_CS_UNSHARED		6		/* - Client state is not shared */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
-- 
2.13.6

