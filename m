From: Tero Pelander <tpeland@tkukoulu.fi>
Subject: minor correction to configure
Date: Thu, 20 Feb 2003 14:17:40 +0200 (EET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.53.0302201413180.22268@roope.top.tkukoulu.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from roope.top.tkukoulu.fi ([192.103.98.2])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lpe5-0002EJ-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 04:17:45 -0800
Received: from localhost (localhost [127.0.0.1])
	by localhost (Postfix) with ESMTP id ED6686
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 14:17:40 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by roope.top.tkukoulu.fi (Postfix) with ESMTP id BAA496
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 14:17:40 +0200 (EET)
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

To make --exec-prefix option work correctly.

--- nfs-utils-cvs/config.mk.in.OLD	2003-02-20 14:07:04.000000000 +0200
+++ nfs-utils-cvs/config.mk.in	2003-02-20 14:09:48.000000000 +0200
@@ -5,7 +5,7 @@
 VERSION		= nfs-utils @VERSION@
 
 prefix		= $(install_prefix)@prefix@
-exec_prefix	= $(install_prefix)@prefix@
+exec_prefix	= $(install_prefix)@exec_prefix@
 BINDIR		= @bindir@
 SBINDIR		= @sbindir@
 MANDIR		= @mandir@


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
