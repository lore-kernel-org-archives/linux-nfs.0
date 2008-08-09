From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sat, 09 Aug 2008 17:47:58 +0100
Message-ID: <1218300478.26926.114.camel@pmac.infradead.org>
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
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, chucklever@gmail.com,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40271 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbYHIQsL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2008 12:48:11 -0400
In-Reply-To: <1218053443.5111.148.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-08-06 at 21:10 +0100, David Woodhouse wrote:
> On Wed, 2008-08-06 at 15:56 -0400, J. Bruce Fields wrote:
> > So the only solution that seems to really be holding up (at least for
> > the near term) is the double-buffering "hack"; could we get a version
> > of that with Neil's review comments addressed?
> 
> git.infradead.org/users/dwmw2/nfsexport-2.6.git
> 
> I inverted the logic so that the file system has to set a
> FS_LOOKUP_IN_READDIR flag to avoid the hack, rather than setting a
> FS_NO_LOOKUP_IN_READDIR flag to _use_ it. Renamed it so that it doesn't
> say 'hack', took out the loop to allocate memory.
> 
> Tasks left for someone more familiar with the NFS code are: 
>  - making it use one of the pages already allocated for the response.
>  - giving it a hint about how many dirents to read into the buffer.

Here it is in a single patch...

commit b4bf782886f5f7711c8ce2c0f3778bf52bda1d56
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Jul 31 20:39:25 2008 +0100

    [JFFS2] Reinstate NFS exportability
    
    Now that the readdir/lookup deadlock issues have been dealt with, we can
    export JFFS2 file systems again.
    
    (For now, you have to specify fsid manually; we should add a method to
    the export_ops to handle that too.)
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

commit 681b29d988a0dbf8d086958cbeae26fea710baf1
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Wed Aug 6 15:21:59 2008 +0100

    Mark isofs as being able to handle lookup() within readdir()
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

commit 14b5cf410c17afd7b2589b68ca3ca23352789d2f
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Wed Aug 6 15:21:39 2008 +0100

    Mark msdos/vfat as being able to handle lookup() within readdir()
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

commit 20a7a67be0ac1f788e77c3e333f241e3395e5dc7
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Wed Aug 6 15:18:37 2008 +0100

    Mark ext[234] as able to handle lookup() within readdir()
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

commit bade5f353e2cfd31fcec038b41e7cb68bb3321f1
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Jul 31 20:38:04 2008 +0100

    Remove XFS buffered readdir hack
    
    Now that we've moved the readdir hack to the nfsd code, we can
    remove the local version from the XFS code.
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

commit b8179eee3e72039c8acc9b8efe807031bba3b931
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Jul 31 20:29:12 2008 +0100

    Copy XFS readdir hack into nfsd code, introduce FS_LOOKUP_IN_READDIR flag
    
    Some file systems with their own internal locking have problems with the
    way that nfsd calls the ->lookup() method from within a filldir function
    called from their ->readdir() method. The recursion back into the file
    system code can cause deadlock.
    
    XFS has a fairly hackish solution to this which involves doing the
    readdir() into a locally-allocated buffer, then going back through it
    calling the filldir function afterwards. It's not ideal, but it works.
    
    It's particularly suboptimal because XFS does this for local file
    systems too, where it's completely unnecessary.
    
    Copy this hack into the NFS code where it can be used only for NFS
    export. Allow file systems which are _not_ prone to this deadlock to
    avoid the buffered version by setting FS_LOOKUP_IN_READDIR in their
    fs_type flags to indicate that calling lookup() from readdir() is OK.
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

commit f5d45f637d4907cd6a55bda9465eec997351e9fc
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Jul 31 17:16:51 2008 +0100

    Factor out nfsd_do_readdir() into its own function
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

 fs/ext2/super.c             |    2 +-
 fs/ext3/super.c             |    2 +-
 fs/ext4/super.c             |    2 +-
 fs/isofs/inode.c            |    2 +-
 fs/jffs2/super.c            |   60 +++++++++++++++++++
 fs/msdos/namei.c            |    2 +-
 fs/nfsd/vfs.c               |  136 ++++++++++++++++++++++++++++++++++++++-----
 fs/vfat/namei.c             |    2 +-
 fs/xfs/linux-2.6/xfs_file.c |  120 --------------------------------------
 include/linux/fs.h          |    2 +
 10 files changed, 189 insertions(+), 141 deletions(-)


diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index fd88c7b..d8ef9ea 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -1401,7 +1401,7 @@ static struct file_system_type ext2_fs_type = {
 	.name		= "ext2",
 	.get_sb		= ext2_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_LOOKUP_IN_READDIR,
 };
 
 static int __init init_ext2_fs(void)
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index f38a5af..790a40e 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -2938,7 +2938,7 @@ static struct file_system_type ext3_fs_type = {
 	.name		= "ext3",
 	.get_sb		= ext3_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_LOOKUP_IN_READDIR,
 };
 
 static int __init init_ext3_fs(void)
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d5d7795..2911f43 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -3497,7 +3497,7 @@ static struct file_system_type ext4dev_fs_type = {
 	.name		= "ext4dev",
 	.get_sb		= ext4_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_LOOKUP_IN_READDIR,
 };
 
 static int __init init_ext4_fs(void)
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index 26948a6..f81b920 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1460,7 +1460,7 @@ static struct file_system_type iso9660_fs_type = {
 	.name		= "iso9660",
 	.get_sb		= isofs_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_LOOKUP_IN_READDIR,
 };
 
 static int __init init_iso9660_fs(void)
diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index efd4012..41ed563 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -22,6 +22,7 @@
 #include <linux/mtd/super.h>
 #include <linux/ctype.h>
 #include <linux/namei.h>
+#include <linux/exportfs.h>
 #include "compr.h"
 #include "nodelist.h"
 
@@ -62,6 +63,64 @@ static int jffs2_sync_fs(struct super_block *sb, int wait)
 	return 0;
 }
 
+static struct inode *jffs2_nfs_get_inode(struct super_block *sb, uint64_t ino,
+					 uint32_t generation)
+{
+	return jffs2_iget(sb, ino);
+}
+
+static struct dentry *jffs2_fh_to_dentry(struct super_block *sb, struct fid *fid,
+					 int fh_len, int fh_type)
+{
+        return generic_fh_to_dentry(sb, fid, fh_len, fh_type,
+                                    jffs2_nfs_get_inode);
+}
+
+static struct dentry *jffs2_fh_to_parent(struct super_block *sb, struct fid *fid,
+					 int fh_len, int fh_type)
+{
+        return generic_fh_to_parent(sb, fid, fh_len, fh_type,
+                                    jffs2_nfs_get_inode);
+}
+
+static struct dentry *jffs2_get_parent(struct dentry *child)
+{
+	struct jffs2_inode_info *f;
+	struct dentry *parent;
+	struct inode *inode;
+	uint32_t pino;
+
+	if (!S_ISDIR(child->d_inode->i_mode))
+		return ERR_PTR(-EACCES);
+
+	f = JFFS2_INODE_INFO(child->d_inode);
+
+	pino = f->inocache->pino_nlink;
+
+	JFFS2_DEBUG("Parent of directory ino #%u is #%u\n",
+		    f->inocache->ino, pino);
+
+	inode = jffs2_iget(child->d_inode->i_sb, pino);
+	if (IS_ERR(inode)) {
+		JFFS2_ERROR("Failed to get inode #%u: %ld\n", pino,
+			    PTR_ERR(inode));
+		return ERR_CAST(inode);
+	}
+
+	parent = d_alloc_anon(inode);
+	if (!parent) {
+		iput(inode);
+		parent = ERR_PTR(-ENOMEM);
+	}
+	return parent;
+}
+
+static struct export_operations jffs2_export_ops = {
+	.get_parent = jffs2_get_parent,
+	.fh_to_dentry = jffs2_fh_to_dentry,
+	.fh_to_parent = jffs2_fh_to_parent,
+};
+
 static const struct super_operations jffs2_super_operations =
 {
 	.alloc_inode =	jffs2_alloc_inode,
@@ -104,6 +163,7 @@ static int jffs2_fill_super(struct super_block *sb, void *data, int silent)
 	spin_lock_init(&c->inocache_lock);
 
 	sb->s_op = &jffs2_super_operations;
+ 	sb->s_export_op = &jffs2_export_ops;
 	sb->s_flags = sb->s_flags | MS_NOATIME;
 	sb->s_xattr = jffs2_xattr_handlers;
 #ifdef CONFIG_JFFS2_FS_POSIX_ACL
diff --git a/fs/msdos/namei.c b/fs/msdos/namei.c
index e844b98..feebc28 100644
--- a/fs/msdos/namei.c
+++ b/fs/msdos/namei.c
@@ -681,7 +681,7 @@ static struct file_system_type msdos_fs_type = {
 	.name		= "msdos",
 	.get_sb		= msdos_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_LOOKUP_IN_READDIR,
 };
 
 static int __init init_msdos_fs(void)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 18060be..ccff326 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1814,6 +1814,123 @@ out:
 	return err;
 }
 
