Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:54538 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700Ab0IJUEG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:04:06 -0400
Received: by gwj17 with SMTP id 17so1310620gwj.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:04:05 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] NFS: Allow NFSROOT debugging messages to be enabled
	dynamically
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:04:02 -0400
Message-ID: <20100910200401.13167.1195.stgit@seurat.1015granger.net>
In-Reply-To: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
References: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

As a convenience, introduce a kernel command line option to enable
NFSROOT debugging messages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Documentation/filesystems/nfs/nfsroot.txt |   22 ++++++++++++++++++++++
 Documentation/kernel-parameters.txt       |    5 ++++-
 fs/nfs/nfsroot.c                          |   19 +++++++++++++------
 3 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
index f2430a7..90c71c6 100644
--- a/Documentation/filesystems/nfs/nfsroot.txt
+++ b/Documentation/filesystems/nfs/nfsroot.txt
@@ -159,6 +159,28 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
                 Default: any
 
 
+nfsrootdebug
+
+  This parameter enables debugging messages to appear in the kernel
+  log at boot time so that administrators can verify that the correct
+  NFS mount options, server address, and root path are passed to the
+  NFS client.
+
+
+rdinit=<executable file>
+
+  To specify which file contains the program that starts system
+  initialization, administrators can use this command line parameter.
+  The default value of this parameter is "/init".  If the specified
+  file exists and the kernel can execute it, root filesystem related
+  kernel command line parameters, including `nfsroot=', are ignored.
+
+  A description of the process of mounting the root file system can be
+  found in:
+
+    Documentation/early-userspace/README
+
+
 
 
 3.) Boot Loader
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index f084af0..0fe70b2 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1532,12 +1532,15 @@ and is between 256 and 4096 characters. It is defined in the file
 			1 to enable accounting
 			Default value is 0.
 
-	nfsaddrs=	[NFS]
+	nfsaddrs=	[NFS] Deprecated.  Use ip= instead.
 			See Documentation/filesystems/nfs/nfsroot.txt.
 
 	nfsroot=	[NFS] nfs root filesystem for disk-less boxes.
 			See Documentation/filesystems/nfs/nfsroot.txt.
 
+	nfsrootdebug	[NFS] enable nfsroot debugging messages.
+			See Documentation/filesystems/nfs/nfsroot.txt.
+
 	nfs.callback_tcpport=
 			[NFS] set the TCP port on which the NFSv4 callback
 			channel should listen.
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 8e7d623..460df36 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -67,6 +67,7 @@
  *				NFS over TCP.
  *	Fabian Frederick:	Option parser rebuilt (using parser lib)
  *	Chuck Lever	:	Use super.c's text-based mount option parsing
+ *	Chuck Lever	:	Add "nfsrootdebug".
  */
 
 #include <linux/types.h>
@@ -80,8 +81,6 @@
 
 #include "internal.h"
 
-/* Define this to allow debugging output */
-#undef NFSROOT_DEBUG
 #define NFSDBG_FACILITY NFSDBG_ROOT
 
 /* Default path we try to mount. "%s" gets replaced by our IP address */
@@ -103,6 +102,18 @@ static char nfs_export_path[NFS_MAXPATHLEN + 1] __initdata = "";
 static char nfs_root_device[NFS_MAXPATHLEN + 1] __initdata = "";
 
 /*
+ * When the "nfsrootdebug" kernel command line option is specified,
+ * enable debugging messages for NFSROOT.
+ */
+static int __init nfs_root_debug(char *__unused)
+{
+	nfs_debug |= NFSDBG_ROOT | NFSDBG_MOUNT;
+	return 1;
+}
+
+__setup("nfsrootdebug", nfs_root_debug);
+
+/*
  *  Parse NFS server and directory information passed on the kernel
  *  command line.
  *
@@ -282,10 +293,6 @@ out_devnametoolong:
  */
 int __init nfs_root_data(char **root_device, char **root_data)
 {
-#ifdef NFSROOT_DEBUG
-	nfs_debug |= NFSDBG_ROOT | NFSDBG_MOUNT;
-#endif	/* NFSROOT_DEBUG */
-
 	servaddr = root_server_addr;
 	if (servaddr == htonl(INADDR_NONE)) {
 		printk(KERN_ERR "Root-NFS: no NFS server address\n");

