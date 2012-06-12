Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906Ab2FLOja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jun 2012 10:39:30 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 Fix umount when filelayout DS is also the MDS
Date: Tue, 12 Jun 2012 10:39:26 -0400
Message-Id: <1339511966-2448-2-git-send-email-andros@netapp.com>
In-Reply-To: <1339511966-2448-1-git-send-email-andros@netapp.com>
References: <1339511966-2448-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Add a secondary creation count to struct nfs_client to handle the corner case
when a file layout data server is also the mounted MDS, and shares the
cl_session. In this case, a umount of the MDS should not destroy the nfs_client
as it could still be in use as a DS (only) for another deviceid/MDS.

Currently there is a 'chicken and egg' issue when the DS is also the mounted
MDS. The nfs_match_client() reference from nfs4_set_ds_client bumps the
cl_count, the nfs_client is not freed at umount, and nfs4_deviceid_purge_client
is not called to dereference the MDS usage of a deviceid which holds a
reference to the DS nfs_client.  The result is the umount program returns,
but the nfs_client is not freed, and the cl_session hearbeat continues.

The MDS (and all other nfs mounts) lose their last nfs_client reference in
nfs_free_server when the last nfs_server (fsid) is umounted.
The file layout DS lose their last nfs_client reference in destroy_ds
when the last deviceid referencing the data server is put and destroy_ds is
called. This is triggered by a call to nfs4_deviceid_purge_client which
removes references to a pNFS deviceid used by an MDS mount.

The new cl_ds_count is an additional 'creation' reference for a file layout
data server struct nfs_client. When an nfs_client is a DS,
the cl_ds_count is incremented from 0 to 1, and decremented from 1 to zero
in destroy_ds called on the last deviceid reference to the data server.

Both the cl_count and the cl_ds_count must be zero to free the nfs_client.

With the cl_ds_count, when the DS is also an MDS, the nfs_match_client
reference from nfs4_set_ds_client triggered by the DS finding the existing
MDS nfs_client is dropped so that the umount call to nfs_free_server
dereferences the (MDS) cl_count to 0. But since the cl_ds_count
is 1, the nfs_client struct is not freed.  Instead, nfs4_deviceid_purge_client
is called to dereference the umounted MDS deviceids. The deviceid in
turn dereferences the data server.

When the DS is not the mounted MDS, the final nfs_client cl_count reference is
dropped in destroy_ds.

Reported-by: Jorge Mora <jorge.mora@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |   71 ++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h          |    1 +
 fs/nfs/nfs4filelayoutdev.c |   29 +++++++++++++++--
 include/linux/nfs_fs_sb.h  |    1 +
 4 files changed, 95 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 17ba6b9..2f83736 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -159,6 +159,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->rpc_ops = cl_init->rpc_ops;
 
 	atomic_set(&clp->cl_count, 1);
+	atomic_set(&clp->cl_ds_count, 0);
 	clp->cl_cons_state = NFS_CS_INITING;
 
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
@@ -316,18 +317,64 @@ static void nfs_free_client(struct nfs_client *clp)
 
 /*
  * Release a reference to a shared client record
+ *
+ * A secondary creation count is added to struct nfs_client to handle the
+ * corner case when a file layout data server is also the mounted MDS, and
+ * shares the cl_session. In this case, a umount of the MDS should not destroy
+ * the nfs_client as it could still be in use as a DS (only) for another
+ * deviceid/MDS.
+ *
+ * Both cl_count and ds_cl_count must be zero to free the nfs_client.
+ *
+ * The cl_ds_count is an additional 'creation' reference for a file layout
+ * data server struct nfs_client. When an nfs_client is a DS,
+ * the cl_ds_count is incremented from 0 to 1, and decremented from 1 to zero
+ * in destroy_ds called on the last deviceid reference to the data server.
+ *
+ * With the cl_ds_count, when the DS is also an MDS, the nfs_match_client
+ * reference from nfs4_set_ds_client is dropped so that the umount call to
+ * nfs_free_server dereferences the cl_count to 0. But since the cl_ds_count
+ * is 1, the nfs_client struct is not freed. Instead,nfs4_deviceid_purge_client
+ * is called to dereference the newly umounted MDS deviceids. The deviceid in
+ * turn dereferences the data server.
  */
