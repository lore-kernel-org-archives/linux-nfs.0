From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 6 - Change name of a #define in nfsd to match 2.6
Date: Thu, 04 Sep 2003 16:25:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19unZ5-0004VX-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19unZK-00027n-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 23:26:10 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19unZJ-0002Mp-Hi
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 23:26:09 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 4 Sep 2003 16:25:56 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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

The meaning is "nohide" not "crossmnt", so we 
should spell it that way.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    2 +-
 ./fs/nfsd/vfs.c               |    6 +++---
 ./include/linux/nfsd/export.h |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-09-04 11:44:35.000000000 +1000
+++ ./fs/nfsd/export.c	2003-09-04 11:46:11.000000000 +1000
@@ -640,7 +640,7 @@ struct flags {
 	{ NFSEXP_UIDMAP, {"uidmap", ""}},
 	{ NFSEXP_KERBEROS, { "kerberos", ""}},
 	{ NFSEXP_SUNSECURE, { "sunsecure", ""}},
-	{ NFSEXP_CROSSMNT, {"nohide", ""}},
+	{ NFSEXP_NOHIDE, {"nohide", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 #ifdef MSNFS

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-09-04 11:33:07.000000000 +1000
+++ ./fs/nfsd/vfs.c	2003-09-04 11:46:11.000000000 +1000
@@ -82,7 +82,7 @@ static struct raparms *		raparm_cache;
  * N.B. After this call _both_ fhp and resfh need an fh_put
  *
  * If the lookup would cross a mountpoint, and the mounted filesystem
- * is exported to the client with NFSEXP_CROSSMNT, then the lookup is
+ * is exported to the client with NFSEXP_NOHIDE, then the lookup is
  * accepted as it stands and the mounted directory is
  * returned. Otherwise the covered directory is returned.
  * NOTE: this mountpoint crossing is not supported properly by all
@@ -116,7 +116,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			dentry = dget(dparent);
 		else if (dparent != exp->ex_dentry)
 			dentry = dget(dparent->d_parent);
-		else if (!EX_CROSSMNT(exp))
+		else if (!EX_NOHIDE(exp))
 			dentry = dget(dparent); /* .. == . just like at / */
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
@@ -158,7 +158,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			exp2 = exp_get(rqstp->rq_client,
 				       mounts->d_inode->i_dev,
 				       mounts->d_inode->i_ino);
-			if (exp2 && EX_CROSSMNT(exp2)) {
+			if (exp2 && EX_NOHIDE(exp2)) {
 				/* successfully crossed mount point */
 				exp = exp2;
 				dput(dentry);

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2003-09-04 11:32:11.000000000 +1000
+++ ./include/linux/nfsd/export.h	2003-09-04 11:46:11.000000000 +1000
@@ -35,7 +35,7 @@
 #define NFSEXP_UIDMAP		0x0040
 #define NFSEXP_KERBEROS		0x0080		/* not available */
 #define NFSEXP_SUNSECURE	0x0100
-#define NFSEXP_CROSSMNT		0x0200
+#define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
 #define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect */
@@ -80,7 +80,7 @@ struct svc_export {
 #define EX_SECURE(exp)		(!((exp)->ex_flags & NFSEXP_INSECURE_PORT))
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
 #define EX_RDONLY(exp)		((exp)->ex_flags & NFSEXP_READONLY)
-#define EX_CROSSMNT(exp)	((exp)->ex_flags & NFSEXP_CROSSMNT)
+#define EX_NOHIDE(exp)		((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_SUNSECURE(exp)	((exp)->ex_flags & NFSEXP_SUNSECURE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
