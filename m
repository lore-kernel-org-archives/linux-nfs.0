From: andros@netapp.com
Subject: [PATCH 01/14] SQUASHME: pnfs_submit: remove unused getdevicelist functions
Date: Thu,  8 Apr 2010 15:53:57 -0400
Message-ID: <1270756450-5570-2-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758821Ab0DHTy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:56 -0400
In-Reply-To: <1270756450-5570-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.h    |    4 ----
 fs/nfs/nfs4filelayoutdev.c |   27 ---------------------------
 2 files changed, 0 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 6051195..d003809 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -106,10 +106,6 @@ int nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 			  loff_t offset,
 			  size_t count,
 			  struct nfs4_pnfs_dserver *dserver);
-int decode_and_add_devicelist(struct filelayout_mount_type *mt, struct pnfs_devicelist *devlist);
-int process_deviceid_list(struct filelayout_mount_type *mt,
-			  struct nfs_fh *fh,
-			  struct pnfs_devicelist *devlist);
 u32 filelayout_dserver_get_index(loff_t offset,
 				 struct nfs4_file_layout_dsaddr *di,
 				 struct nfs4_filelayout_segment *layout);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 16dafc0..e557679 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -662,33 +662,6 @@ decode_and_add_device(struct filelayout_mount_type *mt, struct pnfs_device *dev)
 	return dsaddr;
 }
 
-/* For each deviceid, if not already in the cache,
- * call getdeviceinfo and add the devices associated with
- * the deviceid to the list of available devices for this
- * mount point.
- * Must at some point be followed up with nfs4_pnfs_device_destroy.
- */
-int
-process_deviceid_list(struct filelayout_mount_type *mt,
-		      struct nfs_fh *fh,
-		      struct pnfs_devicelist *devlist)
-{
-	int i;
-
-	dprintk("--> %s: num_devs=%d\n", __func__, devlist->num_devs);
-
-	for (i = 0; i < devlist->num_devs; i++) {
-		if (!nfs4_file_layout_dsaddr_get(mt, &devlist->dev_id[i])) {
-			printk(KERN_WARNING
-			       "<-- %s: Error retrieving device %d\n",
-			       __func__, i);
-			return 1;
-		}
-	}
-	dprintk("<-- %s: success\n", __func__);
-	return 0;
-}
-
 /* Retrieve the information for dev_id, add it to the list
  * of available devices, and return it.
  */
-- 
1.6.6

