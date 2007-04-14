From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS: Fix an Oops in nfs_setattr()
Date: Sat, 14 Apr 2007 19:07:28 -0400
Message-ID: <1176592048.6089.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcrLC-0001Wm-Ql
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 16:07:34 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcrLF-0007cw-62
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 16:07:37 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

It looks like nfs_setattr() and nfs_rename() also need to test whether the
target is a regular file before calling nfs_wb_all()...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c   |    3 ++-
 fs/nfs/inode.c |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 92d8ec8..cd34697 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1684,7 +1684,8 @@ go_ahead:
 	 * ... prune child dentries and writebacks if needed.
 	 */
 	if (atomic_read(&old_dentry->d_count) > 1) {
-		nfs_wb_all(old_inode);
+		if (S_ISREG(old_inode->i_mode))
+			nfs_wb_all(old_inode);
 		shrink_dcache_parent(old_dentry);
 	}
 	nfs_inode_return_delegation(old_inode);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 93d046c..44aa9b7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -341,8 +341,10 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	lock_kernel();
 	nfs_begin_data_update(inode);
 	/* Write all dirty data */
-	filemap_write_and_wait(inode->i_mapping);
-	nfs_wb_all(inode);
+	if (S_ISREG(inode->i_mode)) {
+		filemap_write_and_wait(inode->i_mapping);
+		nfs_wb_all(inode);
+	}
 	/*
 	 * Return any delegations if we're going to change ACLs
 	 */

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
