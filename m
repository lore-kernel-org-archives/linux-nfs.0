Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41439 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbAVLL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 06:11:26 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 16/20] xfs: pass a 64-bit count argument to xfs_iomap_write_unwritten
Date: Thu, 22 Jan 2015 12:10:02 +0100
Message-Id: <1421925006-24231-17-git-send-email-hch@lst.de>
In-Reply-To: <1421925006-24231-1-git-send-email-hch@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code is already ready for it, and the pnfs layout commit code expects
to be able to pass a larger than 32-bit argument.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_iomap.c | 2 +-
 fs/xfs/xfs_iomap.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
index c980e2a..ccb1dd0 100644
--- a/fs/xfs/xfs_iomap.c
+++ b/fs/xfs/xfs_iomap.c
@@ -802,7 +802,7 @@ int
 xfs_iomap_write_unwritten(
 	xfs_inode_t	*ip,
 	xfs_off_t	offset,
-	size_t		count)
+	xfs_off_t	count)
 {
 	xfs_mount_t	*mp = ip->i_mount;
 	xfs_fileoff_t	offset_fsb;
diff --git a/fs/xfs/xfs_iomap.h b/fs/xfs/xfs_iomap.h
index 411fbb8..8688e66 100644
--- a/fs/xfs/xfs_iomap.h
+++ b/fs/xfs/xfs_iomap.h
@@ -27,6 +27,6 @@ int xfs_iomap_write_delay(struct xfs_inode *, xfs_off_t, size_t,
 			struct xfs_bmbt_irec *);
 int xfs_iomap_write_allocate(struct xfs_inode *, xfs_off_t,
 			struct xfs_bmbt_irec *);
-int xfs_iomap_write_unwritten(struct xfs_inode *, xfs_off_t, size_t);
+int xfs_iomap_write_unwritten(struct xfs_inode *, xfs_off_t, xfs_off_t);
 
 #endif /* __XFS_IOMAP_H__*/
-- 
1.9.1

