From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 02/46] nfs41: Add Kconfig symbols for NFSv4.1
Date: Wed,  4 Mar 2009 01:51:54 +0200
Message-ID: <1236124314-3038-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17319
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754781AbZCCXwF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:52:05 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Added CONFIG_NFS_V4_1 and made it depend upon CONFIG_NFS_V4 and EXPERIMENTAL.
Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment

At the moment we're expecting folks trying out nfs41 to
actively participate in the development process by helping us
debug issues and ideally send patches to fix problems.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 36fe20d..055a0aa 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -74,6 +74,15 @@ config NFS_V4
 
 	  If unsure, say N.
 
+config NFS_V4_1
+	bool "NFS client support for NFSv4.1 (DEVELOPER ONLY)"
+	depends on NFS_V4 && EXPERIMENTAL
+	help
+	  This option enables support for minor version 1 of the NFSv4 protocol
+	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
+
+	  Unless you're an NFS developer, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
-- 
1.6.1.3

