From: Greg Banks <gnb@sgi.com>
Subject: [PATCH 2.6] mark NFS/TCP not EXPERIMENTAL
Date: Tue, 8 Jun 2004 11:29:06 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040608012906.GD22272@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXVQU-0002gc-Ed
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 18:29:18 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXVQT-00045q-Pk
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 18:29:17 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

G'day,

NFS/TCP has been used widely for a long time now, and is now  
enabled by many distros and typically recommended for lossy or
congested networks.  This patch removes the EXPERIMENTAL tag,
updates the help text, and changes arch defconfigs to set it
by default (note that several already did so).



Index: linux/arch/alpha/defconfig
===================================================================
--- linux.orig/arch/alpha/defconfig	Mon May 10 12:32:37 2004
+++ linux/arch/alpha/defconfig	Tue Jun  8 10:44:06 2004
@@ -791,7 +791,7 @@ CONFIG_NFS_V3=y
 CONFIG_NFSD=m
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=m
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=m
Index: linux/arch/i386/defconfig
===================================================================
--- linux.orig/arch/i386/defconfig	Mon May 10 12:32:53 2004
+++ linux/arch/i386/defconfig	Tue Jun  8 10:44:12 2004
@@ -1143,7 +1143,7 @@ CONFIG_NFS_FS=y
 # CONFIG_NFS_DIRECTIO is not set
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_EXPORTFS=y
 CONFIG_SUNRPC=y
Index: linux/arch/ia64/defconfig
===================================================================
--- linux.orig/arch/ia64/defconfig	Tue Jun  8 10:06:20 2004
+++ linux/arch/ia64/defconfig	Tue Jun  8 10:47:16 2004
@@ -987,7 +987,7 @@ CONFIG_NFS_DIRECTIO=y
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y
Index: linux/arch/ppc/defconfig
===================================================================
--- linux.orig/arch/ppc/defconfig	Tue Jun  8 10:06:23 2004
+++ linux/arch/ppc/defconfig	Tue Jun  8 10:44:23 2004
@@ -1230,7 +1230,7 @@ CONFIG_NFS_V3=y
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y
Index: linux/arch/s390/defconfig
===================================================================
--- linux.orig/arch/s390/defconfig	Tue Jun  8 10:06:23 2004
+++ linux/arch/s390/defconfig	Tue Jun  8 10:44:29 2004
@@ -425,7 +425,7 @@ CONFIG_NFS_V3=y
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y
Index: linux/fs/Kconfig
===================================================================
--- linux.orig/fs/Kconfig	Tue Jun  8 10:06:26 2004
+++ linux/fs/Kconfig	Tue Jun  8 10:40:21 2004
@@ -1450,11 +1450,13 @@ config NFSD_V4
 	  If unsure, say N.
 
 config NFSD_TCP
-	bool "Provide NFS server over TCP support (EXPERIMENTAL)"
-	depends on NFSD && EXPERIMENTAL
+	bool "Provide NFS server over TCP support"
+	depends on NFSD
+	default y
 	help
-	  Enable NFS service over TCP connections.  This the officially
-	  still experimental, but seems to work well.
+	  If you want your NFS server to support TCP connections, say Y here.
+	  TCP connections usually perform better than the default UDP when
+	  the network is lossy or congested.  If unsure, say Y.
 
 config ROOT_NFS
 	bool "Root file system on NFS"

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
