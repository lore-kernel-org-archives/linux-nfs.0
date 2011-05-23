Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23038 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab1EWV7b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 17:59:31 -0400
Message-ID: <4DDAD8AC.8030206@panasas.com>
Date: Tue, 24 May 2011 00:59:08 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: Bugs in new global-device-cache code
References: <4DD99F9B.2040406@panasas.com> <1306108720-28762-1-git-send-email-bhalevy@panasas.com> <4DD9E805.2020106@panasas.com> <4DDA64C6.2080909@panasas.com> <4DDAC93A.2020209@panasas.com>
In-Reply-To: <4DDAC93A.2020209@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


With this I'm able to do IO.

It is ontop of benney's code and my BUGs fixes
 + a merge fallout, between the two codes.

Current Benny's top + all the fixes has two problems.
1. Very small IOs both reads and writes
  How/where to set rsize/wsize
2. Something funny I'm still investigating. When I do
   a small Io couple of  requests the devices get freed
   at the end on the release of the layout. (Which is not
   layout_returned ever)
   But when I do very large IO and lots of concurrent requests
   the devices do not get to be released at all, they stay in
   cache. But am still investigating

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   31 ++++++++++++++++++++++---------
 fs/nfs/pnfs_dev.c            |    2 +-
 2 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 5210913..83aa088 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -60,6 +60,7 @@ objio_free_deviceid_node(struct nfs4_deviceid_node *d)
 {
 	struct objio_dev_ent *de = container_of(d, struct objio_dev_ent, id_node);
 
+	dprintk("%s: free od=%p\n", __func__, de->od);
 	osduld_put_device(de->od);
 	kfree(de);
 }
@@ -68,14 +69,19 @@ static struct objio_dev_ent *_dev_list_find(const struct nfs_server *nfss,
 	const struct nfs4_deviceid *d_id)
 {
 	struct nfs4_deviceid_node *d;
+	struct objio_dev_ent *de;
 
 	d = nfs4_find_get_deviceid(nfss->pnfs_curr_ld, nfss->nfs_client, d_id);
 	if (!d)
 		return NULL;
-	return container_of(d, struct objio_dev_ent, id_node);
+
+	de = container_of(d, struct objio_dev_ent, id_node);
+	dprintk("%s: found od=%p\n", __func__, de->od);
+	return de;
 }
 
-static int _dev_list_add(const struct nfs_server *nfss,
+static struct objio_dev_ent *
+_dev_list_add(const struct nfs_server *nfss,
 	const struct nfs4_deviceid *d_id, struct osd_dev *od,
 	gfp_t gfp_flags)
 {
@@ -83,9 +89,12 @@ static int _dev_list_add(const struct nfs_server *nfss,
 	struct objio_dev_ent *de = kzalloc(sizeof(*de), gfp_flags);
 	struct objio_dev_ent *n;
 
-	if (!de)
-		return -ENOMEM;
+	if (!de) {
+		dprintk("%s: -ENOMEM od=%p\n", __func__, od);
+		return NULL;
+	}
 
+	dprintk("%s: Adding od=%p\n", __func__, od);
 	nfs4_init_deviceid_node(&de->id_node,
 				nfss->pnfs_curr_ld,
 				nfss->nfs_client,
@@ -95,11 +104,13 @@ static int _dev_list_add(const struct nfs_server *nfss,
 	d = nfs4_insert_deviceid_node(&de->id_node);
 	n = container_of(d, struct objio_dev_ent, id_node);
 	if (n != de) {
-		BUG_ON(n->od != od);
+/*		BUG_ON(n->od != od);*/
+		dprintk("%s: Race with other n->od=%p\n", __func__, n->od);
 		objio_free_deviceid_node(&de->id_node);
+		de = n;
 	}
 
-	return 0;
+	return de;
 }
 
 struct caps_buffers {
@@ -121,7 +132,7 @@ struct objio_segment {
 	unsigned comps_index;
 	unsigned num_comps;
 	/* variable length */
-	struct objio_dev_ent *ods[0];
+	struct objio_dev_ent *ods[];
 };
 
 static inline struct objio_segment *
@@ -205,12 +216,13 @@ static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 		goto out;
 	}
 
-	_dev_list_add(NFS_SERVER(pnfslay->plh_inode), d_id, od, gfp_flags);
+	ode = _dev_list_add(NFS_SERVER(pnfslay->plh_inode), d_id, od,
+			    gfp_flags);
 
 out:
 	dprintk("%s: return=%d\n", __func__, err);
 	objlayout_put_deviceinfo(deviceaddr);
-	return err ? ERR_PTR(err) : od;
+	return err ? ERR_PTR(err) : ode;
 }
 
 static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
@@ -230,6 +242,7 @@ static int objio_devices_lookup(struct pnfs_layout_hdr *pnfslay,
 			goto out;
 		}
 		objio_seg->ods[i] = ode;
+		dprintk("%s: ods[%d] = %p\n", __func__, i, ode->od);
 	}
 	err = 0;
 
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 7997899..7e5542c 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -100,7 +100,7 @@ _find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
 
 	rcu_read_lock();
 	d = _lookup_deviceid(ld, clp, id, hash);
-	if (!atomic_inc_not_zero(&d->ref))
+	if (!d || !atomic_inc_not_zero(&d->ref))
 		d = NULL;
 	rcu_read_unlock();
 	return d;
-- 
1.7.2.3


