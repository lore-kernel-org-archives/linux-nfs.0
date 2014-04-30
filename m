Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:54371 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945938AbaD3Tb5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 15:31:57 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V3 17/17] xprtrdma: Remove Tavor MTU setting
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 30 Apr 2014 15:31:55 -0400
Message-ID: <20140430193155.5663.86148.stgit@manet.1015granger.net>
In-Reply-To: <20140430191433.5663.16217.stgit@manet.1015granger.net>
References: <20140430191433.5663.16217.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  Remove HCA-specific clutter in xprtrdma, which is
supposed to be device-independent.

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

