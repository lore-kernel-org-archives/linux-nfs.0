Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f73.google.com ([209.85.214.73]:60231 "EHLO
        mail-it0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751278AbeEDD31 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 May 2018 23:29:27 -0400
Received: by mail-it0-f73.google.com with SMTP id o143-v6so1276555itg.9
        for <linux-nfs@vger.kernel.org>; Thu, 03 May 2018 20:29:27 -0700 (PDT)
MIME-Version: 1.0
Date: Thu,  3 May 2018 20:29:19 -0700
Message-Id: <20180504032919.90515-1-gthelen@google.com>
Subject: [PATCH] IB: remove redundant INFINIBAND kconfig dependencies
From: Greg Thelen <gthelen@google.com>
To: Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

INFINIBAND_ADDR_TRANS depends on INFINIBAND.  So there's no need for
options which depend INFINIBAND_ADDR_TRANS to also depend on INFINIBAND.
Remove the unnecessary INFINIBAND depends.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 drivers/infiniband/ulp/srpt/Kconfig | 2 +-
 drivers/nvme/host/Kconfig           | 2 +-
 drivers/nvme/target/Kconfig         | 2 +-
 drivers/staging/lustre/lnet/Kconfig | 2 +-
 fs/cifs/Kconfig                     | 2 +-
 net/9p/Kconfig                      | 2 +-
 net/rds/Kconfig                     | 2 +-
 net/sunrpc/Kconfig                  | 2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/ulp/srpt/Kconfig b/drivers/infiniband/ulp/srpt/Kconfig
index fb8b7182f05e..25bf6955b6d0 100644
--- a/drivers/infiniband/ulp/srpt/Kconfig
+++ b/drivers/infiniband/ulp/srpt/Kconfig
@@ -1,6 +1,6 @@
 config INFINIBAND_SRPT
 	tristate "InfiniBand SCSI RDMA Protocol target support"
-	depends on INFINIBAND && INFINIBAND_ADDR_TRANS && TARGET_CORE
+	depends on INFINIBAND_ADDR_TRANS && TARGET_CORE
 	---help---
 
 	  Support for the SCSI RDMA Protocol (SRP) Target driver. The
diff --git a/drivers/nvme/host/Kconfig b/drivers/nvme/host/Kconfig
index 88a8b5916624..dbb7464c018c 100644
--- a/drivers/nvme/host/Kconfig
+++ b/drivers/nvme/host/Kconfig
@@ -27,7 +27,7 @@ config NVME_FABRICS
 
 config NVME_RDMA
 	tristate "NVM Express over Fabrics RDMA host driver"
-	depends on INFINIBAND && INFINIBAND_ADDR_TRANS && BLOCK
+	depends on INFINIBAND_ADDR_TRANS && BLOCK
 	select NVME_CORE
 	select NVME_FABRICS
 	select SG_POOL
diff --git a/drivers/nvme/target/Kconfig b/drivers/nvme/target/Kconfig
index 3c7b61ddb0d1..7595664ee753 100644
--- a/drivers/nvme/target/Kconfig
+++ b/drivers/nvme/target/Kconfig
@@ -27,7 +27,7 @@ config NVME_TARGET_LOOP
 
 config NVME_TARGET_RDMA
 	tristate "NVMe over Fabrics RDMA target support"
-	depends on INFINIBAND && INFINIBAND_ADDR_TRANS
+	depends on INFINIBAND_ADDR_TRANS
 	depends on NVME_TARGET
 	select SGL_ALLOC
 	help
diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index ad049e6f24e4..f3b1ad4bd3dc 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -34,7 +34,7 @@ config LNET_SELFTEST
 
 config LNET_XPRT_IB
 	tristate "LNET infiniband support"
-	depends on LNET && PCI && INFINIBAND && INFINIBAND_ADDR_TRANS
+	depends on LNET && PCI && INFINIBAND_ADDR_TRANS
 	default LNET && INFINIBAND
 	help
 	  This option allows the LNET users to use infiniband as an
diff --git a/fs/cifs/Kconfig b/fs/cifs/Kconfig
index 5f132d59dfc2..d61e2de8d0eb 100644
--- a/fs/cifs/Kconfig
+++ b/fs/cifs/Kconfig
@@ -197,7 +197,7 @@ config CIFS_SMB311
 
 config CIFS_SMB_DIRECT
 	bool "SMB Direct support (Experimental)"
-	depends on CIFS=m && INFINIBAND && INFINIBAND_ADDR_TRANS || CIFS=y && INFINIBAND=y && INFINIBAND_ADDR_TRANS=y
+	depends on CIFS=m && INFINIBAND_ADDR_TRANS || CIFS=y && INFINIBAND_ADDR_TRANS=y
 	help
 	  Enables SMB Direct experimental support for SMB 3.0, 3.02 and 3.1.1.
 	  SMB Direct allows transferring SMB packets over RDMA. If unsure,
diff --git a/net/9p/Kconfig b/net/9p/Kconfig
index e6014e0e51f7..46c39f7da444 100644
--- a/net/9p/Kconfig
+++ b/net/9p/Kconfig
@@ -32,7 +32,7 @@ config NET_9P_XEN
 
 
 config NET_9P_RDMA
-	depends on INET && INFINIBAND && INFINIBAND_ADDR_TRANS
+	depends on INET && INFINIBAND_ADDR_TRANS
 	tristate "9P RDMA Transport (Experimental)"
 	help
 	  This builds support for an RDMA transport.
diff --git a/net/rds/Kconfig b/net/rds/Kconfig
index bffde4b46c5d..1a31502ee7db 100644
--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -8,7 +8,7 @@ config RDS
 
 config RDS_RDMA
 	tristate "RDS over Infiniband"
-	depends on RDS && INFINIBAND && INFINIBAND_ADDR_TRANS
+	depends on RDS && INFINIBAND_ADDR_TRANS
 	---help---
 	  Allow RDS to use Infiniband as a transport.
 	  This transport supports RDMA operations.
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index ac09ca803296..6358e5271070 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -50,7 +50,7 @@ config SUNRPC_DEBUG
 
 config SUNRPC_XPRT_RDMA
 	tristate "RPC-over-RDMA transport"
-	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
+	depends on SUNRPC && INFINIBAND_ADDR_TRANS
 	default SUNRPC && INFINIBAND
 	select SG_POOL
 	help
-- 
2.17.0.441.gb46fe60e1d-goog

