From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: [PATCH] - kNFSd in 2.5.15 - export_operations support for isofs
Date: Fri, 10 May 2002 16:48:37 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15579.27973.491721.865466@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1764DG-0001k1-00
	for <nfs@lists.sourceforge.net>; Thu, 09 May 2002 23:49:10 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 10 May 2002 16:49:01 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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


ISOFS to use export_operations to declare exportability

Exporting ISO's has never been very reliable 
as lookup("..") doesn't work (even though there is
some code that tries to pretend that it does).

This means that if an inode falls out of cache, any 
filehandle on it will become stale.

This patch makes that level of support explicit with
an empty export_operations structure.  get_parent
could be written.... but not today.


 ----------- Diffstat output ------------
 ./fs/isofs/inode.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+)

--- ./fs/isofs/inode.c	2002/05/10 05:18:54	1.1
+++ ./fs/isofs/inode.c	2002/05/10 05:26:16	1.2
@@ -131,6 +131,21 @@
 	statfs:		isofs_statfs,
 };
 
+/* the export_operations structure for describing
+ * how to export (e.g. via kNFSd) is deliberately
+ * empty.
+ * This means that the filesystem want to use iget
+ * to map an inode number into an inode.
+ * The lack of a get_parent operation means that 
+ * if something isn't in the cache, then you cannot
+ * access it.
+ * It should be possible to write a get_parent,
+ * but it would be a bit hairy...
+ */
+static struct export_operations isofs_export_ops = {
+};
+
+
 static struct dentry_operations isofs_dentry_ops[] = {
 	{
 		d_hash:		isofs_hash,
@@ -786,6 +801,7 @@
 	}
 #endif
 	s->s_op = &isofs_sops;
+	s->s_export_op = &isofs_export_ops;
 	sbi->s_mapping = opt.map;
 	sbi->s_rock = (opt.rock == 'y' ? 2 : 0);
 	sbi->s_rock_offset = -1; /* initial offset, will guess until SP is found*/

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
