From: Greg Banks <gnb@sgi.com>
Subject: [PATCH 2.4] mark NFS/TCP not EXPERIMENTAL
Date: Tue, 8 Jun 2004 11:25:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040608012553.GC22272@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXVO7-0002Bt-88
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 18:26:51 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXVO6-0003TN-Jq
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 18:26:50 -0700
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

[a 2.6 version follows shortly]

Index: linux/Documentation/Configure.help
===================================================================
--- linux.orig/Documentation/Configure.help	Sun May 23 16:46:07 2004
+++ linux/Documentation/Configure.help	Tue Jun  8 10:52:17 2004
@@ -17055,10 +17055,11 @@ CONFIG_NFSD_V3
   If you would like to include the NFSv3 server as well as the NFSv2
   server, say Y here.  If unsure, say Y.
 
-Provide NFS over TCP server support EXPERIMENTAL
+Provide NFS over TCP server support
 CONFIG_NFSD_TCP
-  Enable NFS service over TCP connections.  This the officially
-  still experimental, but seems to work well.
+  If you want your NFS server to support TCP connections, say Y here.
+  TCP connections usually perform better than the default UDP when
+  the network is lossy or congested.  If unsure, say Y.
 
 OS/2 HPFS file system support
 CONFIG_HPFS_FS
Index: linux/arch/i386/defconfig
===================================================================
--- linux.orig/arch/i386/defconfig	Thu Apr 15 09:39:58 2004
+++ linux/arch/i386/defconfig	Tue Jun  8 10:54:16 2004
@@ -741,7 +741,7 @@ CONFIG_NFS_FS=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 # CONFIG_SMB_FS is not set
Index: linux/arch/ia64/defconfig
===================================================================
--- linux.orig/arch/ia64/defconfig	Sun May 23 16:46:06 2004
+++ linux/arch/ia64/defconfig	Tue Jun  8 10:54:23 2004
@@ -755,7 +755,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
Index: linux/arch/mips/defconfig
===================================================================
--- linux.orig/arch/mips/defconfig	Thu Feb 19 08:04:50 2004
+++ linux/arch/mips/defconfig	Tue Jun  8 10:54:29 2004
@@ -607,7 +607,7 @@ CONFIG_NFS_FS=y
 CONFIG_ROOT_NFS=y
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 # CONFIG_SMB_FS is not set
Index: linux/arch/mips64/defconfig
===================================================================
--- linux.orig/arch/mips64/defconfig	Thu Feb 19 08:04:52 2004
+++ linux/arch/mips64/defconfig	Tue Jun  8 10:54:35 2004
@@ -563,7 +563,7 @@ CONFIG_NFS_V3=y
 CONFIG_ROOT_NFS=y
 # CONFIG_NFSD is not set
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
Index: linux/arch/ppc/defconfig
===================================================================
--- linux.orig/arch/ppc/defconfig	Thu Feb 19 08:04:54 2004
+++ linux/arch/ppc/defconfig	Tue Jun  8 10:54:39 2004
@@ -812,7 +812,7 @@ CONFIG_NFS_FS=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 # CONFIG_SMB_FS is not set
Index: linux/arch/ppc64/defconfig
===================================================================
--- linux.orig/arch/ppc64/defconfig	Thu Feb 19 08:04:55 2004
+++ linux/arch/ppc64/defconfig	Tue Jun  8 10:54:44 2004
@@ -668,7 +668,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
Index: linux/arch/s390/defconfig
===================================================================
--- linux.orig/arch/s390/defconfig	Thu Feb 19 08:04:56 2004
+++ linux/arch/s390/defconfig	Tue Jun  8 10:54:50 2004
@@ -351,7 +351,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
Index: linux/arch/s390x/defconfig
===================================================================
--- linux.orig/arch/s390x/defconfig	Thu Feb 19 08:04:56 2004
+++ linux/arch/s390x/defconfig	Tue Jun  8 10:54:54 2004
@@ -291,7 +291,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
Index: linux/arch/sh64/defconfig
===================================================================
--- linux.orig/arch/sh64/defconfig	Thu Feb 19 08:04:56 2004
+++ linux/arch/sh64/defconfig	Tue Jun  8 10:54:59 2004
@@ -386,7 +386,7 @@ CONFIG_NFS_V3=y
 CONFIG_ROOT_NFS=y
 # CONFIG_NFSD is not set
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
Index: linux/fs/Config.in
===================================================================
--- linux.orig/fs/Config.in	Sun May 23 16:46:06 2004
+++ linux/fs/Config.in	Tue Jun  8 10:51:01 2004
@@ -132,7 +132,7 @@ if [ "$CONFIG_NET" = "y" ]; then
 
    dep_tristate 'NFS server support' CONFIG_NFSD $CONFIG_INET
    dep_mbool '  Provide NFSv3 server support' CONFIG_NFSD_V3 $CONFIG_NFSD
-   dep_mbool '  Provide NFS server over TCP support (EXPERIMENTAL)' CONFIG_NFSD_TCP $CONFIG_NFSD $CONFIG_EXPERIMENTAL
+   dep_mbool '  Provide NFS server over TCP support' CONFIG_NFSD_TCP $CONFIG_NFSD
 
    if [ "$CONFIG_NFS_FS" = "y" -o "$CONFIG_NFSD" = "y" ]; then
       define_tristate CONFIG_SUNRPC y


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
