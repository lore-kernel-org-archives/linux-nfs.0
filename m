From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - nfsd in 2.5.27 - New struct initialisers for nfsd
Date: Wed, 24 Jul 2002 22:44:58 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15678.41290.270944.712223@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17XLVm-0005nV-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Jul 2002 05:45:02 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <rusty@rustcorp.com.au>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 24 Jul 2002 22:44:50 +1000
To: Linus Torvalds <torvalds@transmeta.com>, rusty@rustcorp.com.au
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


Heading Rusty off at the pass...

This also changes and array initialiser...


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |    8 ++++----
 ./fs/nfsd/lockd.c  |   12 ++++++------
 ./fs/nfsd/nfsctl.c |   28 ++++++++++++++--------------
 ./fs/nfsd/nfssvc.c |   36 +++++++++++++++++-------------------
 ./fs/nfsd/stats.c  |    2 +-
 5 files changed, 42 insertions(+), 44 deletions(-)

--- ./fs/nfsd/export.c	2002/07/24 12:23:21	1.1
+++ ./fs/nfsd/export.c	2002/07/24 12:42:33	1.2
@@ -701,10 +701,10 @@ static int e_show(struct seq_file *m, vo
 }
 
 struct seq_operations nfs_exports_op = {
-	start:	e_start,
-	next:	e_next,
-	stop:	e_stop,
-	show:	e_show,
+	.start	= e_start,
+	.next	= e_next,
+	.stop	= e_stop,
+	.show	= e_show,
 };
 
 /*
--- ./fs/nfsd/lockd.c	2002/07/24 12:23:56	1.1
+++ ./fs/nfsd/lockd.c	2002/07/24 12:42:33	1.2
@@ -61,12 +61,12 @@ nlm_fclose(struct file *filp)
 }
 
 struct nlmsvc_binding		nfsd_nlm_ops = {
-	exp_readlock:		exp_readlock,		/* lock export table for reading */
-	exp_unlock:		exp_readunlock,		/* unlock export table */
-	exp_getclient:		exp_getclient,		/* look up NFS client */
-	fopen:			nlm_fopen,		/* open file for locking */
-	fclose:			nlm_fclose,		/* close file */
-	detach:			exp_nlmdetach,		/* lockd shutdown notification */
+	.exp_readlock	= exp_readlock,		/* lock export table for reading */
+	.exp_unlock	= exp_readunlock,		/* unlock export table */
+	.exp_getclient	= exp_getclient,		/* look up NFS client */
+	.fopen		= nlm_fopen,		/* open file for locking */
+	.fclose		= nlm_fclose,		/* close file */
+	.detach		= exp_nlmdetach,		/* lockd shutdown notification */
 };
 
 /*
--- ./fs/nfsd/nfsctl.c	2002/07/24 12:24:39	1.1
+++ ./fs/nfsd/nfsctl.c	2002/07/24 12:42:33	1.2
@@ -114,14 +114,14 @@ static int TA_release(struct inode *inod
 }
 
 static struct file_operations writer_ops = {
-	write:	fs_write,
+	.write	= fs_write,
 };
 
 static struct file_operations reader_ops = {
-	write:	fs_write,
-	read:	TA_read,
-	open:	TA_open,
-	release:TA_release,
+	.write		= fs_write,
+	.read		= TA_read,
+	.open		= TA_open,
+	.release	= TA_release,
 };
 
 extern struct seq_operations nfs_exports_op;
@@ -130,10 +130,10 @@ static int exports_open(struct inode *in
 	return seq_open(file, &nfs_exports_op);
 }
 static struct file_operations exports_operations = {
-	open:		exports_open,
-	read:		seq_read,
-	llseek:		seq_lseek,
-	release:	seq_release,
+	.open		= exports_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
 };
 
 /*
@@ -305,7 +305,7 @@ static ssize_t write_getfd(struct file *
  */
 
 static struct super_operations s_ops = {
-	statfs:		simple_statfs,
+	.statfs		= simple_statfs,
 };
 
 static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
@@ -371,10 +371,10 @@ static struct super_block *nfsd_get_sb(s
 }
 
 static struct file_system_type nfsd_fs_type = {
-	owner:		THIS_MODULE,
-	name:		"nfsd",
-	get_sb:		nfsd_get_sb,
-	kill_sb:	kill_litter_super,
+	.owner		= THIS_MODULE,
+	.name		= "nfsd",
+	.get_sb		= nfsd_get_sb,
+	.kill_sb	= kill_litter_super,
 };
 
 static int __init init_nfsd(void)
--- ./fs/nfsd/nfssvc.c	2002/07/24 12:26:36	1.1
+++ ./fs/nfsd/nfssvc.c	2002/07/24 12:42:33	1.2
@@ -324,35 +324,33 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 }
 
 static struct svc_version	nfsd_version2 = {
-		vs_vers:	2,
-		vs_nproc:	18,
-		vs_proc:	nfsd_procedures2,
-		vs_dispatch:	nfsd_dispatch
+		.vs_vers	= 2,
+		.vs_nproc	= 18,
+		.vs_proc	= nfsd_procedures2,
+		.vs_dispatch	= nfsd_dispatch
 };
 #ifdef CONFIG_NFSD_V3
 static struct svc_version	nfsd_version3 = {
-		vs_vers:	3,
-		vs_nproc:	22,
-		vs_proc:	nfsd_procedures3,
-		vs_dispatch:	nfsd_dispatch
+		.vs_vers	= 3,
+		.vs_nproc	= 22,
+		.vs_proc	= nfsd_procedures3,
+		.vs_dispatch	= nfsd_dispatch
 };
 #endif
 static struct svc_version *	nfsd_version[] = {
-	NULL,
-	NULL,
-	&nfsd_version2,
+	[2] = &nfsd_version2,
 #ifdef CONFIG_NFSD_V3
-	&nfsd_version3,
+	[3] = &nfsd_version3,
 #endif
 };
 
 #define NFSD_NRVERS		(sizeof(nfsd_version)/sizeof(nfsd_version[0]))
 struct svc_program		nfsd_program = {
-	pg_prog:		NFS_PROGRAM,		/* program number */
-	pg_lovers:		2,			// version
-	pg_hivers:		NFSD_NRVERS-1,		// range
-	pg_nvers:		NFSD_NRVERS,		/* nr of entries in nfsd_version */
-	pg_vers:		nfsd_version,		/* version table */
-	pg_name:		"nfsd",			/* program name */
-	pg_stats:		&nfsd_svcstats,		/* version table */
+	.pg_prog		= NFS_PROGRAM,		/* program number */
+	.pg_lovers		= 2,			// version
+	.pg_hivers		= NFSD_NRVERS-1,	// range
+	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
+	.pg_vers		= nfsd_version,		/* version table */
+	.pg_name		= "nfsd",		/* program name */
+	.pg_stats		= &nfsd_svcstats,	/* version table */
 };
--- ./fs/nfsd/stats.c	2002/07/24 12:28:09	1.1
+++ ./fs/nfsd/stats.c	2002/07/24 12:42:33	1.2
@@ -37,7 +37,7 @@
 
 struct nfsd_stats	nfsdstats;
 struct svc_stat		nfsd_svcstats = {
-	program:	&nfsd_program,
+	.program	= &nfsd_program,
 };
 
 static int


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
