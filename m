From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 11 of 15 - Change names of legacy interfaces in nfsd filesys to start with period
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002Xv-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xc-00
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

The nfsd filesystem provides an interface to nfsd.
Most of the current files should be considered legacy
interfaces as they are not particularly suitable for
filesystem interaction, but are required to support the
syscall interface.
This patch puts a '.' in front of all the names so they
appear as hidden names when the directory is listed.

 ----------- Diffstat output ------------
 ./fs/nfsctl.c      |   17 +++++++----------
 ./fs/nfsd/nfsctl.c |   14 +++++++-------
 2 files changed, 14 insertions(+), 17 deletions(-)

diff ./fs/nfsctl.c~current~ ./fs/nfsctl.c
--- ./fs/nfsctl.c~current~	2003-01-06 10:19:30.000000000 +1100
+++ ./fs/nfsctl.c	2003-01-06 10:19:30.000000000 +1100
@@ -54,16 +54,13 @@ static struct file *do_open(char *name, 
 static struct {
 	char *name; int wsize; int rsize;
 } map[] = {
-	[NFSCTL_SVC]={"svc", sizeof(struct nfsctl_svc)},
-	[NFSCTL_ADDCLIENT]={"add", sizeof(struct nfsctl_client)},
-	[NFSCTL_DELCLIENT]={"del", sizeof(struct nfsctl_client)},
-	[NFSCTL_EXPORT]={"export", sizeof(struct nfsctl_export)},
-	[NFSCTL_UNEXPORT]={"unexport", sizeof(struct nfsctl_export)},
-#ifdef notyet
-	[NFSCTL_UGIDUPDATE]={"ugid", sizeof(struct nfsctl_uidmap)},
-#endif
-	[NFSCTL_GETFD]={"getfd", sizeof(struct nfsctl_fdparm), NFS_FHSIZE},
-	[NFSCTL_GETFS]={"getfs", sizeof(struct nfsctl_fsparm), sizeof(struct knfsd_fh)},
+	[NFSCTL_SVC]={".svc", sizeof(struct nfsctl_svc)},
+	[NFSCTL_ADDCLIENT]={".add", sizeof(struct nfsctl_client)},
+	[NFSCTL_DELCLIENT]={".del", sizeof(struct nfsctl_client)},
+	[NFSCTL_EXPORT]={".export", sizeof(struct nfsctl_export)},
+	[NFSCTL_UNEXPORT]={".unexport", sizeof(struct nfsctl_export)},
+	[NFSCTL_GETFD]={".getfd", sizeof(struct nfsctl_fdparm), NFS_FHSIZE},
+	[NFSCTL_GETFS]={".getfs", sizeof(struct nfsctl_fsparm), sizeof(struct knfsd_fh)},
 };
 
 long

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2003-01-06 10:16:36.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2003-01-06 10:19:30.000000000 +1100
@@ -201,13 +201,13 @@ static struct file_operations exports_op
  *	Description of fs contents.
  */
 static struct { char *name; struct file_operations *ops; int mode; } files[] = {
-	[NFSD_Svc] = {"svc", &transaction_ops, S_IWUSR},
-	[NFSD_Add] = {"add", &transaction_ops, S_IWUSR},
-	[NFSD_Del] = {"del", &transaction_ops, S_IWUSR},
-	[NFSD_Export] = {"export", &transaction_ops, S_IWUSR},
-	[NFSD_Unexport] = {"unexport", &transaction_ops, S_IWUSR},
-	[NFSD_Getfd] = {"getfd", &transaction_ops, S_IWUSR|S_IRUSR},
-	[NFSD_Getfs] = {"getfs", &transaction_ops, S_IWUSR|S_IRUSR},
+	[NFSD_Svc] = {".svc", &transaction_ops, S_IWUSR},
+	[NFSD_Add] = {".add", &transaction_ops, S_IWUSR},
+	[NFSD_Del] = {".del", &transaction_ops, S_IWUSR},
+	[NFSD_Export] = {".export", &transaction_ops, S_IWUSR},
+	[NFSD_Unexport] = {".unexport", &transaction_ops, S_IWUSR},
+	[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
+	[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 	[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 };
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
