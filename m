From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 6 - Move SVCFH_fmt from being 'inline' to being 'extern'.
Date: Fri, 16 Jan 2004 12:27:23 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AhIlf-0002nw-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AhIlp-0007N5-Dv
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:33 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AhIlo-0005TH-W0
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:33 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 16 Jan 2004 12:27:26 +1100
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


This way, the "static char buf" is defined only once instead
of once per file.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c            |   18 ++++++++++++++++++
 ./include/linux/nfsd/nfsfh.h |   17 ++---------------
 2 files changed, 20 insertions(+), 15 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-01-16 12:19:51.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2004-01-16 12:22:12.000000000 +1100
@@ -489,3 +489,21 @@ fh_put(struct svc_fh *fhp)
 	return;
 }
 
+/*
+ * Shorthand for dprintk()'s
+ */
+char * SVCFH_fmt(struct svc_fh *fhp)
+{
+	struct knfsd_fh *fh = &fhp->fh_handle;
+	
+	static char buf[80];
+	sprintf(buf, "%d: %08x %08x %08x %08x %08x %08x",
+		fh->fh_size,
+		fh->fh_base.fh_pad[0],
+		fh->fh_base.fh_pad[1],
+		fh->fh_base.fh_pad[2],
+		fh->fh_base.fh_pad[3],
+		fh->fh_base.fh_pad[4],
+		fh->fh_base.fh_pad[5]);
+	return buf;
+}

diff ./include/linux/nfsd/nfsfh.h~current~ ./include/linux/nfsd/nfsfh.h
--- ./include/linux/nfsd/nfsfh.h~current~	2004-01-13 14:56:17.000000000 +1100
+++ ./include/linux/nfsd/nfsfh.h	2004-01-16 12:22:12.000000000 +1100
@@ -186,21 +186,8 @@ static inline void mk_fsid_v2(u32 *fsidv
 /*
  * Shorthand for dprintk()'s
  */
-inline static char * SVCFH_fmt(struct svc_fh *fhp)
-{
-	struct knfsd_fh *fh = &fhp->fh_handle;
-	
-	static char buf[80];
-	sprintf(buf, "%d: %08x %08x %08x %08x %08x %08x",
-		fh->fh_size,
-		fh->fh_base.fh_pad[0],
-		fh->fh_base.fh_pad[1],
-		fh->fh_base.fh_pad[2],
-		fh->fh_base.fh_pad[3],
-		fh->fh_base.fh_pad[4],
-		fh->fh_base.fh_pad[5]);
-	return buf;
-}
+extern char * SVCFH_fmt(struct svc_fh *fhp);
+
 /*
  * Function prototypes
  */


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
