From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATHC - kNFSd/reiserfs in 2.5.14 - Convert reisferfs to use export_operations
Date: Tue, 7 May 2002 14:51:15 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15575.23875.157599.603637@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: reiserfs-dev@namesys.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174wx9-0005II-00
	for <nfs@lists.sourceforge.net>; Mon, 06 May 2002 21:51:55 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <reiserfs-dev@namesys.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Tue, 7 May 2002 14:51:39 +1000
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


This patch converts reiserfs to use the new export_operations
interface for exporting a filesystem instead of the old
fh_to_dentry and dentry_to_fh.
Essentially it:

  - renamed reiserfs_dentry_to_fh to reiserfs_encode_fh
  - split reiserfs_fh_to_dentry into reiserfs_get_dentry
    and reiserfs_decode_fh
  - calls d_splice_alias from reiserfs_lookup so that building 
    a dcache path from the bottom works well
  - addes reiserfs_get_parent to do a lookup of ".." without going
    through the VFS interfaces.
  - sets sb->s_export_op to be an appropriately initialised
    struct export_operations

This has been tested and works.

NeilBrown

 ----------- Diffstat output ------------
 ./fs/reiserfs/inode.c         |   88 +++++++++++++++++++++---------------------
 ./fs/reiserfs/namei.c         |   45 +++++++++++++++++++++
 ./fs/reiserfs/super.c         |   11 +++--
 ./include/linux/reiserfs_fs.h |   11 +++--
 4 files changed, 106 insertions(+), 49 deletions(-)

--- ./include/linux/reiserfs_fs.h	2002/05/07 04:35:02	1.1
+++ ./include/linux/reiserfs_fs.h	2002/05/07 04:35:15	1.2
@@ -1822,9 +1822,13 @@
 void reiserfs_read_inode2(struct inode * inode, void *p) ;
 void reiserfs_delete_inode (struct inode * inode);
 void reiserfs_write_inode (struct inode * inode, int) ;
-struct dentry *reiserfs_fh_to_dentry(struct super_block *sb, __u32 *data,
-									 int len, int fhtype, int parent);
-int reiserfs_dentry_to_fh(struct dentry *dentry, __u32 *data, int *lenp, int need_parent);
+struct dentry *reiserfs_get_dentry(struct super_block *, void *) ;
+struct dentry *reiserfs_decode_fh(struct super_block *sb, __u32 *data,
+                                     int len, int fhtype,
+				  int (*acceptable)(void *contect, struct dentry *de),
+				  void *context) ;
+int reiserfs_encode_fh( struct dentry *dentry, __u32 *data, int *lenp, 
+						int connectable );
 
 int reiserfs_prepare_write(struct file *, struct page *, unsigned, unsigned) ;
 void reiserfs_truncate_file(struct inode *, int update_timestamps) ;
@@ -1849,6 +1853,7 @@
 int search_by_entry_key (struct super_block * sb, const struct cpu_key * key, 
 			 struct path * path, 
 			 struct reiserfs_dir_entry * de);
+struct dentry *reiserfs_get_parent(struct dentry *) ;
 /* procfs.c */
 
 #if defined( CONFIG_PROC_FS ) && defined( CONFIG_REISERFS_PROC_INFO )
--- ./fs/reiserfs/inode.c	2002/05/07 04:35:02	1.1
+++ ./fs/reiserfs/inode.c	2002/05/07 04:35:15	1.2
@@ -1251,11 +1251,39 @@
     return inode;
 }
 
