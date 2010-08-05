Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760574Ab0HEOSJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 10:18:09 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFS: NFS_V4 is no longer an EXPERIMENTAL feature
Date: Thu,  5 Aug 2010 10:17:51 -0400
Message-Id: <1281017872-6043-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1281017872-6043-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1281017872-6043-1-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-2-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-3-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index a43d07e..d55f3f5 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -61,8 +61,8 @@ config NFS_V3_ACL
 	  If unsure, say N.
 
 config NFS_V4
-	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFS_FS && EXPERIMENTAL
+	bool "NFS client support for NFS version 4"
+	depends on NFS_FS
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support for version 4 of the NFS protocol
@@ -72,7 +72,7 @@ config NFS_V4
 	  space programs which can be found in the Linux nfs-utils package,
 	  available from http://linux-nfs.org/.
 
-	  If unsure, say N.
+	  If unsure, say Y.
 
 config NFS_V4_1
 	bool "NFS client support for NFSv4.1 (DEVELOPER ONLY)"
-- 
1.7.2

