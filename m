From: andros@netapp.com
Subject: [PATCH 12/14] SQUASHME pnfs_submit: remove filelayout CB_NOTIFY_DEVICE support
Date: Thu,  8 Apr 2010 15:54:08 -0400
Message-ID: <1270756450-5570-13-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933346Ab0DHTy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:58 -0400
In-Reply-To: <1270756450-5570-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We won't support CB_NOTIFY_DEVICE in the first submission stage.
Remove filelayout_device_delete and associated functionality.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   16 ----------------
 fs/nfs/nfs4filelayout.h    |    2 --
 fs/nfs/nfs4filelayoutdev.c |   18 ------------------
 3 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index f222c3b..0530b59 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -135,21 +135,6 @@ filelayout_uninitialize_mountpoint(struct pnfs_mount_type *mountid)
 	return 0;
 }
 
-int
-filelayout_device_delete(struct pnfs_mount_type *mountid,
-				struct pnfs_deviceid *dev_id)
-{
-	struct filelayout_mount_type *fl_mt = NULL;
-
-	if (mountid) {
-		fl_mt = (struct filelayout_mount_type *)mountid->mountid;
-
-		if (fl_mt != NULL)
-			nfs4_pnfs_dev_destroy(fl_mt->hlist, dev_id);
-	}
-	return 0;
-}
-
 /* This function is used by the layout driver to calculate the
  * offset of the file on the dserver based on whether the
  * layout type is STRIPE_DENSE or STRIPE_SPARSE
@@ -797,7 +782,6 @@ struct layoutdriver_io_operations filelayout_io_operations = {
 	.free_lseg               = filelayout_free_lseg,
 	.initialize_mountpoint   = filelayout_initialize_mountpoint,
 	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
-	.device_delete           = filelayout_device_delete,
 };
 
 struct layoutdriver_policy_operations filelayout_policy_operations = {
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 560f7f6..e988891 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -96,8 +96,6 @@ extern void print_ds(struct nfs4_pnfs_ds *ds);
 char *deviceid_fmt(const struct pnfs_deviceid *dev_id);
 int  nfs4_pnfs_devlist_init(struct nfs4_pnfs_dev_hlist *hlist);
 void nfs4_pnfs_devlist_destroy(struct nfs4_pnfs_dev_hlist *hlist);
-void nfs4_pnfs_dev_destroy(struct nfs4_pnfs_dev_hlist *hlist,
-				struct pnfs_deviceid *dev_id);
 int nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 			  loff_t offset,
 			  size_t count,
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 2cbe931..2d98ca3 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -368,24 +368,6 @@ nfs4_pnfs_devlist_destroy(struct nfs4_pnfs_dev_hlist *hlist)
 	}
 }
 
-/* De-alloc a devices for a mount point. */
-void
-nfs4_pnfs_dev_destroy(struct nfs4_pnfs_dev_hlist *hlist,
-			struct pnfs_deviceid *dev_id)
-{
-	struct nfs4_file_layout_dsaddr *dsaddr;
-
-	if (hlist == NULL)
-		return;
-
-	dprintk("%s: dev_id=%s\n", __func__, deviceid_fmt(dev_id));
-
-	dsaddr = nfs4_pnfs_device_item_find(hlist, dev_id);
-	if (dsaddr)
-		/* nfs4_pnfs_device_destroy grabs hlist->dev_lock */
-		nfs4_pnfs_device_destroy(dsaddr, hlist);
-}
-
 /*
  * Add the device to the list of available devices for this mount point.
  * The * rpc client is created during first I/O.
-- 
1.6.6

