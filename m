From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 6 - Introduce CROSSMNT flag for knfsd
Date: Wed, 12 Mar 2003 16:35:29 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18sytl-0005RD-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sytw-0000Dw-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 21:35:40 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 12 Mar 2003 16:35:30 +1100
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

Now that we have working up-calls to userspace,
CROSSMNT makes sense.
If CROSSMNT is set for an export, and we too a 
LOOKUP which crosses a mountpoint, we initiate an
upcall to find out if and how that filesystem
is exported.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    9 ++++++++-
 ./fs/nfsd/vfs.c               |   18 +++++++++++++++++-
 ./include/linux/nfsd/export.h |    3 ++-
 3 files changed, 27 insertions(+), 3 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-03-12 15:07:05.000000000 +1100
+++ ./fs/nfsd/export.c	2003-03-12 15:07:11.000000000 +1100
@@ -475,8 +475,14 @@ exp_get_by_name(svc_client *clp, struct 
 
 	exp = svc_export_lookup(&key, 0);
 	if (exp != NULL) 
-		if (cache_check(&svc_export_cache, &exp->h, reqp))
+		switch (cache_check(&svc_export_cache, &exp->h, reqp)) {
+		case 0: break;
+		case -EAGAIN:
+			exp = ERR_PTR(-EAGAIN);
+			break;
+		default:
 			exp = NULL;
+		}
 
 	return exp;
 }
@@ -918,6 +924,7 @@ struct flags {
 	{ NFSEXP_KERBEROS, { "kerberos", ""}},
 	{ NFSEXP_SUNSECURE, { "sunsecure", ""}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
+	{ NFSEXP_CROSSMNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 #ifdef MSNFS

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-03-12 15:07:05.000000000 +1100
+++ ./fs/nfsd/vfs.c	2003-03-12 15:07:11.000000000 +1100
@@ -133,6 +133,12 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 
 			exp2 = exp_parent(exp->ex_client, mnt, dentry,
 					  &rqstp->rq_chandle);
+			if (IS_ERR(exp2)) {
+				err = PTR_ERR(exp2);
+				dput(dentry);
+				mntput(mnt);
+				goto out;
+			}
 			if (!exp2) {
 				dput(dentry);
 				dentry = dget(dparent);
@@ -157,9 +163,19 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			struct dentry *mounts = dget(dentry);
 			while (follow_down(&mnt,&mounts)&&d_mountpoint(mounts))
 				;
+
 			exp2 = exp_get_by_name(exp->ex_client, mnt, 
 					       mounts, &rqstp->rq_chandle);
-			if (exp2 && EX_NOHIDE(exp2)) {
+			if (IS_ERR(exp2)) {
+				err = PTR_ERR(exp2);
+				dput(mounts);
+				dput(dentry);
+				mntput(mnt);
+				goto out;
+			}
+			if (exp2 &&
+			    ((exp->ex_flags & NFSEXP_CROSSMNT)
+			     || EX_NOHIDE(exp2))) {
 				/* successfully crossed mount point */
 				exp_put(exp);
 				exp = exp2;

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2003-03-12 15:07:05.000000000 +1100
+++ ./include/linux/nfsd/export.h	2003-03-12 15:07:11.000000000 +1100
@@ -40,7 +40,8 @@
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
 #define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect */
 #define NFSEXP_FSID		0x2000
-#define NFSEXP_ALLFLAGS		0x3FFF
+#define	NFSEXP_CROSSMNT		0x4000
+#define NFSEXP_ALLFLAGS		0x7FFF
 
 
 #ifdef __KERNEL__


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
