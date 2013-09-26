Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:57682 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab3IZSj6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:39:58 -0400
Received: by mail-qc0-f181.google.com with SMTP id q4so1043276qcx.12
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:39:57 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 01/49] pnfsd: Define CONFIG_PNFSD
Date: Thu, 26 Sep 2013 14:39:52 -0400
Message-Id: <1380220792-12718-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
[rephrased text and moved down to fs/nfsd/Kconfig]
[remove CONFIG_PNFSD's dependency on NFSD_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[rephrase and remove CONFIG_PNFSD's dependency on EXPERIMENTAL]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/Kconfig | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index dc8f1ef..4d68a8c 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -106,3 +106,13 @@ config NFSD_FAULT_INJECTION
 	  testing error recovery on the NFS client.
 
 	  If unsure, say N.
+
+config PNFSD
+	bool "NFSv4.1 server support for Parallel NFS (pNFS) (EXPERIMENTAL)"
+	depends on NFSD_V4
+	help
+	  This option enables support for the parallel NFS features of the
+	  minor version 1 of the NFSv4 protocol (RFC5661)
+	  in the kernel's NFS server.
+
+	  If unsure, say N.
-- 
1.8.3.1

