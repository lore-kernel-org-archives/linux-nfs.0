Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:34136 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab3HOUt1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 16:49:27 -0400
Message-ID: <520D3EA7.1010109@oracle.com>
Date: Thu, 15 Aug 2013 15:48:39 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: Christian Kujau <lists@nerdbynature.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Karl Schmidt <karl@xtronics.com>,
        Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org
Subject: [PATCH] jfs: fix readdir cookie incompatibility with NFSv4
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org> <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com> <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org> <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>
In-Reply-To: <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces the one I posted yesterday. I like this better since
it doesn't require fixing existing on-disk cookies or skipping a
position in the in-inode index table.

NFSv4 reserves readdir cookie values 0-2 for special entries (. and ..),
but jfs allows a value of 2 for a non-special entry. This incompatibility
can result in the nfs client reporting a readdir loop.

This patch doesn't change the value stored internally, but adds one to
the value exposed to the iterate method.

Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
---
 fs/jfs/jfs_dtree.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/jfs/jfs_dtree.c b/fs/jfs/jfs_dtree.c
index 8743ba9..0ec767e 100644
--- a/fs/jfs/jfs_dtree.c
+++ b/fs/jfs/jfs_dtree.c
@@ -3047,6 +3047,14 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 
 		dir_index = (u32) ctx->pos;
 
+		/*
+		 * NFSv4 reserves cookies 1 and 2 for . and .. so we add
+		 * the value we return to the vfs is one greater than the
+		 * one we use internally.
+		 */
+		if (dir_index)
+			dir_index--;
+
 		if (dir_index > 1) {
 			struct dir_table_slot dirtab_slot;
 
@@ -3086,7 +3094,7 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 			if (p->header.flag & BT_INTERNAL) {
 				jfs_err("jfs_readdir: bad index table");
 				DT_PUTPAGE(mp);
-				ctx->pos = -1;
+				ctx->pos = DIREND;
 				return 0;
 			}
 		} else {
@@ -3094,14 +3102,14 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 				/*
 				 * self "."
 				 */
-				ctx->pos = 0;
+				ctx->pos = 1;
 				if (!dir_emit(ctx, ".", 1, ip->i_ino, DT_DIR))
 					return 0;
 			}
 			/*
 			 * parent ".."
 			 */
-			ctx->pos = 1;
+			ctx->pos = 2;
 			if (!dir_emit(ctx, "..", 2, PARENT(ip), DT_DIR))
 				return 0;
 
@@ -3122,22 +3130,23 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 		/*
 		 * Legacy filesystem - OS/2 & Linux JFS < 0.3.6
 		 *
-		 * pn = index = 0:	First entry "."
-		 * pn = 0; index = 1:	Second entry ".."
+		 * pn = 0; index = 1:	First entry "."
+		 * pn = 0; index = 2:	Second entry ".."
 		 * pn > 0:		Real entries, pn=1 -> leftmost page
 		 * pn = index = -1:	No more entries
 		 */
 		dtpos = ctx->pos;
-		if (dtpos == 0) {
+		if (dtpos < 2) {
 			/* build "." entry */
+			ctx->pos = 1;
 			if (!dir_emit(ctx, ".", 1, ip->i_ino, DT_DIR))
 				return 0;
-			dtoffset->index = 1;
+			dtoffset->index = 2;
 			ctx->pos = dtpos;
 		}
 
 		if (dtoffset->pn == 0) {
-			if (dtoffset->index == 1) {
+			if (dtoffset->index == 2) {
 				/* build ".." entry */
 				if (!dir_emit(ctx, "..", 2, PARENT(ip), DT_DIR))
 					return 0;
@@ -3228,6 +3237,12 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 					}
 					jfs_dirent->position = unique_pos++;
 				}
+				/*
+				 * We add 1 to the index because we may
+				 * use a value of 2 internally, and NFSv4
+				 * doesn't like that.
+				 */
+				jfs_dirent->position++;
 			} else {
 				jfs_dirent->position = dtpos;
 				len = min(d_namleft, DTLHDRDATALEN_LEGACY);
-- 
1.8.3.4

