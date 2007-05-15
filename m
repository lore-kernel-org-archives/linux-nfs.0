From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 8] knfsd: exportfs: remove iget abuse
Date: Tue, 15 May 2007 17:16:14 +1000
Message-ID: <1070515071614.16259@suse.de>
References: <20070515170405.15621.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	shaggy@austin.ibm.com, Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnrGo-00042l-E0
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:16:30 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnrGq-0007iC-6d
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:16:33 -0700
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


From: Christoph Hellwig <hch@infradead.org>

When the exportfs interface was added the expectation was that
filesystems provide an operation to convert from a file handle
to an inode/dentry, but it kept a backwards compat option that
still calls into iget.

Calling into iget from non-filesystem code is very bad, because
it gives too little information to filesystem, and simply crashes
if the filesystem doesn't implement the ->read_inode routine.

Fortunately there are only two filesystems left using this fallback:
efs and jfs.  This patch moves a copy of export_iget to each
of those to implement the get_dentry method.

While this is a temporary increase of lines of code in the kernel
it allows for a much cleaner interface and important code restructuring
in later patches.

Cc: shaggy@austin.ibm.com
Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/efs/namei.c         |   32 ++++++++++++++++++++++++++
 ./fs/efs/super.c         |    1 
 ./fs/exportfs/expfs.c    |   56 ++---------------------------------------------
 ./fs/jfs/jfs_inode.h     |    2 -
 ./fs/jfs/namei.c         |   32 ++++++++++++++++++++++++++
 ./fs/jfs/super.c         |    1 
 ./include/linux/efs_fs.h |    1 
 7 files changed, 71 insertions(+), 54 deletions(-)

diff .prev/fs/efs/namei.c ./fs/efs/namei.c
--- .prev/fs/efs/namei.c	2007-05-14 11:14:52.000000000 +1000
+++ ./fs/efs/namei.c	2007-05-14 11:15:29.000000000 +1000
@@ -75,6 +75,38 @@ struct dentry *efs_lookup(struct inode *
 	return NULL;
 }
 
+struct dentry *efs_get_dentry(struct super_block *sb, void *vobjp)
+{
+	__u32 *objp = vobjp;
+	unsigned long ino = objp[0];
+	__u32 generation = objp[1];
+	struct inode *inode;
+	struct dentry *result;
+
+	if (ino == 0)
+		return ERR_PTR(-ESTALE);
+	inode = iget(sb, ino);
+	if (inode == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	if (is_bad_inode(inode) ||
+	    (generation && inode->i_generation != generation)) {
+	    	result = ERR_PTR(-ESTALE);
+		goto out_iput;
+	}
+
+	result = d_alloc_anon(inode);
+	if (!result) {
+		result = ERR_PTR(-ENOMEM);
+		goto out_iput;
+	}
+	return result;
+
+ out_iput:
+	iput(inode);
+	return result;
+}
+
 struct dentry *efs_get_parent(struct dentry *child)
 {
 	struct dentry *parent;

diff .prev/fs/efs/super.c ./fs/efs/super.c
--- .prev/fs/efs/super.c	2007-05-14 11:15:23.000000000 +1000
+++ ./fs/efs/super.c	2007-05-14 11:15:29.000000000 +1000
@@ -115,6 +115,7 @@ static const struct super_operations efs
 };
 
 static struct export_operations efs_export_ops = {
+	.get_dentry	= efs_get_dentry,
 	.get_parent	= efs_get_parent,
 };
 

diff .prev/fs/exportfs/expfs.c ./fs/exportfs/expfs.c
--- .prev/fs/exportfs/expfs.c	2007-05-14 11:15:23.000000000 +1000
+++ ./fs/exportfs/expfs.c	2007-05-14 11:15:29.000000000 +1000
@@ -391,61 +391,11 @@ out:
 	return error;
 }
 
-
-static struct dentry *export_iget(struct super_block *sb, unsigned long ino, __u32 generation)
+static struct dentry *get_dentry(struct super_block *sb, void *vobjp)
 {
-
-	/* iget isn't really right if the inode is currently unallocated!!
-	 * This should really all be done inside each filesystem
-	 *
-	 * ext2fs' read_inode has been strengthed to return a bad_inode if
-	 * the inode had been deleted.
-	 *
-	 * Currently we don't know the generation for parent directory, so
-	 * a generation of 0 means "accept any"
-	 */
-	struct inode *inode;
-	struct dentry *result;
-	if (ino == 0)
-		return ERR_PTR(-ESTALE);
-	inode = iget(sb, ino);
-	if (inode == NULL)
-		return ERR_PTR(-ENOMEM);
-	if (is_bad_inode(inode)
-	    || (generation && inode->i_generation != generation)
-		) {
-		/* we didn't find the right inode.. */
-		dprintk("fh_verify: Inode %lu, Bad count: %d %d or version  %u %u\n",
-			inode->i_ino,
-			inode->i_nlink, atomic_read(&inode->i_count),
-			inode->i_generation,
-			generation);
-
-		iput(inode);
-		return ERR_PTR(-ESTALE);
-	}
-	/* now to find a dentry.
-	 * If possible, get a well-connected one
-	 */
-	result = d_alloc_anon(inode);
-	if (!result) {
-		iput(inode);
-		return ERR_PTR(-ENOMEM);
-	}
-	return result;
+	return ERR_PTR(-ESTALE);
 }
 
