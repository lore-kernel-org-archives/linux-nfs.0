Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57766 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392Ab1DGQhs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 12:37:48 -0400
Received: by mail-iw0-f174.google.com with SMTP id 34so2629173iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Apr 2011 09:37:48 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFSROOT: Select default mount options via Kconfig
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 07 Apr 2011 12:37:46 -0400
Message-ID: <20110407163745.8531.71254.stgit@matisse.1015granger.net>
In-Reply-To: <20110407163304.8531.18745.stgit@matisse.1015granger.net>
References: <20110407163304.8531.18745.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The current NFSROOT default mount options are pretty ancient: NFS
version 2 and UDP are deprecated in many installations.

Because embedded relies on NFSROOT, this is a tricky area to change.
So, keep the legacy defaults, but provide more modern defaults as a
build-time option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/Kconfig   |   13 +++++++++++++
 fs/nfs/nfsroot.c |    4 ++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index ba30665..af744de 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -98,6 +98,19 @@ config ROOT_NFS
 
 	  Most people say N here.
 
+config ROOT_NFS_V3_DEFAULTS
+	bool "Use NFS version 3 and TCP for root file system"
+	depends on ROOT_NFS
+	default n
+	help
+	  The legacy default mount options for NFSROOT use NFS version 2
+	  and UDP.  These are deprecated, but some systems need to continue
+	  to use them as default.
+
+	  Everyone else can choose to use more modern mount options by
+	  default.  Select this option if your server, client, and network
+	  can handle NFS version 3 and TCP.
+
 config NFS_FSCACHE
 	bool "Provide NFS client caching support"
 	depends on NFS_FS=m && FSCACHE || NFS_FS=y && FSCACHE=y
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index c4744e1..9effe0d 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -87,7 +87,11 @@
 #define NFS_ROOT		"/tftpboot/%s"
 
 /* Default NFSROOT mount options. */
+#ifdef CONFIG_ROOT_NFS_V3_DEFAULTS
+#define NFS_DEF_OPTIONS		"vers=3,proto=tcp,mountproto=udp"
+#else
 #define NFS_DEF_OPTIONS		"vers=2,udp,rsize=4096,wsize=4096"
+#endif
 
 /* Parameters passed from the kernel command line */
 static char nfs_root_parms[256] __initdata = "";

