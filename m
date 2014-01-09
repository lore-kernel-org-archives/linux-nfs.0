Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:40612 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477AbaAITAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 14:00:03 -0500
Received: by mail-qc0-f171.google.com with SMTP id n7so1481574qcx.16
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 11:00:01 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: "Yin.JianHong" <jiyin@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH RFC] nfs: remove nfs_show_devname
Date: Thu,  9 Jan 2014 13:59:55 -0500
Message-Id: <1389293995-634-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs code will currently construct a devname to show in places like
/proc/mounts by turning a dentry into a path. Unfortunately, that's
somewhat problematic if the user ended up mounting through a symlink on
the server. The devname that then shows up in /proc/mounts now doesn't
match the one that was originally passed into the mount request.

For instance, suppose a server is exporting a filesystem "/export". We
then have this in /export:

    $ ls -ld foo bar
    lrwxrwxrwx. 1 root root 3 Jan  9 13:46 bar -> foo
    drwxr-xr-x. 2 root root 6 Jan  9 13:45 foo

Now, on the client we mount up 'bar':

    # mount server:/export/bar /mnt/server

...and 'df' now shows a different devname altogether.

    server:/export/foo                20G   66M   20G   1% /mnt/server

In the "old days", this didn't really matter since /proc/mounts was just
informational. On modern distros /etc/mtab is usually a symlink to
/proc/mounts so this means that unmounting by devname isn't always
reliable.

This patch just removes all of this code and has nfs just use the
kernel's standard facility for tracking the devname. With this, the
actual device name used to do the mount is displayed in
/proc/self/mounts, /proc/self/mountinfo, and /proc/self/mountstats.

Reported-by: Yin.JianHong <jiyin@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/internal.h  |  1 -
 fs/nfs/nfs4super.c |  1 -
 fs/nfs/super.c     | 18 ------------------
 3 files changed, 20 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8b5cc04..4e17d3f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -403,7 +403,6 @@ void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
 void nfs_umount_begin(struct super_block *);
 int  nfs_statfs(struct dentry *, struct kstatfs *);
 int  nfs_show_options(struct seq_file *, struct dentry *);
-int  nfs_show_devname(struct seq_file *, struct dentry *);
 int  nfs_show_path(struct seq_file *, struct dentry *);
 int  nfs_show_stats(struct seq_file *, struct dentry *);
 void nfs_put_super(struct super_block *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 65ab0a0..dc09ad2 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -58,7 +58,6 @@ static const struct super_operations nfs4_sops = {
 	.evict_inode	= nfs4_evict_inode,
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
-	.show_devname	= nfs_show_devname,
 	.show_path	= nfs_show_path,
 	.show_stats	= nfs_show_stats,
 	.remount_fs	= nfs_remount,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 910ed90..9490d8ef 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -316,7 +316,6 @@ const struct super_operations nfs_sops = {
 	.evict_inode	= nfs_evict_inode,
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
-	.show_devname	= nfs_show_devname,
 	.show_path	= nfs_show_path,
 	.show_stats	= nfs_show_stats,
 	.remount_fs	= nfs_remount,
@@ -773,23 +772,6 @@ static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
 }
 #endif
 
-int nfs_show_devname(struct seq_file *m, struct dentry *root)
-{
-	char *page = (char *) __get_free_page(GFP_KERNEL);
-	char *devname, *dummy;
-	int err = 0;
-	if (!page)
-		return -ENOMEM;
-	devname = nfs_path(&dummy, root, page, PAGE_SIZE, 0);
-	if (IS_ERR(devname))
-		err = PTR_ERR(devname);
-	else
-		seq_escape(m, devname, " \t\n\\");
-	free_page((unsigned long)page);
-	return err;
-}
-EXPORT_SYMBOL_GPL(nfs_show_devname);
-
 int nfs_show_path(struct seq_file *m, struct dentry *dentry)
 {
 	seq_puts(m, "/");
-- 
1.8.4.2

