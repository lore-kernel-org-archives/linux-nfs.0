From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 08/18] ntfs: new export ops
Date: Wed, 19 Sep 2007 18:30:53 +0200
Message-ID: <20070919163053.GI18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY2Ry-0003VK-Gv
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:54 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IY2S2-0005rr-Gb
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:59 -0700
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


Index: linux-2.6/fs/ntfs/namei.c
===================================================================
--- linux-2.6.orig/fs/ntfs/namei.c	2007-09-13 15:10:45.000000000 +0200
+++ linux-2.6/fs/ntfs/namei.c	2007-09-13 15:20:12.000000000 +0200
@@ -450,58 +450,40 @@ try_next:
 	return parent_dent;
 }
 
-/**
- * ntfs_get_dentry - find a dentry for the inode from a file handle sub-fragment
- * @sb:		super block identifying the mounted ntfs volume
- * @fh:		the file handle sub-fragment
- *
- * Find a dentry for the inode given a file handle sub-fragment.  This function
- * is called from fs/exportfs/expfs.c::find_exported_dentry() which in turn is
- * called from the default ->decode_fh() which is export_decode_fh() in the
- * same file.  The code is closely based on the default ->get_dentry() helper
- * fs/exportfs/expfs.c::get_object().
- *
- * The @fh contains two 32-bit unsigned values, the first one is the inode
- * number and the second one is the inode generation.
- *
- * Return the dentry on success or the error code on error (IS_ERR() is true).
- */
-static struct dentry *ntfs_get_dentry(struct super_block *sb, void *fh)
+static struct inode *ntfs_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	struct inode *vi;
-	struct dentry *dent;
-	unsigned long ino = ((u32 *)fh)[0];
-	u32 gen = ((u32 *)fh)[1];
-
-	ntfs_debug("Entering for inode 0x%lx, generation 0x%x.", ino, gen);
-	vi = ntfs_iget(sb, ino);
-	if (IS_ERR(vi)) {
-		ntfs_error(sb, "Failed to get inode 0x%lx.", ino);
-		return (struct dentry *)vi;
-	}
-	if (unlikely(is_bad_inode(vi) || vi->i_generation != gen)) {
-		/* We didn't find the right inode. */
-		ntfs_error(sb, "Inode 0x%lx, bad count: %d %d or version 0x%x "
-				"0x%x.", vi->i_ino, vi->i_nlink,
-				atomic_read(&vi->i_count), vi->i_generation,
-				gen);
-		iput(vi);
-		return ERR_PTR(-ESTALE);
-	}
-	/* Now find a dentry.  If possible, get a well-connected one. */
-	dent = d_alloc_anon(vi);
-	if (unlikely(!dent)) {
-		iput(vi);
-		return ERR_PTR(-ENOMEM);
+	struct inode *inode;
+
+	inode = ntfs_iget(sb, ino);
+	if (!IS_ERR(inode)) {
+		if (is_bad_inode(inode) || inode->i_generation != generation) {
+			iput(inode);
+			inode = ERR_PTR(-ESTALE);
+		}
 	}
-	ntfs_debug("Done for inode 0x%lx, generation 0x%x.", ino, gen);
-	return dent;
+
+	return inode;
+}
+
+static struct dentry *ntfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type,
+				    ntfs_nfs_get_inode);
+}
+
+static struct dentry *ntfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type,
+				    ntfs_nfs_get_inode);
 }
 
 /**
  * Export operations allowing NFS exporting of mounted NTFS partitions.
  *
- * We use the default ->decode_fh() and ->encode_fh() for now.  Note that they
+ * We use the default ->encode_fh() for now.  Note that they
  * use 32 bits to store the inode number which is an unsigned long so on 64-bit
  * architectures is usually 64 bits so it would all fail horribly on huge
  * volumes.  I guess we need to define our own encode and decode fh functions
@@ -520,7 +502,6 @@ static struct dentry *ntfs_get_dentry(st
 struct export_operations ntfs_export_ops = {
 	.get_parent	= ntfs_get_parent,	/* Find the parent of a given
 						   directory. */
-	.get_dentry	= ntfs_get_dentry,	/* Find a dentry for the inode
-						   given a file handle
-						   sub-fragment. */
+	.fh_to_dentry	= ntfs_fh_to_dentry,
+	.fh_to_parent	= ntfs_fh_to_parent,
 };

--

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
