Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab2DSOH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 10:07:26 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/6] xstat: AFS: Return extended attributes
To: linux-fsdevel@vger.kernel.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Date: Thu, 19 Apr 2012 15:06:39 +0100
Message-ID: <20120419140639.17272.61333.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the AFS filesystem.  This includes the
following:

 (1) The vnode uniquifier as st_gen.

 (2) The data version number as st_data_version.

 (3) XSTAT_INFO_AUTOMOUNT will be set on automount directories by virtue of
     S_AUTOMOUNT being set on the inode.  These are referrals to other volumes
     or other cells.

 (4) XSTAT_INFO_AUTODIR on a directory that does cell lookup for non-existent
     names and mounts them (typically mounted on /afs with -o autocell).  The
     resulting directories are marked XSTAT_INFO_FABRICATED as they do not
     actually exist in the mounted AFS directory.

 (6) Files, directories and symlinks accessed over AFS are marked
     XSTAT_INFO_REMOTE.

 (7) XSTAT_INFO_NONSYSTEM_OWNERSHIP is set as the UID and GID retrieved from an
     AFS share may not be applicable on the system.

 (8) XSTAT_INFO_HAS_ACL is set as AFS directories have ACLs (the UID and GID
     are only used through the ACLs) and these ACLs apply to the contents of
     the directories.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/inode.c |   29 +++++++++++++++++++++--------
 fs/afs/super.c |    7 +++++++
 2 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index d890ae3..062def2 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -71,9 +71,9 @@ static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 	inode->i_uid		= vnode->status.owner;
 	inode->i_gid		= 0;
 	inode->i_size		= vnode->status.size;
-	inode->i_ctime.tv_sec	= vnode->status.mtime_server;
-	inode->i_ctime.tv_nsec	= 0;
-	inode->i_atime		= inode->i_mtime = inode->i_ctime;
+	inode->i_mtime.tv_sec	= vnode->status.mtime_server;
+	inode->i_mtime.tv_nsec	= 0;
+	inode->i_atime		= inode->i_ctime = inode->i_mtime;
 	inode->i_blocks		= 0;
 	inode->i_generation	= vnode->fid.unique;
 	inode->i_version	= vnode->status.data_version;
@@ -374,16 +374,29 @@ error_unlock:
 /*
  * read the attributes of an inode
  */
-int afs_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		      struct kstat *stat)
+int afs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
-	struct inode *inode;
-
-	inode = dentry->d_inode;
+	struct inode *inode = dentry->d_inode;
 
 	_enter("{ ino=%lu v=%u }", inode->i_ino, inode->i_generation);
 
 	generic_fillattr(inode, stat);
+
+	stat->result_mask &= ~(XSTAT_ATIME | XSTAT_CTIME | XSTAT_BLOCKS);
+	stat->result_mask |= XSTAT_GEN | XSTAT_VERSION;
+	stat->gen = inode->i_generation;
+	stat->version = inode->i_version;
+
+	if (test_bit(AFS_VNODE_AUTOCELL, &AFS_FS_I(inode)->flags))
+		stat->information |= XSTAT_INFO_AUTODIR;
+
+	if (test_bit(AFS_VNODE_PSEUDODIR, &AFS_FS_I(inode)->flags))
+		stat->information |= XSTAT_INFO_FABRICATED;
+	else
+		stat->information |= XSTAT_INFO_REMOTE;
+
+	stat->information |=
+		XSTAT_INFO_NONSYSTEM_OWNERSHIP | XSTAT_INFO_HAS_ACL;
 	return 0;
 }
 
diff --git a/fs/afs/super.c b/fs/afs/super.c
index f02b31e..1f13b48 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -314,6 +314,13 @@ static int afs_fill_super(struct super_block *sb,
 	sb->s_bdi		= &as->volume->bdi;
 	strlcpy(sb->s_id, as->volume->vlocation->vldb.name, sizeof(sb->s_id));
 
+	/* construct a volume ID from the AFS volume ID and type */
+	sb->s_volume_id[4] = as->volume->type;
+	sb->s_volume_id[3] = as->volume->vid >> 0;
+	sb->s_volume_id[2] = as->volume->vid >> 8;
+	sb->s_volume_id[1] = as->volume->vid >> 16;
+	sb->s_volume_id[0] = as->volume->vid >> 24;
+
 	/* allocate the root inode and dentry */
 	fid.vid		= as->volume->vid;
 	fid.vnode	= 1;

