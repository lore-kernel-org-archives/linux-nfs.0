From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/18] fat: new export ops
Date: Wed, 19 Sep 2007 18:31:04 +0200
Message-ID: <20070919163104.GK18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY2S8-0003a3-UN
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:31:05 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IY2SC-00019I-AP
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:31:09 -0700
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

Very little changes here, fat had a mostly no op decode_fh before
and does not store any parent information.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/fat/inode.c
===================================================================
--- linux-2.6.orig/fs/fat/inode.c	2007-03-13 19:22:40.000000000 +0100
+++ linux-2.6/fs/fat/inode.c	2007-03-13 19:23:13.000000000 +0100
@@ -651,24 +651,15 @@ static const struct super_operations fat
  * of i_logstart is used to store the directory entry offset.
  */
 
-static struct dentry *
-fat_decode_fh(struct super_block *sb, __u32 *fh, int len, int fhtype,
-	      int (*acceptable)(void *context, struct dentry *de),
-	      void *context)
-{
-	if (fhtype != 3)
-		return ERR_PTR(-ESTALE);
-	if (len < 5)
-		return ERR_PTR(-ESTALE);
-
-	return sb->s_export_op->find_exported_dentry(sb, fh, NULL, acceptable, context);
-}
-
-static struct dentry *fat_get_dentry(struct super_block *sb, void *inump)
+static struct dentry *fat_fh_to_dentry(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
 {
 	struct inode *inode = NULL;
 	struct dentry *result;
-	__u32 *fh = inump;
+	u32 *fh = fid->raw;
+
+	if (fh_len < 5 || fh_type != 3)
+		return NULL;
 
 	inode = iget(sb, fh[0]);
 	if (!inode || is_bad_inode(inode) || inode->i_generation != fh[1]) {
@@ -782,9 +773,8 @@ out:
 }
 
 static struct export_operations fat_export_ops = {
-	.decode_fh	= fat_decode_fh,
 	.encode_fh	= fat_encode_fh,
-	.get_dentry	= fat_get_dentry,
+	.fh_to_dentry	= fat_fh_to_dentry,
 	.get_parent	= fat_get_parent,
 };
 

--

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
