From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 6 - Fix problem with stale filehandles.
Date: Fri, 16 Jan 2004 12:27:20 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AhIlc-0002nF-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AhIlo-0007Mu-Rg
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:32 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AhIlo-0005T2-Fh
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:32 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 16 Jan 2004 12:27:23 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


nfsd_setuser was not called until after filehandle
lookup was done, so filehandle lookup would use the wrong
userid, and so the permission checking in nfsd_acceptable
would be bogus.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-01-16 11:58:48.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2004-01-16 12:19:51.000000000 +1100
@@ -164,6 +164,9 @@ fh_verify(struct svc_rqst *rqstp, struct
 			goto out;
 		}
 
+		/* Set user creds for this exportpoint */
+		nfsd_setuser(rqstp, exp);
+
 		/*
 		 * Look up the dentry using the NFS file handle.
 		 */
@@ -224,9 +227,6 @@ fh_verify(struct svc_rqst *rqstp, struct
 	inode = dentry->d_inode;
 
 
-	/* Set user creds for this exportpoint */
-	nfsd_setuser(rqstp, exp);
-
 	/* Type check. The correct error return for type mismatches
 	 * does not seem to be generally agreed upon. SunOS seems to
 	 * use EISDIR if file isn't S_IFREG; a comment in the NFSv3


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
