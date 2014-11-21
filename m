Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:50678 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757720AbaKUKJL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2014 05:09:11 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so4569028pab.21
        for <linux-nfs@vger.kernel.org>; Fri, 21 Nov 2014 02:09:11 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 4/5] btrfs: don't allow -C or +c chattrs on a swap file
Date: Fri, 21 Nov 2014 02:08:30 -0800
Message-Id: <a422e8d7ce252474b998eeca3af5f1e2964c5c50.1416563833.git.osandov@osandov.com>
In-Reply-To: <cover.1416563833.git.osandov@osandov.com>
References: <cover.1416563833.git.osandov@osandov.com>
In-Reply-To: <cover.1416563833.git.osandov@osandov.com>
References: <cover.1416563833.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

swap_activate will check for a compressed or copy-on-write file; we shouldn't
allow it to become either once it has already been activated.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/btrfs/ioctl.c | 50 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 19 deletions(-)

diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 4399f0c..f022dce 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -293,14 +293,21 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 		}
 	} else {
 		/*
-		 * Revert back under same assuptions as above
+		 * swap_activate checks that we don't swapon a copy-on-write
+		 * file, but we must also make sure that it doesn't become
+		 * copy-on-write.
 		 */
-		if (S_ISREG(mode)) {
-			if (inode->i_size == 0)
-				ip->flags &= ~(BTRFS_INODE_NODATACOW
-				             | BTRFS_INODE_NODATASUM);
-		} else {
-			ip->flags &= ~BTRFS_INODE_NODATACOW;
+		if (!IS_SWAPFILE(inode)) {
+			/*
+			 * Revert back under same assumptions as above
+			 */
+			if (S_ISREG(mode)) {
+				if (inode->i_size == 0)
+					ip->flags &= ~(BTRFS_INODE_NODATACOW |
+						       BTRFS_INODE_NODATASUM);
+			} else {
+				ip->flags &= ~BTRFS_INODE_NODATACOW;
+			}
 		}
 	}
 
@@ -317,20 +324,25 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 		if (ret && ret != -ENODATA)
 			goto out_drop;
 	} else if (flags & FS_COMPR_FL) {
-		const char *comp;
-
-		ip->flags |= BTRFS_INODE_COMPRESS;
-		ip->flags &= ~BTRFS_INODE_NOCOMPRESS;
+		/*
+		 * Like nodatacow, swap_activate checks that we don't swapon a
+		 * compressed file, so we shouldn't let it become compressed.
+		 */
+		if (!IS_SWAPFILE(inode)) {
+			const char *comp;
 
-		if (root->fs_info->compress_type == BTRFS_COMPRESS_LZO)
-			comp = "lzo";
-		else
-			comp = "zlib";
-		ret = btrfs_set_prop(inode, "btrfs.compression",
-				     comp, strlen(comp), 0);
-		if (ret)
-			goto out_drop;
+			ip->flags |= BTRFS_INODE_COMPRESS;
+			ip->flags &= ~BTRFS_INODE_NOCOMPRESS;
 
+			if (root->fs_info->compress_type == BTRFS_COMPRESS_LZO)
+				comp = "lzo";
+			else
+				comp = "zlib";
+			ret = btrfs_set_prop(inode, "btrfs.compression",
+					     comp, strlen(comp), 0);
+			if (ret)
+				goto out_drop;
+		}
 	} else {
 		ret = btrfs_set_prop(inode, "btrfs.compression", NULL, 0, 0);
 		if (ret && ret != -ENODATA)
-- 
2.1.3

