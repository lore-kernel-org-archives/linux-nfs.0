From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 7 of 10 - Changed mountd to use stat64()
Date: Fri, 23 Sep 2005 10:48:24 -0400
Message-ID: <433415B8.6090708@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090907070806030100000308"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIoqp-00062j-1C
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:48:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIoqh-0007Gj-Hg
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:48:35 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEmPwl015327
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:48:25 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEmPV14150
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:48:25 -0400
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
--------------090907070806030100000308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------090907070806030100000308
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-mountd-stat64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-mountd-stat64.patch"

Changed mountd to use stat64() (bz 165062)
Which fixed the following error:
rpc.mountd: can't stat exported dir /mnt/bigfile: Value too large 
for defined data type

I wonder if it would be better just to make mountd a 64bit
application by compiling with -D_FILE_OFFSET_BITS=64?

Details can be found in:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=165062

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.7/utils/mountd/mountd.c.orig	2005-08-02 10:25:34.000000000 -0400
+++ nfs-utils-1.0.7/utils/mountd/mountd.c	2005-08-16 04:01:27.000000000 -0400
@@ -187,7 +187,7 @@ mount_pathconf_2_svc(struct svc_req *rqs
 {
 	struct sockaddr_in *sin
 		= (struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	struct stat	stb;
+	struct stat64	stb;
 	nfs_export	*exp;
 	char		rpath[MAXPATHLEN+1];
 	char		*p = *path;
@@ -209,7 +209,7 @@ mount_pathconf_2_svc(struct svc_req *rqs
 	/* Now authenticate the intruder... */
 	if (!(exp = auth_authenticate("pathconf", sin, p))) {
 		return 1;
-	} else if (stat(p, &stb) < 0) {
+	} else if (stat64(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
 				p, strerror(errno));
 		export_reset (exp);
@@ -263,7 +263,7 @@ get_rootfh(struct svc_req *rqstp, dirpat
 {
 	struct sockaddr_in *sin =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	struct stat	stb, estb;
+	struct stat64	stb, estb;
 	nfs_export	*exp;
 	char		rpath[MAXPATHLEN+1];
 	char		*p = *path;
@@ -283,7 +283,7 @@ get_rootfh(struct svc_req *rqstp, dirpat
 	/* Now authenticate the intruder... */
 	if (!(exp = auth_authenticate("mount", sin, p))) {
 		*error = NFSERR_ACCES;
-	} else if (stat(p, &stb) < 0) {
+	} else if (stat64(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
 				p, strerror(errno));
 		if (errno == ENOENT)
@@ -293,7 +293,7 @@ get_rootfh(struct svc_req *rqstp, dirpat
 	} else if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
 		xlog(L_WARNING, "%s is not a directory or regular file", p);
 		*error = NFSERR_NOTDIR;
-	} else if (stat(exp->m_export.e_path, &estb) < 0) {
+	} else if (stat64(exp->m_export.e_path, &estb) < 0) {
 		xlog(L_WARNING, "can't stat export point %s: %s",
 		     p, strerror(errno));
 		*error = NFSERR_NOENT;

--------------090907070806030100000308--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
