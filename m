From: andros@netapp.com
Subject: [PATCH 08/14] SQUASHME pnfs_submit: change decode_and_add_device parameter
Date: Thu,  8 Apr 2010 15:54:04 -0400
Message-ID: <1270756450-5570-9-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
 <1270756450-5570-5-git-send-email-andros@netapp.com>
 <1270756450-5570-6-git-send-email-andros@netapp.com>
 <1270756450-5570-7-git-send-email-andros@netapp.com>
 <1270756450-5570-8-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933319Ab0DHTy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:58 -0400
In-Reply-To: <1270756450-5570-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation to use the generic deviceid cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 9844a9c..bb8a84a 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -601,19 +601,19 @@ out_err:
  * Must at some point be followed up with nfs4_pnfs_device_destroy
  */
 static struct nfs4_file_layout_dsaddr*
-decode_and_add_device(struct filelayout_mount_type *mt, struct pnfs_device *dev)
+decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
 {
 	struct nfs4_file_layout_dsaddr *dsaddr;
 
-	dsaddr = decode_device(mt, dev);
+	dsaddr = decode_device(FILE_MT(inode), dev);
 	if (!dsaddr) {
 		printk(KERN_WARNING "%s: Could not decode device\n",
 			__func__);
-		nfs4_pnfs_device_destroy(dsaddr, mt->hlist);
+		nfs4_pnfs_device_destroy(dsaddr, FILE_MT(inode)->hlist);
 		return NULL;
 	}
 
-	if (nfs4_pnfs_device_add(mt, dsaddr))
+	if (nfs4_pnfs_device_add(FILE_MT(inode), dsaddr))
 		return NULL;
 
 	return dsaddr;
@@ -681,7 +681,7 @@ retry_once:
 	/* Found new device, need to decode it and then add it to the
 	 * list of known devices for this mountpoint.
 	 */
-	dsaddr = decode_and_add_device(FILE_MT(inode), pdev);
+	dsaddr = decode_and_add_device(inode, pdev);
 out_free:
 	if (minpages > 1 && pdev->area != NULL)
 		vunmap(pdev->area);
-- 
1.6.6

