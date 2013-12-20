Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54503 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932824Ab3LTNZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Dec 2013 08:25:24 -0500
Message-Id: <20131220132521.682711410@bombadil.infradead.org>
Date: Fri, 20 Dec 2013 05:16:39 -0800
From: Christoph Hellwig <hch@infradead.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>,
        Jan Kara <jack@suse.cz>
Subject: [PATCH 04/21] fs: add a set_acl inode operation
References: <20131220131635.650823732@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will allow moving all the Posix ACL handling into the VFS and clean
up tons of cruft in the filesystems.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 include/linux/fs.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 121f11f..09f553c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1580,6 +1580,7 @@ struct inode_operations {
 			   struct file *, unsigned open_flag,
 			   umode_t create_mode, int *opened);
 	int (*tmpfile) (struct inode *, struct dentry *, umode_t);
+	int (*set_acl)(struct inode *, struct posix_acl *, int);
 } ____cacheline_aligned;
 
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
-- 
1.7.10.4


