From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 9 of 10 - Fixed some security issues found by SGI
Date: Fri, 23 Sep 2005 10:49:49 -0400
Message-ID: <4334160D.6020705@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090106070701010901040901"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIos8-00066D-2J
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:49:56 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIos7-0003va-SU
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:49:56 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEnsnP015847
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:49:54 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEnnV14507
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:49:49 -0400
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
--------------090106070701010901040901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------090106070701010901040901
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-sgi-statd-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-sgi-statd-fixes.patch"

Fixed some security issues found by SGI (bz# 133556)

Details can be found in:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=133556

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.7/utils/statd/monitor.c.sgi	2004-09-14 23:08:01.000000000 -0400
+++ nfs-utils-1.0.7/utils/statd/monitor.c	2005-02-21 11:32:06.558972064 -0500
@@ -15,6 +15,7 @@
 #include <string.h>
 #include <unistd.h>
 #include <sys/stat.h>
+#include <errno.h>
 #include <arpa/inet.h>
 #include "misc.h"
 #include "statd.h"
@@ -172,7 +173,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 	sprintf(path, "%s/%s", SM_DIR, mon_name);
 	if ((fd = open(path, O_WRONLY|O_SYNC|O_CREAT, S_IRUSR|S_IWUSR)) < 0) {
 		/* Didn't fly.  We won't monitor. */
-		note(N_ERROR, "creat(%s) failed: %m", path);
+		note(N_ERROR, "creat(%s) failed: %s", path, strerror (errno));
 		nlist_free(NULL, clnt);
 		free(path);
 		goto failure;
--- nfs-utils-1.0.7/utils/statd/statd.c.sgi	2004-12-05 20:25:27.000000000 -0500
+++ nfs-utils-1.0.7/utils/statd/statd.c	2005-02-21 11:32:06.561971608 -0500
@@ -194,8 +194,10 @@ static void drop_privs(void)
 	struct stat st;
 
 	if (stat(SM_DIR, &st) == -1 &&
-	    stat(DIR_BASE, &st) == -1)
+	    stat(DIR_BASE, &st) == -1) {
 		st.st_uid = 0;
+		st.st_gid = 0;
+	}
 
 	if (st.st_uid == 0) {
 		note(N_WARNING, "statd running as root. chown %s to choose different user\n",
--- nfs-utils-1.0.7/utils/statd/svc_run.c.sgi	2004-12-05 20:25:28.000000000 -0500
+++ nfs-utils-1.0.7/utils/statd/svc_run.c	2005-02-21 11:32:06.562971456 -0500
@@ -123,7 +123,8 @@ my_svc_run(void)
 			if (errno == EINTR || errno == ECONNREFUSED
 			 || errno == ENETUNREACH || errno == EHOSTUNREACH)
 				continue;
-			note(N_ERROR, "my_svc_run() - select: %m");
+			note(N_ERROR, "my_svc_run() - select: %s",
+				strerror (errno));
 			return;
 
 		case 0:

--------------090106070701010901040901--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
