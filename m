Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:32810 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752382AbdFPPUc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jun 2017 11:20:32 -0400
Subject: [PATCH v2 01/19] ib_core: Enable and expose force_mr module
 parameter
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Jun 2017 11:20:29 -0400
Message-ID: <20170616152029.14210.50090.stgit@klimt.1015granger.net>
In-Reply-To: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fourth parameter of the module_param_named macro is a set of
file permissions. Passing 0 there means that module parameter is
not created and that adding "options ib_core force_mr=1" to a
modprobe.conf file has no effect.

The default setting of rdma_rw_force_mr continues to be 0, or false.

Fixes: a060b5629ab0 ("IB/core: generic RDMA READ/WRITE API")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 drivers/infiniband/core/rw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/rw.c b/drivers/infiniband/core/rw.c
index dbfd854..1cc8f07 100644
--- a/drivers/infiniband/core/rw.c
+++ b/drivers/infiniband/core/rw.c
@@ -23,7 +23,7 @@ enum {
 };
 
 static bool rdma_rw_force_mr;
-module_param_named(force_mr, rdma_rw_force_mr, bool, 0);
+module_param_named(force_mr, rdma_rw_force_mr, bool, 0644);
 MODULE_PARM_DESC(force_mr, "Force usage of MRs for RDMA READ/WRITE operations");
 
 /*

