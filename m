Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26178 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031568Ab2CFXSH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 18:18:07 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: add crc hash to nfs_display_fhandle
Date: Tue,  6 Mar 2012 18:17:55 -0500
Message-Id: <1331075875-20421-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Match wireshark's CRC-32 hash for easier debugging.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Requested by Chuck and others.

Nothing in trond/nfs-for-next uses nfs_display_fhandle() yet.
I tested by calling it in nfs4xdr.c:encode_putfh().

 fs/nfs/inode.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 99a4f52..c1f44e9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -39,6 +39,7 @@
 #include <linux/slab.h>
 #include <linux/compat.h>
 #include <linux/freezer.h>
+#include <linux/crc32.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -1057,13 +1058,18 @@ struct nfs_fh *nfs_alloc_fhandle(void)
 void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
 {
 	unsigned short i;
+	u32 crc;
 
 	if (fh->size == 0 || fh == NULL) {
 		printk(KERN_DEFAULT "%s at %p is empty\n", caption, fh);
 		return;
 	}
 
-	printk(KERN_DEFAULT "%s at %p is %u bytes:\n", caption, fh, fh->size);
+	/* match wireshark's CRC-32 hash */
+	crc = ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
+
+	printk(KERN_DEFAULT "%s at %p is %u bytes, crc: 0x%08x:\n",
+	                    caption, fh, fh->size, crc);
 	for (i = 0; i < fh->size; i += 16) {
 		__be32 *pos = (__be32 *)&fh->data[i];
 
-- 
1.7.4.4

