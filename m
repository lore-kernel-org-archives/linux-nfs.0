From: andros@netapp.com
Subject: [PATCH 4/4] SQUASHME pnfs-submit nfs4_filelayoutdev.c cleanup
Date: Thu, 15 Jul 2010 12:33:50 -0400
Message-ID: <1279211630-6039-4-git-send-email-andros@netapp.com>
References: <1279211630-6039-1-git-send-email-andros@netapp.com>
 <1279211630-6039-2-git-send-email-andros@netapp.com>
 <1279211630-6039-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2923 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933695Ab0GOQd3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:33:29 -0400
In-Reply-To: <1279211630-6039-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Cleanup comment formatting and extra whitespace.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index c2b8a0a..1452710 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -193,13 +193,11 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		err = -ENODEV;
 		goto out_put;
 	}
-
 	/*
 	 * Mask the (possibly) returned EXCHGID4_FLAG_USE_PNFS_MDS pNFS role
 	 * The is_ds_only_session depends on this.
 	 */
 	clp->cl_exchange_flags &= ~EXCHGID4_FLAG_USE_PNFS_MDS;
-
 	/*
 	 * Set DS lease equal to the MDS lease, renewal is scheduled in
 	 * create_session
@@ -327,8 +325,10 @@ decode_and_add_ds(uint32_t **pp, struct inode *inode)
 			__func__, len);
 		goto out_err;
 	}
-	/* Read the bytes into a temporary buffer */
-	/* XXX: should probably sanity check them */
+	/*
+	 * Read the bytes into a temporary buffer
+	 * XXX: should probably sanity check them
+	 */
 	tmp[0] = be32_to_cpup(p++);
 
 	len = be32_to_cpup(p++);
@@ -355,8 +355,7 @@ out_err:
 	return NULL;
 }
 
-/* Decode opaque device data and return the result
- */
+/* Decode opaque device data and return the result */
 static struct nfs4_file_layout_dsaddr*
 decode_device(struct inode *ino, struct pnfs_device *pdev)
 {
@@ -476,7 +475,8 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
 	return container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
 }
 
-/* Retrieve the information for dev_id, add it to the list
+/*
+ * Retrieve the information for dev_id, add it to the list
  * of available devices, and return it.
  */
 struct nfs4_file_layout_dsaddr *
@@ -533,7 +533,8 @@ get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id)
 	if (rc)
 		goto out_free;
 
-	/* Found new device, need to decode it and then add it to the
+	/*
+	 * Found new device, need to decode it and then add it to the
 	 * list of known devices for this mountpoint.
 	 */
 	dsaddr = decode_and_add_device(inode, pdev);
@@ -560,7 +561,8 @@ nfs4_pnfs_device_item_find(struct nfs_client *clp, struct pnfs_deviceid *id)
 		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
 }
 
-/* Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
+/*
+ * Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
  * Then: ((res + fsi) % dsaddr->stripe_count)
  */
 static inline u32
-- 
1.6.6

