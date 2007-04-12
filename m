From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/8] NFS: Fix an Oops in nfs_setattr()
Date: Wed, 11 Apr 2007 22:37:14 -0400
Message-ID: <20070412023714.15270.33322.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbpBX-0005ks-75
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:19 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbpBZ-0002bX-G6
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 19:37:21 -0700
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
