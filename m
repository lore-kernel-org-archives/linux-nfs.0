From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Fri, 27 Mar 2009 06:06:49 +0300
Message-ID: <1238123209-7128-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24519 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754595AbZC0DGy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:06:54 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added CONFIG_NFSD_V4_1 and made it depend upon NFSD_V4 and EXPERIMENTAL
Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment

At the moment we're expecting folks trying out nfs41 to
actively participate in the development process by helping us
debug issues and ideally send patches to fix problems.

[trailing space fixed]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 503b9da..1f2f893 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -79,3 +79,12 @@ config NFSD_V4
 	  available from http://linux-nfs.org/.
 
 	  If unsure, say N.
+
+config NFSD_V4_1
+	bool "NFS server support for NFSv4.1 (DEVELOPER ONLY)"
+	depends on NFSD_V4 && EXPERIMENTAL
+	help
+	  This option enables support for minor version 1 of the NFSv4 protocol
+	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS server.
+
+	  Unless you're an NFS developer, say N.
-- 
1.6.2.1

