From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 7/8] exportfs: add find_disconnected_root helper
Date: Wed, 7 Mar 2007 10:40:13 +0000
Message-ID: <20070307104013.GG22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtZ7-0003Ip-Rn
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:14 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOtZ9-0002kM-Ni
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:16 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOtZ7-0006bb-HX
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:40:13 +0000
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

Break the loop that finds the root of a disconnected subtree
into a helper of it's own to make reading more clearly and
document the intent.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-02-22 00:39:39.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-02-22 00:39:48.000000000 +0100
@@ -72,6 +72,27 @@
 	return NULL;
 }
 
+/*
+ * Find root of a disconnected subtree and return a reference to it.
+ */
+static struct dentry *
+find_disconnected_root(struct dentry *dentry)
+{
+	dget(dentry);
+	spin_lock(&dentry->d_lock);
+	while (!IS_ROOT(dentry) &&
+	       (dentry->d_parent->d_flags & DCACHE_DISCONNECTED)) {
+		struct dentry *parent = dentry->d_parent;
+		dget(parent);
+		spin_unlock(&dentry->d_lock);
+		dput(dentry);
+		dentry = parent;
+		spin_lock(&dentry->d_lock);
+	}
+	spin_unlock(&dentry->d_lock);
+	return dentry;
+}
+
 /**
  * find_exported_dentry - helper routine to implement export_operations->decode_fh
  * @sb:		The &super_block identifying the filesystem
@@ -166,23 +187,9 @@
 	 * the noprogress counter.  If we go through the loop 10 times (2 is
 	 * probably enough) without getting anywhere, we just give up
 	 */
-	noprogress= 0;
+	noprogress = 0;
 	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
-		struct dentry *pd = target_dir;
-
-		dget(pd);
-		spin_lock(&pd->d_lock);
-		while (!IS_ROOT(pd) &&
-				(pd->d_parent->d_flags&DCACHE_DISCONNECTED)) {
-			struct dentry *parent = pd->d_parent;
-
-			dget(parent);
-			spin_unlock(&pd->d_lock);
-			dput(pd);
-			pd = parent;
-			spin_lock(&pd->d_lock);
-		}
-		spin_unlock(&pd->d_lock);
+		struct dentry *pd = find_disconnected_root(target_dir);
 
 		if (!IS_ROOT(pd)) {
 			/* must have found a connected parent - great */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
