From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 2.4] SGI 932676 link_path_walk refcount problem allows
 umount of active filesystem
Date: Tue, 22 Mar 2005 12:24:37 +1100
Message-ID: <1111454677.1991.766.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fPp/ESy58Gj/36RjsLWj"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux AutoFS Mailing List <autofs@linux.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDY9m-0002v0-9X
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 17:26:06 -0800
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDY9k-0007LQ-RN
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 17:26:06 -0800
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-fPp/ESy58Gj/36RjsLWj
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

G'day,

The attached patch fixes a bug in the VFS code which causes
"Busy inodes after unmount" and a subsequent oops.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


--=-fPp/ESy58Gj/36RjsLWj
Content-Disposition: attachment; filename=sgi932676-fix-link-following-vfsmount-refcount-bug.patch
Content-Type: text/x-patch; name=sgi932676-fix-link-following-vfsmount-refcount-bug.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Following an absolute symlink opens a window during which the
filesystem containing the symlink has an outstanding dentry count
and no outstanding vfsmount count.  A umount() of the filesystem can
(incorrectly) proceed, resulting in the "Busy inodes after unmount"
message and an oops shortly thereafter.

Systems using autofs-controlled NFS mounts are especially vulnerable,
as autofs both increases the number of unmounts happening and does NFS
mounting in response to lookups which can result in multiple-second
vulnerability windows.  However the bug could happen on any filesystem.

This patch adds a mntget()/mntput() pair around the link following code
(as the 2.6 code does).  Attempts to umount() during link following
now return EBUSY.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---
 linux/linux/fs/namei.c |    7 +++++++
 1 files changed, 7 insertions(+)

--- a/linux/linux/fs/namei.c	2005-03-21 12:53:48 +11:00
+++ b/linux/linux/fs/namei.c	2005-03-21 12:16:46 +11:00
@@ -541,8 +541,10 @@
 			goto out_dput;
 
 		if (inode->i_op->follow_link) {
+			struct vfsmount *mnt = mntget(nd->mnt);
 			err = do_follow_link(dentry, nd);
 			dput(dentry);
+			mntput(mnt);
 			if (err)
 				goto return_err;
 			err = -ENOENT;
@@ -596,8 +598,10 @@
 		inode = dentry->d_inode;
 		if ((lookup_flags & LOOKUP_FOLLOW)
 		    && inode && inode->i_op && inode->i_op->follow_link) {
+			struct vfsmount *mnt = mntget(nd->mnt);
 			err = do_follow_link(dentry, nd);
 			dput(dentry);
+			mntput(mnt);
 			if (err)
 				goto return_err;
 			inode = nd->dentry->d_inode;
@@ -1002,6 +1006,7 @@
 	int acc_mode, error = 0;
 	struct inode *inode;
 	struct dentry *dentry;
+	struct vfsmount *mnt;
 	struct dentry *dir;
 	int count = 0;
 
@@ -1185,8 +1190,10 @@
 	 * are done. Procfs-like symlinks just set LAST_BIND.
 	 */
 	UPDATE_ATIME(dentry->d_inode);
+	mnt = mntget(nd->mnt);
 	error = dentry->d_inode->i_op->follow_link(dentry, nd);
 	dput(dentry);
+	mntput(mnt);
 	if (error)
 		return error;
 	if (nd->last_type == LAST_BIND) {

--=-fPp/ESy58Gj/36RjsLWj--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
