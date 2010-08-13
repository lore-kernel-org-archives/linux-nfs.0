Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab0HMVcH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:07 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/50] pnfs_submit: pnfs and nfslayoutdriver kconfig
Date: Fri, 13 Aug 2010 17:31:17 -0400
Message-Id: <1281735122-1496-6-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-5-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index a43d07e..7b914fe 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -79,7 +79,17 @@ config NFS_V4_1
 	depends on NFS_V4 && EXPERIMENTAL
 	help
 	  This option enables support for minor version 1 of the NFSv4 protocol
-	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
+	  (RFC5661) including support for the parallel NFS (pNFS) features
+	  in the kernel's NFS client.
+
+	  Unless you're an NFS developer, say N.
+
+config PNFS_FILE_LAYOUT
+	tristate "NFS client support for the pNFS nfs-files layout (DEVELOPER ONLY)"
+	depends on NFS_FS && NFS_V4_1
+	default y
+	help
+	  This option enables support for the pNFS nfs-files layout.
 
 	  Unless you're an NFS developer, say N.
 
-- 
1.6.2.5

