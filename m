From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 7 - Change NFSEXP_CROSSMNT to NFSEXP_CROSSMOUNT
Date: Tue, 05 Aug 2003 13:59:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19jsyo-0000mr-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jsyw-0001hC-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 20:59:30 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 5 Aug 2003 13:59:25 +1000
To: Linus Torvalds <torvalds@osdl.org>
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

NFSEXP_CROSSMNT used to mean something different, so
using a different name reduces the chance of confusion.
Also there is currently a surplus of vowels, so there is
no need to be frugal

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    2 +-
 ./fs/nfsd/vfs.c               |    2 +-
 ./include/linux/nfsd/export.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-08-04 11:07:47.000000000 +1000
+++ ./fs/nfsd/export.c	2003-08-04 11:07:47.000000000 +1000
@@ -999,7 +999,7 @@ struct flags {
 	{ NFSEXP_KERBEROS, { "kerberos", ""}},
 	{ NFSEXP_SUNSECURE, { "sunsecure", ""}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
-	{ NFSEXP_CROSSMNT, {"crossmnt", ""}},
+	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 #ifdef MSNFS

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-08-04 11:07:47.000000000 +1000
+++ ./fs/nfsd/vfs.c	2003-08-04 11:07:47.000000000 +1000
@@ -99,7 +99,7 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, s
 		mntput(mnt);
 		goto out;
 	}
-	if (exp2 && ((exp->ex_flags & NFSEXP_CROSSMNT) || EX_NOHIDE(exp2))) {
+	if (exp2 && ((exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2))) {
 		/* successfully crossed mount point */
 		exp_put(exp);
 		*expp = exp2;

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2003-08-04 11:07:47.000000000 +1000
+++ ./include/linux/nfsd/export.h	2003-08-04 11:07:47.000000000 +1000
@@ -40,7 +40,7 @@
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
 #define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect */
 #define NFSEXP_FSID		0x2000
-#define	NFSEXP_CROSSMNT		0x4000
+#define	NFSEXP_CROSSMOUNT	0x4000
 #define NFSEXP_ALLFLAGS		0x7FFF
 
 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
