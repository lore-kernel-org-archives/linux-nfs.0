From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH 5/5] initial changes for NFS-over-IPv6
 (linux-2.5.66-NFS_IPv6-Kconfig.dif)
Date: 11 Apr 2003 16:36:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1050104161.1413.282.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bwa@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 194841-0006bE-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 16:36:09 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.9/8.12.2) with ESMTP id h3BNYkQs165330
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 19:34:46 -0400
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

This patch against 2.5.66 provides for configuration of the kernel to
utilize code and data structures which interact with user-space
libraries, utilities and daemons which do not yet have IPv6 support. 
Please see the note regarding this in the email originating this thread.

diff -Naurp linux-2.5.66/fs/Kconfig linux-2.5.66-NFS_IPV6/fs/Kconfig
--- linux-2.5.66/fs/Kconfig	2003-03-24 14:00:48.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/Kconfig	2003-04-10 16:50:49.000000000 -0700
@@ -1329,6 +1329,17 @@ config NFSD_TCP
 	  Enable NFS service over TCP connections.  This the officially
 	  still experimental, but seems to work well.
 
+config NFS_IPV6
+	bool "Provide NFS over IPv6 support (EXPERIMENTAL)"
+	depends on (NFS_FS || NFSD) && IPV6 && EXPERIMENTAL
+	help
+	  Say Y here if you want NFS to be able to run over an IPv6 network.
+          This feature is experimental, and you must have versions of the
+          user-space daemons and utilities (eg. nfs-utils, portmap, mount,
+          glibc) which support RPC over IPv6.
+
+	  If unsure, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP

-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
