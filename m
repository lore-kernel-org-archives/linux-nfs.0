Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.gtisc.gatech.edu ([143.215.130.81]:35479 "EHLO
	mx1.gtisc.gatech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbCYUkk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 16:40:40 -0400
From: Chengyu Song <csong84@gatech.edu>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: taesoo@gatech.edu, changwoo@gatech.edu, sanidhya@gatech.edu,
        blee@gatech.edu, csong84@gatech.edu
Subject: [PATCH 1/1] nfsd: NFSD_FAULT_INJECTION depends on DEBUG_FS
Date: Wed, 25 Mar 2015 16:37:07 -0400
Message-Id: <1427315827-6323-1-git-send-email-csong84@gatech.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSD_FAULT_INJECTION depends on DEBUG_FS, otherwise the debugfs_create_*
interface may return unexpected error -ENODEV, and cause system crash.

Signed-off-by: Chengyu Song <csong84@gatech.edu>
---
 fs/nfsd/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 683bf71..8b87b7a 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -107,7 +107,7 @@ config NFSD_V4_SECURITY_LABEL
 
 config NFSD_FAULT_INJECTION
 	bool "NFS server manual fault injection"
-	depends on NFSD_V4 && DEBUG_KERNEL
+	depends on NFSD_V4 && DEBUG_KERNEL && DEBUG_FS
 	help
 	  This option enables support for manually injecting faults
 	  into the NFS server.  This is intended to be used for
-- 
2.1.0

