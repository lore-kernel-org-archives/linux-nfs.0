From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] fix nfsidem cthon test
Date: Thu, 21 Oct 2004 16:51:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-thl3n8KeGHQ5vd7XnvFN"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKWVf-0001CR-Ju
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 23:33:15 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKWVf-0004bA-2X
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 23:33:15 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


--=-thl3n8KeGHQ5vd7XnvFN
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

G'day,

The attached patch forward ports from 2.4 the fix to nfs_rename()
which makes the nfsidem test in the Connectathon test suite pass.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


--=-thl3n8KeGHQ5vd7XnvFN
Content-Disposition: attachment; filename=gnb-nfs-rename
Content-Type: text/plain; name=gnb-nfs-rename; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Fix nfs_rename() so the nfsidem test in the Connectathon test suite passes.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>


Index: linux/fs/nfs/dir.c
===================================================================
--- linux.orig/fs/nfs/dir.c	2004-10-04 14:35:26.%N +1000
+++ linux/fs/nfs/dir.c	2004-10-21 15:45:21.%N +1000
@@ -1409,7 +1409,7 @@ static int nfs_rename(struct inode *old_
 	struct inode *old_inode = old_dentry->d_inode;
 	struct inode *new_inode = new_dentry->d_inode;
 	struct dentry *dentry = NULL, *rehash = NULL;
-	int error = -EBUSY;
+	int error;
 
 	/*
 	 * To prevent any new references to the target during the rename,
@@ -1436,6 +1436,12 @@ static int nfs_rename(struct inode *old_
 	 */
 	if (!new_inode)
 		goto go_ahead;
+	/* If target is a hard link to the source, then noop */
+	error = 0;
+	if (NFS_FILEID(new_inode) == NFS_FILEID(old_inode))
+		goto out;
+
+	error = -EBUSY;
 	if (S_ISDIR(new_inode->i_mode))
 		goto out;
 	else if (atomic_read(&new_dentry->d_count) > 1) {

--=-thl3n8KeGHQ5vd7XnvFN--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
