From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfs: note that CONFIG_SUNRPC_XPRT_RDMA turns on server
	side support too
Date: Sat, 10 Jan 2009 13:48:19 -0500
Message-ID: <20090110184819.GA30459@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:36617 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbZAJSsU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Jan 2009 13:48:20 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1LLisd-0007zh-El
	for linux-nfs@vger.kernel.org; Sat, 10 Jan 2009 13:48:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We forgot to update this when adding server-side support.
    
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

---

I'm queuing this up for 2.6.29 (or 2.6.30 depending on timing).

--b.

diff --git a/fs/Kconfig b/fs/Kconfig
index 51307b0..3ce84a4 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1392,9 +1392,8 @@ config SUNRPC_XPRT_RDMA
 	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
 	default SUNRPC && INFINIBAND
 	help
-	  This option enables an RPC client transport capability that
-	  allows the NFS client to mount servers via an RDMA-enabled
-	  transport.
+	  This option allows the NFS client and server to support
+	  an RDMA-enabled transport.
 
 	  To compile RPC client RDMA transport support as a module,
 	  choose M here: the module will be called xprtrdma.