-struct dentry *reiserfs_fh_to_dentry(struct super_block *sb, __u32 *data,
-				     int len, int fhtype, int parent) {
+struct dentry *reiserfs_get_dentry(struct super_block *sb, void *vobjp)
+{
+    __u32 *data = vobjp;
     struct cpu_key key ;
-    struct inode *inode = NULL ;
     struct dentry *result;
+    struct inode *inode;
+    
+    key.on_disk_key.k_objectid = data[0] ;
+    key.on_disk_key.k_dir_id = data[1] ;
+    inode = reiserfs_iget(sb, &key) ;
+    if (inode && !IS_ERR(inode) && data[2] != 0 &&
+	data[2] != inode->i_generation) {
+	    iput(inode) ;
+	    inode = NULL ;
+    }
+    if (!inode)
+	    inode = ERR_PTR(-ESTALE);
+    if (IS_ERR(inode))
+	    return ERR_PTR(PTR_ERR(inode));
+    result = d_alloc_anon(inode);
+    if (!result) {
+	    iput(inode);
+	    return ERR_PTR(-ENOMEM);
+    }
+    result->d_vfs_flags |= DCACHE_REFERENCED;
+    return result;
+}
+
+struct dentry *reiserfs_decode_fh(struct super_block *sb, __u32 *data,
+                                     int len, int fhtype,
+				  int (*acceptable)(void *contect, struct dentry *de),
+				  void *context) {
+    __u32 obj[3], parent[3];
 
     /* fhtype happens to reflect the number of u32s encoded.
      * due to a bug in earlier code, fhtype might indicate there
@@ -1275,51 +1303,25 @@
 			   fhtype, len);
 	    fhtype = 5;
     }
-    if (fhtype < 2 || (parent && fhtype < 4)) 
-	goto out ;
 
-    if (! parent) {
-	    /* this works for handles from old kernels because the default
-	    ** reiserfs generation number is the packing locality.
-	    */
-	    key.on_disk_key.k_objectid = data[0] ;
-	    key.on_disk_key.k_dir_id = data[1] ;
-	    inode = reiserfs_iget(sb, &key) ;
-	    if (inode && !IS_ERR(inode) && (fhtype == 3 || fhtype >= 5) &&
-		data[2] != inode->i_generation) {
-		    iput(inode) ;
-		    inode = NULL ;
-	    }
-    } else {
-	    key.on_disk_key.k_objectid = data[fhtype>=5?3:2] ;
-	    key.on_disk_key.k_dir_id = data[fhtype>=5?4:3] ;
-	    inode = reiserfs_iget(sb, &key) ;
-	    if (inode && !IS_ERR(inode) && fhtype == 6 &&
-		data[5] != inode->i_generation) {
-		    iput(inode) ;
-		    inode = NULL ;
-	    }
-    }
-out:
-    if (IS_ERR(inode))
-	return ERR_PTR(PTR_ERR(inode));
-    if (!inode)
-        return ERR_PTR(-ESTALE) ;
+    obj[0] = data[0];
+    obj[1] = data[1];
+    if (fhtype == 3 || fhtype >= 5)
+	    obj[2] = data[2];
+    else    obj[2] = 0; /* generation number */
 
-    /* now to find a dentry.
-     * If possible, get a well-connected one
-     */
-    result = d_alloc_anon(inode);
-    if (result == NULL) {
-	    iput(inode);
-	    return ERR_PTR(-ENOMEM);
+    if (fhtype >= 4) {
+	    parent[0] = data[fhtype>=5?3:2] ;
+	    parent[1] = data[fhtype>=5?4:3] ;
+	    if (fhtype == 6)
+		    parent[2] = data[5];
+	    else    parent[2] = 0;
     }
-    result->d_vfs_flags |= DCACHE_REFERENCED;
-    return result;
-
+    return sb->s_export_op->find_exported_dentry(sb, obj, fhtype < 4 ? NULL : parent,
+			       acceptable, context);
 }
 
-int reiserfs_dentry_to_fh(struct dentry *dentry, __u32 *data, int *lenp, int need_parent) {
+int reiserfs_encode_fh(struct dentry *dentry, __u32 *data, int *lenp, int need_parent) {
     struct inode *inode = dentry->d_inode ;
     int maxlen = *lenp;
     
--- ./fs/reiserfs/namei.c	2002/05/07 04:35:02	1.1
+++ ./fs/reiserfs/namei.c	2002/05/07 04:35:15	1.2
@@ -363,9 +363,54 @@
 	return ERR_PTR(-EIO);
     }
 
+    if (inode)
+	    return d_splice_alias(inode, dentry);
+    
     d_add(dentry, inode);
     return NULL;
 }
+
+
+/* 
+** looks up the dentry of the parent directory for child.
+** taken from ext2_get_parent
+*/
+struct dentry *reiserfs_get_parent(struct dentry *child)
+{
+    int retval;
+    struct inode * inode = NULL;
+    struct reiserfs_dir_entry de;
+    INITIALIZE_PATH (path_to_entry);
+    struct dentry *parent;
+    struct inode *dir = child->d_inode ;
+
+
+    if (dir->i_nlink == 0) {
+	return ERR_PTR(-ENOENT);
+    }
+    de.de_gen_number_bit_string = 0;
+
+    lock_kernel();
+    retval = reiserfs_find_entry (dir, "..", 2, &path_to_entry, &de);
+    pathrelse (&path_to_entry);
+    if (retval != NAME_FOUND) {
+	unlock_kernel();
+	return ERR_PTR(-ENOENT);
+    }
+    inode = reiserfs_iget (dir->i_sb, (struct cpu_key *)&(de.de_dir_id));
+    unlock_kernel();
+
+    if (!inode || IS_ERR(inode)) {
+	return ERR_PTR(-EACCES);
+    }
+    parent = d_alloc_anon(inode);
+    if (!parent) {
+	iput(inode);
+	parent = ERR_PTR(-ENOMEM);
+    }
+    return parent;
+}
+
 
 //
 // a portion of this function, particularly the VFS interface portion,
--- ./fs/reiserfs/super.c	2002/05/07 04:35:02	1.1
+++ ./fs/reiserfs/super.c	2002/05/07 04:35:15	1.2
@@ -496,11 +496,15 @@
   statfs: reiserfs_statfs,
   remount_fs: reiserfs_remount,
 
-  fh_to_dentry: reiserfs_fh_to_dentry,
-  dentry_to_fh: reiserfs_dentry_to_fh,
-
 };
 
+static struct export_operations reiserfs_export_ops = {
+  encode_fh: reiserfs_encode_fh,
+  decode_fh: reiserfs_decode_fh,
+  get_parent: reiserfs_get_parent,
+  get_dentry: reiserfs_get_dentry,
+} ;
+
 /* this was (ext2)parse_options */
 static int parse_options (char * options, unsigned long * mount_options, unsigned long * blocks, char **jdev_name)
 {
@@ -799,6 +803,7 @@
 	      is_reiserfs_3_5 (rs) ? "3.5" : "3.6");
 
     s->s_op = &reiserfs_sops;
+    s->s_export_op = &reiserfs_export_ops;
 
     /* new format is limited by the 32 bit wide i_blocks field, want to
     ** be one full block below that.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
