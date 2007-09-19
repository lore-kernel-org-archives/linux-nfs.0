From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 05/18] ext4: new export ops
Date: Wed, 19 Sep 2007 18:30:38 +0200
Message-ID: <20070919163038.GF18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY2Ri-0003U8-70
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:39 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IY2Rm-0000u9-KO
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:43 -0700
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

Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c	2007-09-13 15:10:46.000000000 +0200
+++ linux-2.6/fs/ext4/super.c	2007-09-13 15:18:21.000000000 +0200
@@ -613,13 +613,10 @@ static int ext4_show_options(struct seq_
 }
 
 
-static struct dentry *ext4_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *ext4_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino < EXT4_FIRST_INO(sb) && ino != EXT4_ROOT_INO)
 		return ERR_PTR(-ESTALE);
@@ -642,15 +639,22 @@ static struct dentry *ext4_get_dentry(st
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
+static struct dentry *ext4_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type,
+				    ext4_nfs_get_inode);
+}
+
+static struct dentry *ext4_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type,
+				    ext4_nfs_get_inode);
 }
 
 #ifdef CONFIG_QUOTA
@@ -720,8 +724,9 @@ static const struct super_operations ext
 };
 
 static struct export_operations ext4_export_ops = {
+	.fh_to_dentry = ext4_fh_to_dentry,
+	.fh_to_parent = ext4_fh_to_parent,
 	.get_parent = ext4_get_parent,
-	.get_dentry = ext4_get_dentry,
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
