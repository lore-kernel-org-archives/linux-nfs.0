Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57177 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1DTR2e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:28:34 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 18/27] pnfs-obj: Define PNFS_OBJLAYOUT Kconfig option
Date: Wed, 20 Apr 2011 20:28:32 +0300
Message-Id: <1303320512-21639-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

* Define the PNFS_OBJLAYOUT Kconfig option in the nfs
  master Kconfig file.
* Add the objlayout driver to the Kernel's Kbuild system.
* Add the fs/nfs/objlayout/Kbuild file for building the
  objlayoutdriver.ko driver

[pnfs-obj: remove of CONFIG_PNFS fallout]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[added "unsure" clause]
[depend on NFS_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig          |   10 ++++++++++
 fs/nfs/Makefile         |    2 ++
 fs/nfs/objlayout/Kbuild |    5 +++++
 3 files changed, 17 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/objlayout/Kbuild

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index ba30665..8151554 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -87,6 +87,16 @@ config NFS_V4_1
 config PNFS_FILE_LAYOUT
 	tristate
 
+config PNFS_OBJLAYOUT
+	tristate "Provide support for the pNFS Objects Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
+	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
+	help
+	  Say M here if you want your pNFS client to support the Objects Layout Driver.
+	  Requires the SCSI osd initiator library (SCSI_OSD_INITIATOR) and
+	  upper level driver (SCSI_OSD_ULD).
+
+	  If unsure, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 4776ff9..c9574f0 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -21,3 +21,5 @@ nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
+
+obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
diff --git a/fs/nfs/objlayout/Kbuild b/fs/nfs/objlayout/Kbuild
new file mode 100644
index 0000000..c326738
--- /dev/null
+++ b/fs/nfs/objlayout/Kbuild
@@ -0,0 +1,5 @@
+#
+# Makefile for the pNFS Objects Layout Driver kernel module
+#
+objlayoutdriver-y := pnfs_osd_xdr_cli.o
+obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayoutdriver.o
-- 
1.7.3.4

