Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162997AbbKTO4e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:56:34 -0500
Subject: [PATCH 10/12] fsinfo: AFS: Return information through the
 filesystem info syscall
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:56:26 +0000
Message-ID: <20151120145626.18930.53321.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return AFS filesystem information through the filesystem info retrieval
system call.  This includes the following:

 (1) information about the capacity and resolution of the inode timestamps;

 (2) the cell name as the domain name, setting FSINFO_DOMAIN_NAME;

 (3) the volume name, setting FSINFO_VOLUME_NAME;

 (4) the volume ID plus the volume type75 as the volume ID, setting
     FSINFO_VOLUME_ID;

and unless AT_NO_ATTR_SYNC is specified:

 (5) the statfs information retrieved from the server.

Note that no FSID value is returned as the local FSID since the FSID value
is a local handle used by NFSD; see the volume ID field instead.

Example output:

	[root@andromeda ~]# ./test-fsinfo /afs
	fsinfo(/afs) = 0
	mask  : 1ad
	dev   : 00:24
	fs    : type=6b414653 name=afs
	ioc   : 0
	nameln: 255
	flags : 1020
	times : range=0-ffffffff
	atime : gran=1s
	btime : gran=1s
	ctime : gran=1s
	mtime : gran=1s
	blocks: n=5000 fr=4998 av=4998
	bsize : 1024
	frsize: 1024
	volid : 20000000 00000000 00000000 00000000
	volume: 'root.afs'
	domain: 'cambridge.redhat.com'

Possibly I should indicate the length of data stored in the volid field.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/super.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/fs/afs/super.c b/fs/afs/super.c
index 1fb4a5129f7d..ca88bb43ee1a 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -37,6 +37,8 @@ static void afs_kill_super(struct super_block *sb);
 static struct inode *afs_alloc_inode(struct super_block *sb);
 static void afs_destroy_inode(struct inode *inode);
 static int afs_statfs(struct dentry *dentry, struct kstatfs *buf);
+static int afs_get_fsinfo(struct dentry *dentry, struct fsinfo *f,
+			  unsigned flags);
 
 struct file_system_type afs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -49,6 +51,7 @@ MODULE_ALIAS_FS("afs");
 
 static const struct super_operations afs_super_ops = {
 	.statfs		= afs_statfs,
+	.get_fsinfo	= afs_get_fsinfo,
 	.alloc_inode	= afs_alloc_inode,
 	.drop_inode	= afs_drop_inode,
 	.destroy_inode	= afs_destroy_inode,
@@ -555,3 +558,39 @@ static int afs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	buf->f_bavail = buf->f_bfree = buf->f_blocks - vs.blocks_in_use;
 	return 0;
 }
+
+/*
+ * Read filesystem information.
+ */
+static int afs_get_fsinfo(struct dentry *dentry, struct fsinfo *f,
+			  unsigned flags)
+{
+	struct afs_super_info *as = dentry->d_sb->s_fs_info;
+	int ret;
+
+	f->f_bsize	= AFS_BLOCK_SIZE;
+	f->f_namelen	= AFSNAMEMAX - 1;
+	f->f_min_time	= 0;
+	f->f_max_time	= U32_MAX;
+
+	/* Construct a volume ID from the AFS volume ID and type */
+	f->f_volume_id[0] = as->volume->vid >> 24;
+	f->f_volume_id[1] = as->volume->vid >> 16;
+	f->f_volume_id[2] = as->volume->vid >> 8;
+	f->f_volume_id[3] = as->volume->vid >> 0;
+	f->f_volume_id[4] = as->volume->type;
+
+	strcpy(f->f_volume_name, as->volume->vlocation->vldb.name);
+	strcpy(f->f_domain_name, as->volume->cell->name);
+
+	f->f_mask = FSINFO_VOLUME_ID | FSINFO_VOLUME_NAME | FSINFO_DOMAIN_NAME;
+
+	if (flags & AT_NO_ATTR_SYNC)
+		return 0;
+
+	ret = vfs_get_fsinfo_from_statfs(dentry, f, flags);
+
+	/* Don't pass the FSID to userspace since this isn't exportable */
+	f->f_mask &= ~FSINFO_FSID;
+	return 0;
+}

