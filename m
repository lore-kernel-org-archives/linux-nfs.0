Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760553Ab0HEOSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 10:18:10 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFS: NFSv4.1 is no longer a "developer only" feature
Date: Thu,  5 Aug 2010 10:17:52 -0400
Message-Id: <1281017872-6043-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1281017872-6043-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1281017872-6043-1-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-2-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-3-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-4-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Mark it as 'experimental' instead, since in practice, NFSv4.1 should now be
relatively stable.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index d55f3f5..cc1bb33 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -75,13 +75,13 @@ config NFS_V4
 	  If unsure, say Y.
 
 config NFS_V4_1
-	bool "NFS client support for NFSv4.1 (DEVELOPER ONLY)"
+	bool "NFS client support for NFSv4.1 (EXPERIMENTAL)"
 	depends on NFS_V4 && EXPERIMENTAL
 	help
 	  This option enables support for minor version 1 of the NFSv4 protocol
 	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
 
-	  Unless you're an NFS developer, say N.
+	  If unsure, say N.
 
 config ROOT_NFS
 	bool "Root file system on NFS"
-- 
1.7.2

