From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 12 of 15 - Add 'filehandle' entry for nfsd filesystem for looking up a filehandle
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002Xz-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xk-00
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

The getfh system call takes an IP address, which is only
really appropriate for AUTH_UNIX authentication.

With this interface, you call can ask for a filehandle for a
particular domain.

You write 
 domainname pathname maxlength
to the file, and then read back the filehandle

All strings a qword quoted.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsctl.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 62 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2003-01-06 10:19:30.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2003-01-06 10:20:19.000000000 +1100
@@ -46,6 +46,8 @@ enum {
 	NFSD_Getfd,
 	NFSD_Getfs,
 	NFSD_List,
+	NFSD_Fh,
+	NFSD_END
 };
 
 /*
@@ -58,6 +60,7 @@ static ssize_t write_export(struct file 
 static ssize_t write_unexport(struct file *file, char *buf, size_t size);
 static ssize_t write_getfd(struct file *file, char *buf, size_t size);
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
+static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -67,6 +70,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Unexport] = write_unexport,
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
+	[NFSD_Fh] = write_filehandle,
 };
 
 /* an argresp is stored in an allocated page and holds the 
@@ -209,6 +213,7 @@ static struct { char *name; struct file_
 	[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
 	[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 	[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
+	[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 };
 
 /*----------------------------------------------------------------------------*/
@@ -337,6 +342,62 @@ static ssize_t write_getfd(struct file *
 	return err;
 }
 
+static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
+{
+	/* request is:
+	 *   domain path maxsize
+	 * response is
+	 *   filehandle
+	 *
+	 * qword quoting is used, so filehandle will be \x....
+	 */
+	char *dname, *path;
+	int maxsize;
+	char *mesg = buf;
+	int len;
+	struct auth_domain *dom;
+	struct knfsd_fh fh;
+
+	if (buf[size-1] != '\n')
+		return -EINVAL;
+	buf[size-1] = 0;
+
+	dname = mesg;
+	len = qword_get(&mesg, dname, size);
+	if (len <= 0) return -EINVAL;
+	
+	path = dname+len+1;
+	len = qword_get(&mesg, path, size);
+	if (len <= 0) return -EINVAL;
+
+	len = get_int(&mesg, &maxsize);
+	if (len)
+		return len;
+
+	if (maxsize < NFS_FHSIZE)
+		return -EINVAL;
+	if (maxsize > NFS3_FHSIZE)
+		maxsize = NFS3_FHSIZE;
+
+	if (qword_get(&mesg, mesg, size)>0)
+		return -EINVAL;
+
+	/* we have all the words, they are in buf.. */
+	dom = unix_domain_find(dname);
+	if (!dom)
+		return -ENOMEM;
+
+	len = exp_rootfh(dom, path, &fh,  maxsize);
+	auth_domain_put(dom);
+	if (len)
+		return len;
+	
+	mesg = buf; len = PAGE_SIZE-sizeof(struct argresp);
+	qword_addhex(&mesg, &len, (char*)&fh.fh_base, fh.fh_size);
+	mesg[-1] = '\n';
+	return mesg - buf;	
+}
+
 /*----------------------------------------------------------------------------*/
 /*
  *	populating the filesystem.
@@ -373,7 +434,7 @@ static int nfsd_fill_super(struct super_
 		iput(inode);
 		return -ENOMEM;
 	}
-	for (i = NFSD_Svc; i <= NFSD_List; i++) {
+	for (i = NFSD_Svc; i < NFSD_END; i++) {
 		struct qstr name;
 		name.name = files[i].name;
 		name.len = strlen(name.name);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
