Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760449AbbKTOzQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:55:16 -0500
Subject: [PATCH 04/12] statx: AFS: Return enhanced file attributes
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:55:10 +0000
Message-ID: <20151120145510.18930.50221.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return enhanced file attributes from the AFS filesystem.  This includes the
following:

 (1) The data version number as st_version, setting STATX_VERSION.

 (2) STATX_INFO_AUTOMOUNT will be set on automount directories by virtue of
     S_AUTOMOUNT being set on the inode.  These are referrals to other
     volumes or other cells.

 (3) STATX_INFO_AUTODIR on a directory that does cell lookup for
     non-existent names and mounts them (typically mounted on /afs with -o
     autocell).  The resulting directories are marked STATX_INFO_FABRICATED
     as they do not actually exist in the mounted AFS directory.

 (4) Files, directories and symlinks accessed over AFS are marked
     STATX_INFO_REMOTE.  Local fake directories are marked
     STATX_INFO_FABRICATED.

 (5) STATX_INFO_NONSYSTEM_OWNERSHIP is set as the UID and GID retrieved
     from an AFS share may not be applicable on the system.

STATX_ATIME, STATX_CTIME and STATX_BLOCKS are cleared as AFS does not
support them.

Example output:

	[root@andromeda ~]# ./samples/statx/test-statx /afs
	statx(/afs) = 0
	results=7ef
	  Size: 2048            Blocks: 0          IO Block: 4096    directory
	Device: 00:25           Inode: 1           Links: 2
	Access: (0777/drwxrwxrwx)  Uid:     0   Gid:     0
	Access: 2006-05-07 00:21:15.000000000+0100
	Modify: 2006-05-07 00:21:15.000000000+0100
	Change: 2006-05-07 00:21:15.000000000+0100
	IO-blocksize: blksize=4096

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/inode.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index e06f5a23352a..dcf0338ea5cc 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -71,9 +71,9 @@ static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 	inode->i_uid		= vnode->status.owner;
 	inode->i_gid		= GLOBAL_ROOT_GID;
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
@@ -374,8 +374,7 @@ error_unlock:
 /*
  * read the attributes of an inode
  */
-int afs_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		      struct kstat *stat)
+int afs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode;
 
@@ -384,6 +383,20 @@ int afs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	_enter("{ ino=%lu v=%u }", inode->i_ino, inode->i_generation);
 
 	generic_fillattr(inode, stat);
+
+	stat->result_mask &= ~(STATX_ATIME | STATX_CTIME | STATX_BLOCKS);
+	stat->result_mask |= STATX_VERSION;
+	stat->version = inode->i_version;
+
+	if (test_bit(AFS_VNODE_AUTOCELL, &AFS_FS_I(inode)->flags))
+		stat->information |= STATX_INFO_AUTODIR;
+
+	if (test_bit(AFS_VNODE_PSEUDODIR, &AFS_FS_I(inode)->flags))
+		stat->information |= STATX_INFO_FABRICATED;
+	else
+		stat->information |= STATX_INFO_REMOTE;
+
+	stat->information |= STATX_INFO_NONSYSTEM_OWNERSHIP;
 	return 0;
 }
 

