From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/18] ext3: new export ops
Date: Wed, 19 Sep 2007 18:30:34 +0200
Message-ID: <20070919163034.GE18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY2Re-0003U5-DQ
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:38 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IY2Rh-0000sI-R6
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:39 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c	2007-09-13 15:10:46.000000000 +0200
+++ linux-2.6/fs/ext3/super.c	2007-09-13 15:16:57.000000000 +0200
@@ -562,13 +562,10 @@ static int ext3_show_options(struct seq_
 }
 
 
-static struct dentry *ext3_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *ext3_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino < EXT3_FIRST_INO(sb) && ino != EXT3_ROOT_INO)
 		return ERR_PTR(-ESTALE);
@@ -591,15 +588,22 @@ static struct dentry *ext3_get_dentry(st
 		iput(inode);
 		return ERR_PTR(-ESTALE);
 	}
-	/* now to find a dentry.
-	 * If possible, get a well-connected one
-	 */
-	result = d_alloc_anon(inode);
-	if (!result) {
-		iput(inode);
-		return ERR_PTR(-ENOMEM);
-	}
-	return result;
+
+	return inode;
+}
+
+static struct dentry *ext3_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type,
+				    ext3_nfs_get_inode);
+}
+
+static struct dentry *ext3_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type,
+				    ext3_nfs_get_inode);
 }
 
 #ifdef CONFIG_QUOTA
@@ -669,8 +673,9 @@ static const struct super_operations ext
 };
 
 static struct export_operations ext3_export_ops = {
+	.fh_to_dentry = ext3_fh_to_dentry,
+	.fh_to_parent = ext3_fh_to_parent,
 	.get_parent = ext3_get_parent,
-	.get_dentry = ext3_get_dentry,
 };
 
 enum {

--

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
