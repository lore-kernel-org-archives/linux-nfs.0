From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 6/8] exportfs: move acceptable check into
	find_acceptable_alias (resend)
Date: Thu, 8 Mar 2007 08:38:33 +0000
Message-ID: <20070308083833.GA5703@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPE8x-0005y6-U4
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 00:38:36 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPE8z-00025q-Pj
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 00:38:38 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HPE8v-0001eP-OE
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 08:38:33 +0000
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

All callers of find_acceptable_alias check if the current dentry
is acceptable before looking for other acceptable aliases using
find_acceptable_alias.  Move the check into find_acceptable_alias
to make the code a little more dense and add a comment to
find_acceptable_alias that documents it's intent.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-02-22 00:29:20.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-02-22 00:31:00.000000000 +0100
@@ -39,6 +39,9 @@
 		return get_name(dir, name, child);
 }
 
+/*
+ * Check if the dentry or any of it's aliases is acceptable.
+ */
 static struct dentry *
 find_acceptable_alias(struct dentry *result,
 		int (*acceptable)(void *context, struct dentry *dentry),
@@ -46,6 +49,9 @@
 {
 	struct dentry *dentry, *toput = NULL;
 
+	if (acceptable(context, result))
+		return result;
+
 	spin_lock(&dcache_lock);
 	list_for_each_entry(dentry, &result->d_inode->i_dentry, d_alias) {
 		dget_locked(dentry);
@@ -128,9 +134,6 @@
 
 		target_dir = dget(result);
 	} else {
-		if (acceptable(context, result))
-			return result;
-
 		alias = find_acceptable_alias(result, acceptable, context);
 		if (alias)
 			return alias;
@@ -291,9 +294,6 @@
 		}
 	}
 	dput(target_dir);
-	/* now result is properly connected, it is our best bet */
-	if (acceptable(context, result))
-		return result;
 
 	alias = find_acceptable_alias(result, acceptable, context);
 	if (alias)

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
