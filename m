From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 9 - Fix #error message when bits are badly defined..
Date: Wed, 21 May 2003 13:12:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1S-00061y-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1g-0000vT-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 20:12:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 21 May 2003 13:12:10 +1000
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

 ----------- Diffstat output ------------
 ./include/linux/nfsd/nfsd.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2003-05-20 16:34:35.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2003-05-20 16:34:36.000000000 +1000
@@ -40,7 +40,7 @@
 #define MAY_OWNER_OVERRIDE	64
 #define	MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
 #if (MAY_SATTR | MAY_TRUNC | MAY_LOCK | MAY_OWNER_OVERRIDE | MAY_LOCAL_ACCESS) & (MAY_READ | MAY_WRITE | MAY_EXEC)
-# error "please use a different value for MAY_SATTR or MAY_TRUNC or MAY_LOCK or MAY_OWNER_OVERRIDE."
+# error "please use a different value for MAY_SATTR or MAY_TRUNC or MAY_LOCK or MAY_LOCAL_ACCESS or MAY_OWNER_OVERRIDE."
 #endif
 #define MAY_CREATE		(MAY_EXEC|MAY_WRITE)
 #define MAY_REMOVE		(MAY_EXEC|MAY_WRITE|MAY_TRUNC)


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
