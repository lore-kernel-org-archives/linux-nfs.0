From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - Silencing mountd
Date: Wed, 16 Jun 2004 11:14:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40D063D1.9010208@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050208030400070104010400"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bac79-0006VH-8J
	for nfs@lists.sourceforge.net; Wed, 16 Jun 2004 08:14:11 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Bac78-0000lt-Pa
	for nfs@lists.sourceforge.net; Wed, 16 Jun 2004 08:14:10 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i5GFE2e1017843
	for <nfs@lists.sourceforge.net>; Wed, 16 Jun 2004 11:14:02 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i5GFE2021563
	for <nfs@lists.sourceforge.net>; Wed, 16 Jun 2004 11:14:02 -0400
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i5GFE1F08707
	for <nfs@lists.sourceforge.net>; Wed, 16 Jun 2004 11:14:01 -0400
To: nfs@lists.sourceforge.net
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
--------------050208030400070104010400
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

Here is a patch to the nfs-utils-1.0.6 rpc.mountd that
eliminates 4 syslog messages that are logged during
_successful_ mounts and showmount queries. This should
save quite a bit of disk space w.r.t syslog logs.

3 of the were converted to error messages
and one was eliminated.

Question: Does anybody depend on or use these messages?
If not, could this be added to the next release of
nfs-utils?

SteveD.




--------------050208030400070104010400
Content-Type: text/plain;
 name="nfs-utils-1.0.6-mountd-nonverbose.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-mountd-nonverbose.patch"

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
 
--- src/utils/mountd/auth.c.org	2004-06-16 08:54:32.000000000 -0400
+++ src/utils/mountd/auth.c	2004-06-16 08:55:15.000000000 -0400
@@ -194,9 +194,8 @@ auth_authenticate(char *what, struct soc
 		break;
 
 	case success:
-		xlog(L_NOTICE, "authenticated %s request from %s:%d for %s (%s)",
-		     what, hp->h_name, ntohs(caller->sin_port), path, epath);
 		break;
+
 	default:
 		xlog(L_NOTICE, "%s request from %s:%d for %s (%s) gave %d",
 		     what, hp->h_name, ntohs(caller->sin_port), path, epath, error);

--------------050208030400070104010400--


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
