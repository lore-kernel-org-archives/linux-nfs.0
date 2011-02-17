Return-Path: <linux-nfs-owner@vger.kernel.org>
Message-Id: <4D5D36CA0200007800032664@vpn.id2.novell.com>
Date: Thu, 17 Feb 2011 13:55:06 +0000
From: "Jan Beulich" <JBeulich@novell.com>
To: <Trond.Myklebust@netapp.com>
Cc: <linux-kbuild@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] re-order and improve fs/nfs/Kconfig
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

To maintain menu hierarchy, options depending on NFS_V4 should directly
follow that parent option.

The either-or selection of which DNS resolver to use can be done more
cleanly using a choice.

For DNS_RESOLVER to be selected to 'm' (instead of 'y') when NFS_FS=m,
the "select" must be moved up (and made conditional).

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 fs/nfs/Kconfig |   61 +++++++++++++++++++++++++++++----------------------------
 1 file changed, 32 insertions(+), 29 deletions(-)

--- 2.6.38-rc5/fs/nfs/Kconfig
+++ 2.6.38-rc5-kconfig-nfs/fs/nfs/Kconfig
@@ -64,6 +64,7 @@ config NFS_V4
 	bool "NFS client support for NFS version 4"
 	depends on NFS_FS
 	select SUNRPC_GSS
+	select DNS_RESOLVER if NFS_USE_KERNEL_DNS
 	help
 	  This option enables support for version 4 of the NFS protocol
 	  (RFC 3530) in the kernel's NFS client.
@@ -74,9 +75,39 @@ config NFS_V4
 
 	  If unsure, say Y.
 
+choice
+	prompt "NFS DNS resolver"
+	default NFS_USE_KERNEL_DNS
+	depends on NFS_V4
+	help
+	  The kernel now provides a method for translating a host name into an
+	  IP address.  Select the first option if you would rather use your
+	  own DNS resolver script.
+
+config NFS_USE_LEGACY_DNS
+	bool "Use the legacy NFS DNS resolver"
+	help
+
+config NFS_USE_KERNEL_DNS
+	bool "Use the in-kernel DNS resolver"
+	select KEYS
+
+endchoice
+
+config NFS_USE_NEW_IDMAPPER
+	bool "Use the new idmapper upcall routine"
+	depends on NFS_V4 && KEYS
+	help
+	  Say Y here if you want NFS to use the new idmapper upcall functions.
+	  You will need /sbin/request-key (usually provided by the keyutils
+	  package).  For details, read
+	  <file:Documentation/filesystems/nfs/idmapper.txt>.
+
+	  If you are unsure, say N.
+
 config NFS_V4_1
 	bool "NFS client support for NFSv4.1 (EXPERIMENTAL)"
-	depends on NFS_FS && NFS_V4 && EXPERIMENTAL
+	depends on NFS_V4 && EXPERIMENTAL
 	select PNFS_FILE_LAYOUT
 	help
 	  This option enables support for minor version 1 of the NFSv4 protocol
@@ -104,31 +135,3 @@ config NFS_FSCACHE
 	help
 	  Say Y here if you want NFS data to be cached locally on disc through
 	  the general filesystem cache manager
-
-config NFS_USE_LEGACY_DNS
-	bool "Use the legacy NFS DNS resolver"
-	depends on NFS_V4
-	help
-	  The kernel now provides a method for translating a host name into an
-	  IP address.  Select Y here if you would rather use your own DNS
-	  resolver script.
-
-	  If unsure, say N
-
-config NFS_USE_KERNEL_DNS
-	bool
-	depends on NFS_V4 && !NFS_USE_LEGACY_DNS
-	select DNS_RESOLVER
-	select KEYS
-	default y
-
-config NFS_USE_NEW_IDMAPPER
-	bool "Use the new idmapper upcall routine"
-	depends on NFS_V4 && KEYS
-	help
-	  Say Y here if you want NFS to use the new idmapper upcall functions.
-	  You will need /sbin/request-key (usually provided by the keyutils
-	  package).  For details, read
-	  <file:Documentation/filesystems/nfs/idmapper.txt>.
-
-	  If you are unsure, say N.



