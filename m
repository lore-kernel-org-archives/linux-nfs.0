From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 05/85] nfs41: Add Kconfig symbols for NFSv4.1
Date: Mon, 10 Nov 2008 22:18:40 +0200
Message-ID: <1226348320-7168-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60695 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbYKJUSq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:18:46 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Added CONFIG_NFS_V4_1 and made it depend upon CONFIG_NFS_V4 and EXPERIMENTAL.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 522469a..9363634 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1216,6 +1216,15 @@ config NFS_V4
 
 	  If unsure, say N.
 
+config NFS_V4_1
+	bool "NFS client support for NFSv4.1 (EXPERIMENTAL)"
+	depends on NFS_V4 && EXPERIMENTAL
+	help
+	  This option enables support for minor version 1 of the NFSv4 protocol
+	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
+
+	  If unsure, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
-- 
1.6.0.2

