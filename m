From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 05/51] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Mon, 10 Nov 2008 22:42:18 +0200
Message-ID: <1226349738-10279-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57184 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbYKJUmb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:42:31 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Added CONFIG_NFSD_V4_1 and made it depend upon NFSD_V4 and EXPERIMENTAL

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 9363634..aee944e 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1317,6 +1317,15 @@ config NFSD_V4
 
 	  If unsure, say N.
 
+config NFSD_V4_1
+	bool "NFS server support for NFSv4.1 (EXPERIMENTAL)"
+	depends on NFSD_V4 && EXPERIMENTAL
+	help
+	  This option enables support for minor version 1 of the NFSv4 protocol
+	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS server.
+
+	  If unsure, say N.
+
 config LOCKD
 	tristate
 
-- 
1.6.0.2

