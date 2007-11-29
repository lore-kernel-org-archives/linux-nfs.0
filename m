From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 8/8] rdma: Kconfig
Date: Thu, 29 Nov 2007 16:45:15 -0600
Message-ID: <20071129224515.14887.46052.stgit@dell3.ogc.int>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48887 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934147AbXK2XDk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:40 -0500
In-Reply-To: <20071129224412.14887.14136.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add NFS_RDMA as an option to the Kconfig file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/Kconfig |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 429a002..13d00b9 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1693,6 +1693,13 @@ config NFSD
 	  To compile the NFS server support as a module, choose M here: the
 	  module will be called nfsd.  If unsure, say N.
 
+config NFSD_RDMA
+	tristate "Provide NFS server over RDMA support (EXPERIMENTAL)"
+	depends on SUNRPC && NFSD && INFINIBAND && EXPERIMENTAL
+	help
+	  If you want your NFS server to support RDMA connections, 
+	  say M or Y here. If unsure, say N.
+
 config NFSD_V2_ACL
 	bool
 	depends on NFSD
