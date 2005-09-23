From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 3 of 10 - Make sure check_new_cache() looks in
 the right place
Date: Fri, 23 Sep 2005 10:44:52 -0400
Message-ID: <433414E4.4000104@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040606090206060605060700"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIonK-0005nQ-Ki
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:44:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIonH-0002VQ-BH
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:44:55 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEiroi014186
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:44:53 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEirV12808
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:44:53 -0400
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
--------------040606090206060605060700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------040606090206060605060700
Content-Type: text/x-patch;
 name="nfs-utils-1.0.6-mountd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-mountd.patch"

Make sure check_new_cache() is looking in the right place
Eliminate 3 syslog message that are logged for successful events.

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- src/support/nfs/cacheio.c.org	2003-08-04 00:12:16.000000000 -0400
+++ src/support/nfs/cacheio.c	2004-03-22 18:12:55.163534208 -0500
@@ -223,12 +223,23 @@ int readline(int fd, char **buf, int *le
  * This succeeds iff the "nfsd" filesystem is mounted on
  * /proc/fs/nfs
  */
+static char *cachelist[] = {
+	{ "auth.unix.ip" }, { "nfsd.export" }, { "nfsd.fh" }, 
+	{ NULL, NULL }
+};
 int
 check_new_cache(void)
 {
 	struct stat stb;
-	return	(stat("/proc/fs/nfs/filehandle", &stb) == 0) ||
-		(stat("/proc/fs/nfsd/filehandle", &stb) == 0);
+	char path[64];
+	int i;
+
+	for (i=0; cachelist[i]; i++ ){
+		sprintf(path, "/proc/net/rpc/%s/channel", cachelist[i]);
+		if (stat(path, &stb) < 0)
+			return 0;
+	}
+	return 1;
 }	


--- src/utils/mountd/mountd.c.org	2003-09-12 18:14:16.000000000 -0400
+++ src/utils/mountd/mountd.c	2004-06-16 09:31:06.000000000 -0400
@@ -90,10 +90,11 @@ mount_dump_1_svc(struct svc_req *rqstp, 
 {
 	struct sockaddr_in *addr =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	xlog(L_NOTICE, "dump request from %s",
-		inet_ntoa(addr->sin_addr));
 
-	*res = mountlist_list();
+	if ((*res = mountlist_list()) == NULL)
+		xlog(L_WARNING, "dump request from %s failed.",
+			inet_ntoa(addr->sin_addr));
+
 	return 1;
 }
 
@@ -143,9 +144,11 @@ mount_export_1_svc(struct svc_req *rqstp
 {
 	struct sockaddr_in *addr =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	xlog(L_NOTICE, "export request from %s",
-		inet_ntoa(addr->sin_addr));
-	*resp = get_exportlist();
+
+	if ((*resp = get_exportlist()) == NULL)
+		xlog(L_WARNING, "export request from %s failed.",
+			inet_ntoa(addr->sin_addr));
+		
 	return 1;
 }
 
@@ -154,9 +157,10 @@ mount_exportall_1_svc(struct svc_req *rq
 {
 	struct sockaddr_in *addr =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	xlog(L_NOTICE, "exportall request from %s",
-		inet_ntoa(addr->sin_addr));
-	*resp = get_exportlist();
+
+	if ((*resp = get_exportlist()) == NULL)
+		xlog(L_WARNING, "exportall request from %s failed.",
+			inet_ntoa(addr->sin_addr));
 	return 1;
 }
 

--------------040606090206060605060700--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
