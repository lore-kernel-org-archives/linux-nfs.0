Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755506Ab2DSOHk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 10:07:40 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/6] xstat: NFS: Return extended attributes
To: linux-fsdevel@vger.kernel.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Date: Thu, 19 Apr 2012 15:06:53 +0100
Message-ID: <20120419140653.17272.95035.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the NFS filesystem.  This includes the
following:

 (1) The change attribute as st_data_version if NFSv4.

 (2) XSTAT_INFO_AUTOMOUNT and XSTAT_INFO_FABRICATED are set on referral or
     submount directories that are automounted upon.  NFS shows one directory
     with a different FSID, but the local filesystem has two: the mountpoint
     directory and the root of the filesystem mounted upon it.

 (3) XSTAT_INFO_REMOTE is set on files acquired over NFS.

Furthermore, what nfs_getattr() does can be controlled as follows:

 (1) If AT_FORCE_ATTR_SYNC is indicated, or mtime, ctime or data_version (NFSv4
     only) are requested then the outstanding writes will be written to the
     server first.

 (2) The inode's attributes may be synchronised with the server:

     (a) If AT_FORCE_ATTR_SYNC is indicated or if atime is requested (and atime
     	 updating is not suppressed by a mount flag) then the attributes will
     	 be reread unconditionally.

     (b) If the data version or any of basic stats are requested then the
     	 attributes will be reread if the cached attributes have expired.

     (c) Otherwise the cached attributes will be used - even if expired -
     	 without reference to the server.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/inode.c |   49 +++++++++++++++++++++++++++++++++++++------------
 fs/nfs/super.c |    1 +
 2 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e8bbfa5..460fcf3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -509,11 +509,18 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
+	unsigned force = stat->query_flags & AT_FORCE_ATTR_SYNC;
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
 
-	/* Flush out writes to the server in order to update c/mtime.  */
-	if (S_ISREG(inode->i_mode)) {
+	if (NFS_SERVER(inode)->nfs_client->rpc_ops->version < 4)
+		stat->request_mask &= ~XSTAT_VERSION;
+
+	/* Flush out writes to the server in order to update c/mtime
+	 * or data version if the user wants them */
+	if ((force || (stat->request_mask &
+		       (XSTAT_MTIME | XSTAT_CTIME | XSTAT_VERSION))) &&
+	    S_ISREG(inode->i_mode)) {
 		err = filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
@@ -528,18 +535,36 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	 *  - NFS never sets MS_NOATIME or MS_NODIRATIME so there is
 	 *    no point in checking those.
 	 */
- 	if ((mnt->mnt_flags & MNT_NOATIME) ||
- 	    ((mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
+	if (mnt->mnt_flags & MNT_NOATIME ||
+	    (mnt->mnt_flags & MNT_NODIRATIME && S_ISDIR(inode->i_mode))) {
+		stat->ioc_flags |= FS_NOATIME_FL;
+		need_atime = 0;
+	} else if (!(stat->request_mask & XSTAT_ATIME)) {
 		need_atime = 0;
+	}
 
-	if (need_atime)
-		err = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	else
-		err = nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	if (!err) {
-		generic_fillattr(inode, stat);
-		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
+	if (force || stat->request_mask & (XSTAT_BASIC_STATS | XSTAT_VERSION)) {
+		if (force || need_atime)
+			err = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
+		else
+			err = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+		if (err)
+			goto out;
 	}
+
+	generic_fillattr(inode, stat);
+	stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
+
+	if (stat->request_mask & XSTAT_VERSION) {
+		stat->version = inode->i_version;
+		stat->result_mask |= XSTAT_VERSION;
+	}
+
+	if (IS_AUTOMOUNT(inode))
+		stat->information |= XSTAT_INFO_FABRICATED;
+
+	stat->information |= XSTAT_INFO_REMOTE;
+
 out:
 	return err;
 }
@@ -852,7 +877,7 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	
+
 	if (mapping->nrpages != 0) {
 		int ret = invalidate_inode_pages2(mapping);
 		if (ret < 0)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 37412f7..faa652c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2222,6 +2222,7 @@ static int nfs_set_super(struct super_block *s, void *data)
 	ret = set_anon_super(s, server);
 	if (ret == 0)
 		server->s_dev = s->s_dev;
+	memcpy(&s->s_volume_id, &server->fsid, sizeof(s->s_volume_id));
 	return ret;
 }
 

