From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils - 5 of 6 - mountd - defined debugging kinds....
Date: Wed, 18 Jun 2003 14:09:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF0AAEF.2080003@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050400090703030905070406"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ShMY-0003gi-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 11:08:50 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h5II8gK16826
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 14:08:42 -0400
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
--------------050400090703030905070406
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Defined the kinds of debugging that are available
with the -d flag to mountd

SteveD.

--------------050400090703030905070406
Content-Type: text/plain;
 name="nfs-utils-1.0.3-05-mountd.man.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.3-05-mountd.man.patch"

--- ./utils/mountd/mountd.man.org	Mon Apr  8 17:43:25 2002
+++ ./utils/mountd/mountd.man	Mon Jun  9 09:59:05 2003
@@ -56,7 +56,7 @@
 .SH OPTIONS
 .TP
 .B \-d kind " or " \-\-debug kind
-Turn on debugging for kind.
+Turn on debugging. Valid kinds are: all, auth, call, general and parse.
 .TP
 .B \-F " or " \-\-foreground
 Run in foreground (do not daemonize)

--------------050400090703030905070406--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
