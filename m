From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd/ext3 in 2.5.14 - export_operations support for ext3
Date: Tue, 7 May 2002 14:45:52 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15575.23552.595114.145678@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sct@redhat.com, akpm@zip.com.au, adilger@turbolinux.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174ws4-0004zh-00
	for <nfs@lists.sourceforge.net>; Mon, 06 May 2002 21:46:40 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <sct@redhat.com>)
	(for <akpm@zip.com.au>) (for <adilger@turbolinux.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Tue, 7 May 2002 14:46:18 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: nfs@lists.sourceforge.net
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


This patch converts ext3 to use the new export_operations for
exporting a filesystem.
In particular it
 - defines "ext3_get_parent" to do a lookup(".."),
 - calls d_splice_alias when ext3_lookup finds something,
   so that build a dcache path from the bottom up works, and
 - sets sb->s_export_op to point to an (almost empty)
   export_operations structure.  The fact that it is mostly empty
   means that the default lookup operations are used, which match the
   previous approach (i.e. use iget, and then check the generation
   number). 

NeilBrown


 ----------- Diffstat output ------------
 ./fs/ext3/namei.c |   39 +++++++++++++++++++++++++++++++++++++++
 ./fs/ext3/super.c |    7 +++++++
 2 files changed, 46 insertions(+)

--- ./fs/ext3/super.c	2002/05/07 04:33:24	1.1
+++ ./fs/ext3/super.c	2002/05/07 04:34:46	1.2
@@ -508,6 +508,12 @@
 	remount_fs:	ext3_remount,		/* BKL held */
 };
 
+struct dentry *ext3_get_parent(struct dentry *child);
+static struct export_operations ext3_export_ops = {
+	get_parent: ext3_get_parent,
+};
+
+
 static int want_value(char *value, char *option)
 {
 	if (!value || !*value) {
@@ -1157,6 +1163,7 @@
 	 * set up enough so that it can read an inode
 	 */
 	sb->s_op = &ext3_sops;
+	sb->s_export_op = &ext3_export_ops;
 	INIT_LIST_HEAD(&sbi->s_orphan); /* unlinked but open files */
 
 	sb->s_root = 0;
--- ./fs/ext3/namei.c	2002/05/07 04:33:24	1.1
+++ ./fs/ext3/namei.c	2002/05/07 04:34:46	1.2
@@ -220,9 +220,48 @@
 		}
 	}
 	unlock_kernel();
+	if (inode)
+		return d_splice_alias(inode, dentry);
 	d_add(dentry, inode);
 	return NULL;
 }
+
+
+struct dentry *ext3_get_parent(struct dentry *child)
+{
+	unsigned long ino;
+	struct dentry *parent;
+	struct inode *inode;
+	struct dentry dotdot;
+	struct ext3_dir_entry_2 * de;
+	struct buffer_head *bh;
+
+	dotdot.d_name.name = "..";
+	dotdot.d_name.len = 2;
+	dotdot.d_parent = child; /* confusing, isn't it! */
+
+	lock_kernel();
+	bh = ext3_find_entry(&dotdot, &de);
+	inode = NULL;
+	if (!bh) {
+		unlock_kernel();
+		return ERR_PTR(-ENOENT);
+	}
+	ino = le32_to_cpu(de->inode);
+	brelse(bh);
+	inode = iget(child->d_inode->i_sb, ino);
+	unlock_kernel();
+
+	if (!inode)
+		return ERR_PTR(-EACCES);
+
+	parent = d_alloc_anon(inode);
+	if (!parent) {
+		iput(inode);
+		parent = ERR_PTR(-ENOMEM);
+	}
+	return parent;
+} 
 
 #define S_SHIFT 12
 static unsigned char ext3_type_by_mode[S_IFMT >> S_SHIFT] = {

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
