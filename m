Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62131 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755526Ab2EJUr0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 16:47:26 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 3/3] NFS: Turn v3 on by default
Date: Thu, 10 May 2012 16:47:20 -0400
Message-Id: <1336682840-10799-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336682840-10799-1-git-send-email-bjschuma@netapp.com>
References: <1336682840-10799-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Most users will use NFS v3 or possibly v4 so this makes it easier for
them.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 66b0f4c..f90f4f5 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -42,6 +42,7 @@ config NFS_V2
 config NFS_V3
 	bool "NFS client support for NFS version 3"
 	depends on NFS_FS
+	default y
 	help
 	  This option enables support for version 3 of the NFS protocol
 	  (RFC 1813) in the kernel's NFS client.
-- 
1.7.10.1

