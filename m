From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 05/39] whiteout/NFSD: Don't return information about
 whiteouts to userspace
Date: Tue, 4 May 2010 09:37:31 +1000
Message-ID: <20100504093731.3a45ff5f@notabene.brown>
References: <1272928358-20854-1-git-send-email-vaurora@redhat.com>
	<1272928358-20854-6-git-send-email-vaurora@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Jan Blunck <jblunck@suse.de>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
To: Valerie Aurora <vaurora@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:43669 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759911Ab0ECXhn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 May 2010 19:37:43 -0400
In-Reply-To: <1272928358-20854-6-git-send-email-vaurora@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon,  3 May 2010 16:12:04 -0700
Valerie Aurora <vaurora@redhat.com> wrote:

> From: Jan Blunck <jblunck@suse.de>
> 
> Userspace isn't ready for handling another file type, so silently drop
> whiteout directory entries before they leave the kernel.

Feels very intrusive doesn't it....

Have you considered something like the following?

NeilBrown

diff --git a/fs/readdir.c b/fs/readdir.c
index 7723401..4c5b347 100644
--- a/fs/readdir.c
+++ b/fs/readdir.c
@@ -19,10 +19,26 @@
 
 #include <asm/uaccess.h>
 
+struct readdir_info {
+	filldir_t filler;
+	void *data;
+};
+
+static int white_out(void *vrdi, const char *name, int namlen,
+		     loff_t offset, u64 ino, unsigned int d_type)
+{
+	struct readdir_info *rdi = vrdi;
+	if (d_type == DT_WHT)
+		return 0;
+	return rdi->filler(rdi->data, name, namlen, offset, info, d_type);
+}
+
 int vfs_readdir(struct file *file, filldir_t filler, void *buf)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
 	int res = -ENOTDIR;
+	struct readir_info rdi = { filler, buf };
+
 	if (!file->f_op || !file->f_op->readdir)
 		goto out;
 
@@ -36,7 +52,7 @@ int vfs_readdir(struct file *file, filldir_t filler, void *buf)
 
 	res = -ENOENT;
 	if (!IS_DEADDIR(inode)) {
-		res = file->f_op->readdir(file, buf, filler);
+		res = file->f_op->readdir(file, &rdi, white_out);
 		file_accessed(file);
 	}
 	mutex_unlock(&inode->i_mutex);
