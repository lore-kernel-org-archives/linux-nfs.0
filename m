Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36773 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbdE3SOM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 14:14:12 -0400
Subject: [PATCH v1 01/17] ib_core: Enable and expose force_mr module
 parameter
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 30 May 2017 14:14:10 -0400
Message-ID: <20170530181410.2992.90842.stgit@klimt.1015granger.net>
In-Reply-To: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
References: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
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

