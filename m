From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] NFS: Allow NFSROOT debugging messages to be enabled
	dynamically
Date: Tue, 11 May 2010 13:17:01 -0400
Message-ID: <20100511171700.2167.97198.stgit@matisse.1015granger.net>
References: <20100511170754.2167.72681.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:60854 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756532Ab0EKRRF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 13:17:05 -0400
Received: by mail-qy0-f183.google.com with SMTP id 13so8473395qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 10:17:04 -0700 (PDT)
In-Reply-To: <20100511170754.2167.72681.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As a convenience, introduce a kernel command line option to enable
NFSROOT debugging messages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Documentation/filesystems/nfs/nfsroot.txt |   22 ++++++++++++++++++++++
 Documentation/kernel-parameters.txt       |    5 ++++-
 fs/nfs/nfsroot.c                          |   19 +++++++++++++------
 3 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
index 3ba0b94..adc2248 100644
--- a/Documentation/filesystems/nfs/nfsroot.txt
+++ b/Documentation/filesystems/nfs/nfsroot.txt
@@ -157,6 +157,28 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
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
index 839b21b..26044a3 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1565,12 +1565,15 @@ and is between 256 and 4096 characters. It is defined in the file
 			Default value depends on CONFIG_NF_CT_ACCT that is
 			going to be removed in 2.6.29.
 
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
index 51be225..b543122 100644
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
@@ -103,6 +102,18 @@ static char nfs_export_path[NFS_MAXPATHLEN] __initdata = "";
 static char nfs_root_device[NFS_MAXPATHLEN] __initdata = "";
 
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

