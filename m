From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 13 of 15 - Add 'threads' file to nfsd filesystem to allow changing number of threads.
Date: Mon, 06 Jan 2003 11:05:05 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlN-0002Y4-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xm-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:26 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:05 +1100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

This uses the read-without-write style transaction files in nfsctl.
We can write a number of threads, and then read back the number of 
threads that resulted, or we can just open and read in which case 
we read back the number of threads without changing it.


 ----------- Diffstat output ------------
 ./fs/nfsd/nfsctl.c |   28 ++++++++++++++++++++++++++++
 ./fs/nfsd/nfssvc.c |    8 ++++++++
 2 files changed, 36 insertions(+)

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2003-01-06 10:20:19.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2003-01-06 10:21:24.000000000 +1100
@@ -47,6 +47,7 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
+	NFSD_Threads,
 	NFSD_END
 };
 
@@ -61,6 +62,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfd(struct file *file, char *buf, size_t size);
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
+static ssize_t write_threads(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -71,6 +73,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_Threads] = write_threads,
 };
 
 /* an argresp is stored in an allocated page and holds the 
@@ -214,6 +217,7 @@ static struct { char *name; struct file_
 	[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 	[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 	[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
+	[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 };
 
 /*----------------------------------------------------------------------------*/
@@ -398,6 +402,30 @@ static ssize_t write_filehandle(struct f
 	return mesg - buf;	
 }
 
+extern int nfsd_nrthreads(void);
+
+static ssize_t write_threads(struct file *file, char *buf, size_t size)
+{
+	/* if size > 0, look for a number of threads and call nfsd_svc
+	 * then write out number of threads as reply
+	 */
+	char *mesg = buf;
+	int rv;
+	if (size > 0) {
+		int newthreads;
+		rv = get_int(&mesg, &newthreads);
+		if (rv)
+			return rv;
+		if (newthreads <0)
+			return -EINVAL;
+		rv = nfsd_svc(2049, newthreads);
+		if (rv)
+			return rv;
+	}
+	sprintf(buf, "%d\n", nfsd_nrthreads());
+	return strlen(buf);
+}
+
 /*----------------------------------------------------------------------------*/
 /*
  *	populating the filesystem.

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2003-01-06 10:21:24.000000000 +1100
+++ ./fs/nfsd/nfssvc.c	2003-01-06 10:21:24.000000000 +1100
@@ -66,6 +66,14 @@ struct list_head nfsd_list = LIST_HEAD_I
  */
 #define	NFSD_MAXSERVS		8192
 
+int nfsd_nrthreads(void)
+{
+	if (nfsd_serv == NULL)
+		return 0;
+	else
+		return nfsd_serv->sv_nrthreads;
+}
+
 int
 nfsd_svc(unsigned short port, int nrservs)
 {


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