-void nfs_put_client(struct nfs_client *clp)
+void _nfs_put_client(struct nfs_client *clp, bool is_ds_call)
 {
 	struct nfs_net *nn;
+	atomic_t *primary = &clp->cl_count, *secondary = &clp->cl_ds_count;
 
 	if (!clp)
 		return;
 
-	dprintk("--> nfs_put_client({%d})\n", atomic_read(&clp->cl_count));
+	dprintk("--> nfs_put_client ({%d, %d})\n", atomic_read(&clp->cl_count),
+		atomic_read(&clp->cl_ds_count));
+
+	if (is_ds_call) {
+		primary = &clp->cl_ds_count;
+		secondary = &clp->cl_count;
+	}
 	nn = net_generic(clp->cl_net, nfs_net_id);
 
-	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
+	/* Dereference the primary count and inspect the secondary count */
+	if (atomic_dec_and_lock(primary, &nn->nfs_client_lock)) {
+		if (atomic_read(secondary) != 0) {
+			spin_unlock(&nn->nfs_client_lock);
+			if (is_ds_call == false) {
+				/*
+				 * This is an MDS-DS nfs_client. The MDS
+				 * use of this nfs_client struct is complete.
+				 * Call nfs4_deviceid_purge client to
+				 * dereference this MDS's use of deviceids
+				 * which in turn dereference DSs.
+				 * The nfs_client will be freed upon last
+				 * deviceid DS reference.
+				 */
+				dprintk("%s Calling deviceid purge on %p\n",
+					__func__, clp);
+				nfs4_deviceid_purge_client(clp);
+			}
+			return;
+		}
 		list_del(&clp->cl_share_link);
 		nfs_cb_idr_remove_locked(clp);
 		spin_unlock(&nn->nfs_client_lock);
@@ -337,8 +384,19 @@ void nfs_put_client(struct nfs_client *clp)
 		nfs_free_client(clp);
 	}
 }
+
+void nfs_put_client(struct nfs_client *clp)
+{
+	_nfs_put_client(clp, false);
+}
 EXPORT_SYMBOL_GPL(nfs_put_client);
 
+void nfs_put_ds_client(struct nfs_client *clp)
+{
+	_nfs_put_client(clp, true);
+}
+EXPORT_SYMBOL_GPL(nfs_put_ds_client);
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 /*
  * Test if two ip6 socket addresses refer to the same socket by
@@ -1511,6 +1569,13 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
 			     mds_clp->cl_rpcclient->cl_auth->au_flavor);
 
+	/*
+	 * Data servers use the cl_ds_count as an additional creation reference
+	 * for the case when a DS is also the MDS. Balanced in destroy_ds.
+	 */
+	if (!IS_ERR(clp))
+		atomic_inc(&clp->cl_ds_count);
+
 	dprintk("<-- %s %p\n", __func__, clp);
 	return clp;
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 18f99ef..d31a2c1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -151,6 +151,7 @@ extern void nfs_clients_init(struct net *net);
 
 extern void nfs_cleanup_cb_ident_idr(struct net *);
 extern void nfs_put_client(struct nfs_client *);
+extern void nfs_put_ds_client(struct nfs_client *);
 extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f81231f..91491c9 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -190,6 +190,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		dprintk("%s: DS %s: trying address %s\n",
 			__func__, ds->ds_remotestr, da->da_remotestr);
 
+		/* References clp->cl_ds_count */
 		clp = nfs4_set_ds_client(mds_srv->nfs_client,
 					(struct sockaddr *)&da->da_addr,
 					da->da_addrlen, IPPROTO_TCP,
@@ -203,6 +204,17 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		goto out;
 	}
 
+	/*
+	 * If DS is the MDS drop the nfs_match_client reference which
+	 * is for mulitple nfs_servers referencing the nfs_client and is
+	 * dereferenced at each nfs_server umount.
+	 * Data servers use the cl_ds_count instead so that the nfs_client
+	 * can still serve as a DS (if so configured) after the umount
+	 * of the MDS.
+	 */
+	if (clp == mds_srv->nfs_client)
+		nfs_put_client(clp);
+
 	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
 	if (status)
 		goto out_put;
@@ -217,7 +229,7 @@ out_put:
 }
 
 static void
-destroy_ds(struct nfs4_pnfs_ds *ds)
+destroy_ds(struct nfs4_pnfs_ds *ds, const struct nfs_client *mds_clp)
 {
 	struct nfs4_pnfs_ds_addr *da;
 
@@ -225,8 +237,17 @@ destroy_ds(struct nfs4_pnfs_ds *ds)
 	ifdebug(FACILITY)
 		print_ds(ds);
 
-	if (ds->ds_clp)
-		nfs_put_client(ds->ds_clp);
+	if (ds->ds_clp) {
+		/* Drop the cl_ds_count creation reference */
+		nfs_put_ds_client(ds->ds_clp);
+		/*
+		 * If DS is not the MDS, dereference the cl_count
+		 * (dereferenced by nfs_free_server if the DS is the MDS).
+		 * Balances the inital SET of cl_count.
+		 */
+		if (ds->ds_clp != mds_clp)
+			nfs_put_client(ds->ds_clp);
+	}
 
 	while (!list_empty(&ds->ds_addrs)) {
 		da = list_first_entry(&ds->ds_addrs,
@@ -256,7 +277,7 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 						&nfs4_ds_cache_lock)) {
 				list_del_init(&ds->ds_node);
 				spin_unlock(&nfs4_ds_cache_lock);
-				destroy_ds(ds);
+				destroy_ds(ds, dsaddr->id_node.nfs_client);
 			}
 		}
 	}
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index fbb78fb..7f0304d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -25,6 +25,7 @@ struct nfs41_impl_id;
  */
 struct nfs_client {
 	atomic_t		cl_count;
+	atomic_t		cl_ds_count;
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
-- 
1.7.6.4

