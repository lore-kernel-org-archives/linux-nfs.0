Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50797 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069Ab1E2STa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:19:30 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/32] NFSv4.1: use layout driver in global device cache
Date: Sun, 29 May 2011 21:19:19 +0300
Message-Id: <1306693159-7902-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

pnfs deviceids are unique per server, per layout type.
struct nfs_client is currently used to distinguish deviceids from
different nfs servers, yet these may clash between different layout
types on the same server.  Therefore, use the layout driver associated
with each deviceid at insertion time to look it up, unhash, or
delete it.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c  |    2 +-
 fs/nfs/nfs4filelayout.c |    3 ++-
 fs/nfs/pnfs.h           |    6 +++---
 fs/nfs/pnfs_dev.c       |   28 +++++++++++++++++-----------
 4 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fb5e5b9..c73e7b2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -278,7 +278,7 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
 			dprintk("%s: NOTIFY_DEVICEID4_CHANGE not supported, "
 				"deleting instead\n", __func__);
-		nfs4_delete_deviceid(clp, &dev->cbd_dev_id);
+		nfs4_delete_deviceid(server->pnfs_curr_ld, clp, &dev->cbd_dev_id);
 	}
 
 out:
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index cd289d9..501a9b8 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -441,7 +441,8 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	}
 
 	/* find and reference the deviceid */
-	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode)->nfs_client, id);
+	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode)->pnfs_curr_ld,
+				   NFS_SERVER(lo->plh_inode)->nfs_client, id);
 	if (d == NULL) {
 		dsaddr = get_device_info(lo->plh_inode, id, gfp_flags);
 		if (dsaddr == NULL)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index fbd3f7c..5b083d2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -171,9 +171,9 @@ struct nfs4_deviceid_node {
 };
 
 void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
-struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
-struct nfs4_deviceid_node *nfs4_unhash_put_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
-void nfs4_delete_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
+struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
+struct nfs4_deviceid_node *nfs4_unhash_put_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
+void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
 			     const struct pnfs_layoutdriver_type *,
 			     const struct nfs_client *,
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 8fd3839..c65e133 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -67,14 +67,16 @@ nfs4_deviceid_hash(const struct nfs4_deviceid *id)
 }
 
 static struct nfs4_deviceid_node *
-_lookup_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
+_lookup_deviceid(const struct pnfs_layoutdriver_type *ld,
+		 const struct nfs_client *clp, const struct nfs4_deviceid *id,
 		 long hash)
 {
 	struct nfs4_deviceid_node *d;
 	struct hlist_node *n;
 
 	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
-		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
+		if (d->ld == ld && d->nfs_client == clp &&
+		    !memcmp(&d->deviceid, id, sizeof(*id))) {
 			if (atomic_read(&d->ref))
 				return d;
 			else
@@ -90,13 +92,14 @@ _lookup_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
  * @id deviceid to look up
  */
 struct nfs4_deviceid_node *
-_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
+_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
+		   const struct nfs_client *clp, const struct nfs4_deviceid *id,
 		   long hash)
 {
 	struct nfs4_deviceid_node *d;
 
 	rcu_read_lock();
-	d = _lookup_deviceid(clp, id, hash);
+	d = _lookup_deviceid(ld, clp, id, hash);
 	if (d && !atomic_inc_not_zero(&d->ref))
 		d = NULL;
 	rcu_read_unlock();
@@ -104,9 +107,10 @@ _find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
 }
 
 struct nfs4_deviceid_node *
-nfs4_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+nfs4_find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
+		       const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
-	return _find_get_deviceid(clp, id, nfs4_deviceid_hash(id));
+	return _find_get_deviceid(ld, clp, id, nfs4_deviceid_hash(id));
 }
 EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
 
@@ -119,13 +123,14 @@ EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
  * @ret the unhashed node, if found and dereferenced to zero, NULL otherwise.
  */
 struct nfs4_deviceid_node *
-nfs4_unhash_put_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+nfs4_unhash_put_deviceid(const struct pnfs_layoutdriver_type *ld,
+			 const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
 	struct nfs4_deviceid_node *d;
 
 	spin_lock(&nfs4_deviceid_lock);
 	rcu_read_lock();
-	d = _lookup_deviceid(clp, id, nfs4_deviceid_hash(id));
+	d = _lookup_deviceid(ld, clp, id, nfs4_deviceid_hash(id));
 	rcu_read_unlock();
 	if (!d) {
 		spin_unlock(&nfs4_deviceid_lock);
@@ -150,11 +155,12 @@ EXPORT_SYMBOL_GPL(nfs4_unhash_put_deviceid);
  * @id deviceid to delete
  */
 void
-nfs4_delete_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *ld,
+		     const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
 	struct nfs4_deviceid_node *d;
 
-	d = nfs4_unhash_put_deviceid(clp, id);
+	d = nfs4_unhash_put_deviceid(ld, clp, id);
 	if (!d)
 		return;
 	d->ld->free_deviceid_node(d);
@@ -194,7 +200,7 @@ nfs4_insert_deviceid_node(struct nfs4_deviceid_node *new)
 
 	spin_lock(&nfs4_deviceid_lock);
 	hash = nfs4_deviceid_hash(&new->deviceid);
-	d = _find_get_deviceid(new->nfs_client, &new->deviceid, hash);
+	d = _find_get_deviceid(new->ld, new->nfs_client, &new->deviceid, hash);
 	if (d) {
 		spin_unlock(&nfs4_deviceid_lock);
 		return d;
-- 
1.7.2.3

