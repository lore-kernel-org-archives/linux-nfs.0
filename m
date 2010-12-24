Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60343 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab0LXBcg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 20:32:36 -0500
Received: by iwn9 with SMTP id 9so6655796iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Dec 2010 17:32:36 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Allow walking nfs_client.cl_superblocks list outside
	client.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 23 Dec 2010 20:32:32 -0500
Message-ID: <20101224013232.2445.72763.stgit@matisse.1015granger.net>
In-Reply-To: <20101224012636.2445.41411.stgit@matisse.1015granger.net>
References: <20101224012636.2445.41411.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We're about to move some fields from struct nfs_client to struct
nfs_server.  There is a many-to-one relationship between nfs_servers
and nfs_clients.  After these fields are moved to the nfs_server
struct, to visit all of the data in these fields that is owned by one
nfs_client, code will need to visit each nfs_server on the
cl_superblocks list for that nfs_client.

To serialize changes to the cl_superblocks list during these little
expeditions, protect the list with RCU.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c     |   44 +++++++++++++++++++++++++-------------------
 fs/nfs/nfs4renewd.c |    9 +++++++--
 2 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0870d0d..05e2ee2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -988,6 +988,27 @@ static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_serve
 	target->options = source->options;
 }
 
+static void nfs_server_insert_lists(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+
+	spin_lock(&nfs_client_lock);
+	list_add_tail_rcu(&server->client_link, &clp->cl_superblocks);
+	list_add_tail(&server->master_link, &nfs_volume_list);
+	spin_unlock(&nfs_client_lock);
+
+}
+
+static void nfs_server_remove_lists(struct nfs_server *server)
+{
+	spin_lock(&nfs_client_lock);
+	list_del_rcu(&server->client_link);
+	list_del(&server->master_link);
+	spin_unlock(&nfs_client_lock);
+
+	synchronize_rcu();
+}
+
 /*
  * Allocate and initialise a server record
  */
@@ -1029,11 +1050,8 @@ void nfs_free_server(struct nfs_server *server)
 {
 	dprintk("--> nfs_free_server()\n");
 
+	nfs_server_remove_lists(server);
 	unset_pnfs_layoutdriver(server);
-	spin_lock(&nfs_client_lock);
-	list_del(&server->client_link);
-	list_del(&server->master_link);
-	spin_unlock(&nfs_client_lock);
 
 	if (server->destroy != NULL)
 		server->destroy(server);
@@ -1108,11 +1126,7 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 		(unsigned long long) server->fsid.major,
 		(unsigned long long) server->fsid.minor);
 
-	spin_lock(&nfs_client_lock);
-	list_add_tail(&server->client_link, &server->nfs_client->cl_superblocks);
-	list_add_tail(&server->master_link, &nfs_volume_list);
-	spin_unlock(&nfs_client_lock);
-
+	nfs_server_insert_lists(server);
 	server->mount_time = jiffies;
 	nfs_free_fattr(fattr);
 	return server;
@@ -1342,11 +1356,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
 		server->namelen = NFS4_MAXNAMLEN;
 
-	spin_lock(&nfs_client_lock);
-	list_add_tail(&server->client_link, &server->nfs_client->cl_superblocks);
-	list_add_tail(&server->master_link, &nfs_volume_list);
-	spin_unlock(&nfs_client_lock);
-
+	nfs_server_insert_lists(server);
 	server->mount_time = jiffies;
 out:
 	nfs_free_fattr(fattr);
@@ -1551,11 +1561,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	if (error < 0)
 		goto out_free_server;
 
-	spin_lock(&nfs_client_lock);
-	list_add_tail(&server->client_link, &server->nfs_client->cl_superblocks);
-	list_add_tail(&server->master_link, &nfs_volume_list);
-	spin_unlock(&nfs_client_lock);
-
+	nfs_server_insert_lists(server);
 	server->mount_time = jiffies;
 
 	nfs_free_fattr(fattr_fsinfo);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 72b6c58..cde5650 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -63,9 +63,14 @@ nfs4_renew_state(struct work_struct *work)
 
 	ops = clp->cl_mvops->state_renewal_ops;
 	dprintk("%s: start\n", __func__);
-	/* Are there any active superblocks? */
-	if (list_empty(&clp->cl_superblocks))
+
+	rcu_read_lock();
+	if (list_empty(&clp->cl_superblocks)) {
+		rcu_read_unlock();
 		goto out;
+	}
+	rcu_read_unlock();
+
 	spin_lock(&clp->cl_lock);
 	lease = clp->cl_lease_time;
 	last = clp->cl_last_renewal;