+struct buffered_dirent {
+	u64		ino;
+	loff_t		offset;
+	int		namlen;
+	unsigned int	d_type;
+	char		name[];
+};
+
+struct readdir_data {
+	char		*dirent;
+	size_t		used;
+};
+
+static int nfsd_buffered_filldir(void *__buf, const char *name, int namlen,
+				 loff_t offset, u64 ino, unsigned int d_type)
+{
+	struct readdir_data *buf = __buf;
+	struct buffered_dirent *de = (void *)(buf->dirent + buf->used);
+	unsigned int reclen;
+
+	reclen = ALIGN(sizeof(struct buffered_dirent) + namlen, sizeof(u64));
+	if (buf->used + reclen > PAGE_SIZE)
+		return -EINVAL;
+
+	de->namlen = namlen;
+	de->offset = offset;
+	de->ino = ino;
+	de->d_type = d_type;
+	memcpy(de->name, name, namlen);
+	buf->used += reclen;
+
+	return 0;
+}
+
+static int nfsd_buffered_readdir(struct file *file, filldir_t func, 
+				 struct readdir_cd *cdp, loff_t *offsetp)
+{
+	struct readdir_data buf;
+	struct buffered_dirent *de;
+	int host_err;
+	int size;
+	loff_t offset;
+
+	buf.dirent = (void *)__get_free_page(GFP_KERNEL);
+	if (!buf.dirent)
+		return -ENOMEM;
+
+	offset = *offsetp;
+	cdp->err = nfserr_eof; /* will be cleared on successful read */
+
+	while (1) {
+		unsigned int reclen;
+
+		buf.used = 0;
+
+		host_err = vfs_readdir(file, nfsd_buffered_filldir, &buf);
+		if (host_err)
+			break;
+
+		size = buf.used;
+
+		if (!size)
+			break;
+
+
+		de = (struct buffered_dirent *)buf.dirent;
+		while (size > 0) {
+			offset = de->offset;
+
+			if (func(cdp, de->name, de->namlen, de->offset,
+				 de->ino, de->d_type))
+				goto done;
+
+			if (cdp->err != nfs_ok)
+				goto done;
+
+			reclen = ALIGN(sizeof(*de) + de->namlen,
+				       sizeof(u64));
+			size -= reclen;
+			de = (struct buffered_dirent *)((char *)de + reclen);
+		}
+		offset = vfs_llseek(file, 0, 1);
+	}
+
+ done:
+	free_page((unsigned long)(buf.dirent));
+
+	if (host_err)
+		return nfserrno(host_err);
+
+	*offsetp = offset;
+	return cdp->err;
+}
+
+static int nfsd_do_readdir(struct file *file, filldir_t func,
+			   struct readdir_cd *cdp, loff_t *offsetp)
+{
+	int host_err;
+
+	/*
+	 * Read the directory entries. This silly loop is necessary because
+	 * readdir() is not guaranteed to fill up the entire buffer, but
+	 * may choose to do less.
+	 */
+	do {
+		cdp->err = nfserr_eof; /* will be cleared on successful read */
+		host_err = vfs_readdir(file, func, cdp);
+	} while (host_err >=0 && cdp->err == nfs_ok);
+
+	*offsetp = vfs_llseek(file, 0, 1);
+
+	if (host_err)
+		return nfserrno(host_err);
+	else
+		return cdp->err;
+}
+
 /*
  * Read entries from a directory.
  * The  NFSv3/4 verifier we ignore for now.
@@ -1823,7 +1940,6 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 	     struct readdir_cd *cdp, filldir_t func)
 {
 	__be32		err;
-	int 		host_err;
 	struct file	*file;
 	loff_t		offset = *offsetp;
 
@@ -1837,21 +1953,11 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 		goto out_close;
 	}
 
-	/*
-	 * Read the directory entries. This silly loop is necessary because
-	 * readdir() is not guaranteed to fill up the entire buffer, but
-	 * may choose to do less.
-	 */
-
-	do {
-		cdp->err = nfserr_eof; /* will be cleared on successful read */
-		host_err = vfs_readdir(file, func, cdp);
-	} while (host_err >=0 && cdp->err == nfs_ok);
-	if (host_err)
-		err = nfserrno(host_err);
+	if ((file->f_path.dentry->d_inode->i_sb->s_type->fs_flags &
+	     FS_LOOKUP_IN_READDIR))
+		err = nfsd_do_readdir(file, func, cdp, offsetp);
 	else
-		err = cdp->err;
-	*offsetp = vfs_llseek(file, 0, 1);
+		err = nfsd_buffered_readdir(file, func, cdp, offsetp);
 
 	if (err == nfserr_eof || err == nfserr_toosmall)
 		err = nfs_ok; /* can still be found in ->err */
diff --git a/fs/vfat/namei.c b/fs/vfat/namei.c
index 155c10b..95d0b6f 100644
--- a/fs/vfat/namei.c
+++ b/fs/vfat/namei.c
@@ -1034,7 +1034,7 @@ static struct file_system_type vfat_fs_type = {
 	.name		= "vfat",
 	.get_sb		= vfat_get_sb,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_LOOKUP_IN_READDIR,
 };
 
 static int __init init_vfat_fs(void)
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
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 580b513..001ba17 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -100,6 +100,8 @@ extern int dir_notify_enable;
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move()
 					 * during rename() internally.
 					 */
+#define FS_LOOKUP_IN_READDIR	65536	/* FS won't deadlock if you call its
+					   lookup() method from filldir */
 
 /*
  * These are the fs-independent mount-flags: up to 32 flags are supported


-- 
dwmw2

