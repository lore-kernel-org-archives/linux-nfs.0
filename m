Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12555 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965399Ab2JCR6u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 13:58:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Remove the dependency on CONFIG_EXPERIMENTAL
Date: Wed,  3 Oct 2012 10:58:49 -0700
Message-Id: <1349287129-51620-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CONFIG_EXPERIMENTAL is deprecated and, regardless of that, this code
is being enabled in most newer distributions.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index db7ad719..13ca196 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -95,8 +95,8 @@ config NFS_SWAP
 	  This option enables swapon to work on files located on NFS mounts.
 
 config NFS_V4_1
-	bool "NFS client support for NFSv4.1 (EXPERIMENTAL)"
-	depends on NFS_V4 && EXPERIMENTAL
+	bool "NFS client support for NFSv4.1"
+	depends on NFS_V4
 	select SUNRPC_BACKCHANNEL
 	help
 	  This option enables support for minor version 1 of the NFSv4 protocol
-- 
1.7.11.4

