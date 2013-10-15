Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47227 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759538Ab3JOTdW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Oct 2013 15:33:22 -0400
Date: Tue, 15 Oct 2013 12:33:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix Kconfig syntax
Message-ID: <20131015193322.GA31890@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The description text for CONFIG_NFSD_V4_SECURITY_LABEL has an unpaired
quote sign which breaks syntax highlighting for the nfsd Kconfig file.
Remove it.

Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index dc8f1ef..f994e75 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -95,7 +95,7 @@ config NFSD_V4_SECURITY_LABEL
 	Smack policies on NFSv4 files, say N.
 
 	WARNING: there is still a chance of backwards-incompatible protocol changes.
-	For now we recommend "Y" only for developers and testers."
+	For now we recommend "Y" only for developers and testers.
 
 config NFSD_FAULT_INJECTION
 	bool "NFS server manual fault injection"
