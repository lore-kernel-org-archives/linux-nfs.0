Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55256 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755532AbbAFQ3w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:52 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 16/18] xfs: do not allocate blocks when converting unwritten extents
Date: Tue,  6 Jan 2015 17:28:39 +0100
Message-Id: <1420561721-9150-17-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current xfs_bmapi_write always allocates blocks when it encounters a
hole.  But for unwritten extent conversions we do not have the proper
transaction reservations to do that, and should error out instead.

Currently this doesn't matter too much because the writeback path
ensures that all blocks are properly allocated, but the pNFS block
server code will accept unwritten extent conversions from clients,
and in case of recovery from a crashed server we might get conversion
requests for blocks whose allocation transaction hasn't made it to
disk before the crash.  Also in general it is a good idea to be
defensive here, especially for client initiated requests.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/libxfs/xfs_bmap.c | 15 +++++++++++++++
 fs/xfs/xfs_iomap.c       | 17 ++++++-----------
 2 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
index b5eb474..be08671 100644
--- a/fs/xfs/libxfs/xfs_bmap.c
+++ b/fs/xfs/libxfs/xfs_bmap.c
@@ -4580,6 +4580,20 @@ xfs_bmapi_write(
 		 * that we found, if any.
 		 */
 		if (inhole || wasdelay) {
+			if ((flags & (XFS_BMAPI_CONVERT|XFS_BMAPI_PREALLOC)) ==
+					XFS_BMAPI_CONVERT) {
+				xfs_filblks_t count;
+
+				if (eof)
+					bma.got.br_startoff = end;
+
+				count = XFS_FILBLKS_MIN(len,
+						bma.got.br_startoff - bno);
+				bno += count;
+				len -= count;
+				goto next;
+			}
+
 			bma.eof = eof;
 			bma.conv = !!(flags & XFS_BMAPI_CONVERT);
 			bma.wasdel = wasdelay;
@@ -4621,6 +4635,7 @@ xfs_bmapi_write(
 		/* update the extent map to return */
 		xfs_bmapi_update_map(&mval, &bno, &len, obno, end, &n, flags);
 
+next:
 		/*
 		 * If we're done, stop now.  Stop when we've allocated
 		 * XFS_BMAP_MAX_NMAP extents no matter what.  Otherwise
diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
index ccb1dd0..4b139f2 100644
--- a/fs/xfs/xfs_iomap.c
+++ b/fs/xfs/xfs_iomap.c
@@ -807,7 +807,6 @@ xfs_iomap_write_unwritten(
 	xfs_mount_t	*mp = ip->i_mount;
 	xfs_fileoff_t	offset_fsb;
 	xfs_filblks_t	count_fsb;
-	xfs_filblks_t	numblks_fsb;
 	xfs_fsblock_t	firstfsb;
 	int		nimaps;
 	xfs_trans_t	*tp;
@@ -896,19 +895,15 @@ xfs_iomap_write_unwritten(
 		if (error)
 			return error;
 
+		if (!nimaps)
+			break;
+
 		if (!(imap.br_startblock || XFS_IS_REALTIME_INODE(ip)))
 			return xfs_alert_fsblock_zero(ip, &imap);
 
-		if ((numblks_fsb = imap.br_blockcount) == 0) {
-			/*
-			 * The numblks_fsb value should always get
-			 * smaller, otherwise the loop is stuck.
-			 */
-			ASSERT(imap.br_blockcount);
-			break;
-		}
-		offset_fsb += numblks_fsb;
-		count_fsb -= numblks_fsb;
+		ASSERT(imap.br_blockcount);
+		offset_fsb += imap.br_blockcount;
+		count_fsb -= imap.br_blockcount;
 	} while (count_fsb > 0);
 
 	return 0;
-- 
1.9.1

