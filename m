From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd in 2.5.15 - Small cleanup of nfsd export checks
Date: Wed, 15 May 2002 15:26:25 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15585.61825.908284.684457@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177rJK-0002nn-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 22:26:50 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <hch@infradead.org>) By tone With Smtp ;
	Wed, 15 May 2002 15:26:40 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: Christoph Hellwig <hch@infradead.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 14 May 2002 12:57:42 +0100

Separate checks for !FS_REQUIRES_DEV and missing fsid option
and missing export operations, second check for missing export
operations and a small cleanup as side effect.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

--- ./fs/nfsd/export.c	2002/05/10 06:38:38	1.2
+++ ./fs/nfsd/export.c	2002/05/15 05:08:19	1.3
@@ -315,17 +315,19 @@
 	 * 2:  We must be able to find an inode from a filehandle.
 	 *       This means that s_export_op must be set.
 	 */
-	if (((inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV)
-	     || (nxp->ex_flags & NFSEXP_FSID))
-	    &&
-	    inode->i_sb->s_export_op)
-		/* Ok, we can export it */;
-	else {
+	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV)) {
+		if (!(nxp->ex_flags & NFSEXP_FSID)) {
+			dprintk("exp_export: export of non-dev fs without fsid");
+			goto finish;
+		}
+	}
+	if (!inode->i_sb->s_export_op) {
 		dprintk("exp_export: export of invalid fs type.\n");
 		goto finish;
 	}
-	if (inode->i_sb->s_export_op &&
-	    !inode->i_sb->s_export_op->find_exported_dentry)
+
+	/* Ok, we can export it */;
+	if (!inode->i_sb->s_export_op->find_exported_dentry)
 		inode->i_sb->s_export_op->find_exported_dentry =
 			find_exported_dentry;
 

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
