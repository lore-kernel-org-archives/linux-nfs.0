From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 7 - Remove some unused export flags and reserve a new one.
Date: Tue, 05 Aug 2003 13:59:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19jsyo-0000my-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jsyx-0001hM-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 20:59:31 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 5 Aug 2003 13:59:26 +1000
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

The 'acl' folks would like an export flag, so this patch
reserves one and also discards some that aren't used and never
will be (for the named purpose).

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    3 ---
 ./include/linux/nfsd/export.h |   10 ++++------
 2 files changed, 4 insertions(+), 9 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-08-04 11:07:47.000000000 +1000
+++ ./fs/nfsd/export.c	2003-08-04 11:07:51.000000000 +1000
@@ -995,9 +995,6 @@ struct flags {
 	{ NFSEXP_ALLSQUASH, {"all_squash", ""}},
 	{ NFSEXP_ASYNC, {"async", "sync"}},
 	{ NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
-	{ NFSEXP_UIDMAP, {"uidmap", ""}},
-	{ NFSEXP_KERBEROS, { "kerberos", ""}},
-	{ NFSEXP_SUNSECURE, { "sunsecure", ""}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2003-08-04 11:07:47.000000000 +1000
+++ ./include/linux/nfsd/export.h	2003-08-04 11:07:51.000000000 +1000
@@ -32,16 +32,15 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-#define NFSEXP_UIDMAP		0x0040
-#define NFSEXP_KERBEROS		0x0080		/* not available */
-#define NFSEXP_SUNSECURE	0x0100
+/* 40 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
 #define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect */
 #define NFSEXP_FSID		0x2000
 #define	NFSEXP_CROSSMOUNT	0x4000
-#define NFSEXP_ALLFLAGS		0x7FFF
+#define	NFSEXP_NOACL		0x8000	/* reserved for possible ACL related use */
+#define NFSEXP_ALLFLAGS		0xFE3F
 
 
 #ifdef __KERNEL__
@@ -74,8 +73,7 @@ struct svc_expkey {
 #define EX_SECURE(exp)		(!((exp)->ex_flags & NFSEXP_INSECURE_PORT))
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
 #define EX_RDONLY(exp)		((exp)->ex_flags & NFSEXP_READONLY)
-#define EX_NOHIDE(exp)	((exp)->ex_flags & NFSEXP_NOHIDE)
-#define EX_SUNSECURE(exp)	((exp)->ex_flags & NFSEXP_SUNSECURE)
+#define EX_NOHIDE(exp)		((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
 
 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
