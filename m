From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 17 - exp_getclient, now just a small wrapper, goes in favour of auth_unix_lookup
Date: Fri, 11 Oct 2002 15:27:32 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKi-0003bD-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLE-0003fy-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:04 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:49 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet



 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   13 -------------
 ./fs/nfsd/nfsctl.c            |    4 ++--
 ./include/linux/nfsd/export.h |    1 -
 3 files changed, 2 insertions(+), 16 deletions(-)

--- ./include/linux/nfsd/export.h	2002/10/11 00:51:15	1.3
+++ ./include/linux/nfsd/export.h	2002/10/11 01:00:39	1.4
@@ -85,7 +85,6 @@ void			nfsd_export_init(void);
 void			nfsd_export_shutdown(void);
 void			exp_readlock(void);
 void			exp_readunlock(void);
-struct auth_domain *	exp_getclient(struct sockaddr_in *sin);
 struct svc_expkey *	exp_find_key(struct auth_domain *clp, 
 				     int fsid_type, u32 *fsidv);
 struct svc_export *	exp_get_by_name(struct auth_domain *clp,
--- ./fs/nfsd/export.c	2002/10/11 00:51:15	1.3
+++ ./fs/nfsd/export.c	2002/10/11 01:00:40	1.4
@@ -557,19 +557,6 @@ exp_pseudoroot(struct auth_domain *clp, 
 	return fh_compose(fhp, exp, exp->ex_dentry, NULL);
 }
 
-/*
- * Find a valid client given an inet address. We always move the most
- * recently used client to the front of the hash chain to speed up
- * future lookups.
- * Locking against other processes is the responsibility of the caller.
- */
-svc_client *
-exp_getclient(struct sockaddr_in *sin)
-{
-	return auth_unix_lookup(sin->sin_addr);
-}
-
-
 /* Iterator */
 
 static void *e_start(struct seq_file *m, loff_t *pos)
--- ./fs/nfsd/nfsctl.c	2002/10/11 00:51:15	1.2
+++ ./fs/nfsd/nfsctl.c	2002/10/11 01:00:40	1.3
@@ -246,7 +246,7 @@ static ssize_t write_getfs(struct file *
 		return -ENOMEM;
 	memset(res, 0, sizeof(struct knfsd_fh));
 	exp_readlock();
-	if (!(clp = exp_getclient(sin)))
+	if (!(clp = auth_unix_lookup(sin->sin_addr)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data.gd_path, res, data.gd_maxlen);
@@ -293,7 +293,7 @@ static ssize_t write_getfd(struct file *
 		return -ENOMEM;
 	sin = (struct sockaddr_in *)&data.gd_addr;
 	exp_readlock();
-	if (!(clp = exp_getclient(sin)))
+	if (!(clp = auth_unix_lookup(sin->sin_addr)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data.gd_path, &fh, NFS_FHSIZE);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
