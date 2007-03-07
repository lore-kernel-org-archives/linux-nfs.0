From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 3/8] exportfs: add procedural interface for NFSD
Date: Wed, 7 Mar 2007 10:39:55 +0000
Message-ID: <20070307103955.GD22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtYr-0003Cj-St
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:00 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOtYr-0002bP-I3
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:39:58 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOtYp-0006Tn-V0
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:39:55 +0000
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

Currently NFSD calls directly into filesystemsthrough the
export_operations structure.  I plan to change this interface
in various ways in later patches, and want to avoid the export
of the default operations to NFSD, so this patch adds two
simple exportfs_encode_fh/exportfs_decode_fh helpers for NFSD
to call instead of poking into exportfs guts.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-02-20 11:46:35.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-02-20 11:46:42.000000000 +0100
@@ -3,6 +3,7 @@
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/module.h>
+#include <linux/mount.h>
 #include <linux/smp_lock.h>
 #include <linux/namei.h>
 
@@ -469,6 +470,26 @@
 				   acceptable, context);
 }
 
+int exportfs_encode_fh(struct dentry *dentry, __u32 *fh, int *max_len,
+		int connectable)
+{
+	struct export_operations *nop = dentry->d_sb->s_export_op;
+
+	return CALL(nop, encode_fh)(dentry, fh, max_len, connectable);
+}
+EXPORT_SYMBOL_GPL(exportfs_encode_fh);
+
+struct dentry *exportfs_decode_fh(struct vfsmount *mnt, __u32 *fh, int fh_len,
+		int fileid_type, int (*acceptable)(void *, struct dentry *),
+		void *context)
+{
+	struct export_operations *nop = mnt->mnt_sb->s_export_op;
+
+	return CALL(nop, decode_fh)(mnt->mnt_sb, fh, fh_len, fileid_type,
+			acceptable, context);
+}
+EXPORT_SYMBOL_GPL(exportfs_decode_fh);
+
 struct export_operations export_op_default = {
 	.decode_fh	= export_decode_fh,
 	.encode_fh	= export_encode_fh,
@@ -478,7 +499,6 @@
 	.get_dentry	= get_dentry,
 };
 
-EXPORT_SYMBOL(export_op_default);
 EXPORT_SYMBOL(find_exported_dentry);
 
 MODULE_LICENSE("GPL");
Index: linux-2.6/fs/nfsd/nfsfh.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfsfh.c	2007-02-20 11:46:30.000000000 +0100
+++ linux-2.6/fs/nfsd/nfsfh.c	2007-02-20 11:47:34.000000000 +0100
@@ -30,10 +30,6 @@
 static int nfsd_nr_verified;
 static int nfsd_nr_put;
 
-extern struct export_operations export_op_default;
-
-#define	CALL(ops,fun) ((ops->fun)?(ops->fun):export_op_default.fun)
-
 /*
  * our acceptability function.
  * if NOSUBTREECHECK, accept anything
@@ -214,11 +210,9 @@
 		if (fileid_type == 0)
 			dentry = dget(exp->ex_dentry);
 		else {
-			struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
-			dentry = CALL(nop,decode_fh)(exp->ex_mnt->mnt_sb,
-						     datap, data_left,
-						     fileid_type,
-						     nfsd_acceptable, exp);
+			dentry = exportfs_decode_fh(exp->ex_mnt, datap,
+					data_left, fileid_type,
+					nfsd_acceptable, exp);
 		}
 		if (dentry == NULL)
 			goto out;
@@ -289,15 +283,13 @@
 static inline int _fh_update(struct dentry *dentry, struct svc_export *exp,
 			     __u32 *datap, int *maxsize)
 {
-	struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
-
 	if (dentry == exp->ex_dentry) {
 		*maxsize = 0;
 		return 0;
 	}
 
-	return CALL(nop,encode_fh)(dentry, datap, maxsize,
-			  !(exp->ex_flags&NFSEXP_NOSUBTREECHECK));
+	return exportfs_encode_fh(dentry, datap, maxsize,
+			  !(exp->ex_flags & NFSEXP_NOSUBTREECHECK));
 }
 
 /*
Index: linux-2.6/include/linux/exportfs.h
===================================================================
--- linux-2.6.orig/include/linux/exportfs.h	2007-02-20 11:46:31.000000000 +0100
+++ linux-2.6/include/linux/exportfs.h	2007-02-20 11:46:42.000000000 +0100
@@ -5,6 +5,7 @@
 
 struct dentry;
 struct super_block;
+struct vfsmount;
 
 
 /**
@@ -116,4 +117,10 @@
 	void *parent, int (*acceptable)(void *context, struct dentry *de),
 	void *context);
 
+extern int exportfs_encode_fh(struct dentry *dentry, __u32 *fh, int *max_len,
+	int connectable);
+extern struct dentry *exportfs_decode_fh(struct vfsmount *mnt, __u32 *fh,
+	int fh_len, int fileid_type, int (*acceptable)(void *, struct dentry *),
+	void *context);
+
 #endif /* LINUX_EXPORTFS_H */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
