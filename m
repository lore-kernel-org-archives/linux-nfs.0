From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 20/21] SQUASHME: Revert "nfsd41: Add Kconfig symbols for NFSv4.1"
Date: Fri,  3 Apr 2009 01:38:59 +0300
Message-ID: <1238711939-22645-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:10090 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762726AbZDBWjF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:39:05 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 1023bd56e438717f458fc7ce1a0dfd8593a6f82e.
---
 fs/nfsd/Kconfig |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 1f2f893..503b9da 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -79,12 +79,3 @@ config NFSD_V4
 	  available from http://linux-nfs.org/.
 
 	  If unsure, say N.
-
-config NFSD_V4_1
-	bool "NFS server support for NFSv4.1 (DEVELOPER ONLY)"
-	depends on NFSD_V4 && EXPERIMENTAL
-	help
-	  This option enables support for minor version 1 of the NFSv4 protocol
-	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS server.
-
-	  Unless you're an NFS developer, say N.
-- 
1.6.2.1

