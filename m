From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - 6 of 6 - mountd - ignore sigpipe
Date: Wed, 18 Jun 2003 14:13:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF0ABC6.2030302@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050902070603000006080909"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ShPz-00053y-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 11:12:23 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h5IICHK17042
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 14:12:17 -0400
To: nfs@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------050902070603000006080909
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch makes mountd ignore SIGPIPE. If forget exactly
how a SIGPIPE can be generated, but was being generated
which in turn was kill mountd...

SteveD.


--------------050902070603000006080909
Content-Type: text/plain;
 name="nfs-utils-1.0.3-06-mountd.sigpipe.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.3-06-mountd.sigpipe.patch"

--- ./utils/mountd/mountd.c.orig	2003-02-18 23:25:04.000000000 -0500
+++ ./utils/mountd/mountd.c	2003-06-02 15:13:37.000000000 -0400
@@ -481,6 +481,7 @@ main(int argc, char **argv)
 	sigaction(SIGHUP, &sa, NULL);
 	sigaction(SIGINT, &sa, NULL);
 	sigaction(SIGTERM, &sa, NULL);
+	sigaction(SIGPIPE, &sa, NULL);
 	/* WARNING: the following works on Linux and SysV, but not BSD! */
 	sigaction(SIGCHLD, &sa, NULL);
 

--------------050902070603000006080909--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