-
-static struct dentry *get_object(struct super_block *sb, void *vobjp)
-{
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
-
-	return export_iget(sb, ino, generation);
-}
-
-
 /**
  * export_encode_fh - default export_operations->encode_fh function
  * @dentry:  the dentry to encode
@@ -524,7 +474,7 @@ struct export_operations export_op_defau
 
 	.get_name	= get_name,
 	.get_parent	= get_parent,
-	.get_dentry	= get_object,
+	.get_dentry	= get_dentry,
 };
 
 EXPORT_SYMBOL(export_op_default);

diff .prev/fs/jfs/jfs_inode.h ./fs/jfs/jfs_inode.h
--- .prev/fs/jfs/jfs_inode.h	2007-05-14 11:14:52.000000000 +1000
+++ ./fs/jfs/jfs_inode.h	2007-05-14 11:15:29.000000000 +1000
@@ -31,7 +31,7 @@ extern void jfs_truncate(struct inode *)
 extern void jfs_truncate_nolock(struct inode *, loff_t);
 extern void jfs_free_zero_link(struct inode *);
 extern struct dentry *jfs_get_parent(struct dentry *dentry);
-extern void jfs_get_inode_flags(struct jfs_inode_info *);
+extern struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp);
 extern void jfs_set_inode_flags(struct inode *);
 extern int jfs_get_block(struct inode *, sector_t, struct buffer_head *, int);
 

diff .prev/fs/jfs/namei.c ./fs/jfs/namei.c
--- .prev/fs/jfs/namei.c	2007-05-14 11:14:52.000000000 +1000
+++ ./fs/jfs/namei.c	2007-05-14 11:15:29.000000000 +1000
@@ -1477,6 +1477,38 @@ static struct dentry *jfs_lookup(struct 
 	return dentry;
 }
 
+struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp)
+{
+	__u32 *objp = vobjp;
+	unsigned long ino = objp[0];
+	__u32 generation = objp[1];
+	struct inode *inode;
+	struct dentry *result;
+
+	if (ino == 0)
+		return ERR_PTR(-ESTALE);
+	inode = iget(sb, ino);
+	if (inode == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	if (is_bad_inode(inode) ||
+	    (generation && inode->i_generation != generation)) {
+	    	result = ERR_PTR(-ESTALE);
+		goto out_iput;
+	}
+
+	result = d_alloc_anon(inode);
+	if (!result) {
+		result = ERR_PTR(-ENOMEM);
+		goto out_iput;
+	}
+	return result;
+
+ out_iput:
+	iput(inode);
+	return result;
+}
+
 struct dentry *jfs_get_parent(struct dentry *dentry)
 {
 	struct super_block *sb = dentry->d_inode->i_sb;

diff .prev/fs/jfs/super.c ./fs/jfs/super.c
--- .prev/fs/jfs/super.c	2007-05-14 11:15:23.000000000 +1000
+++ ./fs/jfs/super.c	2007-05-14 11:15:29.000000000 +1000
@@ -738,6 +738,7 @@ static const struct super_operations jfs
 };
 
 static struct export_operations jfs_export_operations = {
+	.get_dentry	= jfs_get_dentry,
 	.get_parent	= jfs_get_parent,
 };
 

diff .prev/include/linux/efs_fs.h ./include/linux/efs_fs.h
--- .prev/include/linux/efs_fs.h	2007-05-14 11:14:52.000000000 +1000
+++ ./include/linux/efs_fs.h	2007-05-14 11:15:29.000000000 +1000
@@ -45,6 +45,7 @@ extern efs_block_t efs_map_block(struct 
 extern int efs_get_block(struct inode *, sector_t, struct buffer_head *, int);
 
 extern struct dentry *efs_lookup(struct inode *, struct dentry *, struct nameidata *);
+extern struct dentry *efs_get_dentry(struct super_block *sb, void *vobjp);
 extern struct dentry *efs_get_parent(struct dentry *);
 extern int efs_bmap(struct inode *, int);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
