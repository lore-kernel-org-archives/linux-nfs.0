From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: make remounts of NFS filesystems return a proper error
	(resend)
Date: Thu, 10 Apr 2008 08:09:59 -0400
Message-ID: <1207829399-3328-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond.Myklebust@netapp.com
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,
   I sent this a few weeks ago and never got a response. Any thoughts?

Thanks,
Jeff

-----------[snip]------------

Currently if you try to remount an NFS filesystem (using -o remount),
it will return as if the remount had succeeded even though it doesn't
actually apply any changes to the mount options.

Since remount functionality isn't actually implemented, just have any
remount attempt return -ENOSYS to make it clear that it doesn't work.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fcf4b98..74c81bd 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -207,6 +207,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
 static void nfs_put_super(struct super_block *);
+static int nfs_remount(struct super_block *sb, int *flags, char *data);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -230,6 +231,7 @@ static const struct super_operations nfs_sops = {
 	.write_inode	= nfs_write_inode,
 	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
+	.remount_fs	= nfs_remount,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
@@ -274,6 +276,7 @@ static const struct super_operations nfs4_sops = {
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
 	.statfs		= nfs_statfs,
+	.remount_fs	= nfs_remount,
 	.clear_inode	= nfs4_clear_inode,
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
@@ -1681,6 +1684,16 @@ error_splat_super:
 	return error;
 }
 
+/*
+ * Remounts with NFS have a whole host of issues. Just have them fail
+ * outright for now.
+ */
+static int
+nfs_remount(struct super_block *sb, int *flags, char *data)
+{
+	return -ENOSYS;
+}
+
 #ifdef CONFIG_NFS_V4
 
 /*
-- 
1.5.3.6
