From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 01/35] pnfsd: Define CONFIG_PNFSD
Date: Mon,  7 Dec 2009 11:29:57 +0200
Message-ID: <1260178197-14673-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60331 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759170AbZLGJ3B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:29:01 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
[rephrased text and moved down to fs/nfsd/Kconfig]
[remove CONFIG_PNFSD's dependency on NFSD_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/Kconfig |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 503b9da..05f72e4 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -79,3 +79,13 @@ config NFSD_V4
 	  available from http://linux-nfs.org/.
 
 	  If unsure, say N.
+
+config PNFSD
+	bool "NFSv4.1 server support for Parallel NFS (pNFS) (DEVELOPER ONLY)"
+	depends on NFSD_V4 && EXPERIMENTAL
+	help
+	  This option enables support for the parallel NFS features of the
+	  minor version 1 of the NFSv4 protocol (draft-ietf-nfsv4-minorversion1)
+	  in the kernel's NFS server.
+
+	  Unless you're an NFS developer, say N.
-- 
1.6.5.1

