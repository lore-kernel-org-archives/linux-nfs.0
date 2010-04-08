From: andros@netapp.com
Subject: [PATCH 09/14] SQUASHME pnfs_submit: change decode_device parameter
Date: Thu,  8 Apr 2010 15:54:05 -0400
Message-ID: <1270756450-5570-10-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
 <1270756450-5570-5-git-send-email-andros@netapp.com>
 <1270756450-5570-6-git-send-email-andros@netapp.com>
 <1270756450-5570-7-git-send-email-andros@netapp.com>
 <1270756450-5570-8-git-send-email-andros@netapp.com>
 <1270756450-5570-9-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933340Ab0DHTy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:58 -0400
In-Reply-To: <1270756450-5570-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation to use the generic deviceid cache

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index bb8a84a..506ede1 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -505,7 +505,7 @@ out_err:
 /* Decode opaque device data and return the result
  */
 static struct nfs4_file_layout_dsaddr*
-decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
+decode_device(struct inode *ino, struct pnfs_device *pdev)
 {
 	int i, dummy;
 	u32 cnt, num;
@@ -572,7 +572,8 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 		}
 		for (j = 0; j < dummy; j++) {
 			if (j == 0) {
-				dsaddr->ds_list[i] = decode_and_add_ds(&p, mt);
+				dsaddr->ds_list[i] = decode_and_add_ds(&p,
+								FILE_MT(ino));
 				if (dsaddr->ds_list[i] == NULL)
 					goto out_err_free;
 			} else {
@@ -589,7 +590,7 @@ decode_device(struct filelayout_mount_type *mt, struct pnfs_device *pdev)
 	return dsaddr;
 
 out_err_free:
-	nfs4_pnfs_device_destroy(dsaddr, mt->hlist);
+	nfs4_pnfs_device_destroy(dsaddr, FILE_MT(ino)->hlist);
 out_err:
 	dprintk("%s ERROR: returning NULL\n", __func__);
 	return NULL;
@@ -605,7 +606,7 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
 {
 	struct nfs4_file_layout_dsaddr *dsaddr;
 
-	dsaddr = decode_device(FILE_MT(inode), dev);
+	dsaddr = decode_device(inode, dev);
 	if (!dsaddr) {
 		printk(KERN_WARNING "%s: Could not decode device\n",
 			__func__);
-- 
1.6.6

