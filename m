From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.6 patch] select for fs/Kconfig
Date: Sun, 28 Sep 2003 17:18:39 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030928151839.GG15338@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>,
	David Howells <dhowells@redhat.com>,
	David Woodhouse <dwmw2@cambridge.redhat.com>
List-ID: <nfs.lists.sourceforge.net>

The patch below switches fs/Kconfig to use select where appropriate=20
(affects nfs{,d} and afs).

diffstat output:
=FA
 fs/Kconfig |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)
=20

cu
Adrian

--- linux-2.6.0-test6-full/fs/Kconfig.old	2003-09-28 16:12:39.000000000=
 +0200
+++ linux-2.6.0-test6-full/fs/Kconfig	2003-09-28 16:20:56.000000000 +02=
00
@@ -1253,8 +1253,10 @@
=20
 config NFS_FS
 	tristate "NFS file system support"
 	depends on INET
+	select LOCKD
+	select SUNRPC
 	help
 	  If you are connected to some other (usually local) Unix computer
 	  (using SLIP, PLIP, PPP or Ethernet) and want to mount files residin=
g
 	  on that computer (the NFS server) using the Network File Sharing
@@ -1308,8 +1310,10 @@
=20
 config NFSD
 	tristate "NFS server support"
 	depends on INET
+	select LOCKD
+	select SUNRPC
 	help
 	  If you want your Linux box to act as an NFS *server*, so that other
 	  computers on your local network which support NFS can access certai=
n
 	  directories on your box transparently, you have two options: you ca=
n
@@ -1370,10 +1374,8 @@
 	  Most people say N here.
=20
 config LOCKD
 	tristate
-	default m if NFS_FS!=3Dy && NFSD!=3Dy && (NFS_FS=3Dm || NFSD=3Dm)
-	default y if NFS_FS=3Dy || NFSD=3Dy
=20
 config LOCKD_V4
 	bool
 	depends on NFSD_V3 || NFS_V3
@@ -1384,10 +1386,8 @@
 	default NFSD
=20
 config SUNRPC
 	tristate
-	default m if NFS_FS!=3Dy && NFSD!=3Dy && (NFS_FS=3Dm || NFSD=3Dm)
-	default y if NFS_FS=3Dy || NFSD=3Dy
=20
 config SUNRPC_GSS
 	tristate "Provide RPCSEC_GSS authentication (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
@@ -1564,8 +1564,9 @@
 config AFS_FS
 # for fs/nls/Config.in
 	tristate "Andrew File System support (AFS) (Experimental)"
 	depends on INET && EXPERIMENTAL
+	select RXRPC
 	help
 	  If you say Y here, you will get an experimental Andrew File System
 	  driver. It currently only supports unsecured read-only AFS access.
=20
@@ -1574,10 +1575,8 @@
 	  If unsure, say N.
=20
 config RXRPC
 	tristate
-	default m if AFS_FS=3Dm
-	default y if AFS_FS=3Dy
=20
 endmenu
=20
 menu "Partition Types"
