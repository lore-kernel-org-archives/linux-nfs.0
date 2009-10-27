From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfs: new subdir Documentation/filesystems/nfs
Date: Tue, 27 Oct 2009 15:09:38 -0400
Message-ID: <20091027190938.GD7639@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any objections to moving nfs-related documentation to a new subdirectory
of Documentation/filesystems/?

--b.

diff --git a/Documentation/filesystems/00-INDEX b/Documentation/filesystems/00-INDEX
index f15621e..482151c 100644
--- a/Documentation/filesystems/00-INDEX
+++ b/Documentation/filesystems/00-INDEX
@@ -1,7 +1,5 @@
 00-INDEX
 	- this file (info on some of the filesystems supported by linux).
-Exporting
-	- explanation of how to make filesystems exportable.
 Locking
 	- info on locking rules as they pertain to Linux VFS.
 9p.txt
@@ -66,12 +64,8 @@ mandatory-locking.txt
 	- info on the Linux implementation of Sys V mandatory file locking.
 ncpfs.txt
 	- info on Novell Netware(tm) filesystem using NCP protocol.
-nfs41-server.txt
-	- info on the Linux server implementation of NFSv4 minor version 1.
-nfs-rdma.txt
-	- how to install and setup the Linux NFS/RDMA client and server software.
-nfsroot.txt
-	- short guide on setting up a diskless box with NFS root filesystem.
+nfs/
+	- nfs-related documentation.
 nilfs2.txt
 	- info and mount options for the NILFS2 filesystem.
 ntfs.txt
diff --git a/Documentation/filesystems/nfs/00-INDEX b/Documentation/filesystems/nfs/00-INDEX
new file mode 100644
index 0000000..6ff3d21
--- /dev/null
+++ b/Documentation/filesystems/nfs/00-INDEX
@@ -0,0 +1,12 @@
+00-INDEX
+	- this file (nfs-related documentation).
+Exporting
+	- explanation of how to make filesystems exportable.
+nfs.txt
+	- nfs client, and DNS resolution for fs_locations.
+nfs41-server.txt
+	- info on the Linux server implementation of NFSv4 minor version 1.
+nfs-rdma.txt
+	- how to install and setup the Linux NFS/RDMA client and server software
+nfsroot.txt
+	- short guide on setting up a diskless box with NFS root filesystem.
diff --git a/Documentation/filesystems/Exporting b/Documentation/filesystems/nfs/Exporting
similarity index 100%
rename from Documentation/filesystems/Exporting
rename to Documentation/filesystems/nfs/Exporting
diff --git a/Documentation/filesystems/nfs-rdma.txt b/Documentation/filesystems/nfs/nfs-rdma.txt
similarity index 100%
rename from Documentation/filesystems/nfs-rdma.txt
rename to Documentation/filesystems/nfs/nfs-rdma.txt
diff --git a/Documentation/filesystems/nfs.txt b/Documentation/filesystems/nfs/nfs.txt
similarity index 100%
rename from Documentation/filesystems/nfs.txt
rename to Documentation/filesystems/nfs/nfs.txt
diff --git a/Documentation/filesystems/nfs41-server.txt b/Documentation/filesystems/nfs/nfs41-server.txt
similarity index 100%
rename from Documentation/filesystems/nfs41-server.txt
rename to Documentation/filesystems/nfs/nfs41-server.txt
diff --git a/Documentation/filesystems/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
similarity index 100%
rename from Documentation/filesystems/nfsroot.txt
rename to Documentation/filesystems/nfs/nfsroot.txt
diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index 92b888d..a7e9746 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -140,7 +140,7 @@ Callers of notify_change() need ->i_mutex now.
 New super_block field "struct export_operations *s_export_op" for
 explicit support for exporting, e.g. via NFS.  The structure is fully
 documented at its declaration in include/linux/fs.h, and in
-Documentation/filesystems/Exporting.
+Documentation/filesystems/nfs/Exporting.
 
 Briefly it allows for the definition of decode_fh and encode_fh operations
 to encode and decode filehandles, and allows the filesystem to use
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 6fa7292..afb250c 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1016,7 +1016,7 @@ and is between 256 and 4096 characters. It is defined in the file
 			No delay
 
 	ip=		[IP_PNP]
-			See Documentation/filesystems/nfsroot.txt.
+			See Documentation/filesystems/nfs/nfsroot.txt.
 
 	ip2=		[HW] Set IO/IRQ pairs for up to 4 IntelliPort boards
 			See comment before ip2_setup() in
