From: David Howells <dhowells@redhat.com>
Subject: [PATCH 03/18] AFS: Use i_generation not i_version for the vnode
	uniquifier [ver #6]
Date: Thu, 15 Jul 2010 03:17:13 +0100
Message-ID: <20100715021713.5544.70044.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Store the AFS vnode uniquifier in the i_generation field, not the i_version
field of the inode struct.  i_version can then be given the AFS data version
number.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/dir.c      |    8 ++++----
 fs/afs/fsclient.c |    3 ++-
 fs/afs/inode.c    |   10 +++++-----
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index b42d5cc..afb9ff8 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -542,11 +542,11 @@ static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
 	dentry->d_op = &afs_fs_dentry_operations;
 
 	d_add(dentry, inode);
-	_leave(" = 0 { vn=%u u=%u } -> { ino=%lu v=%llu }",
+	_leave(" = 0 { vn=%u u=%u } -> { ino=%lu v=%u }",
 	       fid.vnode,
 	       fid.unique,
 	       dentry->d_inode->i_ino,
-	       (unsigned long long)dentry->d_inode->i_version);
+	       dentry->d_inode->i_generation);
 
 	return NULL;
 }
@@ -626,10 +626,10 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 		 * been deleted and replaced, and the original vnode ID has
 		 * been reused */
 		if (fid.unique != vnode->fid.unique) {
-			_debug("%s: file deleted (uq %u -> %u I:%llu)",
+			_debug("%s: file deleted (uq %u -> %u I:%u)",
 			       dentry->d_name.name, fid.unique,
 			       vnode->fid.unique,
-			       (unsigned long long)dentry->d_inode->i_version);
+			       dentry->d_inode->i_generation);
 			spin_lock(&vnode->lock);
 			set_bit(AFS_VNODE_DELETED, &vnode->flags);
 			spin_unlock(&vnode->lock);
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 4bd0218..346e328 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -89,7 +89,7 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 			i_size_write(&vnode->vfs_inode, size);
 			vnode->vfs_inode.i_uid = status->owner;
 			vnode->vfs_inode.i_gid = status->group;
-			vnode->vfs_inode.i_version = vnode->fid.unique;
+			vnode->vfs_inode.i_generation = vnode->fid.unique;
 			vnode->vfs_inode.i_nlink = status->nlink;
 
 			mode = vnode->vfs_inode.i_mode;
@@ -102,6 +102,7 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 		vnode->vfs_inode.i_ctime.tv_sec	= status->mtime_server;
 		vnode->vfs_inode.i_mtime	= vnode->vfs_inode.i_ctime;
 		vnode->vfs_inode.i_atime	= vnode->vfs_inode.i_ctime;
+		vnode->vfs_inode.i_version	= data_version;
 	}
 
 	expected_version = status->data_version;
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index d00b312..ee3190a 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -73,7 +73,8 @@ static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 	inode->i_ctime.tv_nsec	= 0;
 	inode->i_atime		= inode->i_mtime = inode->i_ctime;
 	inode->i_blocks		= 0;
-	inode->i_version	= vnode->fid.unique;
+	inode->i_generation	= vnode->fid.unique;
+	inode->i_version	= vnode->status.data_version;
 	inode->i_mapping->a_ops	= &afs_fs_aops;
 
 	/* check to see whether a symbolic link is really a mountpoint */
@@ -98,7 +99,7 @@ static int afs_iget5_test(struct inode *inode, void *opaque)
 	struct afs_iget_data *data = opaque;
 
 	return inode->i_ino == data->fid.vnode &&
-		inode->i_version == data->fid.unique;
+		inode->i_generation == data->fid.unique;
 }
 
 /*
@@ -110,7 +111,7 @@ static int afs_iget5_set(struct inode *inode, void *opaque)
 	struct afs_vnode *vnode = AFS_FS_I(inode);
 
 	inode->i_ino = data->fid.vnode;
-	inode->i_version = data->fid.unique;
+	inode->i_generation = data->fid.unique;
 	vnode->fid = data->fid;
 	vnode->volume = data->volume;
 
@@ -306,8 +307,7 @@ int afs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 
 	inode = dentry->d_inode;
 
-	_enter("{ ino=%lu v=%llu }", inode->i_ino,
-		(unsigned long long)inode->i_version);
+	_enter("{ ino=%lu v=%u }", inode->i_ino, inode->i_generation);
 
 	generic_fillattr(inode, stat);
 	return 0;
