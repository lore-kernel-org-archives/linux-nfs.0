Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55245 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755532AbbAFQ3s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:48 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 13/18] exportfs: add methods for block layout exports
Date: Tue,  6 Jan 2015 17:28:36 +0100
Message-Id: <1420561721-9150-14-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add three methods to allow exporting pnfs block layout volumes:

 - get_uuid: get a filesystem unique signature exposed to clients
 - map_blocks: map and if nessecary allocate blocks for a layout
 - commit_blocks: commit blocks in a layout once the client is done with them

For now we stick the external pnfs block layout interfaces into s_export_op to
avoid mixing them up with the internal interface between the NFS server and
the layout drivers.  Once we've fully internalized the latter interface we
can redecide if these methods should stay in s_export_ops.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/exportfs.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 41b223a..ff46bf7 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 
 struct dentry;
+struct iattr;
 struct inode;
 struct super_block;
 struct vfsmount;
@@ -180,6 +181,19 @@ struct fid {
  *    get_name is not (which is possibly inconsistent)
  */
 
+/* types of block ranges for multipage write mappings. */
+#define IOMAP_HOLE	0x01	/* no blocks allocated, need allocation */
+#define IOMAP_DELALLOC	0x02	/* delayed allocation blocks */
+#define IOMAP_MAPPED	0x03	/* blocks allocated @blkno */
+#define IOMAP_UNWRITTEN	0x04	/* blocks allocated @blkno in unwritten state */
+
+struct iomap {
+	sector_t	blkno;	/* first sector of mapping */
+	loff_t		offset;	/* file offset of mapping, bytes */
+	u64		length;	/* length of mapping, bytes */
+	int		type;	/* type of mapping */
+};
+
 struct export_operations {
 	int (*encode_fh)(struct inode *inode, __u32 *fh, int *max_len,
 			struct inode *parent);
@@ -191,6 +205,13 @@ struct export_operations {
 			struct dentry *child);
 	struct dentry * (*get_parent)(struct dentry *child);
 	int (*commit_metadata)(struct inode *inode);
+
+	int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
+	int (*map_blocks)(struct inode *inode, loff_t offset,
+			  u64 len, struct iomap *iomap,
+			  bool write, u32 *device_generation);
+	int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
+			     int nr_iomaps, struct iattr *iattr);
 };
 
 extern int exportfs_encode_inode_fh(struct inode *inode, struct fid *fid,
-- 
1.9.1

