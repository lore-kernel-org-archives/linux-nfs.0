Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51494 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758425Ab3HODzV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Aug 2013 23:55:21 -0400
Message-ID: <520C50F7.3010209@oracle.com>
Date: Wed, 14 Aug 2013 22:54:31 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christian Kujau <lists@nerdbynature.de>, Karl Schmidt <karl@xtronics.com>,
        Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org
Subject: [PATCH] jfs: avoid misuse of cookie value of 2
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org> <20130812162924.GB2395@fieldses.org>
In-Reply-To: <20130812162924.GB2395@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the sake of those not watching
https://bugzilla.kernel.org/show_bug.cgi?id=60737

It looks like the problem is that jfs was using a cookie value of 2 for
a real directory entry, where NFSv4 expect 2 to represent "..". This
patch has so far only been lightly tested.

NFSv4 reserves cookie values 0, 1 and 2 for a rewind, and the "." and ".."
entries. jfs was using 0 and 1 for "." and "..", but 2 for a regular entry.
This patch makes jfs conform by using 1 and 2 for "." and ".." and fixes
any regular entry using the value 2.

Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>

diff --git a/fs/jfs/jfs_dtree.c b/fs/jfs/jfs_dtree.c
index 8743ba9..93466e8 100644
--- a/fs/jfs/jfs_dtree.c
+++ b/fs/jfs/jfs_dtree.c
@@ -349,11 +349,8 @@ static u32 add_index(tid_t tid, struct inode *ip, s64 bn, int slot)
 
 	ASSERT(DO_INDEX(ip));
 
-	if (jfs_ip->next_index < 2) {
-		jfs_warn("add_index: next_index = %d.  Resetting!",
-			   jfs_ip->next_index);
-		jfs_ip->next_index = 2;
-	}
+	if (jfs_ip->next_index < 3) {
+		jfs_ip->next_index = 3;
 
 	index = jfs_ip->next_index++;
 
@@ -2864,7 +2861,7 @@ void dtInitRoot(tid_t tid, struct inode *ip, u32 idotdot)
 		} else
 			ip->i_size = 1;
 
-		jfs_ip->next_index = 2;
+		jfs_ip->next_index = 3;
 	} else
 		ip->i_size = IDATASIZE;
 
@@ -2951,7 +2948,7 @@ static void add_missing_indices(struct inode *inode, s64 bn)
 	for (i = 0; i < p->header.nextindex; i++) {
 		d = (struct ldtentry *) &p->slot[stbl[i]];
 		index = le32_to_cpu(d->index);
-		if ((index < 2) || (index >= JFS_IP(inode)->next_index)) {
+		if ((index < 3) || (index >= JFS_IP(inode)->next_index)) {
 			d->index = cpu_to_le32(add_index(tid, inode, bn, i));
 			if (dtlck->index >= dtlck->maxcnt)
 				dtlck = (struct dt_lock *) txLinelock(dtlck);
@@ -3031,7 +3028,7 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 	struct jfs_dirent *jfs_dirent;
 	int jfs_dirents;
 	int overflow, fix_page, page_fixed = 0;
-	static int unique_pos = 2;	/* If we can't fix broken index */
+	static int unique_pos = 3;	/* If we can't fix broken index */
 
 	if (ctx->pos == DIREND)
 		return 0;
@@ -3039,15 +3036,16 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 	if (DO_INDEX(ip)) {
 		/*
 		 * persistent index is stored in directory entries.
-		 * Special cases:	 0 = .
-		 *			 1 = ..
+		 * Special cases:	 0 = rewind
+		 *			 1 = .
+		 *			 2 = ..
 		 *			-1 = End of directory
 		 */
 		do_index = 1;
 
 		dir_index = (u32) ctx->pos;
 
-		if (dir_index > 1) {
+		if (dir_index > 2) {
 			struct dir_table_slot dirtab_slot;
 
 			if (dtEmpty(ip) ||
@@ -3090,18 +3088,18 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 				return 0;
 			}
 		} else {
-			if (dir_index == 0) {
+			if (dir_index < 2) {
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
 
@@ -3122,22 +3120,24 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
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
+			ctx->pos = 1;
 			/* build "." entry */
 			if (!dir_emit(ctx, ".", 1, ip->i_ino, DT_DIR))
 				return 0;
-			dtoffset->index = 1;
+			dtoffset->index = 2;
 			ctx->pos = dtpos;
 		}
 
 		if (dtoffset->pn == 0) {
-			if (dtoffset->index == 1) {
+			if (dtoffset->index == 2) {
+				ctx->pos = 2;
 				/* build ".." entry */
 				if (!dir_emit(ctx, "..", 2, PARENT(ip), DT_DIR))
 					return 0;
@@ -3210,8 +3210,12 @@ int jfs_readdir(struct file *file, struct dir_context *ctx)
 				 * directory index for the lost+found
 				 * directory.  Rather than let it go,
 				 * we can try to fix it.
+				 *
+				 * Additionally, a value of 2 used to be
+				 * valid, but it didn't work well with
+				 * NFSv4, so if found, we need to change it
 				 */
-				if ((jfs_dirent->position < 2) ||
+				if ((jfs_dirent->position < 3) ||
 				    (jfs_dirent->position >=
 				     JFS_IP(ip)->next_index)) {
 					if (!page_fixed && !isReadOnly(ip)) {
