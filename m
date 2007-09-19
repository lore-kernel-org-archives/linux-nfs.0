From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/18] shmem: new export ops
Date: Wed, 19 Sep 2007 18:31:12 +0200
Message-ID: <20070919163112.GM18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY2SG-0003c7-Uj
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:31:13 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IY2SJ-0001D7-AB
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:31:17 -0700
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

I'm not sure what people were thinking when adding support to
export tmpfs, but here's the conversion anyway:


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2007-02-11 10:46:30.000000000 +0100
+++ linux-2.6/mm/shmem.c	2007-02-11 10:53:12.000000000 +0100
@@ -1977,33 +1977,25 @@
 	return ino->i_ino == inum && fh[0] == ino->i_generation;
 }
 
-static struct dentry *shmem_get_dentry(struct super_block *sb, void *vfh)
+static struct dentry *shmem_fh_to_dentry(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
 {
-	struct dentry *de = NULL;
 	struct inode *inode;
-	__u32 *fh = vfh;
-	__u64 inum = fh[2];
-	inum = (inum << 32) | fh[1];
+	struct dentry *dentry = NULL;
+	u64 inum = fid->raw[2];
+	inum = (inum << 32) | fid->raw[1];
 
-	inode = ilookup5(sb, (unsigned long)(inum+fh[0]), shmem_match, vfh);
+	if (fh_len < 3)
+		return NULL;
+
+	inode = ilookup5(sb, (unsigned long)(inum + fid->raw[0]),
+			shmem_match, fid->raw);
 	if (inode) {
-		de = d_find_alias(inode);
+		dentry = d_find_alias(inode);
 		iput(inode);
 	}
 
-	return de? de: ERR_PTR(-ESTALE);
-}
-
-static struct dentry *shmem_decode_fh(struct super_block *sb, __u32 *fh,
-		int len, int type,
-		int (*acceptable)(void *context, struct dentry *de),
-		void *context)
-{
-	if (len < 3)
-		return ERR_PTR(-ESTALE);
-
-	return sb->s_export_op->find_exported_dentry(sb, fh, NULL, acceptable,
-							context);
+	return dentry;
 }
 
 static int shmem_encode_fh(struct dentry *dentry, __u32 *fh, int *len,
@@ -2038,9 +2030,8 @@
 
 static struct export_operations shmem_export_ops = {
 	.get_parent     = shmem_get_parent,
-	.get_dentry     = shmem_get_dentry,
 	.encode_fh      = shmem_encode_fh,
-	.decode_fh      = shmem_decode_fh,
+	.fh_to_dentry	= shmem_fh_to_dentry,
 };
 
 static int shmem_parse_options(char *options, int *mode, uid_t *uid,

--

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
