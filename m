Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hub024-nj-5.exch024.serverdata.net ([206.225.165.120]:38414
	"EHLO HUB024-nj-5.exch024.serverdata.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753555Ab1G0K4q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 06:56:46 -0400
From: Anand Avati <avati@gluster.com>
To: <miklos@szeredi.hu>
CC: <fuse-devel@lists.sourceforge.net>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, Anand Avati <avati@gluster.com>
Subject: [PATCH v2 2/2] fuse: permit O_DIRECT flag in open()
Date: Wed, 27 Jul 2011 03:56:19 -0700
Message-ID: <1311764179-20326-2-git-send-email-avati@gluster.com>
In-Reply-To: <1311764179-20326-1-git-send-email-avati@gluster.com>
References: <n>
 <1311764179-20326-1-git-send-email-avati@gluster.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

FUSE currently disallows O_DIRECT flag in open(). It is tricky dealing with
setting/unsetting of O_DIRECT flag on an open file. There are applications
(primarily VMs and databases) which open files with O_DIRECT flag. These
applications do not work on FUSE due to this limitation.

The approach with this patch is to permit opens with O_DIRECT, but instead
disable setting/unsetting of the O_DIRECT flag no matter how the file was
opened. This limitation is for more practical than disallowing O_DIRECT
altogether.

Signed-off-by: Anand Avati <avati@gluster.com>
---
 fs/fuse/file.c |   36 ++++++++++++++++++++++++++++++++----
 1 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 82a6646..355c30f 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -154,6 +154,27 @@ int fuse_do_open(struct fuse_conn *fc, u64 nodeid, struct file *file,
 		return err;
 	}
 
+	if (file->f_flags & O_DIRECT) {
+		if (!(outarg.open_flags & FOPEN_DIRECT_IO)) {
+			/* filesystem process did not acknowledge the O_DIRECT
+			   flag with FOPEN_DIRECT_IO bit in ourarg. Hence
+			   we fail the open().
+
+			   Notify the filesystem process about the failed
+			   open with fuse_sync_release right here itself as
+			   file->private_data is not yet set up for release
+			   notification.
+			*/
+			fuse_sync_release(ff, file->f_flags);
+			return -EINVAL;
+		}
+
+		/* make VFS believe we don't support O_DIRECT till we
+		   implement a_ops->direct_IO
+		*/
+		file->f_flags &= ~O_DIRECT;
+	}
+
 	if (isdir)
 		outarg.open_flags &= ~FOPEN_DIRECT_IO;
 
@@ -193,10 +214,6 @@ int fuse_open_common(struct inode *inode, struct file *file, bool isdir)
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	int err;
 
-	/* VFS checks this, but only _after_ ->open() */
-	if (file->f_flags & O_DIRECT)
-		return -EINVAL;
-
 	err = generic_file_open(inode, file);
 	if (err)
 		return err;
@@ -2132,6 +2149,15 @@ int fuse_notify_poll_wakeup(struct fuse_conn *fc,
 	return 0;
 }
 
+
+static int fuse_check_flags(struct file *filp, int flags)
+{
+	if ((filp->f_flags ^ flags) & O_DIRECT)
+		return -EINVAL;
+	return 0;
+}
+
+
 static const struct file_operations fuse_file_operations = {
 	.llseek		= fuse_file_llseek,
 	.read		= do_sync_read,
@@ -2149,6 +2175,7 @@ static const struct file_operations fuse_file_operations = {
 	.unlocked_ioctl	= fuse_file_ioctl,
 	.compat_ioctl	= fuse_file_compat_ioctl,
 	.poll		= fuse_file_poll,
+	.check_flags	= fuse_check_flags,
 };
 
 static const struct file_operations fuse_direct_io_file_operations = {
@@ -2165,6 +2192,7 @@ static const struct file_operations fuse_direct_io_file_operations = {
 	.unlocked_ioctl	= fuse_file_ioctl,
 	.compat_ioctl	= fuse_file_compat_ioctl,
 	.poll		= fuse_file_poll,
+	.check_flags	= fuse_check_flags,
 	/* no splice_read */
 };
 
-- 
1.7.4.4

