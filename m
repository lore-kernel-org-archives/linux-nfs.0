Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:33198 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbdAaTaL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 14:30:11 -0500
In-Reply-To: <20170131191704.GA8281@n2100.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
From: Russell King <rmk+kernel@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH 4.10-rc3 01/13] net: sunrpc: fix build errors when
 linux/phy*.h is removed from net/dsa.h
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Message-Id: <E1cYdwi-0000Vs-97@rmk-PC.armlinux.org.uk>
Date: Tue, 31 Jan 2017 19:18:28 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Removing linux/phy.h from net/dsa.h reveals a build error in the sunrpc
code:

net/sunrpc/xprtrdma/svc_rdma_backchannel.c: In function 'xprt_rdma_bc_put':
net/sunrpc/xprtrdma/svc_rdma_backchannel.c:277:2: error: implicit declaration of function 'module_put' [-Werror=implicit-function-declaration]
net/sunrpc/xprtrdma/svc_rdma_backchannel.c: In function 'xprt_setup_rdma_bc':
net/sunrpc/xprtrdma/svc_rdma_backchannel.c:348:7: error: implicit declaration of function 'try_module_get' [-Werror=implicit-function-declaration]

Fix this by adding linux/module.h to svc_rdma_backchannel.c

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 288e35c2d8f4..cb1e48e54eb1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -4,6 +4,7 @@
  * Support for backward direction RPCs on RPC/RDMA (server-side).
  */
 
+#include <linux/module.h>
 #include <linux/sunrpc/svc_rdma.h>
 #include "xprt_rdma.h"
 
-- 
2.7.4

