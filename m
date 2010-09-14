Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55556 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab0INFhQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Sep 2010 01:37:16 -0400
Message-ID: <4C8F09C7.20103@cn.fujitsu.com>
Date: Tue, 14 Sep 2010 13:36:07 +0800
From: fuliankun <fuliankun@cn.fujitsu.com>
To: linux-nfs@vger.kernel.org
CC: chuck.lever@oracle.com
Subject: [PATCH] xprtrdma: fix code style problem
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Fix code style problem.

Signed-off-by: Fu Liankun <fuliankun@cn.fujitsu.com>

---
 net/sunrpc/xprtrdma/verbs.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 5f4c7b3..b98fe97 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -861,18 +861,19 @@ retry:
 		goto out;
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
+	/* XXX Tavor device performs badly with 2K MTU! */
+	if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
+		struct pci_dev *pcid =
+			to_pci_dev(ia->ri_id->device->dma_device);
+		if (pcid->device == PCI_DEVICE_ID_MELLANOX_TAVOR &&
+		    (pcid->vendor == PCI_VENDOR_ID_MELLANOX ||
+		     pcid->vendor == PCI_VENDOR_ID_TOPSPIN)) {
+			struct ib_qp_attr attr = {
+				.path_mtu = IB_MTU_1024
+			};
+			rc = ib_modify_qp(ia->ri_id->qp, &attr, IB_QP_PATH_MTU);
+		}
 	}
-}
 
 	ep->rep_connected = 0;
 
-- 1.7.0.1 
