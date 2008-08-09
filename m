From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 2/4] Copy XFS readdir hack into nfsd code.
Date: Sat, 09 Aug 2008 21:02:38 +0100
Message-ID: <1218312158.5063.7.camel@pmac.infradead.org>
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
Received: from bombadil.infradead.org ([18.85.46.34]:51340 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbYHIUDG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2008 16:03:06 -0400
In-Reply-To: <1218311710.26926.125.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
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

Copy this hack into the NFS code where it can be used only for NFS
export. In response to feedback, use it unconditionally rather than only
for the affected file systems.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 fs/nfsd/vfs.c |  108 +++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 93 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 3e22634..d789fb8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1814,27 +1814,105 @@ out:
 	return err;
 }
 
-static int nfsd_do_readdir(struct file *file, filldir_t func,
-			   struct readdir_cd *cdp, loff_t *offsetp)
+/*
+ * We do this buffering because we must not call back into the file
+ * system's ->lookup() method from the filldir callback. That may well
+ * deadlock a number of file systems.
+ *
+ * This is based heavily on the implementation of same in XFS.
+ */
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
 {
+	struct readdir_data buf;
+	struct buffered_dirent *de;
 	int host_err;
+	int size;
+	loff_t offset;
 
-	/*
-	 * Read the directory entries. This silly loop is necessary because
-	 * readdir() is not guaranteed to fill up the entire buffer, but
-	 * may choose to do less.
-	 */
-	do {
-		cdp->err = nfserr_eof; /* will be cleared on successful read */
-		host_err = vfs_readdir(file, func, cdp);
-	} while (host_err >=0 && cdp->err == nfs_ok);
+	buf.dirent = (void *)__get_free_page(GFP_KERNEL);
+	if (!buf.dirent)
+		return -ENOMEM;
+
+	offset = *offsetp;
+	cdp->err = nfserr_eof; /* will be cleared on successful read */
 
-	*offsetp = vfs_llseek(file, 0, 1);
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
 
 	if (host_err)
 		return nfserrno(host_err);
-	else
-		return cdp->err;
+
+	*offsetp = offset;
+	return cdp->err;
 }
 
 /*
@@ -1859,7 +1937,7 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 		goto out_close;
 	}
 
-	err = nfsd_do_readdir(file, func, cdp, offsetp);
+	err = nfsd_buffered_readdir(file, func, cdp, offsetp);
 
 	if (err == nfserr_eof || err == nfserr_toosmall)
 		err = nfs_ok; /* can still be found in ->err */
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



