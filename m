From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 8] knfsd: exportfs: add procedural interface
	for NFSD
Date: Tue, 15 May 2007 17:16:22 +1000
Message-ID: <1070515071622.16279@suse.de>
References: <20070515170405.15621.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnrGn-00042W-Sc
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:16:30 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnrGp-0001QH-VX
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:16:32 -0700
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

Currently NFSD calls directly into filesystems through the
export_operations structure.  I plan to change this interface
in various ways in later patches, and want to avoid the export
of the default operations to NFSD, so this patch adds two
simple exportfs_encode_fh/exportfs_decode_fh helpers for NFSD
to call instead of poking into exportfs guts.


Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/exportfs/expfs.c      |   22 +++++++++++++++++++++-
 ./fs/nfsd/nfsfh.c          |   18 +++++-------------
 ./include/linux/exportfs.h |    7 +++++++
 3 files changed, 33 insertions(+), 14 deletions(-)

diff .prev/fs/exportfs/expfs.c ./fs/exportfs/expfs.c
--- .prev/fs/exportfs/expfs.c	2007-05-14 11:15:29.000000000 +1000
+++ ./fs/exportfs/expfs.c	2007-05-14 11:15:31.000000000 +1000
@@ -3,6 +3,7 @@
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/module.h>
+#include <linux/mount.h>
 #include <linux/namei.h>
 
 struct export_operations export_op_default;
@@ -468,6 +469,26 @@ static struct dentry *export_decode_fh(s
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
@@ -477,7 +498,6 @@ struct export_operations export_op_defau
 	.get_dentry	= get_dentry,
 };
 
-EXPORT_SYMBOL(export_op_default);
 EXPORT_SYMBOL(find_exported_dentry);
 
 MODULE_LICENSE("GPL");

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-05-14 11:15:23.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2007-05-14 11:15:31.000000000 +1000
@@ -28,10 +28,6 @@
 static int nfsd_nr_verified;
 static int nfsd_nr_put;
 
-extern struct export_operations export_op_default;
-
-#define	CALL(ops,fun) ((ops->fun)?(ops->fun):export_op_default.fun)
-
 /*
  * our acceptability function.
  * if NOSUBTREECHECK, accept anything
@@ -212,11 +208,9 @@ fh_verify(struct svc_rqst *rqstp, struct
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
@@ -287,15 +281,13 @@ out:
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

diff .prev/include/linux/exportfs.h ./include/linux/exportfs.h
--- .prev/include/linux/exportfs.h	2007-05-14 11:15:23.000000000 +1000
+++ ./include/linux/exportfs.h	2007-05-14 11:15:31.000000000 +1000
@@ -5,6 +5,7 @@
 
 struct dentry;
 struct super_block;
+struct vfsmount;
 
 
 /**
@@ -116,4 +117,10 @@ extern struct dentry *find_exported_dent
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
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
