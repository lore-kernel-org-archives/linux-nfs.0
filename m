From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 16 - Don't store path in exports table.
Date: Thu, 12 Sep 2002 12:35:14 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023514.19607@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJpT-0002I3-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:35:39 -0700
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


### Comments for ChangeSet

Instead, use d_path to find path from dentry/vfsmnt.
This requires allocating a buffer at exp_open time,
and releasing it when closing.




 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    7 +++++--
 ./fs/nfsd/nfsctl.c            |   21 +++++++++++++++++++--
 ./include/linux/nfsd/export.h |    1 -
 3 files changed, 24 insertions(+), 5 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 01:35:01	1.5
+++ ./include/linux/nfsd/export.h	2002/09/11 01:35:40	1.6
@@ -62,7 +62,6 @@ struct svc_export {
 	struct list_head	ex_hash;
 	struct list_head	ex_fsid_hash;
 	struct list_head	ex_list;
-	char			ex_path[NFS_MAXPATHLEN+1];
 	struct svc_client *	ex_client;
 	int			ex_flags;
 	struct vfsmount *	ex_mnt;
--- ./fs/nfsd/export.c	2002/09/11 01:35:01	1.7
+++ ./fs/nfsd/export.c	2002/09/11 01:35:40	1.8
@@ -334,7 +334,6 @@ exp_export(struct nfsctl_export *nxp)
 		goto finish;
 	dprintk("nfsd: created export entry %p for client %p\n", exp, clp);
 
-	strcpy(exp->ex_path, nxp->ex_path);
 	exp->ex_client = clp;
 	exp->ex_mnt = mntget(nd.mnt);
 	exp->ex_dentry = dget(nd.dentry);
@@ -640,6 +639,7 @@ static int e_show(struct seq_file *m, vo
 {
 	struct svc_export *exp = p;
 	struct svc_client *clp;
+	char *pbuf;
 	int j, first = 0;
 
 	if (p == (void *)1) {
@@ -650,7 +650,10 @@ static int e_show(struct seq_file *m, vo
 
 	clp = exp->ex_client;
 
-	mangle(m, exp->ex_path);
+	pbuf = m->private;
+	mangle(m, d_path(exp->ex_dentry, exp->ex_mnt,
+			 pbuf, PAGE_SIZE));
+
 	seq_putc(m, '\t');
 	mangle(m, clp->cl_ident);
 	seq_putc(m, '(');
--- ./fs/nfsd/nfsctl.c	2002/09/11 01:35:17	1.1
+++ ./fs/nfsd/nfsctl.c	2002/09/11 01:35:40	1.2
@@ -127,13 +127,30 @@ static struct file_operations reader_ops
 extern struct seq_operations nfs_exports_op;
 static int exports_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &nfs_exports_op);
+	int res;
+	res = seq_open(file, &nfs_exports_op);
+	if (!res) {
+		char *namebuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (namebuf == NULL)
+			res = -ENOMEM;
+		else
+			((struct seq_file *)file->private_data)->private = namebuf;
+	}
+	return res;
+}
+static int exports_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *m = (struct seq_file *)file->private_data;
+	kfree(m->private);
+	m->private = NULL;
+	return seq_release(inode, file);
 }
+
 static struct file_operations exports_operations = {
 	.open		= exports_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release,
+	.release	= exports_release,
 };
 
 /*


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
