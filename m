From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/11] NFSD: Remove NFSv4 dependency on NFSv3
Date: Fri, 08 Feb 2008 12:52:08 -0500
Message-ID: <20080208175208.16261.74626.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:8713 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759380AbYBHRwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:52:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Because NFSD_V4 "depends on" NFSD_V3, it appears as a child of
the NFSD_V3 menu entry, and is not visible if NFSD_V3 is unselected.

Replace the dependency on NFSD_V3 with a "select NFSD_V3".  This makes
NFSD_V4 look and work just like NFS_V3, while ensuring that NFSD_V3 is
enabled if NFSD_V4 is.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 9ad62a9..4c16789 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1723,7 +1723,8 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && EXPERIMENTAL
+	depends on NFSD && EXPERIMENTAL
+	select NFSD_V3
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for

