Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46771 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab1EXPHz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:07:55 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/12] SQUASHME: pnfs-obj: Bugs in new global-device-cache code
Date: Tue, 24 May 2011 18:07:24 +0300
Message-Id: <1306249644-23422-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix BUGs in the new "Use global-device-cache".

One thing I don't understand is why the compiler did
not complain when the code was returning the wrong
type of structure

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 167cd1e..faacde2 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -56,6 +56,7 @@ objio_free_deviceid_node(struct nfs4_deviceid_node *d)
 {
 	struct objio_dev_ent *de = container_of(d, struct objio_dev_ent, id_node);
 
+	dprintk("%s: free od=%p\n", __func__, de->od);
 	osduld_put_device(de->od);
 	kfree(de);
 }
@@ -64,14 +65,18 @@ static struct objio_dev_ent *_dev_list_find(const struct nfs_server *nfss,
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
+	return de;
 }
 
-static int _dev_list_add(const struct nfs_server *nfss,
+static struct objio_dev_ent *
+_dev_list_add(const struct nfs_server *nfss,
 	const struct nfs4_deviceid *d_id, struct osd_dev *od,
 	gfp_t gfp_flags)
 {
@@ -79,9 +84,12 @@ static int _dev_list_add(const struct nfs_server *nfss,
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
@@ -91,11 +99,12 @@ static int _dev_list_add(const struct nfs_server *nfss,
 	d = nfs4_insert_deviceid_node(&de->id_node);
 	n = container_of(d, struct objio_dev_ent, id_node);
 	if (n != de) {
-		BUG_ON(n->od != od);
+		dprintk("%s: Race with other n->od=%p\n", __func__, n->od);
 		objio_free_deviceid_node(&de->id_node);
+		de = n;
 	}
 
-	return 0;
+	return de;
 }
 
 struct caps_buffers {
@@ -117,7 +126,7 @@ struct objio_segment {
 	unsigned comps_index;
 	unsigned num_comps;
 	/* variable length */
-	struct objio_dev_ent *ods[0];
+	struct objio_dev_ent *ods[];
 };
 
 static inline struct objio_segment *
@@ -176,12 +185,13 @@ static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
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
-- 
1.7.2.3

