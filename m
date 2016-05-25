Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36290 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcEYFJt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 01:09:49 -0400
Received: by mail-pf0-f173.google.com with SMTP id f144so1161901pfa.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 May 2016 22:09:49 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH 4/4] nfsd: Provide a config option for flex file layouts
Date: Tue, 24 May 2016 22:09:39 -0700
Message-Id: <1464152979-103988-5-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfsd/Kconfig | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index c9f583d..76edffb 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -111,6 +111,19 @@ config NFSD_SCSILAYOUT
 
 	  If unsure, say N.
 
+config NFSD_FLEXFILELAYOUT
+	bool "NFSv4.1 server support for pNFS Flex File layouts"
+	depends on NFSD_V4
+	select NFSD_PNFS
+	help
+	  This option enables support for the exporting pNFS Flex File
+	  layouts in the kernel's NFS server. The pNFS Flex File  layout
+	  enables NFS clients to directly perform I/O to NFSv3 devices
+	  accesible to both the server and the clients.  See
+	  draft-ietf-nfsv4-flex-files for more details.
+
+	  If unsure, say N.
+
 config NFSD_V4_SECURITY_LABEL
 	bool "Provide Security Label support for NFSv4 server"
 	depends on NFSD_V4 && SECURITY
-- 
1.8.3.1

