Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:48081 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381Ab1FNCcT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:19 -0400
Message-Id: <f923ec713a320635f3cf2a38472a810658185313.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 07/33] pnfsblock: define PNFS_BLOCK Kconfig option
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:17 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Define a configuration variable to enable/disable compilation of the
block driver code.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs-block: fix CONFIG_PNFS_BLOCK dependencies]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig              |   10 ++++++++++
 fs/nfs/Makefile             |    1 +
 fs/nfs/blocklayout/Makefile |    5 +++++
 3 files changed, 16 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/blocklayout/Makefile

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 8151554..b613820 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -97,6 +97,16 @@ config PNFS_OBJLAYOUT
 
 	  If unsure, say N.
 
+config PNFS_BLOCK
+	tristate "Provide a pNFS block client (EXPERIMENTAL)"
+	depends on NFS_FS && NFS_V4_1
+	select MD
+	select BLK_DEV_DM
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

