From: andros@netapp.com
Subject: [PATCH 02/14] SQUASHME pnfs-submit: call get_device_info from filelayout_check
Date: Thu,  8 Apr 2010 15:53:58 -0400
Message-ID: <1270756450-5570-3-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758840Ab0DHTy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:56 -0400
In-Reply-To: <1270756450-5570-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

filelayout_check() validates a LAYOUTGET return including the deviceid.
If the deviceid is not cached, GETDEVICEINFO is called.

Once cached, the deviceid will only be uncached upon umount or a return of all
refering layouts. So, there is no need for a get_device_info call in the I/O
paths.

Remove nfs4_file_layout_dsaddr_get.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   11 +++++++----
 fs/nfs/nfs4filelayout.h    |    6 ++++--
 fs/nfs/nfs4filelayoutdev.c |   27 +++------------------------
 3 files changed, 14 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index df6c1d0..ffc3ef2 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -413,12 +413,15 @@ filelayout_check_layout(struct pnfs_layout_type *lo,
 	struct nfs_server *nfss = NFS_SERVER(PNFS_INODE(lo));
 
 	dprintk("--> %s\n", __func__);
-	dsaddr = nfs4_file_layout_dsaddr_get(FILE_MT(PNFS_INODE(lo)),
+	dsaddr = nfs4_pnfs_device_item_find(FILE_MT(PNFS_INODE(lo))->hlist,
 					     &fl->dev_id);
 	if (dsaddr == NULL) {
-		dprintk("%s NO device for dev_id %s\n",
+		dsaddr = get_device_info(FILE_MT(PNFS_INODE(lo)), &fl->dev_id);
+		if (dsaddr == NULL) {
+			dprintk("%s NO device for dev_id %s\n",
 				__func__, deviceid_fmt(&fl->dev_id));
-		goto out;
+			goto out;
+		}
 	}
 	if (fl->first_stripe_index < 0 ||
 	    fl->first_stripe_index > dsaddr->stripe_count) {
@@ -645,7 +648,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	stripesz = filelayout_get_stripesize(layoutid);
 	dprintk("%s stripesize %Zd\n", __func__, stripesz);
 
-	dsaddr = nfs4_file_layout_dsaddr_get(FILE_MT(data->inode),
+	dsaddr = nfs4_pnfs_device_item_find(FILE_MT(data->inode)->hlist,
 					     &nfslay->dev_id);
 	if (dsaddr == NULL) {
 		data->pdata.pnfs_error = -EIO;
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index d003809..3821989 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -121,7 +121,9 @@ u32 filelayout_dserver_get_index(loff_t offset,
 } while (0)
 
 struct nfs4_file_layout_dsaddr *
-nfs4_file_layout_dsaddr_get(struct filelayout_mount_type *,
-			  struct pnfs_deviceid *);
+nfs4_pnfs_device_item_find(struct nfs4_pnfs_dev_hlist *hlist,
+			   struct pnfs_deviceid *dev_id);
+struct nfs4_file_layout_dsaddr *
+get_device_info(struct filelayout_mount_type *mt, struct pnfs_deviceid *dev_id);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index e557679..ebb9845 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -52,13 +52,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
-struct nfs4_file_layout_dsaddr *nfs4_file_layout_dsaddr_get(
-					struct filelayout_mount_type *mt,
-					struct pnfs_deviceid *dev_id);
-struct nfs4_file_layout_dsaddr *nfs4_pnfs_device_item_find(
-					struct nfs4_pnfs_dev_hlist *hlist,
-					struct pnfs_deviceid *dev_id);
-
 void
 print_ds_list(struct nfs4_multipath *multipath)
 {
@@ -665,7 +658,7 @@ decode_and_add_device(struct filelayout_mount_type *mt, struct pnfs_device *dev)
 /* Retrieve the information for dev_id, add it to the list
  * of available devices, and return it.
  */
-static struct nfs4_file_layout_dsaddr *
+struct nfs4_file_layout_dsaddr *
 get_device_info(struct filelayout_mount_type *mt,
 		struct pnfs_deviceid *dev_id)
 {
@@ -737,21 +730,6 @@ out_free:
 }
 
 struct nfs4_file_layout_dsaddr *
-nfs4_file_layout_dsaddr_get(struct filelayout_mount_type *mt,
-			    struct pnfs_deviceid *dev_id)
-{
-	struct nfs4_file_layout_dsaddr *dsaddr;
-
-	read_lock(&mt->hlist->dev_lock);
-	dsaddr = _device_lookup(mt->hlist, dev_id);
-	read_unlock(&mt->hlist->dev_lock);
-
-	if (dsaddr == NULL)
-		dsaddr = get_device_info(mt, dev_id);
-	return dsaddr;
-}
-
-struct nfs4_file_layout_dsaddr *
 nfs4_pnfs_device_item_find(struct nfs4_pnfs_dev_hlist *hlist,
 			   struct pnfs_deviceid *dev_id)
 {
@@ -798,7 +776,8 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 	if (!layout)
 		return 1;
 
-	dsaddr = nfs4_file_layout_dsaddr_get(FILE_MT(inode), &layout->dev_id);
+	dsaddr = nfs4_pnfs_device_item_find(FILE_MT(inode)->hlist,
+					    &layout->dev_id);
 	if (dsaddr == NULL)
 		return 1;
 
-- 
1.6.6

