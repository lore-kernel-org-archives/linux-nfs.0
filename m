From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 3/4] Remove XFS buffered readdir hack
Date: Sat, 09 Aug 2008 21:03:11 +0100
Message-ID: <1218312191.5063.8.camel@pmac.infradead.org>
References: <1217607571.3454.417.camel@pmac.infradead.org>
	 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	 <20080802182644.GE30454@fieldses.org>
	 <18581.40178.976747.769343@notabene.brown>
	 <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com>
	 <18582.21855.2092.903688@notabene.brown>
	 <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com>
	 <20080805085157.GG21635@disturbed>
	 <18584.56584.98868.881298@notabene.brown>
	 <20080806000805.GJ21635@disturbed>  <20080806195635.GA31126@fieldses.org>
	 <1218053443.5111.148.camel@pmac.infradead.org>
	 <1218300478.26926.114.camel@pmac.infradead.org>
	 <1218311710.26926.125.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, chucklever@gmail.com,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51369 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbYHIUDT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2008 16:03:19 -0400
In-Reply-To: <1218311710.26926.125.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we've moved the readdir hack to the nfsd code, we can
remove the local version from the XFS code.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 fs/xfs/linux-2.6/xfs_file.c |  128 -------------------------------------------
 1 files changed, 0 insertions(+), 128 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_file.c b/fs/xfs/linux-2.6/xfs_file.c
index 5f60363..1946b44 100644
--- a/fs/xfs/linux-2.6/xfs_file.c
+++ b/fs/xfs/linux-2.6/xfs_file.c
@@ -204,15 +204,6 @@ xfs_file_fsync(
 	return -xfs_fsync(XFS_I(dentry->d_inode));
 }
 
-/*
- * Unfortunately we can't just use the clean and simple readdir implementation
- * below, because nfs might call back into ->lookup from the filldir callback
- * and that will deadlock the low-level btree code.
- *
- * Hopefully we'll find a better workaround that allows to use the optimal
- * version at least for local readdirs for 2.6.25.
- */
-#if 0
 STATIC int
 xfs_file_readdir(
 	struct file	*filp,
@@ -244,125 +235,6 @@ xfs_file_readdir(
 		return -error;
 	return 0;
 }
-#else
-
-struct hack_dirent {
-	u64		ino;
-	loff_t		offset;
-	int		namlen;
-	unsigned int	d_type;
-	char		name[];
-};
-
-struct hack_callback {
-	char		*dirent;
-	size_t		len;
-	size_t		used;
-};
-
-STATIC int
-xfs_hack_filldir(
-	void		*__buf,
-	const char	*name,
-	int		namlen,
-	loff_t		offset,
-	u64		ino,
-	unsigned int	d_type)
-{
-	struct hack_callback *buf = __buf;
-	struct hack_dirent *de = (struct hack_dirent *)(buf->dirent + buf->used);
-	unsigned int reclen;
-
-	reclen = ALIGN(sizeof(struct hack_dirent) + namlen, sizeof(u64));
-	if (buf->used + reclen > buf->len)
-		return -EINVAL;
-
-	de->namlen = namlen;
-	de->offset = offset;
-	de->ino = ino;
-	de->d_type = d_type;
-	memcpy(de->name, name, namlen);
-	buf->used += reclen;
-	return 0;
-}
-
-STATIC int
-xfs_file_readdir(
-	struct file	*filp,
-	void		*dirent,
-	filldir_t	filldir)
-{
-	struct inode	*inode = filp->f_path.dentry->d_inode;
-	xfs_inode_t	*ip = XFS_I(inode);
-	struct hack_callback buf;
-	struct hack_dirent *de;
-	int		error;
-	loff_t		size;
-	int		eof = 0;
-	xfs_off_t       start_offset, curr_offset, offset;
-
-	/*
-	 * Try fairly hard to get memory
-	 */
-	buf.len = PAGE_CACHE_SIZE;
-	do {
-		buf.dirent = kmalloc(buf.len, GFP_KERNEL);
-		if (buf.dirent)
-			break;
-		buf.len >>= 1;
-	} while (buf.len >= 1024);
-
-	if (!buf.dirent)
-		return -ENOMEM;
-
-	curr_offset = filp->f_pos;
-	if (curr_offset == 0x7fffffff)
-		offset = 0xffffffff;
-	else
-		offset = filp->f_pos;
-
-	while (!eof) {
-		unsigned int reclen;
-
-		start_offset = offset;
-
-		buf.used = 0;
-		error = -xfs_readdir(ip, &buf, buf.len, &offset,
-				     xfs_hack_filldir);
-		if (error || offset == start_offset) {
-			size = 0;
-			break;
-		}
-
-		size = buf.used;
-		de = (struct hack_dirent *)buf.dirent;
-		while (size > 0) {
-			curr_offset = de->offset /* & 0x7fffffff */;
-			if (filldir(dirent, de->name, de->namlen,
-					curr_offset & 0x7fffffff,
-					de->ino, de->d_type)) {
-				goto done;
-			}
-
-			reclen = ALIGN(sizeof(struct hack_dirent) + de->namlen,
-				       sizeof(u64));
-			size -= reclen;
-			de = (struct hack_dirent *)((char *)de + reclen);
-		}
-	}
-
- done:
-	if (!error) {
-		if (size == 0)
-			filp->f_pos = offset & 0x7fffffff;
-		else if (de)
-			filp->f_pos = curr_offset;
-	}
-
-	kfree(buf.dirent);
-	return error;
-}
-#endif
 
 STATIC int
 xfs_file_mmap(
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



