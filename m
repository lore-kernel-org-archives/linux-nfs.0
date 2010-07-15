From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/18] xstat: AFS: Return extended attributes [ver #6]
Date: Thu, 15 Jul 2010 03:17:14 +0100
Message-ID: <20100715021714.5544.76201.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <samba-technical-bounces@lists.samba.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
List-Unsubscribe: <https://lists.samba.org/mailman/options/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces@lists.samba.org
Errors-To: samba-technical-bounces@lists.samba.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the AFS filesystem.  This includes the
following:

 (1) The vnode uniquifier as st_gen.

 (2) The data version number as st_data_version.

 (3) FS_AUTOMOUNT_FL on mountpoint directories.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/inode.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index ee3190a..02f115f 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -300,16 +300,19 @@ error_unlock:
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
+	stat->result_mask |= XSTAT_REQUEST_GEN | XSTAT_REQUEST_DATA_VERSION;
+	stat->gen = inode->i_generation;
+	stat->data_version = inode->i_version;
+	if (test_bit(AFS_VNODE_MOUNTPOINT, &AFS_FS_I(inode)->flags))
+		stat->inode_flags |= FS_AUTOMOUNT_FL;
 	return 0;
 }
 
