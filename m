From: Thomas Reifferscheid <reiffer@kph.uni-mainz.de>
Subject: Patch for 2.4.20pre11/fs/filesystems.c
Date: Fri, 25 Oct 2002 14:58:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DB93FE9.F0B50FA7@kph.uni-mainz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailout02.sul.t-online.com ([194.25.134.17])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18542p-0001h4-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 05:58:32 -0700
Received: from kph.uni-mainz.de (thomas.at.home.org [192.168.0.225])
	by debian.at.home.org (Postfix) with ESMTP id 3E8B293360
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 14:58:18 +0200 (CEST)
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

When I do

CONFIG_NFS_FS=m
# CONFIG_NFS_V3 is not set
# CONFIG_ROOT_NFS is not set
CONFIG_NFSD=m
# CONFIG_NFSD_V3 is not set
# CONFIG_NFSD_TCP is not set
# CONFIG_NCPFS_NFS_NS is not set


and want to insert the module I get:

unresolved symbol nfsd_linkage

which already was described by Jean-Luc Fontaine in 
http://marc.theaimsgroup.com/?l=linux-kernel&m=98173746131993&w=2

Where as I do:

CONFIG_NFS_FS=m
# CONFIG_NFS_V3 is not set
# CONFIG_ROOT_NFS is not set
CONFIG_NFSD=y
# CONFIG_NFSD_V3 is not set
# CONFIG_NFSD_TCP is not set
# CONFIG_NCPFS_NFS_NS is not set

everything works pretty fine.


You can see some changes have been made here: 
http://groups.google.de/groups?q=filesystems.c+torvalds&hl=de&lr=&ie=UTF-8&selm=nfs-valinux.15468.35577.461935.694932%40notabene.cse.unsw.edu.au&rnum=1


My patch does solve this and works for me.

Cheers,
Thomas


--- linux-2.4.20pre11-orig/fs/filesystems.c     Sat Aug  3 02:39:45 2002
+++ linux-2.4.20pre11/fs/filesystems.c  Fri Oct 25 04:44:15 2002
@@ -13,7 +13,7 @@
 #include <linux/kmod.h>
 #include <linux/nfsd/interface.h>
 
-#if ! defined(CONFIG_NFSD)
+#if ! defined(CONFIG_NFSD) || defined(CONFIG_NFSD_MODULE)
 struct nfsd_linkage *nfsd_linkage;
 
 long


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
