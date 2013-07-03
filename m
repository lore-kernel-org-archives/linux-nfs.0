Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755922Ab3GCNEj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jul 2013 09:04:39 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Disable NFS version 2
Date: Wed,  3 Jul 2013 09:04:35 -0400
Message-Id: <1372856675-5520-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch disables the NFS version 2 module from being compile by default.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 13ca196..6831a01 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -32,12 +32,12 @@ config NFS_FS
 config NFS_V2
 	tristate "NFS client support for NFS version 2"
 	depends on NFS_FS
-	default y
+	default n
 	help
 	  This option enables support for version 2 of the NFS protocol
 	  (RFC 1094) in the kernel's NFS client.
 
-	  If unsure, say Y.
+	  If unsure, say n.
 
 config NFS_V3
 	tristate "NFS client support for NFS version 3"
-- 
1.8.1.4

