From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 1 of 10  - Removed sync warning on readonly exports
Date: Fri, 23 Sep 2005 10:44:13 -0400
Message-ID: <433414BD.5080209@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070106020303080504080908"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIoml-0005mH-2K
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:44:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIomj-0002NF-MA
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:44:23 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEiEvs013933
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:44:14 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEiEV12556
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:44:14 -0400
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
--------------070106020303080504080908
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The following 10 patches are a result of bugs that were reported
to us and have been fixed in various Red Hat releases.
I'm hopeful that at least some of them will incorporated into
the SourceForge CVS tree....

steved.



--------------070106020303080504080908
Content-Type: text/x-patch;
 name="nfs-utils-1.0.6-expwarn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-expwarn.patch"

Removed sync warning on readonly exports.

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- src/support/nfs/exports.c.org	2003-08-06 01:19:42.000000000 -0400
+++ src/support/nfs/exports.c	2004-06-14 06:48:29.000000000 -0400
@@ -442,7 +442,7 @@ bad_option:
 	ep->e_nsqgids = nsqgids;
 
 out:
-	if (warn && !had_sync_opt)
+	if (warn && !had_sync_opt && !(ep->e_flags & NFSEXP_READONLY))
 		xlog(L_WARNING, "%s [%d]: No 'sync' or 'async' option specified for export \"%s:%s\".\n"
 				"  Assuming default behaviour ('sync').\n"
 		     		"  NOTE: this default has changed from previous versions\n",

--------------070106020303080504080908--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
