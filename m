From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils - Silencing mountd
Date: Fri, 18 Jun 2004 09:02:45 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40D2E7F5.3060402@RedHat.com>
References: <40D063D1.9010208@RedHat.com> <20040616224504.GB29503@sgi.com> <40D1EA4A.6080002@RedHat.com> <20040617221347.GC31781@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090301080801000701000906"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BbJ0k-0002bg-7a
	for nfs@lists.sourceforge.net; Fri, 18 Jun 2004 06:02:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BbJ0j-0008FA-Oj
	for nfs@lists.sourceforge.net; Fri, 18 Jun 2004 06:02:25 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i5ID2Ie1024472
	for <nfs@lists.sourceforge.net>; Fri, 18 Jun 2004 09:02:18 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i5ID2I017147
	for <nfs@lists.sourceforge.net>; Fri, 18 Jun 2004 09:02:18 -0400
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i5ID2HF10991
	for <nfs@lists.sourceforge.net>; Fri, 18 Jun 2004 09:02:17 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20040617221347.GC31781@sgi.com>
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
--------------090301080801000701000906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ok, here is the patch with the "authenticated message" put
back... It turns out the message is more useful than I though...

SteveD.


--------------090301080801000701000906
Content-Type: text/plain;
 name="nfs-utils-1.0.6-mountd-nonverbose2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-mountd-nonverbose2.patch"

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
 

--------------090301080801000701000906--


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
