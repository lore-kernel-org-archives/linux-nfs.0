From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 5/8] exportfs: untangle ISDIR logic in
	find_exported_dentry
Date: Wed, 7 Mar 2007 10:40:08 +0000
Message-ID: <20070307104008.GF22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtZ1-0003IW-R9
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:08 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOtZ3-0005nE-IP
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:10 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOtZ2-0006bM-6i
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:40:08 +0000
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

Rework some logic in find_exported_dentry so that we only have a single
S_ISDIR check and logic that makes clear to the reader what we're really
doing here.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-02-22 00:27:10.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-02-22 00:39:35.000000000 +0100
@@ -118,30 +118,23 @@
 	if (IS_ERR(result))
 		return result;
 
-	if (S_ISDIR(result->d_inode->i_mode) &&
-	    (result->d_flags & DCACHE_DISCONNECTED)) {
-		/* it is an unconnected directory, we must connect it */
-		;
-	} else {
-		if (acceptable(context, result))
-			return result;
-		if (S_ISDIR(result->d_inode->i_mode)) {
+	if (S_ISDIR(result->d_inode->i_mode)) {
+		if (!(result->d_flags & DCACHE_DISCONNECTED)) {
+			if (acceptable(context, result))
+				return result;
 			err = -EACCES;
 			goto err_result;
 		}
 
+		target_dir = dget(result);
+	} else {
+		if (acceptable(context, result))
+			return result;
+
 		alias = find_acceptable_alias(result, acceptable, context);
 		if (alias)
 			return alias;
-	}			
 
-	/* It's a directory, or we are required to confirm the file's
-	 * location in the tree based on the parent information
- 	 */
-	dprintk("find_exported_dentry: need to look harder for %s/%d\n",sb->s_id,*(int*)obj);
-	if (S_ISDIR(result->d_inode->i_mode))
-		target_dir = dget(result);
-	else {
 		if (parent == NULL)
 			goto err_result;
 
@@ -151,6 +144,7 @@
 			goto err_result;
 		}
 	}
+
 	/*
 	 * Now we need to make sure that target_dir is properly connected.
 	 * It may already be, as the flag isn't always updated when connection

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
