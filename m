From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 3/4] Switch XFS to using FS_NO_LOOKUP_IN_READDIR, remove
	local readdir hack
Date: Thu, 31 Jul 2008 22:55:05 +0100
Message-ID: <1217541305.1126.19.camel@shinybook.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <18458.28833.539314.455215@notabene.brown>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we've moved the readdir hack to the nfsd code, we can just set
the FS_NO_LOOKUP_IN_READDIR flag and then remove the local hack from the
xfs code.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 fs/xfs/linux-2.6/xfs_file.c  |  120 ------------------------------------------
 fs/xfs/linux-2.6/xfs_super.c |    2 +-
 2 files changed, 1 insertions(+), 121 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_file.c b/fs/xfs/linux-2.6/xfs_file.c
index 5f60363..d65d377 100644
--- a/fs/xfs/linux-2.6/xfs_file.c
+++ b/fs/xfs/linux-2.6/xfs_file.c
@@ -212,7 +212,6 @@ xfs_file_fsync(
  * Hopefully we'll find a better workaround that allows to use the optimal
  * version at least for local readdirs for 2.6.25.
  */
-#if 0
 STATIC int
 xfs_file_readdir(
 	struct file	*filp,
@@ -244,125 +243,6 @@ xfs_file_readdir(
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
diff --git a/fs/xfs/linux-2.6/xfs_super.c b/fs/xfs/linux-2.6/xfs_super.c
index 9433812..e44a21d 100644
--- a/fs/xfs/linux-2.6/xfs_super.c
+++ b/fs/xfs/linux-2.6/xfs_super.c
@@ -1426,7 +1426,7 @@ static struct file_system_type xfs_fs_type = {
 	.name			= "xfs",
 	.get_sb			= xfs_fs_get_sb,
 	.kill_sb		= kill_block_super,
-	.fs_flags		= FS_REQUIRES_DEV,
+	.fs_flags		= FS_REQUIRES_DEV | FS_NO_LOOKUP_IN_READDIR,
 };
 
 
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

