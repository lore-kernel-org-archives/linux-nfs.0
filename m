From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: [PATCH] various minor manpage fixes
Date: Mon, 20 Nov 2006 23:47:52 +0100
Message-ID: <20061120224752.GA13561@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmHwo-0006cU-R7
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 14:49:06 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmHwp-0003tD-GO
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 14:49:08 -0800
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1GmHwn-0007Jq-31
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 23:49:05 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1GmHvc-0003Xc-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Nov 2006 23:47:52 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

Here's another patch that has been sitting in our tree for a while, which
should probably go in upstream. Changelog:

=== snip ===
Author: Steinar H. Gunderson <sesse@debian.org>
Date:   Mon, 20 Nov 2006 23:46:32 +0100

    Use memset instead of __bzero. bzero has been deprecated
    for years (and anything starting with __ is an internal
    function anyhow), and __bzero seems to have broken on ia64
    not too long ago.
=== snip ===

diff -ur nfs-utils-1.0.10.orig/support/nfs/svc_socket.c nfs-utils-1.0.10/support/nfs/svc_socket.c
--- nfs-utils-1.0.10.orig/support/nfs/svc_socket.c	2006-08-07 08:40:50.000000000 +0200
+++ nfs-utils-1.0.10/support/nfs/svc_socket.c	2006-11-20 23:46:05.000000000 +0100
@@ -64,7 +64,7 @@
 	}
     }
 
-  __bzero ((char *) &addr, sizeof (addr));
+  memset (&addr, 0, sizeof (addr));
   addr.sin_family = AF_INET;
 
   ret = getrpcbynumber_r (number, &rpcbuf, rpcdata, sizeof rpcdata,

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
