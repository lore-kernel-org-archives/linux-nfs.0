From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 34 of 34 - make sure sunrpc init routines called before gss init routines.
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006Le-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPsQ-000782-09
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:52:42 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPgR-0002a9-5y
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:40:19 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:43 +1100
To: Andrew Morton <akpm@osdl.org>
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


 ----------- Diffstat output ------------
 ./net/sunrpc/Makefile |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./net/sunrpc/Makefile~current~ ./net/sunrpc/Makefile
--- ./net/sunrpc/Makefile~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/Makefile	2004-02-24 10:42:37.000000000 +1100
@@ -2,9 +2,9 @@
 # Makefile for Linux kernel SUN RPC
 #
 
-obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
 
 obj-$(CONFIG_SUNRPC) += sunrpc.o
+obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
 
 sunrpc-y := clnt.o xprt.o sched.o \
 	    auth.o auth_null.o auth_unix.o \


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
