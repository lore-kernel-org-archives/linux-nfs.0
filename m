From: andros@netapp.com
Subject: [PATCH 13/14] SQUASHME pnfs_submit: stand alone data server cache
Date: Thu,  8 Apr 2010 15:54:09 -0400
Message-ID: <1270756450-5570-14-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
 <1270756450-5570-5-git-send-email-andros@netapp.com>
 <1270756450-5570-6-git-send-email-andros@netapp.com>
 <1270756450-5570-7-git-send-email-andros@netapp.com>
 <1270756450-5570-8-git-send-email-andros@netapp.com>
 <1270756450-5570-9-git-send-email-andros@netapp.com>
 <1270756450-5570-10-git-send-email-andros@netapp.com>
 <1270756450-5570-11-git-send-email-andros@netapp.com>
 <1270756450-5570-12-git-send-email-andros@netapp.com>
 <1270756450-5570-13-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933349Ab0DHTy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:58 -0400
In-Reply-To: <1270756450-5570-13-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Data servers can be associated with any device ID from any server.
Multiple file layout meta data servers can share a data server.
Implement a stand alone data server cache to share data servers and
their session between deviceid's and meta data servers.

The data server cache is only changed at GETDEVICEINFO return or umount.
Once in the cache and referenced by a deviceid structure, the use of the
data server in the I/O path is via deviceid struct array indexes.
Therefore, nether an hlist nor rwspin locks are needed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.h    |    3 +-
 fs/nfs/nfs4filelayoutdev.c |   57 ++++++++++++++++---------------------------
 2 files changed, 22 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index e988891..809747f 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -34,7 +34,7 @@ enum stripetype4 {
 
 /* Individual ip address */
 struct nfs4_pnfs_ds {
-	struct hlist_node 	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
+	struct list_head 	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
 	u32 			ds_ip_addr;
 	u32 			ds_port;
 	struct nfs_client	*ds_clp;
@@ -54,7 +54,6 @@ struct nfs4_file_layout_dsaddr {
 struct nfs4_pnfs_dev_hlist {
 	rwlock_t		dev_lock;
 	struct hlist_head	dev_list[NFS4_PNFS_DEV_HASH_SIZE];
-	struct hlist_head	dev_dslist[NFS4_PNFS_DEV_HASH_SIZE];
 };
 
 /*
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 2d98ca3..50e2865 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -52,6 +52,9 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
+DEFINE_SPINLOCK(nfs4_ds_cache_lock);
+static LIST_HEAD(nfs4_data_server_cache);
+
 void
 print_ds(struct nfs4_pnfs_ds *ds)
 {
@@ -131,21 +134,16 @@ _device_lookup(struct nfs4_pnfs_dev_hlist *hlist,
 	return NULL;
 }
 
-/* Assumes lock is held */
+/* nfs4_ds_cache_lock is held */
 static inline struct nfs4_pnfs_ds *
-_data_server_lookup(struct nfs4_pnfs_dev_hlist *hlist, u32 ip_addr, u32 port)
+_data_server_lookup(u32 ip_addr, u32 port)
 {
-	unsigned long      hash;
-	struct hlist_node *np;
+	struct nfs4_pnfs_ds *ds;
 
 	dprintk("_data_server_lookup: ip_addr=%x port=%hu\n",
 			ntohl(ip_addr), ntohs(port));
 
-	hash = hash_long(ip_addr, NFS4_PNFS_DEV_HASH_BITS);
-
-	hlist_for_each(np, &hlist->dev_dslist[hash]) {
-		struct nfs4_pnfs_ds *ds;
-		ds = hlist_entry(np, struct nfs4_pnfs_ds, ds_node);
+	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
 		if (ds->ds_ip_addr == ip_addr &&
 		    ds->ds_port == port) {
 			return ds;
@@ -170,19 +168,6 @@ _device_add(struct nfs4_pnfs_dev_hlist *hlist,
 	hlist_add_head(&dsaddr->hash_node, &hlist->dev_list[hash]);
 }
 
-/* Assumes lock is held */
-static inline void
-_data_server_add(struct nfs4_pnfs_dev_hlist *hlist, struct nfs4_pnfs_ds *ds)
-{
-	unsigned long      hash;
-
-	dprintk("_data_server_add: ip_addr=%x port=%hu\n",
-			ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
-
-	hash = hash_long(ds->ds_ip_addr, NFS4_PNFS_DEV_HASH_BITS);
-	hlist_add_head(&ds->ds_node, &hlist->dev_dslist[hash]);
-}
-
 /* Create an rpc to the data server defined in 'dev_list' */
 static int
 nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
@@ -295,7 +280,7 @@ nfs4_pnfs_device_destroy(struct nfs4_file_layout_dsaddr *dsaddr,
 			 struct nfs4_pnfs_dev_hlist *hlist)
 {
 	struct nfs4_pnfs_ds *ds;
-	HLIST_HEAD(release);
+	LIST_HEAD(release);
 	int i;
 
 	if (!dsaddr)
@@ -312,16 +297,18 @@ nfs4_pnfs_device_destroy(struct nfs4_file_layout_dsaddr *dsaddr,
 		ds = dsaddr->ds_list[i];
 		if (ds != NULL) {
 			/* if we are last user - move to release list */
-			if (atomic_dec_and_test(&ds->ds_count)) {
-				hlist_del_init(&ds->ds_node);
-				hlist_add_head(&ds->ds_node, &release);
+			if (atomic_dec_and_lock(&ds->ds_count,
+						&nfs4_ds_cache_lock)) {
+				list_del_init(&ds->ds_node);
+				spin_unlock(&nfs4_ds_cache_lock);
+				list_add(&ds->ds_node, &release);
 			}
 		}
 	}
 	write_unlock(&hlist->dev_lock);
-	while (!hlist_empty(&release)) {
-		ds = hlist_entry(release.first, struct nfs4_pnfs_ds, ds_node);
-		hlist_del(&ds->ds_node);
+	while (!list_empty(&release)) {
+		ds = list_entry(release.next, struct nfs4_pnfs_ds, ds_node);
+		list_del(&ds->ds_node);
 		destroy_ds(ds);
 	}
 	kfree(dsaddr);
@@ -336,7 +323,6 @@ nfs4_pnfs_devlist_init(struct nfs4_pnfs_dev_hlist *hlist)
 
 	for (i = 0; i < NFS4_PNFS_DEV_HASH_SIZE; i++) {
 		INIT_HLIST_HEAD(&hlist->dev_list[i]);
-		INIT_HLIST_HEAD(&hlist->dev_dslist[i]);
 	}
 
 	return 0;
@@ -402,7 +388,6 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 		 u32 ip_addr, u32 port, char *r_addr, int len)
 {
 	struct nfs4_pnfs_ds *tmp_ds, *ds;
-	struct nfs4_pnfs_dev_hlist *hlist = FILE_MT(inode)->hlist;
 
 	*dsp = NULL;
 
@@ -415,15 +400,15 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 	ds->ds_port = port;
 	strncpy(ds->r_addr, r_addr, len);
 	atomic_set(&ds->ds_count, 1);
-	INIT_HLIST_NODE(&ds->ds_node);
+	INIT_LIST_HEAD(&ds->ds_node);
 	ds->ds_clp = NULL;
 
-	write_lock(&hlist->dev_lock);
-	tmp_ds = _data_server_lookup(hlist, ip_addr, port);
+	spin_lock(&nfs4_ds_cache_lock);
+	tmp_ds = _data_server_lookup(ip_addr, port);
 	if (tmp_ds == NULL) {
 		dprintk("%s add new data server ip 0x%x\n", __func__,
 				ds->ds_ip_addr);
-		_data_server_add(hlist, ds);
+		list_add(&ds->ds_node, &nfs4_data_server_cache);
 		*dsp = ds;
 	}
 	if (tmp_ds != NULL) {
@@ -434,7 +419,7 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 				atomic_read(&tmp_ds->ds_count));
 		*dsp = tmp_ds;
 	}
-	write_unlock(&hlist->dev_lock);
+	spin_unlock(&nfs4_ds_cache_lock);
 }
 
 static struct nfs4_pnfs_ds *
-- 
1.6.6

