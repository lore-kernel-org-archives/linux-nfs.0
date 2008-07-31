From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 2/4] Copy XFS readdir hack into nfsd code, introduce
	FS_NO_LOOKUP_IN_READDIR flag
Date: Thu, 31 Jul 2008 22:54:56 +0100
Message-ID: <1217541296.1126.18.camel@shinybook.infradead.org>
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

Some file systems with their own internal locking have problems with the
way that nfsd calls the ->lookup() method from within a filldir function
called from their ->readdir() method. The recursion back into the file
system code can cause deadlock.

XFS has a fairly hackish solution to this which involves doing the
readdir() into a locally-allocated buffer, then going back through it
calling the filldir function afterwards. It's not ideal, but it works.

It's particularly suboptimal because XFS does this for local file
systems too, where it's completely unnecessary.

Copy this hack into the NFS code where it can be used only for NFS, and
only for file systems which indicate that they need it by setting
FS_NO_LOOKUP_IN_READDIR in their fs_type flags.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 fs/nfsd/vfs.c      |  111 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h |    2 +
 2 files changed, 112 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 3e22634..81c9411 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1814,6 +1814,111 @@ out:
 	return err;
 }
 
+struct hack_dirent {
+	u64		ino;
+	loff_t		offset;
+	int		namlen;
+	unsigned int	d_type;
+	char		name[];
+};
+
+struct hack_callback {
+	char		*dirent;
+	size_t		len;
+	size_t		used;
+};
+
+static int nfsd_hack_filldir(void *__buf, const char *name, int namlen,
+			     loff_t offset, u64 ino, unsigned int d_type)
+{
+	struct hack_callback *buf = __buf;
+	struct hack_dirent *de = (void *)(buf->dirent + buf->used);
+	unsigned int reclen;
+
+	reclen = ALIGN(sizeof(struct hack_dirent) + namlen, sizeof(u64));
+	if (buf->used + reclen > buf->len)
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
+static int nfsd_hack_readdir(struct file *file, filldir_t func, 
+			     struct readdir_cd *cdp, loff_t *offsetp)
+{
+	struct hack_callback buf;
+	struct hack_dirent *de;
+	int host_err;
+	int size;
+	loff_t offset;
+
+	/*
+	 * Try fairly hard to get memory
+	 */
+	buf.len = PAGE_CACHE_SIZE;
+	do {
+		buf.dirent = kmalloc(buf.len, GFP_KERNEL);
+		if (buf.dirent)
+			break;
+		buf.len >>= 1;
+	} while (buf.len >= 1024);
+
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
+		host_err = vfs_readdir(file, nfsd_hack_filldir, &buf);
+		if (host_err)
+			break;
+
+		size = buf.used;
+
+		if (!size)
+			break;
+
+
+		de = (struct hack_dirent *)buf.dirent;
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
+			reclen = ALIGN(sizeof(struct hack_dirent) + de->namlen,
+				       sizeof(u64));
+			size -= reclen;
+			de = (struct hack_dirent *)((char *)de + reclen);
+		}
+		offset = vfs_llseek(file, 0, 1);
+	}
+
+ done:
+	kfree(buf.dirent);
+
+	if (host_err)
+		return nfserrno(host_err);
+
+	*offsetp = offset;
+	return cdp->err;
+}
+
 static int nfsd_do_readdir(struct file *file, filldir_t func,
 			   struct readdir_cd *cdp, loff_t *offsetp)
 {
@@ -1859,7 +1964,11 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 		goto out_close;
 	}
 
-	err = nfsd_do_readdir(file, func, cdp, offsetp);
+	if ((file->f_path.dentry->d_inode->i_sb->s_type->fs_flags &
+	     FS_NO_LOOKUP_IN_READDIR))
+		err = nfsd_hack_readdir(file, func, cdp, offsetp);
+	else
+		err = nfsd_do_readdir(file, func, cdp, offsetp);
 
 	if (err == nfserr_eof || err == nfserr_toosmall)
 		err = nfs_ok; /* can still be found in ->err */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 580b513..80ca410 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -100,6 +100,8 @@ extern int dir_notify_enable;
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move()
 					 * during rename() internally.
 					 */
+#define FS_NO_LOOKUP_IN_READDIR	65536	/* FS will deadlock if you call its
+					   lookup() method from filldir */
 
 /*
  * These are the fs-independent mount-flags: up to 32 flags are supported
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

