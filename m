Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:46362 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbaEVA4o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 20:56:44 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v4 17/24] xprtrdma: Remove Tavor MTU setting
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Wed, 21 May 2014 20:56:42 -0400
Message-ID: <20140522005642.27190.68081.stgit@manet.1015granger.net>
In-Reply-To: <20140522004505.27190.58897.stgit@manet.1015granger.net>
References: <20140522004505.27190.58897.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  Remove HCA-specific clutter in xprtrdma, which is
supposed to be device-independent.

Hal Rosenstock <hal@dev.mellanox.co.il> observes:
> Note that there is OpenSM option (enable_quirks) to return 1K MTU
> in SA PathRecord responses for Tavor so that can be used for this.
> The default setting for enable_quirks is FALSE so that would need
> changing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/verbs.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 54edf2a..515dfc1 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -48,7 +48,6 @@
  */
 
 #include <linux/interrupt.h>
-#include <linux/pci.h>	/* for Tavor hack below */
 #include <linux/slab.h>
 #include <asm/bitops.h>
 
@@ -920,19 +919,6 @@ retry:
 		}
 	}
 
-/* XXX Tavor device performs badly with 2K MTU! */
-if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
-	struct pci_dev *pcid = to_pci_dev(ia->ri_id->device->dma_device);
-	if (pcid->device == PCI_DEVICE_ID_MELLANOX_TAVOR &&
-	    (pcid->vendor == PCI_VENDOR_ID_MELLANOX ||
-	     pcid->vendor == PCI_VENDOR_ID_TOPSPIN)) {
-		struct ib_qp_attr attr = {
-			.path_mtu = IB_MTU_1024
-		};
-		rc = ib_modify_qp(ia->ri_id->qp, &attr, IB_QP_PATH_MTU);
-	}
-}
-
 	ep->rep_connected = 0;
 
 	rc = rdma_connect(ia->ri_id, &ep->rep_remote_cma);