@@ -1537,10 +1537,10 @@ and is between 256 and 4096 characters. It is defined in the file
 			going to be removed in 2.6.29.
 
 	nfsaddrs=	[NFS]
-			See Documentation/filesystems/nfsroot.txt.
+			See Documentation/filesystems/nfs/nfsroot.txt.
 
 	nfsroot=	[NFS] nfs root filesystem for disk-less boxes.
-			See Documentation/filesystems/nfsroot.txt.
+			See Documentation/filesystems/nfs/nfsroot.txt.
 
 	nfs.callback_tcpport=
 			[NFS] set the TCP port on which the NFSv4 callback
diff --git a/fs/cifs/export.c b/fs/cifs/export.c
index 75949d6..6177f7c 100644
--- a/fs/cifs/export.c
+++ b/fs/cifs/export.c
@@ -24,7 +24,7 @@
  */
 
  /*
-  * See Documentation/filesystems/Exporting
+  * See Documentation/filesystems/nfs/Exporting
   * and examples in fs/exportfs
   *
   * Since cifs is a network file system, an "fsid" must be included for
diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 197c7db..e9e1759 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -6,7 +6,7 @@
  * and for mapping back from file handles to dentries.
  *
  * For details on why we do all the strange and hairy things in here
- * take a look at Documentation/filesystems/Exporting.
+ * take a look at Documentation/filesystems/nfs/Exporting.
  */
 #include <linux/exportfs.h>
 #include <linux/fs.h>
diff --git a/fs/isofs/export.c b/fs/isofs/export.c
index e81a305..ed752cb 100644
--- a/fs/isofs/export.c
+++ b/fs/isofs/export.c
@@ -9,7 +9,7 @@
  *
  * The following files are helpful:
  *
- *     Documentation/filesystems/Exporting
+ *     Documentation/filesystems/nfs/Exporting
  *     fs/exportfs/expfs.c.
  */
 
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 2a77bc2..59e5673 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -90,7 +90,7 @@ config ROOT_NFS
 	  If you want your system to mount its root file system via NFS,
 	  choose Y here.  This is common practice for managing systems
 	  without local permanent storage.  For details, read
-	  <file:Documentation/filesystems/nfsroot.txt>.
+	  <file:Documentation/filesystems/nfs/nfsroot.txt>.
 
 	  Most people say N here.
 
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 27e772c..dc12f41 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -97,7 +97,7 @@ struct fid {
  * @get_name:       find the name for a given inode in a given directory
  * @get_parent:     find the parent of a given directory
  *
- * See Documentation/filesystems/Exporting for details on how to use
+ * See Documentation/filesystems/nfs/Exporting for details on how to use
  * this interface correctly.
  *
  * encode_fh:
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 70491d9..0c94a1a 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -166,7 +166,7 @@ config IP_PNP_DHCP
 
 	  If unsure, say Y. Note that if you want to use DHCP, a DHCP server
 	  must be operating on your network.  Read
-	  <file:Documentation/filesystems/nfsroot.txt> for details.
+	  <file:Documentation/filesystems/nfs/nfsroot.txt> for details.
 
 config IP_PNP_BOOTP
 	bool "IP: BOOTP support"
@@ -181,7 +181,7 @@ config IP_PNP_BOOTP
 	  does BOOTP itself, providing all necessary information on the kernel
 	  command line, you can say N here. If unsure, say Y. Note that if you
 	  want to use BOOTP, a BOOTP server must be operating on your network.
-	  Read <file:Documentation/filesystems/nfsroot.txt> for details.
+	  Read <file:Documentation/filesystems/nfs/nfsroot.txt> for details.
 
 config IP_PNP_RARP
 	bool "IP: RARP support"
@@ -194,7 +194,7 @@ config IP_PNP_RARP
 	  older protocol which is being obsoleted by BOOTP and DHCP), say Y
 	  here. Note that if you want to use RARP, a RARP server must be
 	  operating on your network. Read
-	  <file:Documentation/filesystems/nfsroot.txt> for details.
+	  <file:Documentation/filesystems/nfs/nfsroot.txt> for details.
 
 # not yet ready..
 #   bool '    IP: ARP support' CONFIG_IP_PNP_ARP
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index f8d04c2..7dcbf47 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1447,7 +1447,7 @@ late_initcall(ip_auto_config);
 
 /*
  *  Decode any IP configuration options in the "ip=" or "nfsaddrs=" kernel
- *  command line parameter.  See Documentation/filesystems/nfsroot.txt.
+ *  command line parameter.  See Documentation/filesystems/nfs/nfsroot.txt.
  */
 static int __init ic_proto_name(char *name)
 {
