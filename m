From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 02/67] nfs41: Add Kconfig symbols for NFSv4.1
Date: Thu,  2 Apr 2009 16:50:37 +0300
Message-ID: <1238680237-13462-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30322 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752784AbZDBNu4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:50:56 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
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
index e67f3ec..5d6d6f4 100644
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
1.6.2.1

