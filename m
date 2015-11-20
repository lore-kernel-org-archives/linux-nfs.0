Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162997AbbKTO4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:56:21 -0500
Subject: [PATCH 09/12] fsinfo: Ext4: Return information through the
 filesystem info syscall
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:56:13 +0000
Message-ID: <20151120145613.18930.78846.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return Ext4 filesystem information through the filesystem info retrieval
system call.  This includes the following:

 (1) information about the capacity and resolution of the inode timestamps;

 (2) the volume label as the volume name, setting FSINFO_VOLUME_NAME;

 (3) the remote FSID as the volume ID, setting FSINFO_VOLUME_ID;

 (4) the statfs information;

 (5) a list of supported IOC flags.

Example output:

	[root@andromeda ~]# ./test-fsinfo /var/cache/fscache/
	fsinfo(/var/cache/fscache/) = 0
	mask  : 9f
	dev   : 08:06
	fs    : type=ef53 name=ext4
	ioc   : 4bdfff
	nameln: 255
	flags : 1020
	times : range=ffffffff80000000-37fffffff
	atime : gran=1e-09s
	btime : gran=1e-09s
	ctime : gran=1e-09s
	mtime : gran=1e-09s
	blocks: n=1123529 fr=208887 av=146054
	files : n=293760 fr=225334 av=225334
	bsize : 4096
	frsize: 4096
	fsid  : 48bc815f32464608
	volume: 'fred'

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ext4/super.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index a63c7b0a10cf..fbd1cad4ff3b 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -73,6 +73,8 @@ static void ext4_clear_journal_err(struct super_block *sb,
 static int ext4_sync_fs(struct super_block *sb, int wait);
 static int ext4_remount(struct super_block *sb, int *flags, char *data);
 static int ext4_statfs(struct dentry *dentry, struct kstatfs *buf);
+static int ext4_get_fsinfo(struct dentry *dentry, struct fsinfo *f,
+			   unsigned flags);
 static int ext4_unfreeze(struct super_block *sb);
 static int ext4_freeze(struct super_block *sb);
 static struct dentry *ext4_mount(struct file_system_type *fs_type, int flags,
@@ -1122,6 +1124,7 @@ static const struct super_operations ext4_sops = {
 	.freeze_fs	= ext4_freeze,
 	.unfreeze_fs	= ext4_unfreeze,
 	.statfs		= ext4_statfs,
+	.get_fsinfo	= ext4_get_fsinfo,
 	.remount_fs	= ext4_remount,
 	.show_options	= ext4_show_options,
 #ifdef CONFIG_QUOTA
@@ -3524,6 +3527,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	if (sb->s_magic != EXT4_SUPER_MAGIC)
 		goto cantfind_ext4;
 	sbi->s_kbytes_written = le64_to_cpu(es->s_kbytes_written);
+	memcpy(sb->s_uuid, es->s_uuid, sizeof(sb->s_uuid));
 
 	/* Warn if metadata_csum and gdt_csum are both set. */
 	if (EXT4_HAS_RO_COMPAT_FEATURE(sb,
@@ -5179,6 +5183,41 @@ static int ext4_statfs(struct dentry *dentry, struct kstatfs *buf)
 	return 0;
 }
 
+/*
+ * Read filesystem information.
+ */
+static int ext4_get_fsinfo(struct dentry *dentry, struct fsinfo *f,
+			   unsigned flags)
+{
+	struct super_block *sb = dentry->d_sb;
+	struct ext4_sb_info *sbi = EXT4_SB(sb);
+	struct ext4_super_block *es = sbi->s_es;
+	struct inode *inode = d_inode(dentry);
+	struct ext4_inode *raw_inode;
+	struct ext4_inode_info *ei = EXT4_I(inode);
+
+	strcpy(f->f_volume_name, es->s_volume_name);
+
+	f->f_mask = FSINFO_FSID | FSINFO_VOLUME_NAME;
+	f->f_supported_ioc_flags = EXT4_FL_USER_VISIBLE;
+
+	f->f_min_time = S32_MIN;
+	f->f_max_time = S32_MAX;
+
+	if (EXT4_FITS_IN_INODE(raw_inode, ei, i_ctime_extra))
+		f->f_ctime_gran_exponent = -9;
+	if (EXT4_FITS_IN_INODE(raw_inode, ei, i_mtime_extra))
+		f->f_mtime_gran_exponent = -9;
+	if (EXT4_FITS_IN_INODE(raw_inode, ei, i_atime_extra)) {
+		f->f_atime_gran_exponent = -9;
+		f->f_max_time += ((1 << EXT4_EPOCH_BITS) - 1) * 0x100000000LL;
+	}
+	if (EXT4_FITS_IN_INODE(raw_inode, ei, i_crtime_extra))
+		f->f_btime_gran_exponent = -9;
+
+	return vfs_get_fsinfo_from_statfs(dentry, f, flags);
+}
+
 /* Helper function for writing quotas on sync - we need to start transaction
  * before quota file is locked for write. Otherwise the are possible deadlocks:
  * Process 1                         Process 2

