From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 6 - Rename NFSEXP_CROSSMNT to NFSEXP_NOHIDE
Date: Wed, 12 Mar 2003 16:35:29 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18sytl-0005R8-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sytv-0000Dp-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 21:35:39 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 12 Mar 2003 16:35:29 +1100
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

becase nohide is the user-space visible name
for the flag, and we are about to define a real
CROSSMNT.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    2 +-
 ./fs/nfsd/vfs.c               |    6 +++---
 ./include/linux/nfsd/export.h |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-03-12 15:03:20.000000000 +1100
+++ ./fs/nfsd/export.c	2003-03-12 15:07:05.000000000 +1100
@@ -917,7 +917,7 @@ struct flags {
 	{ NFSEXP_UIDMAP, {"uidmap", ""}},
 	{ NFSEXP_KERBEROS, { "kerberos", ""}},
 	{ NFSEXP_SUNSECURE, { "sunsecure", ""}},
-	{ NFSEXP_CROSSMNT, {"nohide", ""}},
+	{ NFSEXP_NOHIDE, {"nohide", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 #ifdef MSNFS

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-03-12 15:07:05.000000000 +1100
+++ ./fs/nfsd/vfs.c	2003-03-12 15:07:05.000000000 +1100
@@ -79,7 +79,7 @@ static struct raparms *		raparm_cache;
  * N.B. After this call _both_ fhp and resfh need an fh_put
  *
  * If the lookup would cross a mountpoint, and the mounted filesystem
- * is exported to the client with NFSEXP_CROSSMNT, then the lookup is
+ * is exported to the client with NFSEXP_NOHIDE, then the lookup is
  * accepted as it stands and the mounted directory is
  * returned. Otherwise the covered directory is returned.
  * NOTE: this mountpoint crossing is not supported properly by all
@@ -115,7 +115,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			read_lock(&dparent_lock);
 			dentry = dget(dparent->d_parent);
 			read_unlock(&dparent_lock);
-		} else  if (!EX_CROSSMNT(exp))
+		} else  if (!EX_NOHIDE(exp))
 			dentry = dget(dparent); /* .. == . just like at / */
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
@@ -159,7 +159,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 				;
 			exp2 = exp_get_by_name(exp->ex_client, mnt, 
 					       mounts, &rqstp->rq_chandle);
-			if (exp2 && EX_CROSSMNT(exp2)) {
+			if (exp2 && EX_NOHIDE(exp2)) {
 				/* successfully crossed mount point */
 				exp_put(exp);
 				exp = exp2;

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2003-03-12 15:07:05.000000000 +1100
+++ ./include/linux/nfsd/export.h	2003-03-12 15:07:05.000000000 +1100
@@ -35,7 +35,7 @@
 #define NFSEXP_UIDMAP		0x0040
 #define NFSEXP_KERBEROS		0x0080		/* not available */
 #define NFSEXP_SUNSECURE	0x0100
-#define NFSEXP_CROSSMNT		0x0200
+#define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
 #define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect */
@@ -73,7 +73,7 @@ struct svc_expkey {
 #define EX_SECURE(exp)		(!((exp)->ex_flags & NFSEXP_INSECURE_PORT))
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
 #define EX_RDONLY(exp)		((exp)->ex_flags & NFSEXP_READONLY)
-#define EX_CROSSMNT(exp)	((exp)->ex_flags & NFSEXP_CROSSMNT)
+#define EX_NOHIDE(exp)	((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_SUNSECURE(exp)	((exp)->ex_flags & NFSEXP_SUNSECURE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
 


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
