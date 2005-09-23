From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 6 of 10 - Fixed subscripting problem in idmapd
Date: Fri, 23 Sep 2005 10:47:41 -0400
Message-ID: <4334158D.2060506@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050009040306080607080500"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIoq1-00060Y-EN
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:47:45 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIoq0-0003N7-6F
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:47:45 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NElgaG015096
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:47:42 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NElgV13987
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:47:42 -0400
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------050009040306080607080500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------050009040306080607080500
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-idmap-reopen.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-idmap-reopen.patch"

Fixed subscripting problem in idmapd (bz 158188)
This fixes the following problem:
rpc.idmapd: nfsdreopen: Opening '' failed: errno 2 (No such file or directory)

Details can be found in:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=158188

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.7/utils/idmapd/idmapd.c.orig	2005-05-26 14:50:08.164704000 -0400
+++ nfs-utils-1.0.7/utils/idmapd/idmapd.c	2005-05-26 20:40:19.688208000 -0400
@@ -92,8 +92,8 @@
 		(w) = p;			\
 } while (0)
 
-#define IC_IDNAME 1
-#define IC_NAMEID 2
+#define IC_IDNAME 0
+#define IC_NAMEID 1
 struct idmap_client {
 	int                        ic_fd;
 	int                        ic_dirfd;
@@ -590,8 +590,8 @@ nfsdreopen()
 static int
 nfsdopen(char *path)
 {
-	return ((nfsdopenone(&nfsd_ic[0], IC_NAMEID, path) == 0 &&
-		    nfsdopenone(&nfsd_ic[1], IC_IDNAME, path) == 0) ? 0 : -1);
+	return ((nfsdopenone(&nfsd_ic[IC_NAMEID], IC_NAMEID, path) == 0 &&
+		    nfsdopenone(&nfsd_ic[IC_IDNAME], IC_IDNAME, path) == 0) ? 0 : -1);
 }
 
 static int

--------------050009040306080607080500--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
