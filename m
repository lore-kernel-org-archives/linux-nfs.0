Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392AbcD2M6O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 08:58:14 -0400
Subject: [PATCH 4/6] statx: NFS: Return enhanced file attributes
From: David Howells <dhowells@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-ext4@vger.kernel.org
Date: Fri, 29 Apr 2016 13:58:06 +0100
Message-ID: <20160429125806.23636.51590.stgit@warthog.procyon.org.uk>
In-Reply-To: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return enhanced file atrributes from the NFS filesystem.  This includes the
following:

 (1) The change attribute as st_version if NFSv4.

 (2) STATX_INFO_AUTOMOUNT and STATX_INFO_FABRICATED are set on referral or
     submount directories that are automounted upon.  NFS shows one
     directory with a different FSID, but the local filesystem has two: the
     mountpoint directory and the root of the filesystem mounted upon it.

 (3) STATX_INFO_REMOTE is set on files acquired over NFS.

 (4) STATX_IOC_FLAGS is set and if the atime is unavailable on a file,
     st_ioc_flags will have FL_NOATIME_FL set in it.

Furthermore, what nfs_getattr() does can be controlled as follows:

 (1) If AT_NO_ATTR_SYNC is indicated then this will suppress the flushing
     of outstanding writes and the rereading of the inode's attributes with
     the server as detailed below.

 (2) Otherwise:

     (a) If AT_FORCE_ATTR_SYNC is indicated, or mtime, ctime or
     	 data_version (NFSv4 only) are requested then the outstanding
     	 writes will be written to the server first.

     (b) The inode's attributes will be reread from the server:

     	 (i) if AT_FORCE_ATTR_SYNC is indicated;

        (ii) if atime is requested (and atime updating is not suppressed by
     	     a mount flag); or

       (iii) if the cached attributes have expired;

If the inode isn't synchronised, then the cached attributes will be used -
even if expired - without reference to the server.

Example output:

	[root@andromeda ~]# ./samples/statx/test-statx /warthog/
	statx(/warthog/) = 0
	results=37ef
	  Size: 4096            Blocks: 8          IO Block: 1048576  directory
	Device: 00:26           Inode: 2           Links: 122
	Access: (3777/drwxrwxrwx)  Uid:     0   Gid:  4041
	Access: 2015-10-30 16:15:41.730925545+0000
	Modify: 2015-10-07 10:33:19.896108112+0100
	Change: 2015-10-07 10:33:19.896108112+0100
	Data version: 5614e6df35698650h
	Inode flags: 00000000 (-------- -------- -------- --------)
	Information: 00000010 (-------- -------- -------- ---r----)
	IO-blocksize: blksize=1048576

Note that the NFS4 protocol potentially provides a creation time that could
be passed through this interface and system, hidden and archive values that
could be passed as IOC flags.  There is also a backup time that could be
added.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/inode.c |   41 ++++++++++++++++++++++++++++++++++-------
 1 file changed, 34 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 738c84a42eb0..8637236bca0c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -655,12 +655,23 @@ static bool nfs_need_revalidate_inode(struct inode *inode)
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = d_inode(dentry);
-	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
+	bool force_sync = stat->query_flags & AT_FORCE_ATTR_SYNC;
+	bool suppress_sync = stat->query_flags & AT_NO_ATTR_SYNC;
+	bool need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err = 0;
 
 	trace_nfs_getattr_enter(inode);
-	/* Flush out writes to the server in order to update c/mtime.  */
-	if (S_ISREG(inode->i_mode)) {
+
+	if (NFS_SERVER(inode)->nfs_client->rpc_ops->version < 4)
+		stat->request_mask &= ~STATX_VERSION;
+
+	/* Flush out writes to the server in order to update c/mtime or data
+	 * version if the user wants them.
+	 */
+	if (S_ISREG(inode->i_mode) && !suppress_sync &&
+	    (force_sync || (stat->request_mask &
+			    (STATX_MTIME | STATX_CTIME | STATX_VERSION)))
+	    ) {
 		inode_lock(inode);
 		err = nfs_sync_inode(inode);
 		inode_unlock(inode);
@@ -677,11 +688,13 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	 *  - NFS never sets MS_NOATIME or MS_NODIRATIME so there is
 	 *    no point in checking those.
 	 */
- 	if ((mnt->mnt_flags & MNT_NOATIME) ||
- 	    ((mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
-		need_atime = 0;
+	if (!(stat->request_mask & STATX_ATIME) ||
+	    (mnt->mnt_flags & MNT_NOATIME) ||
+	    ((mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
+		need_atime = false;
 
-	if (need_atime || nfs_need_revalidate_inode(inode)) {
+	if (!suppress_sync &&
+	    (force_sync || need_atime || nfs_need_revalidate_inode(inode))) {
 		struct nfs_server *server = NFS_SERVER(inode);
 
 		if (server->caps & NFS_CAP_READDIRPLUS)
@@ -694,6 +707,20 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 		if (S_ISDIR(inode->i_mode))
 			stat->blksize = NFS_SERVER(inode)->dtsize;
 	}
+
+	generic_fillattr(inode, stat);
+	stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
+
+	if (stat->request_mask & STATX_VERSION) {
+		stat->version = inode->i_version;
+		stat->result_mask |= STATX_VERSION;
+	}
+
+	if (IS_AUTOMOUNT(inode))
+		stat->information |= STATX_INFO_FABRICATED;
+
+	stat->information |= STATX_INFO_REMOTE;
+
 out:
 	trace_nfs_getattr_exit(inode, err);
 	return err;

