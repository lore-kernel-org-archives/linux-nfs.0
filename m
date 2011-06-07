Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52922 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab1FGR1H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:07 -0400
Date: Tue, 7 Jun 2011 13:27:04 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 10/88] pnfsblock: define PNFS_BLOCK Kconfig option
Message-ID: <6d8d3b9723e497188fbfe4603d258b3986a059d7.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Define a configuration variable to enable/disable compilation of the
block driver code.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs-block: fix CONFIG_PNFS_BLOCK dependencies]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig              |    8 ++++++++
 fs/nfs/Makefile             |    1 +
 fs/nfs/blocklayout/Makefile |    5 +++++
 3 files changed, 14 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/blocklayout/Makefile

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index c96f9eb..d6bfd87 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -105,6 +105,14 @@ config PNFS_PANLAYOUT
 
 	  If unsure, say N.
 
+config PNFS_BLOCK
+	tristate "Provide a pNFS block client (EXPERIMENTAL)"
+	depends on NFS_FS && PNFS
+	help
+	  Say M or y here if you want your pNfs client to support the block protocol
+
+	  If unsure, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 6a34f7d..b58613d 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -23,3 +23,4 @@ obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
+obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
new file mode 100644
index 0000000..f214c1c
--- /dev/null
+++ b/fs/nfs/blocklayout/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the pNFS block layout driver kernel module
+#
+obj-$(CONFIG_PNFS_BLOCK) +=
+blocklayoutdriver-objs :=
-- 
1.7.4.1

